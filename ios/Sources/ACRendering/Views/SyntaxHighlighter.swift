// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI

/// Token types for syntax highlighting
enum SyntaxTokenType {
    case keyword
    case string
    case comment
    case number
    case type
    case function
    case property
    case annotation
    case punctuation
    case plain
}

/// A token with its text and type
struct SyntaxToken {
    let text: String
    let type: SyntaxTokenType
}

/// VS Code Dark+ inspired color palette for syntax highlighting
enum SyntaxColors {
    static let keyword = Color(red: 0x56 / 255.0, green: 0x9C / 255.0, blue: 0xD6 / 255.0)       // #569CD6
    static let string = Color(red: 0xCE / 255.0, green: 0x91 / 255.0, blue: 0x78 / 255.0)         // #CE9178
    static let comment = Color(red: 0x6A / 255.0, green: 0x99 / 255.0, blue: 0x55 / 255.0)        // #6A9955
    static let number = Color(red: 0xB5 / 255.0, green: 0xCE / 255.0, blue: 0xA8 / 255.0)         // #B5CEA8
    static let type = Color(red: 0x4E / 255.0, green: 0xC9 / 255.0, blue: 0xB0 / 255.0)           // #4EC9B0
    static let function = Color(red: 0xDC / 255.0, green: 0xDC / 255.0, blue: 0xAA / 255.0)       // #DCDCAA
    static let property = Color(red: 0x9C / 255.0, green: 0xDC / 255.0, blue: 0xFE / 255.0)       // #9CDCFE
    static let annotation = Color(red: 0xD7 / 255.0, green: 0xBA / 255.0, blue: 0x7D / 255.0)     // #D7BA7D
    static let punctuation = Color(red: 0xD4 / 255.0, green: 0xD4 / 255.0, blue: 0xD4 / 255.0)    // #D4D4D4
    static let plain = Color(red: 0xD4 / 255.0, green: 0xD4 / 255.0, blue: 0xD4 / 255.0)          // #D4D4D4

    static func color(for tokenType: SyntaxTokenType) -> Color {
        switch tokenType {
        case .keyword: return keyword
        case .string: return string
        case .comment: return comment
        case .number: return number
        case .type: return type
        case .function: return function
        case .property: return property
        case .annotation: return annotation
        case .punctuation: return punctuation
        case .plain: return plain
        }
    }
}

/// Language-specific keyword sets
private let swiftKeywords: Set<String> = [
    "import", "struct", "class", "enum", "protocol", "extension", "func", "var", "let",
    "if", "else", "guard", "switch", "case", "default", "for", "while", "repeat",
    "return", "throw", "throws", "try", "catch", "do", "in", "where", "as", "is",
    "true", "false", "nil", "self", "Self", "super", "init", "deinit", "typealias",
    "static", "private", "public", "internal", "fileprivate", "open", "mutating",
    "override", "final", "weak", "unowned", "lazy", "some", "any", "async", "await",
    "@State", "@Binding", "@Published", "@ObservedObject", "@StateObject", "@Environment",
    "@EnvironmentObject", "@MainActor"
]

private let swiftTypes: Set<String> = [
    "String", "Int", "Double", "Float", "Bool", "Array", "Dictionary", "Set", "Optional",
    "View", "Text", "VStack", "HStack", "ZStack", "Button", "Image", "Color",
    "NavigationView", "List", "ForEach", "Binding", "ObservableObject", "AnyView",
    "CGFloat", "CGSize", "CGRect", "URL", "Data", "Date", "Error", "Result", "Void"
]

private let kotlinKeywords: Set<String> = [
    "package", "import", "class", "interface", "object", "fun", "val", "var",
    "if", "else", "when", "for", "while", "do", "return", "throw", "try", "catch",
    "finally", "in", "is", "as", "true", "false", "null", "this", "super",
    "private", "public", "internal", "protected", "open", "abstract", "sealed",
    "data", "enum", "companion", "override", "suspend", "inline", "crossinline",
    "noinline", "reified", "lateinit", "by", "lazy", "const", "typealias"
]

private let kotlinTypes: Set<String> = [
    "String", "Int", "Long", "Double", "Float", "Boolean", "Unit", "Nothing",
    "List", "Map", "Set", "Array", "MutableList", "MutableMap", "MutableSet",
    "Pair", "Triple", "Result", "Sequence", "Any", "Comparable"
]

