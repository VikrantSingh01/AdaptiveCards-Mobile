// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString

/** Token types for syntax highlighting */
enum class SyntaxTokenType {
    KEYWORD, STRING, COMMENT, NUMBER, TYPE, FUNCTION,
    PROPERTY, ANNOTATION, PUNCTUATION, PLAIN
}

/** VS Code Dark+ inspired color palette */
object SyntaxColors {
    val keyword = Color(0xFF569CD6)
    val string = Color(0xFFCE9178)
    val comment = Color(0xFF6A9955)
    val number = Color(0xFFB5CEA8)
    val type = Color(0xFF4EC9B0)
    val function = Color(0xFFDCDCAA)
    val property = Color(0xFF9CDCFE)
    val annotation = Color(0xFFD7BA7D)
    val punctuation = Color(0xFFD4D4D4)
    val plain = Color(0xFFD4D4D4)

    fun colorFor(tokenType: SyntaxTokenType): Color = when (tokenType) {
        SyntaxTokenType.KEYWORD -> keyword
        SyntaxTokenType.STRING -> string
        SyntaxTokenType.COMMENT -> comment
        SyntaxTokenType.NUMBER -> number
        SyntaxTokenType.TYPE -> type
        SyntaxTokenType.FUNCTION -> function
        SyntaxTokenType.PROPERTY -> property
        SyntaxTokenType.ANNOTATION -> annotation
        SyntaxTokenType.PUNCTUATION -> punctuation
        SyntaxTokenType.PLAIN -> plain
    }
}

/** A token with its text and type */
data class SyntaxToken(val text: String, val type: SyntaxTokenType)

/** Regex-based syntax highlighter supporting multiple languages */
object SyntaxHighlighter {

    /** Highlight a line of code and return an AnnotatedString */
    fun highlightLine(line: String, language: String?): AnnotatedString {
        val tokens = tokenize(line, language)
        return buildAnnotatedString {
            for (token in tokens) {
                pushStyle(SpanStyle(color = SyntaxColors.colorFor(token.type)))
                append(token.text)
                pop()
            }
        }
    }

    /** Tokenize a line of code based on language */
    fun tokenize(line: String, language: String?): List<SyntaxToken> {
        if (line.isEmpty()) return listOf(SyntaxToken(" ", SyntaxTokenType.PLAIN))

        val lang = normalizeLanguage(language)
        return when (lang) {
            "json" -> highlightJSON(line)
            "xml", "html" -> highlightXML(line)
            "yaml", "yml" -> highlightYAML(line)
            "css" -> highlightCSS(line)
            "sql" -> highlightGeneric(line, SQL_KEYWORDS, SQL_TYPES, "--")
            "bash", "shell", "sh", "zsh" -> highlightBash(line)
            "swift" -> highlightGeneric(line, SWIFT_KEYWORDS, SWIFT_TYPES, "//")
            "kotlin", "kt" -> highlightGeneric(line, KOTLIN_KEYWORDS, KOTLIN_TYPES, "//")
            "java" -> highlightGeneric(line, JAVA_KEYWORDS, JAVA_TYPES, "//")
            "javascript", "js" -> highlightGeneric(line, JS_KEYWORDS, emptySet(), "//")
            "typescript", "ts" -> highlightGeneric(line, TS_KEYWORDS, TS_TYPES, "//")
            "python", "py" -> highlightGeneric(line, PYTHON_KEYWORDS, PYTHON_TYPES, "#")
            "go" -> highlightGeneric(line, GO_KEYWORDS, GO_TYPES, "//")
            "rust", "rs" -> highlightGeneric(line, RUST_KEYWORDS, RUST_TYPES, "//")
            "c" -> highlightGeneric(line, C_KEYWORDS, emptySet(), "//")
            "cpp", "c++", "cxx" -> highlightGeneric(line, CPP_KEYWORDS, emptySet(), "//")
            "csharp", "c#", "cs" -> highlightGeneric(line, CPP_KEYWORDS, emptySet(), "//")
            "ruby", "rb" -> highlightGeneric(line, RUBY_KEYWORDS, emptySet(), "#")
            "php" -> highlightGeneric(line, PHP_KEYWORDS, emptySet(), "//")
            else -> highlightGeneric(line, emptySet(), emptySet(), "//")
        }
    }

