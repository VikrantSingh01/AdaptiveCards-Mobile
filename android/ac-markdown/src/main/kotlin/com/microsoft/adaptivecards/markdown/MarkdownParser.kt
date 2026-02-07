package com.microsoft.adaptivecards.markdown

import androidx.collection.LruCache

/**
 * Represents a parsed markdown token
 */
sealed class MarkdownToken {
    data class Text(val text: String) : MarkdownToken()
    data class Bold(val text: String) : MarkdownToken()
    data class Italic(val text: String) : MarkdownToken()
    data class Code(val text: String) : MarkdownToken()
    data class Link(val text: String, val url: String) : MarkdownToken()
    data class Header(val level: Int, val text: String) : MarkdownToken()
    data class BulletItem(val text: String) : MarkdownToken()
    data class NumberedItem(val number: Int, val text: String) : MarkdownToken()
    object LineBreak : MarkdownToken()
}

/**
 * Parses a subset of markdown syntax into structured tokens
 */
class MarkdownParser private constructor() {
    
    companion object {
        private val cache = LruCache<String, List<MarkdownToken>>(100)
        
        /**
         * Parse markdown text into tokens
         * @param text The markdown text to parse
         * @return List of parsed tokens
         */
        fun parse(text: String): List<MarkdownToken> {
            // Check cache first
            cache.get(text)?.let { return it }
            
            val parser = MarkdownParser()
            val tokens = parser.parseText(text)
            
            // Cache the result
            cache.put(text, tokens)
            
            return tokens
        }
    }
    
    private fun parseText(text: String): List<MarkdownToken> {
        val tokens = mutableListOf<MarkdownToken>()
        val lines = text.lines()
        
        for (line in lines) {
            if (line.isEmpty()) {
                tokens.add(MarkdownToken.LineBreak)
                continue
            }
            
            // Check for headers
            if (line.startsWith("#")) {
                parseHeader(line)?.let {
                    tokens.add(it)
                    continue
                }
            }
            
            // Check for bullet list
            if (line.startsWith("- ")) {
                val content = line.substring(2)
                tokens.add(MarkdownToken.BulletItem(content))
                continue
            }
            
            // Check for numbered list
            parseNumberedList(line)?.let {
                tokens.add(it)
                continue
            }
            
            // Parse inline markdown
            tokens.addAll(parseInlineMarkdown(line))
            tokens.add(MarkdownToken.LineBreak)
        }
        
        // Remove trailing line breaks
        while (tokens.lastOrNull() is MarkdownToken.LineBreak) {
            tokens.removeAt(tokens.lastIndex)
        }
        
        return tokens
    }
    
    private fun parseHeader(line: String): MarkdownToken? {
        var level = 0
        var index = 0
        
        while (index < line.length && line[index] == '#') {
            level++
            index++
        }
        
        if (level == 0 || level > 3) return null
        
        // Skip whitespace after #
        while (index < line.length && line[index].isWhitespace()) {
            index++
        }
        
        val text = line.substring(index)
        return MarkdownToken.Header(level, text)
    }
    
    private fun parseNumberedList(line: String): MarkdownToken? {
        // Pattern: "1. text"
        val pattern = Regex("""^(\d+)\.\s+(.+)$""")
        val match = pattern.matchEntire(line) ?: return null
        
        val number = match.groupValues[1].toIntOrNull() ?: return null
        val content = match.groupValues[2]
        
        return MarkdownToken.NumberedItem(number, content)
    }
    
    private fun parseInlineMarkdown(line: String): List<MarkdownToken> {
        val tokens = mutableListOf<MarkdownToken>()
        var currentText = StringBuilder()
        var i = 0
        
        while (i < line.length) {
            val char = line[i]
            
            // Check for bold **text**
            if (char == '*' && i < line.length - 1 && line[i + 1] == '*') {
                extractDelimited(line, i, "**")?.let { (text, endIndex) ->
                    if (currentText.isNotEmpty()) {
                        tokens.add(MarkdownToken.Text(currentText.toString()))
                        currentText = StringBuilder()
                    }
                    tokens.add(MarkdownToken.Bold(text))
                    i = endIndex
                    return@let
                } ?: run {
                    currentText.append(char)
                    i++
                    return@run
                }
                continue
            }
            
            // Check for italic *text*
            if (char == '*') {
                extractDelimited(line, i, "*")?.let { (text, endIndex) ->
                    if (currentText.isNotEmpty()) {
                        tokens.add(MarkdownToken.Text(currentText.toString()))
                        currentText = StringBuilder()
                    }
                    tokens.add(MarkdownToken.Italic(text))
                    i = endIndex
                    return@let
                } ?: run {
                    currentText.append(char)
                    i++
                    return@run
                }
                continue
            }
            
            // Check for inline code `code`
            if (char == '`') {
                extractDelimited(line, i, "`")?.let { (text, endIndex) ->
                    if (currentText.isNotEmpty()) {
                        tokens.add(MarkdownToken.Text(currentText.toString()))
                        currentText = StringBuilder()
                    }
                    tokens.add(MarkdownToken.Code(text))
                    i = endIndex
                    return@let
                } ?: run {
                    currentText.append(char)
                    i++
                    return@run
                }
                continue
            }
            
            // Check for link [text](url)
            if (char == '[') {
                extractLink(line, i)?.let { (text, url, endIndex) ->
                    if (currentText.isNotEmpty()) {
                        tokens.add(MarkdownToken.Text(currentText.toString()))
                        currentText = StringBuilder()
                    }
                    tokens.add(MarkdownToken.Link(text, url))
                    i = endIndex
                    return@let
                } ?: run {
                    currentText.append(char)
                    i++
                    return@run
                }
                continue
            }
            
            currentText.append(char)
            i++
        }
        
        if (currentText.isNotEmpty()) {
            tokens.add(MarkdownToken.Text(currentText.toString()))
        }
        
        return tokens
    }
    
    private fun extractDelimited(text: String, startIndex: Int, delimiter: String): Pair<String, Int>? {
        val delimiterLength = delimiter.length
        var searchStart = startIndex + delimiterLength
        
        if (searchStart >= text.length) return null
        
        // Find closing delimiter
        while (searchStart <= text.length - delimiterLength) {
            if (text.substring(searchStart, searchStart + delimiterLength) == delimiter) {
                val content = text.substring(startIndex + delimiterLength, searchStart)
                val endIndex = searchStart + delimiterLength
                return Pair(content, endIndex)
            }
            searchStart++
        }
        
        return null
    }
    
    private fun extractLink(text: String, startIndex: Int): Triple<String, String, Int>? {
        // Pattern: [text](url)
        var i = startIndex + 1
        val linkText = StringBuilder()
        
        // Extract link text
        while (i < text.length && text[i] != ']') {
            linkText.append(text[i])
            i++
        }
        
        if (i >= text.length || text[i] != ']') return null
        i++
        
        if (i >= text.length || text[i] != '(') return null
        i++
        
        val linkUrl = StringBuilder()
        while (i < text.length && text[i] != ')') {
            linkUrl.append(text[i])
            i++
        }
        
        if (i >= text.length || text[i] != ')') return null
        i++
        
        return Triple(linkText.toString(), linkUrl.toString(), i)
    }
}

/**
 * Helper extension to detect if text contains markdown syntax
 */
fun String.containsMarkdown(): Boolean {
    return this.contains("*") ||
           this.contains("[") ||
           this.contains("`") ||
           this.startsWith("#") ||
           this.startsWith("- ") ||
           this.matches(Regex(""".*\d+\.\s+.*"""))
}