private let javaKeywords: Set<String> = [
    "package", "import", "class", "interface", "enum", "extends", "implements",
    "public", "private", "protected", "static", "final", "abstract", "synchronized",
    "volatile", "transient", "native", "strictfp", "void", "new", "this", "super",
    "if", "else", "switch", "case", "default", "for", "while", "do", "break",
    "continue", "return", "throw", "throws", "try", "catch", "finally",
    "true", "false", "null", "instanceof", "assert"
]

private let javaTypes: Set<String> = [
    "String", "Integer", "Long", "Double", "Float", "Boolean", "Character", "Byte",
    "Short", "Object", "Class", "List", "Map", "Set", "ArrayList", "HashMap",
    "Optional", "Stream", "Collection", "Iterable", "Comparable", "Runnable",
    "Thread", "Exception", "RuntimeException", "int", "long", "double", "float",
    "boolean", "char", "byte", "short"
]

private let jsKeywords: Set<String> = [
    "import", "export", "from", "default", "function", "const", "let", "var",
    "if", "else", "switch", "case", "for", "while", "do", "break", "continue",
    "return", "throw", "try", "catch", "finally", "new", "delete", "typeof",
    "instanceof", "in", "of", "class", "extends", "super", "this",
    "true", "false", "null", "undefined", "void", "yield", "async", "await",
    "static", "get", "set", "constructor"
]

private let tsKeywords: Set<String> = jsKeywords.union([
    "type", "interface", "enum", "namespace", "module", "declare", "abstract",
    "implements", "readonly", "keyof", "infer", "as", "is", "never", "unknown",
    "any", "private", "public", "protected"
])

private let tsTypes: Set<String> = [
    "string", "number", "boolean", "object", "symbol", "bigint", "void", "never",
    "unknown", "any", "undefined", "null", "Array", "Promise", "Record", "Partial",
    "Required", "Readonly", "Pick", "Omit", "Exclude", "Extract", "Map", "Set"
]

private let pythonKeywords: Set<String> = [
    "import", "from", "as", "def", "class", "return", "yield", "lambda",
    "if", "elif", "else", "for", "while", "break", "continue", "pass",
    "try", "except", "finally", "raise", "with", "assert",
    "True", "False", "None", "and", "or", "not", "in", "is", "del",
    "global", "nonlocal", "async", "await", "self", "cls"
]

private let pythonTypes: Set<String> = [
    "str", "int", "float", "bool", "list", "dict", "set", "tuple", "bytes",
    "type", "object", "Exception", "range", "enumerate", "zip", "map", "filter"
]

private let goKeywords: Set<String> = [
    "package", "import", "func", "var", "const", "type", "struct", "interface",
    "map", "chan", "if", "else", "switch", "case", "default", "for", "range",
    "break", "continue", "return", "go", "select", "defer", "fallthrough", "goto",
    "true", "false", "nil", "iota"
]

private let goTypes: Set<String> = [
    "string", "int", "int8", "int16", "int32", "int64",
    "uint", "uint8", "uint16", "uint32", "uint64",
    "float32", "float64", "complex64", "complex128",
    "bool", "byte", "rune", "error", "any"
]

private let rustKeywords: Set<String> = [
    "use", "mod", "pub", "fn", "let", "mut", "const", "static", "struct", "enum",
    "trait", "impl", "for", "if", "else", "match", "while", "loop", "break",
    "continue", "return", "as", "in", "ref", "move", "self", "Self", "super",
    "where", "async", "await", "unsafe", "extern", "crate", "type", "dyn",
    "true", "false"
]

private let rustTypes: Set<String> = [
    "i8", "i16", "i32", "i64", "i128", "isize",
    "u8", "u16", "u32", "u64", "u128", "usize",
    "f32", "f64", "bool", "char", "str",
    "String", "Vec", "Box", "Rc", "Arc", "Option", "Result",
    "HashMap", "HashSet", "BTreeMap", "BTreeSet"
]

private let bashKeywords: Set<String> = [
    "if", "then", "else", "elif", "fi", "case", "esac", "for", "while", "until",
    "do", "done", "in", "function", "return", "exit", "local", "export", "readonly",
    "declare", "typeset", "source", "echo", "printf", "read", "set", "unset",
    "shift", "test", "true", "false"
]

