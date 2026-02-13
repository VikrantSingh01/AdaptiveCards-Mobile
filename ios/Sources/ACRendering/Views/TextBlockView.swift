import SwiftUI
import ACCore
import ACAccessibility
import ACMarkdown

struct TextBlockView: View {
    let textBlock: TextBlock
    let hostConfig: HostConfig

    @Environment(\.layoutDirection) var layoutDirection

    var body: some View {
        if textBlock.text.containsMarkdown {
            // Render with markdown support
            let tokens = MarkdownParser.parse(textBlock.text)
            let attributedString = MarkdownRenderer.render(
                tokens: tokens,
                font: font,
                color: foregroundColor
            )

            Text(attributedString)
                .multilineTextAlignment(textAlignment)
                .lineLimit(textBlock.maxLines)
                .frame(maxWidth: .infinity, alignment: frameAlignment)
                .spacing(textBlock.spacing, hostConfig: hostConfig)
                .separator(textBlock.separator, hostConfig: hostConfig)
                .accessibilityElement(label: textBlock.text)
        } else {
            // Render plain text
            Text(textBlock.text)
                .font(font)
                .foregroundColor(foregroundColor)
                .multilineTextAlignment(textAlignment)
                .lineLimit(textBlock.maxLines)
                .frame(maxWidth: .infinity, alignment: frameAlignment)
                .spacing(textBlock.spacing, hostConfig: hostConfig)
                .separator(textBlock.separator, hostConfig: hostConfig)
                .accessibilityElement(label: textBlock.text)
        }
    }

    private var font: Font {
        let size = fontSize
        let weight = fontWeight

        if textBlock.fontType == .monospace {
            return .system(size: CGFloat(size), weight: weight, design: .monospaced)
        } else {
            return .system(size: CGFloat(size), weight: weight)
        }
    }

    private var fontSize: Int {
        let fontSizeEnum = textBlock.size ?? .default
        switch fontSizeEnum {
        case .small:
            return hostConfig.fontSizes.small
        case .default:
            return hostConfig.fontSizes.default
        case .medium:
            return hostConfig.fontSizes.medium
        case .large:
            return hostConfig.fontSizes.large
        case .extraLarge:
            return hostConfig.fontSizes.extraLarge
        }
    }

    private var fontWeight: Font.Weight {
        let fontWeightEnum = textBlock.weight ?? .default
        let weightValue: Int

        switch fontWeightEnum {
        case .lighter:
            weightValue = hostConfig.fontWeights.lighter
        case .default:
            weightValue = hostConfig.fontWeights.default
        case .bolder:
            weightValue = hostConfig.fontWeights.bolder
        }

        switch weightValue {
        case 100...299:
            return .light
        case 300...399:
            return .regular
        case 400...599:
            return .medium
        case 600...799:
            return .semibold
        default:
            return .bold
        }
    }

    private var foregroundColor: Color {
        let color = textBlock.color ?? .default
        let containerStyle = ContainerStyle.default
        let styleConfig = hostConfig.containerStyles.default
        let colorConfig: ColorConfig

        switch color {
        case .default:
            colorConfig = styleConfig.foregroundColors.default
        case .dark:
            colorConfig = styleConfig.foregroundColors.dark
        case .light:
            colorConfig = styleConfig.foregroundColors.light
        case .accent:
            colorConfig = styleConfig.foregroundColors.accent
        case .good:
            colorConfig = styleConfig.foregroundColors.good
        case .warning:
            colorConfig = styleConfig.foregroundColors.warning
        case .attention:
            colorConfig = styleConfig.foregroundColors.attention
        }

        let hex = textBlock.isSubtle == true ? colorConfig.subtle : colorConfig.default
        return Color(hex: hex)
    }

    private var textAlignment: TextAlignment {
        .from(textBlock.horizontalAlignment)
    }

    private var frameAlignment: Alignment {
        .from(
            horizontal: textBlock.horizontalAlignment,
            vertical: nil,
            layoutDirection: layoutDirection
        )
    }
}