    private fun normalizeLanguage(language: String?): String =
        (language ?: "").lowercase().trim()

    // region Generic Highlighter

    private fun highlightGeneric(
        line: String,
        keywords: Set<String>,
        types: Set<String>,
        commentPrefix: String
    ): List<SyntaxToken> {
        val tokens = mutableListOf<SyntaxToken>()
        val chars = line.toCharArray()
        var i = 0

        while (i < chars.size) {
            // Line comment
            if (matchesPrefix(chars, i, commentPrefix)) {
                tokens.add(SyntaxToken(line.substring(i), SyntaxTokenType.COMMENT))
                return tokens
            }

            // Block comment
            if (i + 1 < chars.size && chars[i] == '/' && chars[i + 1] == '*') {
                tokens.add(SyntaxToken(line.substring(i), SyntaxTokenType.COMMENT))
                return tokens
            }

            // Strings
            if (chars[i] == '"' || chars[i] == '\'' || chars[i] == '`') {
                val str = consumeString(chars, i, chars[i])
                tokens.add(SyntaxToken(str, SyntaxTokenType.STRING))
                i += str.length
                continue
            }

            // Annotations/decorators
            if (chars[i] == '@') {
                val word = consumeWord(chars, i)
                if (word.length > 1) {
                    if (word in keywords) {
                        tokens.add(SyntaxToken(word, SyntaxTokenType.KEYWORD))
                    } else {
                        tokens.add(SyntaxToken(word, SyntaxTokenType.ANNOTATION))
                    }
                    i += word.length
                    continue
                }
            }

            // Numbers
            if (chars[i].isDigit() || (chars[i] == '.' && i + 1 < chars.size && chars[i + 1].isDigit())) {
                val num = consumeNumber(chars, i)
                tokens.add(SyntaxToken(num, SyntaxTokenType.NUMBER))
                i += num.length
                continue
            }

            // Words
            if (chars[i].isLetter() || chars[i] == '_' || chars[i] == '#') {
                val word = consumeWord(chars, i)
                when {
                    word in keywords -> tokens.add(SyntaxToken(word, SyntaxTokenType.KEYWORD))
                    word in types -> tokens.add(SyntaxToken(word, SyntaxTokenType.TYPE))
                    i + word.length < chars.size && chars[i + word.length] == '(' ->
                        tokens.add(SyntaxToken(word, SyntaxTokenType.FUNCTION))
                    word.first().isUpperCase() && types.isNotEmpty() ->
                        tokens.add(SyntaxToken(word, SyntaxTokenType.TYPE))
                    else -> tokens.add(SyntaxToken(word, SyntaxTokenType.PLAIN))
                }
                i += word.length
                continue
            }

            // Operators and punctuation
            if (chars[i] in "{}[]().,;:+-*/%=<>!&|^~?") {
                tokens.add(SyntaxToken(chars[i].toString(), SyntaxTokenType.PUNCTUATION))
                i++
                continue
            }

            // Whitespace
            val ws = consumeWhitespace(chars, i)
            if (ws.isNotEmpty()) {
                tokens.add(SyntaxToken(ws, SyntaxTokenType.PLAIN))
                i += ws.length
            } else {
                tokens.add(SyntaxToken(chars[i].toString(), SyntaxTokenType.PLAIN))
                i++
            }
        }

        return tokens
    }

    // endregion

    // region JSON Highlighter

