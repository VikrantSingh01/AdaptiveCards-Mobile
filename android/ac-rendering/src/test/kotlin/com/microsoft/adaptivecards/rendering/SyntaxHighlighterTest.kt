// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

package com.microsoft.adaptivecards.rendering

import com.microsoft.adaptivecards.rendering.composables.SyntaxHighlighter
import com.microsoft.adaptivecards.rendering.composables.SyntaxTokenType
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test

class SyntaxHighlighterTest {

    // MARK: - Swift Highlighting

    @Test
    fun `swift keywords are highlighted`() {
        val tokens = SyntaxHighlighter.tokenize("import SwiftUI", "swift")
        assertEquals(3, tokens.size) // "import", " ", "SwiftUI"
        assertEquals(SyntaxTokenType.KEYWORD, tokens[0].type)
        assertEquals("import", tokens[0].text)
        assertEquals(SyntaxTokenType.TYPE, tokens[2].type)
        assertEquals("SwiftUI", tokens[2].text)
    }

    @Test
    fun `swift struct declaration`() {
        val tokens = SyntaxHighlighter.tokenize("struct ContentView: View {", "swift")
        val types = tokens.map { it.type }
        assertTrue(types.contains(SyntaxTokenType.KEYWORD)) // struct
        assertTrue(types.contains(SyntaxTokenType.TYPE)) // View
        assertTrue(types.contains(SyntaxTokenType.PUNCTUATION)) // { :
    }

    @Test
    fun `swift annotation`() {
        val tokens = SyntaxHighlighter.tokenize("    @State private var count = 0", "swift")
        val keywordTexts = tokens.filter { it.type == SyntaxTokenType.KEYWORD }.map { it.text }
        assertTrue("@State" in keywordTexts)
        assertTrue("private" in keywordTexts)
        assertTrue("var" in keywordTexts)
    }

    @Test
    fun `swift string literal`() {
        val tokens = SyntaxHighlighter.tokenize("let name = \"hello\"", "swift")
        val stringTokens = tokens.filter { it.type == SyntaxTokenType.STRING }
        assertEquals(1, stringTokens.size)
        assertEquals("\"hello\"", stringTokens[0].text)
    }

    @Test
    fun `swift comment`() {
        val tokens = SyntaxHighlighter.tokenize("// This is a comment", "swift")
        assertEquals(1, tokens.size)
        assertEquals(SyntaxTokenType.COMMENT, tokens[0].type)
        assertEquals("// This is a comment", tokens[0].text)
    }

    @Test
    fun `swift number literal`() {
        val tokens = SyntaxHighlighter.tokenize("let x = 42", "swift")
        val numberTokens = tokens.filter { it.type == SyntaxTokenType.NUMBER }
        assertEquals(1, numberTokens.size)
        assertEquals("42", numberTokens[0].text)
    }

    @Test
    fun `swift function call`() {
        val tokens = SyntaxHighlighter.tokenize("print(\"hello\")", "swift")
        val funcTokens = tokens.filter { it.type == SyntaxTokenType.FUNCTION }
        assertEquals(1, funcTokens.size)
        assertEquals("print", funcTokens[0].text)
    }

    // MARK: - JavaScript Highlighting

    @Test
    fun `javascript keywords and strings`() {
        val tokens = SyntaxHighlighter.tokenize("const name = 'World';", "javascript")
        val keywordTexts = tokens.filter { it.type == SyntaxTokenType.KEYWORD }.map { it.text }
        assertTrue("const" in keywordTexts)
        val stringTokens = tokens.filter { it.type == SyntaxTokenType.STRING }
        assertEquals(1, stringTokens.size)
        assertEquals("'World'", stringTokens[0].text)
    }

    @Test
    fun `javascript async await`() {
        val tokens = SyntaxHighlighter.tokenize("async function fetchData() {", "javascript")
        val keywordTexts = tokens.filter { it.type == SyntaxTokenType.KEYWORD }.map { it.text }
        assertTrue("async" in keywordTexts)
        assertTrue("function" in keywordTexts)
    }

