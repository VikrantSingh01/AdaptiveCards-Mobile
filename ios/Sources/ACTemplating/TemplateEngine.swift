// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import Foundation

/// Template engine for expanding Adaptive Card templates with data binding
public final class TemplateEngine {
    private let parser = ExpressionParser()

    public init() {}

    // MARK: - String Resources

    /// Resolve `${rs:key}` string resource references in a raw JSON string.
    /// Must be called **before** template expansion or JSON parsing.
    ///
    /// - Parameters:
    ///   - json: Raw card JSON string (may contain `${rs:key}` references)
    ///   - locale: Preferred locale for localized values (e.g. "en-US"). Falls back to `defaultValue`.
    /// - Returns: JSON string with all valid `${rs:key}` patterns replaced
    public func resolveStringResources(_ json: String, locale: String? = nil) -> String {
        // Extract the "resources" object from the raw JSON
        guard let data = json.data(using: .utf8),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let resources = root["resources"] as? [String: Any],
              let strings = resources["strings"] as? [String: Any] else {
            return json
        }

        // Build a flat lookup: key -> resolved string
        var lookup: [String: String] = [:]
        for (key, value) in strings {
            guard let entry = value as? [String: Any] else { continue }
            let defaultValue = entry["defaultValue"] as? String ?? ""

            if let locale = locale,
               let localizedValues = entry["localizedValues"] as? [String: String] {
                // Case-insensitive locale match
                let resolved = localizedValues.first(where: {
                    $0.key.caseInsensitiveCompare(locale) == .orderedSame
                })?.value
                lookup[key] = resolved ?? defaultValue
            } else {
                lookup[key] = defaultValue
            }
        }

        guard !lookup.isEmpty else { return json }

        // Replace all ${rs:key} patterns (case-sensitive: only lowercase "rs:" is valid)
        var result = json
        for (key, value) in lookup {
            let escapedValue = value
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
            result = result.replacingOccurrences(of: "${rs:\(key)}", with: escapedValue)
        }

        return result
    }