    private fun highlightJSON(line: String): List<SyntaxToken> {
        val tokens = mutableListOf<SyntaxToken>()
        val chars = line.toCharArray()
        var i = 0

        while (i < chars.size) {
            if (chars[i] == '"') {
                val str = consumeString(chars, i, '"')
                val afterStr = i + str.length
                var j = afterStr
                while (j < chars.size && chars[j] == ' ') j++
                if (j < chars.size && chars[j] == ':') {
                    tokens.add(SyntaxToken(str, SyntaxTokenType.PROPERTY))
                } else {
                    tokens.add(SyntaxToken(str, SyntaxTokenType.STRING))
                }
                i += str.length
                continue
            }

            if (chars[i].isDigit() || chars[i] == '-') {
                val num = consumeNumber(chars, i)
                if (num.isNotEmpty() && num != "-") {
                    tokens.add(SyntaxToken(num, SyntaxTokenType.NUMBER))
                    i += num.length
                    continue
                }
            }

            val word = consumeWord(chars, i)
            if (word in setOf("true", "false", "null")) {
                tokens.add(SyntaxToken(word, SyntaxTokenType.KEYWORD))
                i += word.length
                continue
            }

            if (chars[i] in "{}[]:,") {
                tokens.add(SyntaxToken(chars[i].toString(), SyntaxTokenType.PUNCTUATION))
                i++
                continue
            }

            val ws = consumeWhitespace(chars, i)
            if (ws.isNotEmpty()) {
                tokens.add(SyntaxToken(ws, SyntaxTokenType.PLAIN))
                i += ws.length
            } else {
                tokens.add(SyntaxToken(chars[i].toString(), SyntaxTokenType.PLAIN))
                i++
            }
        }

        return tokens
    }

    // endregion

    // region XML/HTML Highlighter

    private fun highlightXML(line: String): List<SyntaxToken> {
        val tokens = mutableListOf<SyntaxToken>()
        val chars = line.toCharArray()
        var i = 0

        while (i < chars.size) {
            if (matchesPrefix(chars, i, "<!--")) {
                tokens.add(SyntaxToken(line.substring(i), SyntaxTokenType.COMMENT))
                return tokens
            }

            if (chars[i] == '<') {
                val sb = StringBuilder("<")
                i++
                while (i < chars.size && chars[i] != '>') {
                    if (chars[i] == '"') {
                        val str = consumeString(chars, i, '"')
                        tokens.add(SyntaxToken(sb.toString(), SyntaxTokenType.KEYWORD))
                        sb.clear()
                        tokens.add(SyntaxToken(str, SyntaxTokenType.STRING))
                        i += str.length
                        continue
                    }
                    sb.append(chars[i])
                    i++
                }
                if (i < chars.size) {
                    sb.append(chars[i])
                    i++
                }
                if (sb.isNotEmpty()) {
                    tokens.add(SyntaxToken(sb.toString(), SyntaxTokenType.KEYWORD))
                }
                continue
            }

            val sb = StringBuilder()
            while (i < chars.size && chars[i] != '<') {
                sb.append(chars[i])
                i++
            }
            if (sb.isNotEmpty()) {
                tokens.add(SyntaxToken(sb.toString(), SyntaxTokenType.PLAIN))
            }
        }

        return tokens
    }

    // endregion

    // region YAML Highlighter

    private fun highlightYAML(line: String): List<SyntaxToken> {
        val trimmed = line.trim()

        if (trimmed.startsWith("#")) {
            return listOf(SyntaxToken(line, SyntaxTokenType.COMMENT))
        }

        val colonIdx = line.indexOf(':')
        if (colonIdx >= 0) {
            val key = line.substring(0, colonIdx)
            val value = line.substring(colonIdx + 1)
            val trimmedValue = value.trim()

            val valueType = when {
                trimmedValue in setOf("true", "false", "null") -> SyntaxTokenType.KEYWORD
                trimmedValue.firstOrNull()?.isDigit() == true -> SyntaxTokenType.NUMBER
                else -> SyntaxTokenType.STRING
            }

            return listOf(
                SyntaxToken(key, SyntaxTokenType.PROPERTY),
                SyntaxToken(":", SyntaxTokenType.PUNCTUATION),
                SyntaxToken(value, valueType)
            )
        }

        return listOf(SyntaxToken(line, SyntaxTokenType.PLAIN))
    }