    @Test
    fun `javascript comment`() {
        val tokens = SyntaxHighlighter.tokenize("// fetch from API", "js")
        assertEquals(1, tokens.size)
        assertEquals(SyntaxTokenType.COMMENT, tokens[0].type)
    }

    // MARK: - Python Highlighting

    @Test
    fun `python comment`() {
        val tokens = SyntaxHighlighter.tokenize("# This is a comment", "python")
        assertEquals(1, tokens.size)
        assertEquals(SyntaxTokenType.COMMENT, tokens[0].type)
    }

    @Test
    fun `python keywords`() {
        val tokens = SyntaxHighlighter.tokenize("def process(data):", "python")
        val keywordTexts = tokens.filter { it.type == SyntaxTokenType.KEYWORD }.map { it.text }
        assertTrue("def" in keywordTexts)
    }

    @Test
    fun `python types`() {
        val tokens = SyntaxHighlighter.tokenize("from typing import List, Dict", "python")
        val keywordTexts = tokens.filter { it.type == SyntaxTokenType.KEYWORD }.map { it.text }
        val typeTexts = tokens.filter { it.type == SyntaxTokenType.TYPE }.map { it.text }
        assertTrue("from" in keywordTexts)
        assertTrue("import" in keywordTexts)
        assertTrue("List" in typeTexts)
        assertTrue("Dict" in typeTexts)
    }

    // MARK: - JSON Highlighting

    @Test
    fun `json key-value pairs`() {
        val tokens = SyntaxHighlighter.tokenize("  \"name\": \"John\"", "json")
        val propertyTokens = tokens.filter { it.type == SyntaxTokenType.PROPERTY }
        val stringTokens = tokens.filter { it.type == SyntaxTokenType.STRING }
        assertEquals(1, propertyTokens.size)
        assertEquals("\"name\"", propertyTokens[0].text)
        assertEquals(1, stringTokens.size)
        assertEquals("\"John\"", stringTokens[0].text)
    }

    @Test
    fun `json boolean`() {
        val tokens = SyntaxHighlighter.tokenize("  \"active\": true", "json")
        val keywordTexts = tokens.filter { it.type == SyntaxTokenType.KEYWORD }.map { it.text }
        assertTrue("true" in keywordTexts)
    }

    @Test
    fun `json number`() {
        val tokens = SyntaxHighlighter.tokenize("  \"count\": 42", "json")
        val numberTokens = tokens.filter { it.type == SyntaxTokenType.NUMBER }
        assertEquals(1, numberTokens.size)
        assertEquals("42", numberTokens[0].text)
    }

    @Test
    fun `json brackets`() {
        val tokens = SyntaxHighlighter.tokenize("{", "json")
        assertEquals(1, tokens.size)
        assertEquals(SyntaxTokenType.PUNCTUATION, tokens[0].type)
    }

    // MARK: - SQL Highlighting

    @Test
    fun `sql keywords`() {
        val tokens = SyntaxHighlighter.tokenize("SELECT name FROM users WHERE active = true", "sql")
        val keywordTexts = tokens.filter { it.type == SyntaxTokenType.KEYWORD }.map { it.text }
        assertTrue("SELECT" in keywordTexts)
        assertTrue("FROM" in keywordTexts)
        assertTrue("WHERE" in keywordTexts)
        assertTrue("true" in keywordTexts)
    }

    @Test
    fun `sql comment`() {
        val tokens = SyntaxHighlighter.tokenize("-- Get active users", "sql")
        assertEquals(1, tokens.size)
        assertEquals(SyntaxTokenType.COMMENT, tokens[0].type)
    }

    // MARK: - Kotlin Highlighting

    @Test
    fun `kotlin data class`() {
        val tokens = SyntaxHighlighter.tokenize("data class User(val name: String)", "kotlin")
        val keywordTexts = tokens.filter { it.type == SyntaxTokenType.KEYWORD }.map { it.text }
        assertTrue("data" in keywordTexts)
        assertTrue("class" in keywordTexts)
        assertTrue("val" in keywordTexts)
    }

