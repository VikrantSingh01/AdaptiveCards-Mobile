import SwiftUI
import ACCore
import ACAccessibility

struct RichTextBlockView: View {
    let richTextBlock: RichTextBlock
    let hostConfig: HostConfig

    @Environment(\.layoutDirection) var layoutDirection

    var body: some View {
        Text(attributedText)
            .multilineTextAlignment(textAlignment)
            .frame(maxWidth: .infinity, alignment: frameAlignment)
            .spacing(richTextBlock.spacing, hostConfig: hostConfig)
            .separator(richTextBlock.separator, hostConfig: hostConfig)
            .accessibilityElement(label: plainText)
    }

    private var attributedText: AttributedString {
        var result = AttributedString()

        for textRun in richTextBlock.inlines {
            var runText = AttributedString(textRun.text)

            // Apply font size
            let size = fontSize(for: textRun)
            runText.font = .system(size: CGFloat(size), weight: fontWeight(for: textRun))

            // Apply color
            runText.foregroundColor = foregroundColor(for: textRun)

            // Apply text styling
            if textRun.italic == true {
                runText.font = runText.font?.italic()
            }
            if textRun.strikethrough == true {
                runText.strikethroughStyle = .single
            }
            if textRun.underline == true {
                runText.underlineStyle = .single
            }

            result.append(runText)
        }

        return result
    }

    private func fontSize(for textRun: TextRun) -> Int {
        let fontSizeEnum = textRun.size ?? .default
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

    private func fontWeight(for textRun: TextRun) -> Font.Weight {
        let fontWeightEnum = textRun.weight ?? .default
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

    private func foregroundColor(for textRun: TextRun) -> Color {
        let color = textRun.color ?? .default
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

        let hex = textRun.isSubtle == true ? colorConfig.subtle : colorConfig.default
        return Color(hex: hex)
    }

    private var textAlignment: TextAlignment {
        .from(richTextBlock.horizontalAlignment)
    }

    private var frameAlignment: Alignment {
        .from(
            horizontal: richTextBlock.horizontalAlignment,
            vertical: nil,
            layoutDirection: layoutDirection
        )
    }

    private var plainText: String {
        richTextBlock.inlines.map { $0.text }.joined()
    }
}