    // endregion

    // region CSS Highlighter

    private fun highlightCSS(line: String): List<SyntaxToken> {
        val trimmed = line.trim()
        if (trimmed.startsWith("/*") || trimmed.startsWith("*")) {
            return listOf(SyntaxToken(line, SyntaxTokenType.COMMENT))
        }

        val tokens = mutableListOf<SyntaxToken>()
        val chars = line.toCharArray()
        var i = 0

        while (i < chars.size) {
            if (chars[i] == '"' || chars[i] == '\'') {
                val str = consumeString(chars, i, chars[i])
                tokens.add(SyntaxToken(str, SyntaxTokenType.STRING))
                i += str.length
                continue
            }

            if (chars[i].isDigit() || (chars[i] == '.' && i + 1 < chars.size && chars[i + 1].isDigit())) {
                val num = consumeNumber(chars, i)
                val sb = StringBuilder(num)
                var j = i + num.length
                while (j < chars.size && chars[j].isLetter()) { sb.append(chars[j]); j++ }
                tokens.add(SyntaxToken(sb.toString(), SyntaxTokenType.NUMBER))
                i = j
                continue
            }

            if (chars[i] == '#' && i + 1 < chars.size && chars[i + 1].isLetterOrDigit()) {
                val sb = StringBuilder("#")
                var j = i + 1
                while (j < chars.size && chars[j].isLetterOrDigit()) { sb.append(chars[j]); j++ }
                tokens.add(SyntaxToken(sb.toString(), SyntaxTokenType.NUMBER))
                i = j
                continue
            }

            if (chars[i] in "{}();,:") {
                tokens.add(SyntaxToken(chars[i].toString(), SyntaxTokenType.PUNCTUATION))
                i++
                continue
            }

            if (chars[i].isLetter() || chars[i] == '-' || chars[i] == '_' || chars[i] == '.') {
                val sb = StringBuilder()
                var j = i
                while (j < chars.size && (chars[j].isLetterOrDigit() || chars[j] == '-' || chars[j] == '_' || chars[j] == '.')) {
                    sb.append(chars[j]); j++
                }
                val word = sb.toString()
                when {
                    word in CSS_KEYWORDS -> tokens.add(SyntaxToken(word, SyntaxTokenType.KEYWORD))
                    word.startsWith(".") || word.startsWith("#") -> tokens.add(SyntaxToken(word, SyntaxTokenType.TYPE))
                    else -> tokens.add(SyntaxToken(word, SyntaxTokenType.PROPERTY))
                }
                i = j
                continue
            }

            val ws = consumeWhitespace(chars, i)
            if (ws.isNotEmpty()) {
                tokens.add(SyntaxToken(ws, SyntaxTokenType.PLAIN))
                i += ws.length
            } else {
                tokens.add(SyntaxToken(chars[i].toString(), SyntaxTokenType.PLAIN))
                i++
            }
        }

        return tokens
    }

    // endregion

    // region Bash Highlighter

    private fun highlightBash(line: String): List<SyntaxToken> {
        val trimmed = line.trim()
        if (trimmed.startsWith("#")) {
            return listOf(SyntaxToken(line, SyntaxTokenType.COMMENT))
        }
        return highlightGeneric(line, BASH_KEYWORDS, emptySet(), "#")
    }

    // endregion

    // region Tokenizer Helpers

    private fun matchesPrefix(chars: CharArray, index: Int, prefix: String): Boolean {
        if (index + prefix.length > chars.size) return false
        for (j in prefix.indices) {
            if (chars[index + j] != prefix[j]) return false
        }
        return true
    }