    // MARK: - XML/HTML Highlighting

    @Test
    fun `xml comment`() {
        val tokens = SyntaxHighlighter.tokenize("<!-- comment -->", "xml")
        assertEquals(1, tokens.size)
        assertEquals(SyntaxTokenType.COMMENT, tokens[0].type)
    }

    // MARK: - YAML Highlighting

    @Test
    fun `yaml key-value`() {
        val tokens = SyntaxHighlighter.tokenize("name: John", "yaml")
        val propertyTokens = tokens.filter { it.type == SyntaxTokenType.PROPERTY }
        assertEquals(1, propertyTokens.size)
        assertEquals("name", propertyTokens[0].text)
    }

    @Test
    fun `yaml comment`() {
        val tokens = SyntaxHighlighter.tokenize("# configuration", "yaml")
        assertEquals(1, tokens.size)
        assertEquals(SyntaxTokenType.COMMENT, tokens[0].type)
    }

    // MARK: - Edge Cases

    @Test
    fun `empty line returns single plain token`() {
        val tokens = SyntaxHighlighter.tokenize("", "swift")
        assertEquals(1, tokens.size)
        assertEquals(" ", tokens[0].text)
        assertEquals(SyntaxTokenType.PLAIN, tokens[0].type)
    }

    @Test
    fun `null language does not crash`() {
        val tokens = SyntaxHighlighter.tokenize("hello world", null)
        assertFalse(tokens.isEmpty())
    }

    @Test
    fun `unknown language still tokenizes`() {
        val tokens = SyntaxHighlighter.tokenize("let x = 42;", "brainfuck")
        assertFalse(tokens.isEmpty())
        val numberTokens = tokens.filter { it.type == SyntaxTokenType.NUMBER }
        assertEquals(1, numberTokens.size)
    }

    @Test
    fun `hex number`() {
        val tokens = SyntaxHighlighter.tokenize("let color = 0xFF00AA", "swift")
        val numberTokens = tokens.filter { it.type == SyntaxTokenType.NUMBER }
        assertEquals(1, numberTokens.size)
        assertEquals("0xFF00AA", numberTokens[0].text)
    }

    @Test
    fun `block comment start`() {
        val tokens = SyntaxHighlighter.tokenize("/* block comment */", "swift")
        assertEquals(1, tokens.size)
        assertEquals(SyntaxTokenType.COMMENT, tokens[0].type)
    }

    @Test
    fun `whitespace preservation`() {
        val tokens = SyntaxHighlighter.tokenize("    return true", "swift")
        val allText = tokens.joinToString("") { it.text }
        assertEquals("    return true", allText)
    }

    @Test
    fun `decimal number`() {
        val tokens = SyntaxHighlighter.tokenize("let pi = 3.14159", "swift")
        val numberTokens = tokens.filter { it.type == SyntaxTokenType.NUMBER }
        assertEquals(1, numberTokens.size)
        assertEquals("3.14159", numberTokens[0].text)
    }

    // MARK: - AnnotatedString Output

    @Test
    fun `highlightLine returns AnnotatedString with correct text`() {
        val result = SyntaxHighlighter.highlightLine("let x = 42", "swift")
        assertEquals("let x = 42", result.text)
    }

    // MARK: - All Languages Smoke Test

    @Test
    fun `all languages highlight without crashing`() {
        val languages = listOf(
            "swift", "kotlin", "java", "javascript", "typescript", "python",
            "go", "rust", "c", "cpp", "csharp", "ruby", "php",
            "bash", "shell", "sql", "json", "xml", "html", "yaml", "css",
            null, "unknown"
        )
        val sampleCode = "let x = 42; // comment\nfunction foo() { return \"hello\"; }"

        for (language in languages) {
            for (line in sampleCode.split("\n")) {
                val tokens = SyntaxHighlighter.tokenize(line, language)
                assertFalse(tokens.isEmpty(), "Empty tokens for language: $language")
                val reconstructed = tokens.joinToString("") { it.text }
                assertEquals(line, reconstructed, "Text not preserved for language: $language")
            }
        }
    }
}
