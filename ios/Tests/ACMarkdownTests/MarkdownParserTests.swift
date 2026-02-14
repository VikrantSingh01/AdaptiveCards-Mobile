import XCTest
@testable import ACMarkdown

final class MarkdownParserTests: XCTestCase {

    func testBoldParsing() {
        let tokens = MarkdownParser.parse("This is **bold** text")
        XCTAssertEqual(tokens.count, 3) // text, bold, text

        if case .bold(let text) = tokens[1] {
            XCTAssertEqual(text, "bold")
        } else {
            XCTFail("Expected bold token")
        }
    }

    func testItalicParsing() {
        let tokens = MarkdownParser.parse("This is *italic* text")
        XCTAssertEqual(tokens.count, 3) // text, italic, text

        if case .italic(let text) = tokens[1] {
            XCTAssertEqual(text, "italic")
        } else {
            XCTFail("Expected italic token")
        }
    }

    func testCodeParsing() {
        let tokens = MarkdownParser.parse("This is `code` text")
        XCTAssertEqual(tokens.count, 3) // text, code, text

        if case .code(let text) = tokens[1] {
            XCTAssertEqual(text, "code")
        } else {
            XCTFail("Expected code token")
        }
    }

    func testLinkParsing() {
        let tokens = MarkdownParser.parse("This is a [link](https://example.com)")

        var foundLink = false
        for token in tokens {
            if case .link(let text, let url) = token {
                XCTAssertEqual(text, "link")
                XCTAssertEqual(url, "https://example.com")
                foundLink = true
            }
        }
        XCTAssertTrue(foundLink, "Expected to find link token")
    }

    func testHeaderParsing() {
        let h1Tokens = MarkdownParser.parse("# Header 1")
        if case .header(let level, let text) = h1Tokens[0] {
            XCTAssertEqual(level, 1)
            XCTAssertEqual(text, "Header 1")
        } else {
            XCTFail("Expected header token")
        }

        let h2Tokens = MarkdownParser.parse("## Header 2")
        if case .header(let level, let text) = h2Tokens[0] {
            XCTAssertEqual(level, 2)
            XCTAssertEqual(text, "Header 2")
        } else {
            XCTFail("Expected header token")
        }
    }

    func testBulletListParsing() {
        let tokens = MarkdownParser.parse("- Item 1")

        if case .bulletItem(let text) = tokens[0] {
            XCTAssertEqual(text, "Item 1")
        } else {
            XCTFail("Expected bullet item token")
        }
    }

    func testNumberedListParsing() {
        let tokens = MarkdownParser.parse("1. First item")

        if case .numberedItem(let number, let text) = tokens[0] {
            XCTAssertEqual(number, 1)
            XCTAssertEqual(text, "First item")
        } else {
            XCTFail("Expected numbered item token")
        }
    }

    func testMixedMarkdown() {
        let tokens = MarkdownParser.parse("Mix **bold** and *italic* with `code`")
        XCTAssertTrue(tokens.count > 0)

        var hasBold = false
        var hasItalic = false
        var hasCode = false

        for token in tokens {
            if case .bold = token { hasBold = true }
            if case .italic = token { hasItalic = true }
            if case .code = token { hasCode = true }
        }

        XCTAssertTrue(hasBold, "Expected bold token")
        XCTAssertTrue(hasItalic, "Expected italic token")
        XCTAssertTrue(hasCode, "Expected code token")
    }

    func testEmptyString() {
        let tokens = MarkdownParser.parse("")
        XCTAssertEqual(tokens.count, 0)
    }

    func testPlainText() {
        let tokens = MarkdownParser.parse("Plain text without markdown")
        XCTAssertEqual(tokens.count, 1) // text

        if case .text(let text) = tokens[0] {
            XCTAssertEqual(text, "Plain text without markdown")
        } else {
            XCTFail("Expected text token")
        }
    }

    func testCaching() {
        let text = "This is **cached** text"

        // Parse twice
        let tokens1 = MarkdownParser.parse(text)
        let tokens2 = MarkdownParser.parse(text)

        // Should return same tokens
        XCTAssertEqual(tokens1.count, tokens2.count)
    }

    // MARK: - URL Scheme Security Tests (GHSA-r5qq-54gp-7gcx)

    func testSafeUrlSchemes() {
        XCTAssertTrue(MarkdownRenderer.isSafeUrl(URL(string: "https://example.com")!))
        XCTAssertTrue(MarkdownRenderer.isSafeUrl(URL(string: "http://example.com")!))
        XCTAssertTrue(MarkdownRenderer.isSafeUrl(URL(string: "mailto:user@example.com")!))
        XCTAssertTrue(MarkdownRenderer.isSafeUrl(URL(string: "tel:+1234567890")!))
    }

    func testBlocksJavascriptScheme() {
        let url = URL(string: "javascript:alert('XSS')")!
        XCTAssertFalse(MarkdownRenderer.isSafeUrl(url))
    }

    func testBlocksDataScheme() {
        let url = URL(string: "data:text/html,<script>alert('XSS')</script>")!
        XCTAssertFalse(MarkdownRenderer.isSafeUrl(url))
    }

    func testBlocksFileScheme() {
        let url = URL(string: "file:///etc/passwd")!
        XCTAssertFalse(MarkdownRenderer.isSafeUrl(url))
    }

    func testBlocksCustomAppScheme() {
        let url = URL(string: "myapp://deeplink/action")!
        XCTAssertFalse(MarkdownRenderer.isSafeUrl(url))
    }

    func testBlocksVbscriptScheme() {
        if let url = URL(string: "vbscript:msgbox('XSS')") {
            XCTAssertFalse(MarkdownRenderer.isSafeUrl(url))
        }
    }

    func testRendererStripsUnsafeLink() {
        let tokens = MarkdownParser.parse("[click](javascript:alert('XSS'))")
        let rendered = MarkdownRenderer.render(tokens: tokens)

        // The rendered text should contain the display text but NOT be a clickable link
        let fullText = String(rendered.characters)
        XCTAssertTrue(fullText.contains("click"))

        // Verify no link attribute is set on the rendered string
        var hasLink = false
        for run in rendered.runs {
            if run.link != nil {
                hasLink = true
            }
        }
        XCTAssertFalse(hasLink, "Unsafe URL should not produce a clickable link")
    }

    func testRendererAllowsSafeLink() {
        let tokens = MarkdownParser.parse("[click](https://example.com)")
        let rendered = MarkdownRenderer.render(tokens: tokens)

        var hasLink = false
        for run in rendered.runs {
            if run.link != nil {
                hasLink = true
            }
        }
        XCTAssertTrue(hasLink, "Safe URL should produce a clickable link")
    }
}