    private fun consumeString(chars: CharArray, start: Int, quote: Char): String {
        val sb = StringBuilder()
        sb.append(chars[start])
        var i = start + 1
        while (i < chars.size) {
            sb.append(chars[i])
            if (chars[i] == quote && (i == start + 1 || chars[i - 1] != '\\')) break
            i++
        }
        return sb.toString()
    }

    private fun consumeWord(chars: CharArray, start: Int): String {
        val sb = StringBuilder()
        var i = start
        if (i < chars.size && chars[i] == '@') { sb.append(chars[i]); i++ }
        if (i < chars.size && chars[i] == '#' && sb.isEmpty()) { sb.append(chars[i]); i++ }
        while (i < chars.size && (chars[i].isLetterOrDigit() || chars[i] == '_' || chars[i] == '?')) {
            sb.append(chars[i]); i++
        }
        return sb.toString()
    }

    private fun consumeNumber(chars: CharArray, start: Int): String {
        val sb = StringBuilder()
        var i = start
        var hasDecimal = false

        if (i < chars.size && chars[i] == '-') { sb.append(chars[i]); i++ }

        if (i + 1 < chars.size && chars[i] == '0' && (chars[i + 1] == 'x' || chars[i + 1] == 'X')) {
            sb.append(chars[i]); sb.append(chars[i + 1]); i += 2
            while (i < chars.size && chars[i].isLetterOrDigit()) { sb.append(chars[i]); i++ }
            return sb.toString()
        }

        while (i < chars.size) {
            when {
                chars[i].isDigit() -> { sb.append(chars[i]); i++ }
                chars[i] == '.' && !hasDecimal && i + 1 < chars.size && chars[i + 1].isDigit() -> {
                    sb.append(chars[i]); hasDecimal = true; i++
                }
                (chars[i] == 'e' || chars[i] == 'E') && sb.isNotEmpty() -> {
                    sb.append(chars[i]); i++
                    if (i < chars.size && (chars[i] == '+' || chars[i] == '-')) { sb.append(chars[i]); i++ }
                }
                else -> break
            }
        }
        return sb.toString()
    }

    private fun consumeWhitespace(chars: CharArray, start: Int): String {
        val sb = StringBuilder()
        var i = start
        while (i < chars.size && chars[i].isWhitespace()) { sb.append(chars[i]); i++ }
        return sb.toString()
    }

    // endregion

    // region Language Keyword Sets

    private val SWIFT_KEYWORDS = setOf(
        "import", "struct", "class", "enum", "protocol", "extension", "func", "var", "let",
        "if", "else", "guard", "switch", "case", "default", "for", "while", "repeat",
        "return", "throw", "throws", "try", "catch", "do", "in", "where", "as", "is",
        "true", "false", "nil", "self", "Self", "super", "init", "deinit", "typealias",
        "static", "private", "public", "internal", "fileprivate", "open", "mutating",
        "override", "final", "weak", "unowned", "lazy", "some", "any", "async", "await",
        "@State", "@Binding", "@Published", "@ObservedObject", "@StateObject", "@Environment",
        "@EnvironmentObject", "@MainActor"
    )

    private val SWIFT_TYPES = setOf(
        "String", "Int", "Double", "Float", "Bool", "Array", "Dictionary", "Set", "Optional",
        "View", "Text", "VStack", "HStack", "ZStack", "Button", "Image", "Color",
        "NavigationView", "List", "ForEach", "Binding", "ObservableObject", "AnyView",
        "CGFloat", "CGSize", "CGRect", "URL", "Data", "Date", "Error", "Result", "Void"
    )

    private val KOTLIN_KEYWORDS = setOf(
        "package", "import", "class", "interface", "object", "fun", "val", "var",
        "if", "else", "when", "for", "while", "do", "return", "throw", "try", "catch",
        "finally", "in", "is", "as", "true", "false", "null", "this", "super",
        "private", "public", "internal", "protected", "open", "abstract", "sealed",
        "data", "enum", "companion", "override", "suspend", "inline", "crossinline",
        "noinline", "reified", "lateinit", "by", "lazy", "const", "typealias"
    )