private let sqlKeywords: Set<String> = [
    "SELECT", "FROM", "WHERE", "INSERT", "UPDATE", "DELETE", "CREATE", "DROP",
    "ALTER", "TABLE", "INDEX", "VIEW", "INTO", "VALUES", "SET", "JOIN", "LEFT",
    "RIGHT", "INNER", "OUTER", "ON", "AND", "OR", "NOT", "NULL", "IS", "IN",
    "BETWEEN", "LIKE", "ORDER", "BY", "GROUP", "HAVING", "LIMIT", "OFFSET",
    "UNION", "ALL", "AS", "DISTINCT", "COUNT", "SUM", "AVG", "MIN", "MAX",
    "EXISTS", "CASE", "WHEN", "THEN", "ELSE", "END", "PRIMARY", "KEY",
    "FOREIGN", "REFERENCES", "CONSTRAINT", "DEFAULT", "CHECK", "UNIQUE",
    "select", "from", "where", "insert", "update", "delete", "create", "drop",
    "alter", "table", "index", "view", "into", "values", "set", "join", "left",
    "right", "inner", "outer", "on", "and", "or", "not", "null", "is", "in",
    "between", "like", "order", "by", "group", "having", "limit", "offset",
    "union", "all", "as", "distinct", "count", "sum", "avg", "min", "max",
    "exists", "case", "when", "then", "else", "end", "primary", "key",
    "foreign", "references", "constraint", "default", "check", "unique",
    "TRUE", "FALSE", "true", "false"
]

private let sqlTypes: Set<String> = [
    "INT", "INTEGER", "BIGINT", "SMALLINT", "TINYINT", "FLOAT", "DOUBLE", "DECIMAL",
    "NUMERIC", "VARCHAR", "CHAR", "TEXT", "BLOB", "DATE", "DATETIME", "TIMESTAMP",
    "BOOLEAN", "SERIAL", "UUID",
    "int", "integer", "bigint", "smallint", "tinyint", "float", "double", "decimal",
    "numeric", "varchar", "char", "text", "blob", "date", "datetime", "timestamp",
    "boolean", "serial", "uuid"
]

private let cssKeywords: Set<String> = [
    "important", "inherit", "initial", "unset", "revert", "none", "auto",
    "block", "inline", "flex", "grid", "absolute", "relative", "fixed", "sticky",
    "solid", "dashed", "dotted", "hidden", "visible", "scroll", "wrap", "nowrap"
]

private let rubyKeywords: Set<String> = [
    "require", "include", "extend", "module", "class", "def", "end", "do",
    "if", "elsif", "else", "unless", "case", "when", "while", "until", "for",
    "begin", "rescue", "ensure", "raise", "return", "yield", "block_given?",
    "true", "false", "nil", "self", "super", "puts", "print", "attr_accessor",
    "attr_reader", "attr_writer", "private", "public", "protected", "new",
    "then", "and", "or", "not", "in", "lambda", "proc"
]

private let phpKeywords: Set<String> = [
    "namespace", "use", "class", "interface", "trait", "extends", "implements",
    "function", "public", "private", "protected", "static", "abstract", "final",
    "const", "var", "new", "return", "throw", "try", "catch", "finally",
    "if", "elseif", "else", "switch", "case", "default", "for", "foreach",
    "while", "do", "break", "continue", "echo", "print", "require", "include",
    "true", "false", "null", "self", "parent", "array", "list", "match",
    "fn", "yield", "as", "instanceof"
]

private let cKeywords: Set<String> = [
    "auto", "break", "case", "char", "const", "continue", "default", "do",
    "double", "else", "enum", "extern", "float", "for", "goto", "if",
    "int", "long", "register", "return", "short", "signed", "sizeof", "static",
    "struct", "switch", "typedef", "union", "unsigned", "void", "volatile", "while",
    "true", "false", "NULL", "include", "define", "ifdef", "ifndef", "endif", "pragma"
]

