package com.microsoft.adaptivecards.markdown

import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test

class MarkdownParserTest {
    
    @Test
    fun `test bold parsing`() {
        val tokens = MarkdownParser.parse("This is **bold** text")
        assertTrue(tokens.size >= 3)
        
        val boldToken = tokens.find { it is MarkdownToken.Bold }
        assertNotNull(boldToken)
        assertTrue(boldToken is MarkdownToken.Bold)
        assertEquals("bold", (boldToken as MarkdownToken.Bold).text)
    }
    
    @Test
    fun `test italic parsing`() {
        val tokens = MarkdownParser.parse("This is *italic* text")
        assertTrue(tokens.size >= 3)
        
        val italicToken = tokens.find { it is MarkdownToken.Italic }
        assertNotNull(italicToken)
        assertTrue(italicToken is MarkdownToken.Italic)
        assertEquals("italic", (italicToken as MarkdownToken.Italic).text)
    }
    
    @Test
    fun `test code parsing`() {
        val tokens = MarkdownParser.parse("This is `code` text")
        assertTrue(tokens.size >= 3)
        
        val codeToken = tokens.find { it is MarkdownToken.Code }
        assertNotNull(codeToken)
        assertTrue(codeToken is MarkdownToken.Code)
        assertEquals("code", (codeToken as MarkdownToken.Code).text)
    }
    
    @Test
    fun `test link parsing`() {
        val tokens = MarkdownParser.parse("This is a [link](https://example.com)")
        
        val linkToken = tokens.find { it is MarkdownToken.Link }
        assertNotNull(linkToken)
        assertTrue(linkToken is MarkdownToken.Link)
        assertEquals("link", (linkToken as MarkdownToken.Link).text)
        assertEquals("https://example.com", linkToken.url)
    }
    
    @Test
    fun `test header parsing`() {
        val h1Tokens = MarkdownParser.parse("# Header 1")
        val h1Token = h1Tokens[0]
        assertTrue(h1Token is MarkdownToken.Header)
        assertEquals(1, (h1Token as MarkdownToken.Header).level)
        assertEquals("Header 1", h1Token.text)
        
        val h2Tokens = MarkdownParser.parse("## Header 2")
        val h2Token = h2Tokens[0]
        assertTrue(h2Token is MarkdownToken.Header)
        assertEquals(2, (h2Token as MarkdownToken.Header).level)
        assertEquals("Header 2", h2Token.text)
    }
    
    @Test
    fun `test bullet list parsing`() {
        val tokens = MarkdownParser.parse("- Item 1")
        
        val bulletToken = tokens[0]
        assertTrue(bulletToken is MarkdownToken.BulletItem)
        assertEquals("Item 1", (bulletToken as MarkdownToken.BulletItem).text)
    }
    
    @Test
    fun `test numbered list parsing`() {
        val tokens = MarkdownParser.parse("1. First item")
        
        val numberedToken = tokens[0]
        assertTrue(numberedToken is MarkdownToken.NumberedItem)
        assertEquals(1, (numberedToken as MarkdownToken.NumberedItem).number)
        assertEquals("First item", numberedToken.text)
    }
    
    @Test
    fun `test mixed markdown`() {
        val tokens = MarkdownParser.parse("Mix **bold** and *italic* with `code`")
        assertTrue(tokens.isNotEmpty())
        
        val hasBold = tokens.any { it is MarkdownToken.Bold }
        val hasItalic = tokens.any { it is MarkdownToken.Italic }
        val hasCode = tokens.any { it is MarkdownToken.Code }
        
        assertTrue(hasBold, "Expected bold token")
        assertTrue(hasItalic, "Expected italic token")
        assertTrue(hasCode, "Expected code token")
    }
    
    @Test
    fun `test empty string`() {
        val tokens = MarkdownParser.parse("")
        assertEquals(0, tokens.size)
    }
    
    @Test
    fun `test plain text`() {
        val tokens = MarkdownParser.parse("Plain text without markdown")
        assertTrue(tokens.size >= 1)
        
        val textToken = tokens[0]
        assertTrue(textToken is MarkdownToken.Text)
        assertEquals("Plain text without markdown", (textToken as MarkdownToken.Text).text)
    }
    
    @Test
    fun `test caching`() {
        val text = "This is **cached** text"
        
        // Parse twice
        val tokens1 = MarkdownParser.parse(text)
        val tokens2 = MarkdownParser.parse(text)
        
        // Should return same tokens
        assertEquals(tokens1.size, tokens2.size)
    }
    
    @Test
    fun `test containsMarkdown extension`() {
        assertTrue("This is **bold**".containsMarkdown())
        assertTrue("This is *italic*".containsMarkdown())
        assertTrue("This is `code`".containsMarkdown())
        assertTrue("[link](url)".containsMarkdown())
        assertTrue("# Header".containsMarkdown())
        assertTrue("- bullet".containsMarkdown())
        assertTrue("1. numbered".containsMarkdown())
        assertFalse("Plain text".containsMarkdown())
    }

    // URL Scheme Security Tests (GHSA-r5qq-54gp-7gcx)

    @Test
    fun `test safe URL schemes are allowed`() {
        assertTrue(MarkdownRenderer.isSafeUrl("https://example.com"))
        assertTrue(MarkdownRenderer.isSafeUrl("http://example.com"))
        assertTrue(MarkdownRenderer.isSafeUrl("mailto:user@example.com"))
        assertTrue(MarkdownRenderer.isSafeUrl("tel:+1234567890"))
    }

    @Test
    fun `test javascript scheme is blocked`() {
        assertFalse(MarkdownRenderer.isSafeUrl("javascript:alert('XSS')"))
    }

    @Test
    fun `test data scheme is blocked`() {
        assertFalse(MarkdownRenderer.isSafeUrl("data:text/html,<script>alert('XSS')</script>"))
    }

    @Test
    fun `test file scheme is blocked`() {
        assertFalse(MarkdownRenderer.isSafeUrl("file:///etc/passwd"))
    }

    @Test
    fun `test custom app scheme is blocked`() {
        assertFalse(MarkdownRenderer.isSafeUrl("myapp://deeplink/action"))
    }

    @Test
    fun `test vbscript scheme is blocked`() {
        assertFalse(MarkdownRenderer.isSafeUrl("vbscript:msgbox('XSS')"))
    }

    @Test
    fun `test renderer strips unsafe link annotation`() {
        val tokens = MarkdownParser.parse("[click](javascript:alert('XSS'))")
        val rendered = MarkdownRenderer.render(tokens)

        // Text content should be present
        assertTrue(rendered.text.contains("click"))

        // No URL annotation should exist for unsafe schemes
        val annotations = rendered.getStringAnnotations(tag = "URL", start = 0, end = rendered.length)
        assertTrue(annotations.isEmpty(), "Unsafe URL should not produce a URL annotation")
    }

    @Test
    fun `test renderer keeps safe link annotation`() {
        val tokens = MarkdownParser.parse("[click](https://example.com)")
        val rendered = MarkdownRenderer.render(tokens)

        val annotations = rendered.getStringAnnotations(tag = "URL", start = 0, end = rendered.length)
        assertTrue(annotations.isNotEmpty(), "Safe URL should produce a URL annotation")
        assertEquals("https://example.com", annotations.first().item)
    }

    @Test
    fun `test schemeless URL is blocked`() {
        assertFalse(MarkdownRenderer.isSafeUrl("no-scheme-url"))
    }
}
