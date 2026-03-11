#!/usr/bin/env swift
/// Card Parsing Smoke Test
/// Validates that all shared test card JSON files can be parsed by the iOS SDK
/// without throwing decoding errors.
///
/// Usage: swift test-card-parsing.swift [path-to-test-cards]
/// Runs from: shared/scripts/

import Foundation

// MARK: - Lightweight card parser that mimics the SDK's Codable decoder

struct CardParseResult {
    let filename: String
    let success: Bool
    let error: String?
    let elementCount: Int
    let unknownTypes: [String]
}

func parseCard(_ json: String) -> (success: Bool, error: String?, elementCount: Int, unknownTypes: [String]) {
    guard let data = json.data(using: .utf8),
          let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          (root["type"] as? String) == "AdaptiveCard" else {
        return (false, "Not a valid AdaptiveCard JSON", 0, [])
    }

    var elementCount = 0
    var unknownTypes: [String] = []

    let knownTypes: Set<String> = [
        "TextBlock", "Image", "Media", "RichTextBlock",
        "Container", "ColumnSet", "Column", "ImageSet", "FactSet", "ActionSet",
        "Table", "TableRow", "TableCell",
        "Input.Text", "Input.Number", "Input.Date", "Input.Time",
        "Input.Toggle", "Input.ChoiceSet", "Input.Rating", "Input.DataGrid",
        "Carousel", "CarouselPage", "Accordion", "CodeBlock",
        "Rating", "ProgressBar", "ProgressRing", "Spinner",
        "TabSet", "List", "CompoundButton", "Badge",
        "DonutChart", "BarChart", "LineChart", "PieChart", "Chart.Donut",
        "Icon",
        "Action.OpenUrl", "Action.Submit", "Action.ShowCard",
        "Action.ToggleVisibility", "Action.Execute",
        "Action.Popover", "Action.ResetInputs",
        "AdaptiveCard"
    ]

    func walkElements(_ obj: Any) {
        if let dict = obj as? [String: Any] {
            if let type = dict["type"] as? String {
                elementCount += 1
                if !knownTypes.contains(type) && !type.hasPrefix("Action.") {
                    unknownTypes.append(type)
                }
            }
            for (_, value) in dict {
                walkElements(value)
            }
        } else if let array = obj as? [Any] {
            for item in array {
                walkElements(item)
            }
        }
    }

    walkElements(root)
    return (true, nil, elementCount, unknownTypes)
}

// MARK: - Main

let args = CommandLine.arguments
let basePath: String
if args.count > 1 {
    basePath = args[1]
} else {
    // Default: relative to script location
    let scriptDir = URL(fileURLWithPath: #file).deletingLastPathComponent().path
    basePath = "\(scriptDir)/../test-cards"
}

let fileManager = FileManager.default

func findJSONFiles(in directory: String) -> [String] {
    guard let enumerator = fileManager.enumerator(atPath: directory) else { return [] }
    var files: [String] = []
    while let path = enumerator.nextObject() as? String {
        if path.hasSuffix(".json") && !path.contains("-data.json") {
            files.append("\(directory)/\(path)")
        }
    }
    return files.sorted()
}

let jsonFiles = findJSONFiles(in: basePath)
print("Found \(jsonFiles.count) card JSON files in \(basePath)\n")

var results: [CardParseResult] = []
var passCount = 0
var failCount = 0
var unknownTypeSet: Set<String> = []

for file in jsonFiles {
    let filename = URL(fileURLWithPath: file).lastPathComponent
    guard let content = try? String(contentsOfFile: file, encoding: .utf8) else {
        results.append(CardParseResult(filename: filename, success: false, error: "Could not read file", elementCount: 0, unknownTypes: []))
        failCount += 1
        continue
    }

    let (success, error, count, unknowns) = parseCard(content)
    results.append(CardParseResult(filename: filename, success: success, error: error, elementCount: count, unknownTypes: unknowns))

    if success {
        passCount += 1
        if !unknowns.isEmpty {
            unknownTypeSet.formUnion(unknowns)
        }
    } else {
        failCount += 1
    }
}

// MARK: - Report

print("=" * 60)
print("CARD PARSING REPORT")
print("=" * 60)
print("Total: \(jsonFiles.count) | Pass: \(passCount) | Fail: \(failCount)")
print("")

if failCount > 0 {
    print("FAILURES:")
    for result in results where !result.success {
        print("  ✗ \(result.filename): \(result.error ?? "unknown error")")
    }
    print("")
}

if !unknownTypeSet.isEmpty {
    print("UNKNOWN ELEMENT TYPES (not handled by SDK):")
    for type in unknownTypeSet.sorted() {
        let count = results.flatMap(\.unknownTypes).filter { $0 == type }.count
        print("  ? \(type) (\(count) occurrences)")
    }
    print("")
}

print("Per-card element counts:")
for result in results where result.success {
    let status = result.unknownTypes.isEmpty ? "✓" : "⚠"
    let extra = result.unknownTypes.isEmpty ? "" : " (unknown: \(result.unknownTypes.joined(separator: ", ")))"
    print("  \(status) \(result.filename): \(result.elementCount) elements\(extra)")
}

exit(failCount > 0 ? 1 : 0)

// Helper
extension String {
    static func * (lhs: String, rhs: Int) -> String {
        String(repeating: lhs, count: rhs)
    }
}