private let cppKeywords: Set<String> = cKeywords.union([
    "class", "namespace", "using", "template", "typename", "public", "private",
    "protected", "virtual", "override", "final", "new", "delete", "this",
    "throw", "try", "catch", "nullptr", "constexpr", "auto", "decltype",
    "static_cast", "dynamic_cast", "reinterpret_cast", "const_cast",
    "noexcept", "inline", "explicit", "friend", "operator", "bool",
    "cout", "cin", "endl", "std", "string", "vector", "map", "set"
])

/// Regex-based syntax highlighter supporting multiple languages
struct SyntaxHighlighter {

    /// Highlight a line of code based on language
    static func highlight(line: String, language: String?) -> [SyntaxToken] {
        guard !line.isEmpty else {
            return [SyntaxToken(text: " ", type: .plain)]
        }

        let lang = normalizeLanguage(language)

        switch lang {
        case "json":
            return highlightJSON(line)
        case "xml", "html":
            return highlightXML(line)
        case "yaml", "yml":
            return highlightYAML(line)
        case "css":
            return highlightCSS(line)
        case "sql":
            return highlightGeneric(line, keywords: sqlKeywords, types: sqlTypes, commentPrefix: "--")
        case "bash", "shell", "sh", "zsh":
            return highlightBash(line)
        case "swift":
            return highlightGeneric(line, keywords: swiftKeywords, types: swiftTypes, commentPrefix: "//")
        case "kotlin", "kt":
            return highlightGeneric(line, keywords: kotlinKeywords, types: kotlinTypes, commentPrefix: "//")
        case "java":
            return highlightGeneric(line, keywords: javaKeywords, types: javaTypes, commentPrefix: "//")
        case "javascript", "js":
            return highlightGeneric(line, keywords: jsKeywords, types: [], commentPrefix: "//")
        case "typescript", "ts":
            return highlightGeneric(line, keywords: tsKeywords, types: tsTypes, commentPrefix: "//")
        case "python", "py":
            return highlightGeneric(line, keywords: pythonKeywords, types: pythonTypes, commentPrefix: "#")
        case "go":
            return highlightGeneric(line, keywords: goKeywords, types: goTypes, commentPrefix: "//")
        case "rust", "rs":
            return highlightGeneric(line, keywords: rustKeywords, types: rustTypes, commentPrefix: "//")
        case "c":
            return highlightGeneric(line, keywords: cKeywords, types: [], commentPrefix: "//")
        case "cpp", "c++", "cxx":
            return highlightGeneric(line, keywords: cppKeywords, types: [], commentPrefix: "//")
        case "csharp", "c#", "cs":
            return highlightGeneric(line, keywords: cppKeywords, types: [], commentPrefix: "//")
        case "ruby", "rb":
            return highlightGeneric(line, keywords: rubyKeywords, types: [], commentPrefix: "#")
        case "php":
            return highlightGeneric(line, keywords: phpKeywords, types: [], commentPrefix: "//")
        default:
            return highlightGeneric(line, keywords: [], types: [], commentPrefix: "//")
        }
    }

    private static func normalizeLanguage(_ language: String?) -> String {
        return (language ?? "").lowercased().trimmingCharacters(in: .whitespaces)
    }

    // MARK: - Generic Highlighter