    private val KOTLIN_TYPES = setOf(
        "String", "Int", "Long", "Double", "Float", "Boolean", "Unit", "Nothing",
        "List", "Map", "Set", "Array", "MutableList", "MutableMap", "MutableSet",
        "Pair", "Triple", "Result", "Sequence", "Any", "Comparable"
    )

    private val JAVA_KEYWORDS = setOf(
        "package", "import", "class", "interface", "enum", "extends", "implements",
        "public", "private", "protected", "static", "final", "abstract", "synchronized",
        "volatile", "transient", "native", "strictfp", "void", "new", "this", "super",
        "if", "else", "switch", "case", "default", "for", "while", "do", "break",
        "continue", "return", "throw", "throws", "try", "catch", "finally",
        "true", "false", "null", "instanceof", "assert"
    )

    private val JAVA_TYPES = setOf(
        "String", "Integer", "Long", "Double", "Float", "Boolean", "Character", "Byte",
        "Short", "Object", "Class", "List", "Map", "Set", "ArrayList", "HashMap",
        "Optional", "Stream", "Collection", "Iterable", "Comparable", "Runnable",
        "Thread", "Exception", "RuntimeException", "int", "long", "double", "float",
        "boolean", "char", "byte", "short"
    )

    private val JS_KEYWORDS = setOf(
        "import", "export", "from", "default", "function", "const", "let", "var",
        "if", "else", "switch", "case", "for", "while", "do", "break", "continue",
        "return", "throw", "try", "catch", "finally", "new", "delete", "typeof",
        "instanceof", "in", "of", "class", "extends", "super", "this",
        "true", "false", "null", "undefined", "void", "yield", "async", "await",
        "static", "get", "set", "constructor"
    )

    private val TS_KEYWORDS = JS_KEYWORDS + setOf(
        "type", "interface", "enum", "namespace", "module", "declare", "abstract",
        "implements", "readonly", "keyof", "infer", "as", "is", "never", "unknown",
        "any", "private", "public", "protected"
    )

    private val TS_TYPES = setOf(
        "string", "number", "boolean", "object", "symbol", "bigint", "void", "never",
        "unknown", "any", "undefined", "null", "Array", "Promise", "Record", "Partial",
        "Required", "Readonly", "Pick", "Omit", "Exclude", "Extract", "Map", "Set"
    )

    private val PYTHON_KEYWORDS = setOf(
        "import", "from", "as", "def", "class", "return", "yield", "lambda",
        "if", "elif", "else", "for", "while", "break", "continue", "pass",
        "try", "except", "finally", "raise", "with", "assert",
        "True", "False", "None", "and", "or", "not", "in", "is", "del",
        "global", "nonlocal", "async", "await", "self", "cls"
    )

    private val PYTHON_TYPES = setOf(
        "str", "int", "float", "bool", "list", "dict", "set", "tuple", "bytes",
        "type", "object", "Exception", "range", "enumerate", "zip", "map", "filter"
    )

    private val GO_KEYWORDS = setOf(
        "package", "import", "func", "var", "const", "type", "struct", "interface",
        "map", "chan", "if", "else", "switch", "case", "default", "for", "range",
        "break", "continue", "return", "go", "select", "defer", "fallthrough", "goto",
        "true", "false", "nil", "iota"
    )

    private val GO_TYPES = setOf(
        "string", "int", "int8", "int16", "int32", "int64",
        "uint", "uint8", "uint16", "uint32", "uint64",
        "float32", "float64", "complex64", "complex128",
        "bool", "byte", "rune", "error", "any"
    )

    private val RUST_KEYWORDS = setOf(
        "use", "mod", "pub", "fn", "let", "mut", "const", "static", "struct", "enum",
        "trait", "impl", "for", "if", "else", "match", "while", "loop", "break",
        "continue", "return", "as", "in", "ref", "move", "self", "Self", "super",
        "where", "async", "await", "unsafe", "extern", "crate", "type", "dyn",
        "true", "false"
    )

