// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

import XCTest
@testable import ACRendering

final class SyntaxHighlighterTests: XCTestCase {

    // MARK: - Swift Highlighting

    func testSwiftKeywords() {
        let tokens = SyntaxHighlighter.highlight(line: "import SwiftUI", language: "swift")
        XCTAssertEqual(tokens.count, 3) // "import", " ", "SwiftUI"
        XCTAssertEqual(tokens[0].type, .keyword)
        XCTAssertEqual(tokens[0].text, "import")
        XCTAssertEqual(tokens[2].type, .type)
        XCTAssertEqual(tokens[2].text, "SwiftUI")
    }

    func testSwiftStructDeclaration() {
        let tokens = SyntaxHighlighter.highlight(line: "struct ContentView: View {", language: "swift")
        let types = tokens.map { $0.type }
        XCTAssertTrue(types.contains(.keyword)) // struct
        XCTAssertTrue(types.contains(.type)) // View
        XCTAssertTrue(types.contains(.punctuation)) // { :
    }

    func testSwiftAnnotation() {
        let tokens = SyntaxHighlighter.highlight(line: "    @State private var count = 0", language: "swift")
        let keywordTokens = tokens.filter { $0.type == .keyword }
        // @State, private, var should all be keywords
        let keywordTexts = keywordTokens.map { $0.text }
        XCTAssertTrue(keywordTexts.contains("@State"))
        XCTAssertTrue(keywordTexts.contains("private"))
        XCTAssertTrue(keywordTexts.contains("var"))
    }

    func testSwiftStringLiteral() {
        let tokens = SyntaxHighlighter.highlight(line: "let name = \"hello\"", language: "swift")
        let stringTokens = tokens.filter { $0.type == .string }
        XCTAssertEqual(stringTokens.count, 1)
        XCTAssertEqual(stringTokens[0].text, "\"hello\"")
    }