    private static func highlightGeneric(
        _ line: String,
        keywords: Set<String>,
        types: Set<String>,
        commentPrefix: String
    ) -> [SyntaxToken] {
        var tokens: [SyntaxToken] = []
        let chars = Array(line)
        var i = 0

        while i < chars.count {
            // Check for line comment
            if matchesPrefix(chars, at: i, prefix: commentPrefix) {
                let rest = String(chars[i...])
                tokens.append(SyntaxToken(text: rest, type: .comment))
                return tokens
            }

            // Check for block comment start
            if i + 1 < chars.count && chars[i] == "/" && chars[i + 1] == "*" {
                let rest = String(chars[i...])
                tokens.append(SyntaxToken(text: rest, type: .comment))
                return tokens
            }

            // Strings (double-quoted)
            if chars[i] == "\"" {
                let str = consumeString(chars, from: i, quote: "\"")
                tokens.append(SyntaxToken(text: str, type: .string))
                i += str.count
                continue
            }

            // Strings (single-quoted)
            if chars[i] == "'" {
                let str = consumeString(chars, from: i, quote: "'")
                tokens.append(SyntaxToken(text: str, type: .string))
                i += str.count
                continue
            }

            // Template strings (backtick)
            if chars[i] == "`" {
                let str = consumeString(chars, from: i, quote: "`")
                tokens.append(SyntaxToken(text: str, type: .string))
                i += str.count
                continue
            }

            // Annotations/decorators (@ prefixed)
            if chars[i] == "@" {
                let word = consumeWord(chars, from: i)
                if word.count > 1 {
                    // Check if it is a keyword (like @State in Swift)
                    if keywords.contains(word) {
                        tokens.append(SyntaxToken(text: word, type: .keyword))
                    } else {
                        tokens.append(SyntaxToken(text: word, type: .annotation))
                    }
                    i += word.count
                    continue
                }
            }

            // Numbers
            if chars[i].isNumber || (chars[i] == "." && i + 1 < chars.count && chars[i + 1].isNumber) {
                let num = consumeNumber(chars, from: i)
                tokens.append(SyntaxToken(text: num, type: .number))
                i += num.count
                continue
            }

            // Words (identifiers, keywords, types)
            if chars[i].isLetter || chars[i] == "_" || chars[i] == "#" {
                let word = consumeWord(chars, from: i)
                if keywords.contains(word) {
                    tokens.append(SyntaxToken(text: word, type: .keyword))
                } else if types.contains(word) {
                    tokens.append(SyntaxToken(text: word, type: .type))
                } else if i + word.count < chars.count && chars[i + word.count] == "(" {
                    tokens.append(SyntaxToken(text: word, type: .function))
                } else if word.first?.isUppercase == true && !types.isEmpty {
                    tokens.append(SyntaxToken(text: word, type: .type))
                } else {
                    tokens.append(SyntaxToken(text: word, type: .plain))
                }
                i += word.count
                continue
            }

            // Operators and punctuation
            if "{}[]().,;:+-*/%=<>!&|^~?".contains(chars[i]) {
                tokens.append(SyntaxToken(text: String(chars[i]), type: .punctuation))
                i += 1
                continue
            }

            // Whitespace and other characters
            let ws = consumeWhitespace(chars, from: i)
            if !ws.isEmpty {
                tokens.append(SyntaxToken(text: ws, type: .plain))
                i += ws.count
            } else {
                tokens.append(SyntaxToken(text: String(chars[i]), type: .plain))
                i += 1
            }
        }

        return tokens
    }

    // MARK: - JSON Highlighter

    private static func highlightJSON(_ line: String) -> [SyntaxToken] {
        var tokens: [SyntaxToken] = []
        let chars = Array(line)
        var i = 0

        while i < chars.count {
            if chars[i] == "\"" {
                let str = consumeString(chars, from: i, quote: "\"")
                // Check if this is a key (followed by colon)
                let afterStr = i + str.count
                var j = afterStr
                while j < chars.count && chars[j] == " " { j += 1 }
                if j < chars.count && chars[j] == ":" {
                    tokens.append(SyntaxToken(text: str, type: .property))
                } else {
                    tokens.append(SyntaxToken(text: str, type: .string))
                }
                i += str.count
                continue
            }

            if chars[i].isNumber || chars[i] == "-" {
                let num = consumeNumber(chars, from: i)
                if num.count > 0 && (num != "-") {
                    tokens.append(SyntaxToken(text: num, type: .number))
                    i += num.count
                    continue
                }
            }

            let word = consumeWord(chars, from: i)
            if word == "true" || word == "false" || word == "null" {
                tokens.append(SyntaxToken(text: word, type: .keyword))
                i += word.count
                continue
            }

            if "{}[]:,".contains(chars[i]) {
                tokens.append(SyntaxToken(text: String(chars[i]), type: .punctuation))
                i += 1
                continue
            }

            let ws = consumeWhitespace(chars, from: i)
            if !ws.isEmpty {
                tokens.append(SyntaxToken(text: ws, type: .plain))
                i += ws.count
            } else {
                tokens.append(SyntaxToken(text: String(chars[i]), type: .plain))
                i += 1
            }
        }

        return tokens
    }

    // MARK: - XML/HTML Highlighter