    private val RUST_TYPES = setOf(
        "i8", "i16", "i32", "i64", "i128", "isize",
        "u8", "u16", "u32", "u64", "u128", "usize",
        "f32", "f64", "bool", "char", "str",
        "String", "Vec", "Box", "Rc", "Arc", "Option", "Result",
        "HashMap", "HashSet", "BTreeMap", "BTreeSet"
    )

    private val BASH_KEYWORDS = setOf(
        "if", "then", "else", "elif", "fi", "case", "esac", "for", "while", "until",
        "do", "done", "in", "function", "return", "exit", "local", "export", "readonly",
        "declare", "typeset", "source", "echo", "printf", "read", "set", "unset",
        "shift", "test", "true", "false"
    )

    private val SQL_KEYWORDS = setOf(
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
    )

    private val SQL_TYPES = setOf(
        "INT", "INTEGER", "BIGINT", "SMALLINT", "TINYINT", "FLOAT", "DOUBLE", "DECIMAL",
        "NUMERIC", "VARCHAR", "CHAR", "TEXT", "BLOB", "DATE", "DATETIME", "TIMESTAMP",
        "BOOLEAN", "SERIAL", "UUID",
        "int", "integer", "bigint", "smallint", "tinyint", "float", "double", "decimal",
        "numeric", "varchar", "char", "text", "blob", "date", "datetime", "timestamp",
        "boolean", "serial", "uuid"
    )

    private val C_KEYWORDS = setOf(
        "auto", "break", "case", "char", "const", "continue", "default", "do",
        "double", "else", "enum", "extern", "float", "for", "goto", "if",
        "int", "long", "register", "return", "short", "signed", "sizeof", "static",
        "struct", "switch", "typedef", "union", "unsigned", "void", "volatile", "while",
        "true", "false", "NULL", "include", "define", "ifdef", "ifndef", "endif", "pragma"
    )

    private val CPP_KEYWORDS = C_KEYWORDS + setOf(
        "class", "namespace", "using", "template", "typename", "public", "private",
        "protected", "virtual", "override", "final", "new", "delete", "this",
        "throw", "try", "catch", "nullptr", "constexpr", "decltype",
        "static_cast", "dynamic_cast", "reinterpret_cast", "const_cast",
        "noexcept", "inline", "explicit", "friend", "operator", "bool",
        "cout", "cin", "endl", "std", "string", "vector", "map", "set"
    )

    private val CSS_KEYWORDS = setOf(
        "important", "inherit", "initial", "unset", "revert", "none", "auto",
        "block", "inline", "flex", "grid", "absolute", "relative", "fixed", "sticky",
        "solid", "dashed", "dotted", "hidden", "visible", "scroll", "wrap", "nowrap"
    )

    private val RUBY_KEYWORDS = setOf(
        "require", "include", "extend", "module", "class", "def", "end", "do",
        "if", "elsif", "else", "unless", "case", "when", "while", "until", "for",
        "begin", "rescue", "ensure", "raise", "return", "yield", "block_given?",
        "true", "false", "nil", "self", "super", "puts", "print", "attr_accessor",
        "attr_reader", "attr_writer", "private", "public", "protected", "new",
        "then", "and", "or", "not", "in", "lambda", "proc"
    )

    private val PHP_KEYWORDS = setOf(
        "namespace", "use", "class", "interface", "trait", "extends", "implements",
        "function", "public", "private", "protected", "static", "abstract", "final",
        "const", "var", "new", "return", "throw", "try", "catch", "finally",
        "if", "elseif", "else", "switch", "case", "default", "for", "foreach",
        "while", "do", "break", "continue", "echo", "print", "require", "include",
        "true", "false", "null", "self", "parent", "array", "list", "match",
        "fn", "yield", "as", "instanceof"
    )

    // endregion
}