    func testSwiftComment() {
        let tokens = SyntaxHighlighter.highlight(line: "// This is a comment", language: "swift")
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens[0].type, .comment)
        XCTAssertEqual(tokens[0].text, "// This is a comment")
    }

    func testSwiftNumberLiteral() {
        let tokens = SyntaxHighlighter.highlight(line: "let x = 42", language: "swift")
        let numberTokens = tokens.filter { $0.type == .number }
        XCTAssertEqual(numberTokens.count, 1)
        XCTAssertEqual(numberTokens[0].text, "42")
    }

    func testSwiftFunctionCall() {
        let tokens = SyntaxHighlighter.highlight(line: "print(\"hello\")", language: "swift")
        let funcTokens = tokens.filter { $0.type == .function }
        XCTAssertEqual(funcTokens.count, 1)
        XCTAssertEqual(funcTokens[0].text, "print")
    }

    // MARK: - JavaScript Highlighting

    func testJSKeywordsAndStrings() {
        let tokens = SyntaxHighlighter.highlight(line: "const name = 'World';", language: "javascript")
        let keywordTokens = tokens.filter { $0.type == .keyword }
        let stringTokens = tokens.filter { $0.type == .string }
        XCTAssertTrue(keywordTokens.map { $0.text }.contains("const"))
        XCTAssertEqual(stringTokens.count, 1)
        XCTAssertEqual(stringTokens[0].text, "'World'")
    }

    func testJSAsyncAwait() {
        let tokens = SyntaxHighlighter.highlight(line: "async function fetchData() {", language: "javascript")
        let keywordTokens = tokens.filter { $0.type == .keyword }
        let keywordTexts = keywordTokens.map { $0.text }
        XCTAssertTrue(keywordTexts.contains("async"))
        XCTAssertTrue(keywordTexts.contains("function"))
    }

    func testJSComment() {
        let tokens = SyntaxHighlighter.highlight(line: "// fetch from API", language: "js")
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens[0].type, .comment)
    }

    // MARK: - Python Highlighting

    func testPythonDefAndComment() {
        let tokens = SyntaxHighlighter.highlight(line: "# This is a comment", language: "python")
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens[0].type, .comment)
    }

    func testPythonKeywords() {
        let tokens = SyntaxHighlighter.highlight(line: "def process(data):", language: "python")
        let keywordTokens = tokens.filter { $0.type == .keyword }
        XCTAssertTrue(keywordTokens.map { $0.text }.contains("def"))
    }

    func testPythonTypes() {
        let tokens = SyntaxHighlighter.highlight(line: "from typing import List, Dict", language: "python")
        let keywordTokens = tokens.filter { $0.type == .keyword }
        let typeTokens = tokens.filter { $0.type == .type }
        XCTAssertTrue(keywordTokens.map { $0.text }.contains("from"))
        XCTAssertTrue(keywordTokens.map { $0.text }.contains("import"))
        XCTAssertTrue(typeTokens.map { $0.text }.contains("List"))
        XCTAssertTrue(typeTokens.map { $0.text }.contains("Dict"))
    }

    // MARK: - JSON Highlighting

    func testJSONKeyValue() {
        let tokens = SyntaxHighlighter.highlight(line: "  \"name\": \"John\"", language: "json")
        let propertyTokens = tokens.filter { $0.type == .property }
        let stringTokens = tokens.filter { $0.type == .string }
        XCTAssertEqual(propertyTokens.count, 1)
        XCTAssertEqual(propertyTokens[0].text, "\"name\"")
        XCTAssertEqual(stringTokens.count, 1)
        XCTAssertEqual(stringTokens[0].text, "\"John\"")
    }

    func testJSONBoolean() {
        let tokens = SyntaxHighlighter.highlight(line: "  \"active\": true", language: "json")
        let keywordTokens = tokens.filter { $0.type == .keyword }
        XCTAssertTrue(keywordTokens.map { $0.text }.contains("true"))
    }

    func testJSONNumber() {
        let tokens = SyntaxHighlighter.highlight(line: "  \"count\": 42", language: "json")
        let numberTokens = tokens.filter { $0.type == .number }
        XCTAssertEqual(numberTokens.count, 1)
        XCTAssertEqual(numberTokens[0].text, "42")
    }

    func testJSONBrackets() {
        let tokens = SyntaxHighlighter.highlight(line: "{", language: "json")
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens[0].type, .punctuation)
    }

    // MARK: - SQL Highlighting

    func testSQLKeywords() {
        let tokens = SyntaxHighlighter.highlight(line: "SELECT name FROM users WHERE active = true", language: "sql")
        let keywordTokens = tokens.filter { $0.type == .keyword }
        let keywordTexts = keywordTokens.map { $0.text }
        XCTAssertTrue(keywordTexts.contains("SELECT"))
        XCTAssertTrue(keywordTexts.contains("FROM"))
        XCTAssertTrue(keywordTexts.contains("WHERE"))
        XCTAssertTrue(keywordTexts.contains("true"))
    }

    func testSQLComment() {
        let tokens = SyntaxHighlighter.highlight(line: "-- Get active users", language: "sql")
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens[0].type, .comment)
    }

    // MARK: - Kotlin Highlighting

    func testKotlinDataClass() {
        let tokens = SyntaxHighlighter.highlight(line: "data class User(val name: String)", language: "kotlin")
        let keywordTokens = tokens.filter { $0.type == .keyword }
        let keywordTexts = keywordTokens.map { $0.text }
        XCTAssertTrue(keywordTexts.contains("data"))
        XCTAssertTrue(keywordTexts.contains("class"))
        XCTAssertTrue(keywordTexts.contains("val"))
    }

    // MARK: - XML/HTML Highlighting

    func testXMLTag() {
        let tokens = SyntaxHighlighter.highlight(line: "<div class=\"main\">Hello</div>", language: "html")
        let keywordTokens = tokens.filter { $0.type == .keyword }
        let stringTokens = tokens.filter { $0.type == .string }
        XCTAssertFalse(keywordTokens.isEmpty)
        XCTAssertFalse(stringTokens.isEmpty)
    }

    func testXMLComment() {
        let tokens = SyntaxHighlighter.highlight(line: "<!-- comment -->", language: "xml")
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens[0].type, .comment)
    }

    // MARK: - YAML Highlighting

    func testYAMLKeyValue() {
        let tokens = SyntaxHighlighter.highlight(line: "name: John", language: "yaml")
        let propertyTokens = tokens.filter { $0.type == .property }
        XCTAssertEqual(propertyTokens.count, 1)
        XCTAssertEqual(propertyTokens[0].text, "name")
    }

    func testYAMLComment() {
        let tokens = SyntaxHighlighter.highlight(line: "# configuration", language: "yaml")
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens[0].type, .comment)
    }

    // MARK: - Edge Cases

    func testEmptyLine() {
        let tokens = SyntaxHighlighter.highlight(line: "", language: "swift")
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens[0].text, " ")
        XCTAssertEqual(tokens[0].type, .plain)
    }

    func testNilLanguage() {
        let tokens = SyntaxHighlighter.highlight(line: "hello world", language: nil)
        XCTAssertFalse(tokens.isEmpty)
        // Should still tokenize without crashing
    }

    func testUnknownLanguage() {
        let tokens = SyntaxHighlighter.highlight(line: "let x = 42;", language: "brainfuck")
        XCTAssertFalse(tokens.isEmpty)
        // Numbers should still be detected by the generic highlighter
        let numberTokens = tokens.filter { $0.type == .number }
        XCTAssertEqual(numberTokens.count, 1)
    }

    func testHexNumber() {
        let tokens = SyntaxHighlighter.highlight(line: "let color = 0xFF00AA", language: "swift")
        let numberTokens = tokens.filter { $0.type == .number }
        XCTAssertEqual(numberTokens.count, 1)
        XCTAssertEqual(numberTokens[0].text, "0xFF00AA")
    }

    func testEscapedStringQuote() {
        let tokens = SyntaxHighlighter.highlight(line: "let s = \"he said \\\"hi\\\"\"", language: "swift")
        let stringTokens = tokens.filter { $0.type == .string }
        XCTAssertEqual(stringTokens.count, 1)
    }

    func testBlockCommentStart() {
        let tokens = SyntaxHighlighter.highlight(line: "/* block comment */", language: "swift")
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens[0].type, .comment)
    }

    func testWhitespacePreservation() {
        let tokens = SyntaxHighlighter.highlight(line: "    return true", language: "swift")
        // Leading whitespace should be preserved as plain tokens
        let allText = tokens.map { $0.text }.joined()
        XCTAssertEqual(allText, "    return true")
    }

    func testDecimalNumber() {
        let tokens = SyntaxHighlighter.highlight(line: "let pi = 3.14159", language: "swift")
        let numberTokens = tokens.filter { $0.type == .number }
        XCTAssertEqual(numberTokens.count, 1)
        XCTAssertEqual(numberTokens[0].text, "3.14159")
    }

    // MARK: - All Supported Languages Smoke Test

    func testAllLanguagesHighlightWithoutCrashing() {
        let languages = [
            "swift", "kotlin", "java", "javascript", "typescript", "python",
            "go", "rust", "c", "cpp", "csharp", "ruby", "php",
            "bash", "shell", "sql", "json", "xml", "html", "yaml", "css",
            nil, "unknown"
        ]
        let sampleCode = "let x = 42; // comment\nfunction foo() { return \"hello\"; }"

        for language in languages {
            for line in sampleCode.components(separatedBy: "\n") {
                let tokens = SyntaxHighlighter.highlight(line: line, language: language)
                XCTAssertFalse(tokens.isEmpty, "Empty tokens for language: \(language ?? "nil")")
                // Verify all text is preserved
                let reconstructed = tokens.map { $0.text }.joined()
                XCTAssertEqual(reconstructed, line, "Text not preserved for language: \(language ?? "nil")")
            }
        }
    }
}