    private static func highlightXML(_ line: String) -> [SyntaxToken] {
        var tokens: [SyntaxToken] = []
        let chars = Array(line)
        var i = 0

        while i < chars.count {
            // Comment
            if matchesPrefix(chars, at: i, prefix: "<!--") {
                let rest = String(chars[i...])
                tokens.append(SyntaxToken(text: rest, type: .comment))
                return tokens
            }

            // Tags
            if chars[i] == "<" {
                var tag = "<"
                i += 1
                // Consume tag name and attributes
                while i < chars.count && chars[i] != ">" {
                    if chars[i] == "\"" {
                        let str = consumeString(chars, from: i, quote: "\"")
                        tokens.append(SyntaxToken(text: tag, type: .keyword))
                        tag = ""
                        tokens.append(SyntaxToken(text: str, type: .string))
                        i += str.count
                        continue
                    }
                    tag.append(chars[i])
                    i += 1
                }
                if i < chars.count {
                    tag.append(chars[i])
                    i += 1
                }
                if !tag.isEmpty {
                    tokens.append(SyntaxToken(text: tag, type: .keyword))
                }
                continue
            }

            // Text content
            var text = ""
            while i < chars.count && chars[i] != "<" {
                text.append(chars[i])
                i += 1
            }
            if !text.isEmpty {
                tokens.append(SyntaxToken(text: text, type: .plain))
            }
        }

        return tokens
    }

    // MARK: - YAML Highlighter

    private static func highlightYAML(_ line: String) -> [SyntaxToken] {
        var tokens: [SyntaxToken] = []
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        // Comments
        if trimmed.hasPrefix("#") {
            return [SyntaxToken(text: line, type: .comment)]
        }

        // Key-value pairs
        if let colonRange = line.range(of: ":") {
            let key = String(line[line.startIndex..<colonRange.lowerBound])
            let colon = ":"
            let value = String(line[colonRange.upperBound...])

            tokens.append(SyntaxToken(text: key, type: .property))
            tokens.append(SyntaxToken(text: colon, type: .punctuation))

            let trimmedValue = value.trimmingCharacters(in: .whitespaces)
            if trimmedValue == "true" || trimmedValue == "false" || trimmedValue == "null" {
                tokens.append(SyntaxToken(text: value, type: .keyword))
            } else if trimmedValue.first?.isNumber == true {
                tokens.append(SyntaxToken(text: value, type: .number))
            } else {
                tokens.append(SyntaxToken(text: value, type: .string))
            }
        } else if trimmed.hasPrefix("-") {
            tokens.append(SyntaxToken(text: line, type: .plain))
        } else {
            tokens.append(SyntaxToken(text: line, type: .plain))
        }

        return tokens
    }

    // MARK: - CSS Highlighter

    private static func highlightCSS(_ line: String) -> [SyntaxToken] {
        var tokens: [SyntaxToken] = []
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        if trimmed.hasPrefix("/*") || trimmed.hasPrefix("*") {
            return [SyntaxToken(text: line, type: .comment)]
        }

        let chars = Array(line)
        var i = 0

        while i < chars.count {
            if chars[i] == "\"" || chars[i] == "'" {
                let str = consumeString(chars, from: i, quote: chars[i])
                tokens.append(SyntaxToken(text: str, type: .string))
                i += str.count
                continue
            }

            if chars[i].isNumber || (chars[i] == "." && i + 1 < chars.count && chars[i + 1].isNumber) {
                let num = consumeNumber(chars, from: i)
                // Include unit suffix (px, em, rem, etc.)
                var unit = ""
                var j = i + num.count
                while j < chars.count && chars[j].isLetter {
                    unit.append(chars[j])
                    j += 1
                }
                tokens.append(SyntaxToken(text: num + unit, type: .number))
                i = j
                continue
            }

            if chars[i] == "#" && i + 1 < chars.count && (chars[i + 1].isHexDigit) {
                var hex = "#"
                var j = i + 1
                while j < chars.count && chars[j].isHexDigit { hex.append(chars[j]); j += 1 }
                tokens.append(SyntaxToken(text: hex, type: .number))
                i = j
                continue
            }

            if chars[i] == ":" && i + 1 < chars.count && chars[i + 1] != ":" {
                tokens.append(SyntaxToken(text: ":", type: .punctuation))
                i += 1
                continue
            }

            if "{}();,".contains(chars[i]) {
                tokens.append(SyntaxToken(text: String(chars[i]), type: .punctuation))
                i += 1
                continue
            }

            if chars[i].isLetter || chars[i] == "-" || chars[i] == "_" || chars[i] == "." {
                let word = consumeCSSWord(chars, from: i)
                if cssKeywords.contains(word) {
                    tokens.append(SyntaxToken(text: word, type: .keyword))
                } else if word.hasPrefix(".") || word.hasPrefix("#") {
                    tokens.append(SyntaxToken(text: word, type: .type))
                } else {
                    tokens.append(SyntaxToken(text: word, type: .property))
                }
                i += word.count
                continue
            }

            let ws = consumeWhitespace(chars, from: i)
            if !ws.isEmpty {
                tokens.append(SyntaxToken(text: ws, type: .plain))
                i += ws.count
            } else {
                tokens.append(SyntaxToken(text: String(chars[i]), type: .plain))
                i += 1
            }
        }

        return tokens
    }

