import SwiftUI

/// Renders markdown tokens to AttributedString for SwiftUI Text views
public class MarkdownRenderer {

    /// Convert markdown tokens to AttributedString
    /// - Parameters:
    ///   - tokens: The parsed markdown tokens
    ///   - font: Base font to use
    ///   - color: Base text color
    /// - Returns: AttributedString with markdown styling applied
    public static func render(
        tokens: [MarkdownToken],
        font: Font = .body,
        color: Color = .primary
    ) -> AttributedString {
        var result = AttributedString()

        for token in tokens {
            let attributed = renderToken(token, font: font, color: color)
            result.append(attributed)
        }

        return result
    }

    private static func renderToken(
        _ token: MarkdownToken,
        font: Font,
        color: Color
    ) -> AttributedString {
        switch token {
        case .text(let text):
            var attributed = AttributedString(text)
            attributed.font = font
            attributed.foregroundColor = color
            return attributed

        case .bold(let text):
            var attributed = AttributedString(text)
            attributed.font = font.bold()
            attributed.foregroundColor = color
            return attributed

        case .italic(let text):
            var attributed = AttributedString(text)
            attributed.font = font.italic()
            attributed.foregroundColor = color
            return attributed

        case .code(let text):
            var attributed = AttributedString(text)
            attributed.font = .system(.body, design: .monospaced)
            attributed.foregroundColor = color
            attributed.backgroundColor = Color.gray.opacity(0.2)
            return attributed

        case .link(let text, let url):
            var attributed = AttributedString(text)
            attributed.font = font
            attributed.foregroundColor = .blue
            attributed.underlineStyle = .single
            if let url = URL(string: url) {
                attributed.link = url
            }
            return attributed

        case .header(let level, let text):
            var attributed = AttributedString(text)
            let fontSize: Font = switch level {
            case 1: .title
            case 2: .title2
            case 3: .title3
            default: .body
            }
            attributed.font = fontSize.bold()
            attributed.foregroundColor = color
            return attributed

        case .bulletItem(let text):
            var attributed = AttributedString("• \(text)")
            attributed.font = font
            attributed.foregroundColor = color
            return attributed

        case .numberedItem(let number, let text):
            var attributed = AttributedString("\(number). \(text)")
            attributed.font = font
            attributed.foregroundColor = color
            return attributed

        case .lineBreak:
            return AttributedString("\n")
        }
    }
}
