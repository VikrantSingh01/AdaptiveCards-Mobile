// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
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

        for inline in richTextBlock.inlines {
            switch inline {
            case .textRun(let textRun):
                result.append(attributedString(for: textRun))
            case .citationRun(let citationRun):
                result.append(attributedString(for: citationRun))
            }
        }

        return result
    }

    private func attributedString(for textRun: TextRun) -> AttributedString {
        let expandedText = DateTimeMacroExpander.expand(textRun.text)
        var runText = AttributedString(expandedText)

        let size = fontSize(for: textRun)
        #if canImport(UIKit)
        let weight = uiFontWeight(for: textRun)
        runText.font = Font(UIFont.systemFont(ofSize: CGFloat(size), weight: weight))
        #else
        runText.font = .system(size: CGFloat(size), weight: swiftUIFontWeight(for: textRun))
        #endif

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

        // Highlight support — use HostConfig highlightColors for the active color slot
        if textRun.highlight == true {
            runText.backgroundColor = highlightColor(for: textRun)
        }

        // Link styling for text runs with selectAction
        if textRun.selectAction != nil {
            runText.underlineStyle = .single
            runText.foregroundColor = foregroundColor(for: TextRun(text: textRun.text, color: .accent))
        }

        return runText
    }

    private func attributedString(for citationRun: CitationRun) -> AttributedString {
        let badgeText = "[\(citationRun.referenceIndex)]"
        var runText = AttributedString(badgeText)

        // Render as a small superscript-style badge with accent color
        let accentColor = hostConfig.containerStyles.default.foregroundColors.accent
        let hex = accentColor.default
        runText.foregroundColor = Color(hex: hex)

        let smallSize = hostConfig.fontSizes.small
        #if canImport(UIKit)
        runText.font = Font(UIFont.systemFont(ofSize: CGFloat(smallSize), weight: .semibold))
        #else
        runText.font = .system(size: CGFloat(smallSize), weight: .semibold)
        #endif

        runText.baselineOffset = 4.0

        return runText
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
        case 100...199:
            return .ultraLight
        case 200...299:
            return .light
        case 300...399:
            return .regular
        case 400...499:
            return .regular
        case 500...599:
            return .medium
        case 600...699:
            return .semibold
        case 700...799:
            return .bold
        default:
            return .heavy
        }
    }

    private func swiftUIFontWeight(for textRun: TextRun) -> Font.Weight {
        let fontWeightEnum = textRun.weight ?? .default
        switch fontWeightEnum {
        case .lighter: return .light
        case .default: return .regular
        case .bolder: return .bold
        }
    }

    #if canImport(UIKit)
    private func uiFontWeight(for textRun: TextRun) -> UIFont.Weight {
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
        case 100...199:
            return .ultraLight
        case 200...299:
            return .light
        case 300...399:
            return .regular
        case 400...499:
            return .regular
        case 500...599:
            return .medium
        case 600...699:
            return .semibold
        case 700...799:
            return .bold
        default:
            return .heavy
        }
    }
    #endif

    private func highlightColor(for textRun: TextRun) -> Color {
        let color = textRun.color ?? .default
        let styleConfig = hostConfig.containerStyles.default
        let colorConfig: ColorConfig

        switch color {
        case .default: colorConfig = styleConfig.foregroundColors.default
        case .dark: colorConfig = styleConfig.foregroundColors.dark
        case .light: colorConfig = styleConfig.foregroundColors.light
        case .accent: colorConfig = styleConfig.foregroundColors.accent
        case .good: colorConfig = styleConfig.foregroundColors.good
        case .warning: colorConfig = styleConfig.foregroundColors.warning
        case .attention: colorConfig = styleConfig.foregroundColors.attention
        }

        let hex = textRun.isSubtle == true ? colorConfig.highlightColors.subtle : colorConfig.highlightColors.default
        return Color(hex: hex)
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

    private func textRunForFontCalc(_ inline: InlineElement) -> TextRun? {
        if case .textRun(let run) = inline { return run }
        return nil
    }
}