    // MARK: - Bash Highlighter

    private static func highlightBash(_ line: String) -> [SyntaxToken] {
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        if trimmed.hasPrefix("#") {
            return [SyntaxToken(text: line, type: .comment)]
        }

        return highlightGeneric(line, keywords: bashKeywords, types: [], commentPrefix: "#")
    }

    // MARK: - Tokenizer Helpers

    private static func matchesPrefix(_ chars: [Character], at index: Int, prefix: String) -> Bool {
        let prefixChars = Array(prefix)
        guard index + prefixChars.count <= chars.count else { return false }
        for j in 0..<prefixChars.count {
            if chars[index + j] != prefixChars[j] { return false }
        }
        return true
    }

    private static func consumeString(_ chars: [Character], from start: Int, quote: Character) -> String {
        var result = String(chars[start])
        var i = start + 1
        while i < chars.count {
            result.append(chars[i])
            if chars[i] == quote && (i == start + 1 || chars[i - 1] != "\\") {
                break
            }
            i += 1
        }
        return result
    }

    private static func consumeWord(_ chars: [Character], from start: Int) -> String {
        var result = ""
        var i = start
        // Allow @ prefix for annotations
        if i < chars.count && chars[i] == "@" {
            result.append(chars[i])
            i += 1
        }
        // Allow # prefix for preprocessor directives
        if i < chars.count && chars[i] == "#" && result.isEmpty {
            result.append(chars[i])
            i += 1
        }
        while i < chars.count && (chars[i].isLetter || chars[i].isNumber || chars[i] == "_" || chars[i] == "?") {
            result.append(chars[i])
            i += 1
        }
        return result
    }

    private static func consumeCSSWord(_ chars: [Character], from start: Int) -> String {
        var result = ""
        var i = start
        while i < chars.count && (chars[i].isLetter || chars[i].isNumber || chars[i] == "-" || chars[i] == "_" || chars[i] == ".") {
            result.append(chars[i])
            i += 1
        }
        return result
    }

    private static func consumeNumber(_ chars: [Character], from start: Int) -> String {
        var result = ""
        var i = start
        var hasDecimal = false

        // Leading negative sign
        if i < chars.count && chars[i] == "-" {
            result.append(chars[i])
            i += 1
        }

        // Hex prefix
        if i + 1 < chars.count && chars[i] == "0" && (chars[i + 1] == "x" || chars[i + 1] == "X") {
            result.append(contentsOf: [chars[i], chars[i + 1]])
            i += 2
            while i < chars.count && chars[i].isHexDigit {
                result.append(chars[i])
                i += 1
            }
            return result
        }

        while i < chars.count {
            if chars[i].isNumber {
                result.append(chars[i])
            } else if chars[i] == "." && !hasDecimal && i + 1 < chars.count && chars[i + 1].isNumber {
                result.append(chars[i])
                hasDecimal = true
            } else if (chars[i] == "e" || chars[i] == "E") && !result.isEmpty {
                result.append(chars[i])
                i += 1
                if i < chars.count && (chars[i] == "+" || chars[i] == "-") {
                    result.append(chars[i])
                    i += 1
                }
                continue
            } else {
                break
            }
            i += 1
        }
        return result
    }

    private static func consumeWhitespace(_ chars: [Character], from start: Int) -> String {
        var result = ""
        var i = start
        while i < chars.count && chars[i].isWhitespace {
            result.append(chars[i])
            i += 1
        }
        return result
    }
}
