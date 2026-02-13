import SwiftUI

/// A SwiftUI view that renders markdown text with proper styling
public struct MarkdownTextView: View {
    private let text: String
    private let font: Font
    private let color: Color

    /// Create a new MarkdownTextView
    /// - Parameters:
    ///   - text: The markdown text to render
    ///   - font: Base font to use (default: .body)
    ///   - color: Base text color (default: .primary)
    public init(
        _ text: String,
        font: Font = .body,
        color: Color = .primary
    ) {
        self.text = text
        self.font = font
        self.color = color
    }

    public var body: some View {
        let tokens = MarkdownParser.parse(text)
        let attributedString = MarkdownRenderer.render(tokens: tokens, font: font, color: color)

        Text(attributedString)
    }
}

/// Helper to detect if text contains markdown syntax
public extension String {
    /// Static regex for numbered list detection (reused for performance)
    private static let numberedListRegex = try? NSRegularExpression(
        pattern: #"^\d+\.\s"#,
        options: []
    )

    /// Check if the string contains markdown syntax
    var containsMarkdown: Bool {
        // Check for inline formatting
        if self.contains("*") || self.contains("[") || self.contains("`") {
            return true
        }

        // Check for headers
        if self.hasPrefix("#") {
            return true
        }

        // Check for bullet lists
        if self.hasPrefix("- ") {
            return true
        }

        // Check for numbered lists (must start with digit followed by ". ")
        if let regex = String.numberedListRegex,
           regex.firstMatch(in: self, range: NSRange(self.startIndex..., in: self)) != nil {
            return true
        }

        return false
    }
}

#if DEBUG
struct MarkdownTextView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 16) {
            MarkdownTextView("This is **bold** text")
            MarkdownTextView("This is *italic* text")
            MarkdownTextView("This is `code` text")
            MarkdownTextView("This is a [link](https://example.com)")
            MarkdownTextView("# Header 1")
            MarkdownTextView("## Header 2")
            MarkdownTextView("### Header 3")
            MarkdownTextView("- Bullet item 1")
            MarkdownTextView("1. Numbered item")
            MarkdownTextView("Mix **bold** and *italic* with `code`")
        }
        .padding()
    }
}
#endif
