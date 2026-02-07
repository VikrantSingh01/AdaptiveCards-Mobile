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
    /// Check if the string contains markdown syntax
    var containsMarkdown: Bool {
        return self.contains("*") ||
               self.contains("[") ||
               self.contains("`") ||
               self.hasPrefix("#") ||
               self.hasPrefix("- ") ||
               self.contains(where: { $0.isNumber }) && self.contains(". ")
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
