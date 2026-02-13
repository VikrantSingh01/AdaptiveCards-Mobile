import Foundation

/// Represents a parsed markdown token
public enum MarkdownToken {
    case text(String)
    case bold(String)
    case italic(String)
    case code(String)
    case link(text: String, url: String)
    case header(level: Int, text: String)
    case bulletItem(String)
    case numberedItem(number: Int, text: String)
    case lineBreak
}

/// Parses a subset of markdown syntax into structured tokens
public class MarkdownParser {

    private static let cache = NSCache<NSString, NSArray>()

    /// Parse markdown text into tokens
    /// - Parameter text: The markdown text to parse
    /// - Returns: Array of parsed tokens
    public static func parse(_ text: String) -> [MarkdownToken] {
        // Check cache first
        let cacheKey = text as NSString
        if let cached = cache.object(forKey: cacheKey) as? [MarkdownToken] {
            return cached
        }

        let parser = MarkdownParser()
        let tokens = parser.parseText(text)

        // Cache the result
        cache.setObject(tokens as NSArray, forKey: cacheKey)

        return tokens
    }

    private init() {}

    private func parseText(_ text: String) -> [MarkdownToken] {
        var tokens: [MarkdownToken] = []
        let lines = text.components(separatedBy: .newlines)

        for line in lines {
            if line.isEmpty {
                tokens.append(.lineBreak)
                continue
            }

            // Check for headers
            if line.hasPrefix("#") {
                if let headerToken = parseHeader(line) {
                    tokens.append(headerToken)
                    continue
                }
            }

            // Check for bullet list
            if line.hasPrefix("- ") {
                let content = String(line.dropFirst(2))
                tokens.append(.bulletItem(content))
                continue
            }

            // Check for numbered list
            if let numberedToken = parseNumberedList(line) {
                tokens.append(numberedToken)
                continue
            }

            // Parse inline markdown
            tokens.append(contentsOf: parseInlineMarkdown(line))
            tokens.append(.lineBreak)
        }

        // Remove trailing line breaks
        while case .lineBreak = tokens.last {
            tokens.removeLast()
        }

        return tokens
    }

    private func parseHeader(_ line: String) -> MarkdownToken? {
        var level = 0
        var index = line.startIndex

        while index < line.endIndex && line[index] == "#" {
            level += 1
            index = line.index(after: index)
        }

        guard level > 0 && level <= 3 else { return nil }

        // Skip whitespace after #
        while index < line.endIndex && line[index].isWhitespace {
            index = line.index(after: index)
        }

        let text = String(line[index...])
        return .header(level: level, text: text)
    }

    private func parseNumberedList(_ line: String) -> MarkdownToken? {
        // Pattern: "1. text"
        let pattern = #"^(\d+)\.\s+(.+)$"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) else {
            return nil
        }

        if let numberRange = Range(match.range(at: 1), in: line),
           let contentRange = Range(match.range(at: 2), in: line),
           let number = Int(line[numberRange]) {
            let content = String(line[contentRange])
            return .numberedItem(number: number, text: content)
        }

        return nil
    }

    private func parseInlineMarkdown(_ line: String) -> [MarkdownToken] {
        var tokens: [MarkdownToken] = []
        var currentText = ""
        var i = line.startIndex

        while i < line.endIndex {
            let char = line[i]

            // Check for bold **text**
            if char == "*" && i < line.index(before: line.endIndex) && line[line.index(after: i)] == "*" {
                if let (boldText, endIndex) = extractDelimited(from: line, startIndex: i, delimiter: "**") {
                    if !currentText.isEmpty {
                        tokens.append(.text(currentText))
                        currentText = ""
                    }
                    tokens.append(.bold(boldText))
                    i = endIndex
                    continue
                }
            }

            // Check for italic *text*
            if char == "*" {
                if let (italicText, endIndex) = extractDelimited(from: line, startIndex: i, delimiter: "*") {
                    if !currentText.isEmpty {
                        tokens.append(.text(currentText))
                        currentText = ""
                    }
                    tokens.append(.italic(italicText))
                    i = endIndex
                    continue
                }
            }

            // Check for inline code `code`
            if char == "`" {
                if let (codeText, endIndex) = extractDelimited(from: line, startIndex: i, delimiter: "`") {
                    if !currentText.isEmpty {
                        tokens.append(.text(currentText))
                        currentText = ""
                    }
                    tokens.append(.code(codeText))
                    i = endIndex
                    continue
                }
            }

            // Check for link [text](url)
            if char == "[" {
                if let (linkText, linkUrl, endIndex) = extractLink(from: line, startIndex: i) {
                    if !currentText.isEmpty {
                        tokens.append(.text(currentText))
                        currentText = ""
                    }
                    tokens.append(.link(text: linkText, url: linkUrl))
                    i = endIndex
                    continue
                }
            }

            currentText.append(char)
            i = line.index(after: i)
        }

        if !currentText.isEmpty {
            tokens.append(.text(currentText))
        }

        return tokens
    }

    private func extractDelimited(from text: String, startIndex: String.Index, delimiter: String) -> (String, String.Index)? {
        let delimiterLength = delimiter.count
        var searchStart = text.index(startIndex, offsetBy: delimiterLength)

        guard searchStart < text.endIndex else { return nil }

        // Find closing delimiter
        while searchStart < text.endIndex {
            if text[searchStart...].hasPrefix(delimiter) {
                let content = String(text[text.index(startIndex, offsetBy: delimiterLength)..<searchStart])
                let endIndex = text.index(searchStart, offsetBy: delimiterLength)
                return (content, endIndex)
            }
            searchStart = text.index(after: searchStart)
        }

        return nil
    }

    private func extractLink(from text: String, startIndex: String.Index) -> (String, String, String.Index)? {
        // Pattern: [text](url)
        var i = text.index(after: startIndex)
        var linkText = ""

        // Extract link text
        while i < text.endIndex && text[i] != "]" {
            linkText.append(text[i])
            i = text.index(after: i)
        }

        guard i < text.endIndex && text[i] == "]" else { return nil }
        i = text.index(after: i)

        guard i < text.endIndex && text[i] == "(" else { return nil }
        i = text.index(after: i)

        var linkUrl = ""
        while i < text.endIndex && text[i] != ")" {
            linkUrl.append(text[i])
            i = text.index(after: i)
        }

        guard i < text.endIndex && text[i] == ")" else { return nil }
        i = text.index(after: i)

        return (linkText, linkUrl, i)
    }
}

extension MarkdownToken: Equatable {
    public static func == (lhs: MarkdownToken, rhs: MarkdownToken) -> Bool {
        switch (lhs, rhs) {
        case (.text(let l), .text(let r)):
            return l == r
        case (.bold(let l), .bold(let r)):
            return l == r
        case (.italic(let l), .italic(let r)):
            return l == r
        case (.code(let l), .code(let r)):
            return l == r
        case (.link(let lt, let lu), .link(let rt, let ru)):
            return lt == rt && lu == ru
        case (.header(let ll, let lt), .header(let rl, let rt)):
            return ll == rl && lt == rt
        case (.bulletItem(let l), .bulletItem(let r)):
            return l == r
        case (.numberedItem(let ln, let lt), .numberedItem(let rn, let rt)):
            return ln == rn && lt == rt
        case (.lineBreak, .lineBreak):
            return true
        default:
            return false
        }
    }
}