    /// Expand a template string with data binding.
    /// If the template is valid JSON, uses structured expansion (parse → expand → serialize)
    /// to ensure the output remains valid JSON. Falls back to string-based expansion.
    /// - Parameters:
    ///   - template: Template string containing ${...} expressions
    ///   - data: Data object for binding
    /// - Returns: Expanded string
    /// - Throws: TemplatingError if expansion fails
    public func expand(template: String, data: [String: Any]) throws -> String {
        // Try structured JSON expansion first (produces valid JSON output)
        if let jsonData = template.data(using: .utf8),
           let jsonObject = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
            let context = DataContext(data: data)
            // Use do/catch so structured expansion failures fall through to string expansion
            do {
                let expanded = try expandDictionary(jsonObject, context: context)
                if let outputData = try? JSONSerialization.data(withJSONObject: expanded, options: [.sortedKeys]),
                   let outputString = String(data: outputData, encoding: .utf8) {
                    return outputString
                }
            } catch {
                // Structured expansion failed; fall through to string-based expansion
            }
        }
        // Fallback to string-based expansion for non-JSON templates
        let context = DataContext(data: data)
        return try expandString(template, context: context)
    }

    /// Expand a template JSON object with data binding
    /// - Parameters:
    ///   - template: Template JSON dictionary
    ///   - data: Data object for binding
    /// - Returns: Expanded JSON dictionary
    /// - Throws: TemplatingError if expansion fails
    public func expand(template: [String: Any], data: [String: Any]) throws -> [String: Any] {
        let context = DataContext(data: data)
        return try expandDictionary(template, context: context)
    }

    // MARK: - Private Methods

    private func expandString(_ string: String, context: DataContext) throws -> String {
        var result = string
        var searchIndex = result.startIndex

        while searchIndex < result.endIndex {
            // Find next ${
            guard let startRange = result.range(of: "${", range: searchIndex..<result.endIndex) else {
                break
            }

            // Find matching }
            var braceCount = 1
            var endIndex = result.index(after: startRange.upperBound)

            while endIndex < result.endIndex && braceCount > 0 {
                let char = result[endIndex]
                if char == "{" {
                    braceCount += 1
                } else if char == "}" {
                    braceCount -= 1
                }

                if braceCount > 0 {
                    endIndex = result.index(after: endIndex)
                }
            }

            guard braceCount == 0 else {
                // Unmatched brace — skip this pattern and continue
                searchIndex = result.index(after: startRange.lowerBound)
                continue
            }

            // Extract expression
            let expressionStart = startRange.upperBound
            let expression = String(result[expressionStart..<endIndex])

            // Evaluate expression — on failure, leave the ${...} unresolved and continue
            guard let parsedExpression = try? parser.parse(expression) else {
                searchIndex = result.index(after: endIndex)
                continue
            }
            let evaluator = ExpressionEvaluator(context: context)
            guard let value = try? evaluator.evaluate(parsedExpression) else {
                searchIndex = result.index(after: endIndex)
                continue
            }

            // Replace ${expression} with value
            let replacement = stringValue(value)
            let replacementRange = startRange.lowerBound..<result.index(after: endIndex)
            result.replaceSubrange(replacementRange, with: replacement)

            // Update search position
            searchIndex = result.index(startRange.lowerBound, offsetBy: replacement.count)
        }

        return result
    }

    private func expandDictionary(_ dict: [String: Any], context: DataContext) throws -> [String: Any] {
        var result: [String: Any] = [:]

        for (key, value) in dict {
            // Handle $when condition
            if key == "$when" {
                if let condition = value as? String {
                    let expressionStr = extractExpression(from: condition)
                    if let parsedExpression = try? parser.parse(expressionStr) {
                        let evaluator = ExpressionEvaluator(context: context)
                        if let conditionResult = try? evaluator.evaluate(parsedExpression) {
                            if !toBool(conditionResult) {
                                return [:]
                            }
                        }
                    }
                }
                continue // Don't include $when in output
            }

            // Expand value — gracefully handle per-field failures to avoid blank cards
            if let expanded = try? expandValue(value, context: context) {
                result[key] = expanded
            } else {
                result[key] = value
            }
        }

        return result
    }

    private func expandArray(_ array: [Any], context: DataContext) throws -> [Any] {
        var result: [Any] = []

        for item in array {
            if let dict = item as? [String: Any] {
                // Check for $data iteration — handle both String and non-String values
                if let dataBindingValue = dict["$data"] {
                    var itemTemplate = dict
                    itemTemplate.removeValue(forKey: "$data")

                    if let dataBinding = dataBindingValue as? String {
                        let expressionStr = extractExpression(from: dataBinding)
                        // Gracefully handle unparseable $data values (e.g. "{hello}")
                        guard let parsedExpression = try? parser.parse(expressionStr) else {
                            // Treat as literal string data context
                            let childContext = DataContext(data: dataBinding, root: context.root, index: nil, parent: context)
                            let expandedItem = try expandDictionary(itemTemplate, context: childContext)
                            if !expandedItem.isEmpty {
                                result.append(expandedItem)
                            }
                            continue
                        }
                        let evaluator = ExpressionEvaluator(context: context)
                        let dataValue = try evaluator.evaluate(parsedExpression)

                        if let dataArray = dataValue as? [Any] {
                            for (index, dataItem) in dataArray.enumerated() {
                                let childContext = context.createChild(data: dataItem, index: index)
                                let expandedItem = try expandDictionary(itemTemplate, context: childContext)
                                if !expandedItem.isEmpty {
                                    result.append(expandedItem)
                                }
                            }
                            continue
                        } else if dataValue != nil {
                            let childContext = DataContext(data: dataValue, root: context.root, index: nil, parent: context)
                            let expandedItem = try expandDictionary(itemTemplate, context: childContext)
                            if !expandedItem.isEmpty {
                                result.append(expandedItem)
                            }
                            continue
                        }
                    } else {
                        // Non-string $data (Int, Dict, Array, etc.) — use as literal data context
                        let childContext = DataContext(data: dataBindingValue, root: context.root, index: nil, parent: context)
                        let expandedItem = try expandDictionary(itemTemplate, context: childContext)
                        if !expandedItem.isEmpty {
                            result.append(expandedItem)
                        }
                        continue
                    }
                }

                // Regular dictionary expansion
                // Separate "expansion threw" from "$when filtered this item":
                // - expandDictionary returns [:] when $when is false → omit item
                // - expandDictionary throws → keep original as graceful fallback
                if let expandedDict = try? expandDictionary(dict, context: context) {
                    if !expandedDict.isEmpty {
                        result.append(expandedDict)
                    }
                    // else: item was filtered by $when — intentionally omit
                } else {
                    result.append(dict)
                }
            } else {
                if let expanded = try? expandValue(item, context: context) {
                    result.append(expanded)
                } else {
                    result.append(item)
                }
            }
        }

        return result
    }

    private func expandValue(_ value: Any, context: DataContext) throws -> Any {
        if let string = value as? String {
            // If the entire string is a single ${expr} with no surrounding content,
            // return the native evaluated value (preserving arrays, objects, numbers,
            // booleans) instead of stringifying.
            // IMPORTANT: Do NOT trim whitespace — "${open} " must go through string
            // expansion to produce "127.42 " (a string), not the native Double 127.42.
            // Trimming caused FactSet values and other string fields to become numbers,
            // which then failed Codable decoding and produced blank cards.
            if string.hasPrefix("${") && string.hasSuffix("}") {
                var braceCount = 0
                var firstCloseIndex = -1
                let chars = Array(string)
                for i in 2..<chars.count {
                    if chars[i] == "{" {
                        braceCount += 1
                    } else if chars[i] == "}" {
                        if braceCount == 0 {
                            firstCloseIndex = i
                            break
                        }
                        braceCount -= 1
                    }
                }
                if firstCloseIndex == chars.count - 1 {
                    // Pure expression — return native value
                    let expression = String(chars[2..<(chars.count - 1)])
                    if let parsed = try? parser.parse(expression) {
                        let evaluator = ExpressionEvaluator(context: context)
                        if let result = try? evaluator.evaluate(parsed) {
                            return result
                        }
                        // Evaluation failed; fall through to expandString
                    }
                }
            }
            return try expandString(string, context: context)
        } else if let dict = value as? [String: Any] {
            return try expandDictionary(dict, context: context)
        } else if let array = value as? [Any] {
            return try expandArray(array, context: context)
        } else {
            return value
        }
    }

    // MARK: - Helpers

    /// Extracts a raw expression from a template string.
    /// If the string is of the form "${expr}", returns "expr".
    /// Otherwise returns the string as-is (assumed to be a raw expression).
    private func extractExpression(from template: String) -> String {
        let trimmed = template.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("${") && trimmed.hasSuffix("}") {
            let start = trimmed.index(trimmed.startIndex, offsetBy: 2)
            let end = trimmed.index(before: trimmed.endIndex)
            return String(trimmed[start..<end])
        }
        return trimmed
    }

    private func stringValue(_ value: Any?) -> String {
        if let str = value as? String {
            return str
        } else if let num = value as? Double {
            // Format numbers without unnecessary decimal places
            return num.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(num)) : String(num)
        } else if let num = value as? Int {
            return String(num)
        } else if let bool = value as? Bool {
            return bool ? "true" : "false"
        } else if value == nil {
            return ""
        } else if let dict = value as? [String: Any] {
            // Serialize dictionaries as valid JSON
            if let data = try? JSONSerialization.data(withJSONObject: dict),
               let json = String(data: data, encoding: .utf8) {
                return json
            }
            return "{}"
        } else if let array = value as? [Any] {
            // Serialize arrays as valid JSON
            if let data = try? JSONSerialization.data(withJSONObject: array),
               let json = String(data: data, encoding: .utf8) {
                return json
            }
            return "[]"
        } else {
            return String(describing: value as Any)
        }
    }

    private func toBool(_ value: Any?) -> Bool {
        if let bool = value as? Bool {
            return bool
        } else if let num = value as? Double {
            return num != 0
        } else if let num = value as? Int {
            return num != 0
        } else if let str = value as? String {
            return !str.isEmpty
        } else if value == nil {
            return false
        } else if let array = value as? [Any] {
            return !array.isEmpty
        } else if let dict = value as? [String: Any] {
            return !dict.isEmpty
        }
        return true
    }
}

// MARK: - Errors

public enum TemplatingError: Error, LocalizedError {
    case unmatchedBrace
    case invalidExpression(String)
    case evaluationFailed(String)

    public var errorDescription: String? {
        switch self {
        case .unmatchedBrace:
            return "Unmatched brace in template expression"
        case .invalidExpression(let message):
            return "Invalid expression: \(message)"
        case .evaluationFailed(let message):
            return "Expression evaluation failed: \(message)"
        }
    }
}
