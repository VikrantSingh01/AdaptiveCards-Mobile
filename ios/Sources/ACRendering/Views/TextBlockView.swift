// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import ACCore
import ACAccessibility
import ACMarkdown

struct TextBlockView: View {
    let textBlock: TextBlock
    let hostConfig: HostConfig

    @Environment(\.layoutDirection) var layoutDirection
    @Environment(\.tableCellHorizontalAlignment) var tableCellAlignment
    @Environment(\.isInsideTableCell) var isInsideTableCell

    private var displayText: String {
        let raw = textBlock.text ?? ""
        let expanded = DateTimeMacroExpander.expand(raw)
        // AC spec: literal \n in text should render as line breaks
        return expanded.replacingOccurrences(of: "\\n", with: "\n")
    }

    var body: some View {
        if displayText.containsMarkdown {
            // Render with markdown support
            let tokens = MarkdownParser.parse(displayText)
            let attributedString = MarkdownRenderer.render(
                tokens: tokens,
                font: font,
                color: foregroundColor
            )

            Text(attributedString)
                .multilineTextAlignment(textAlignment)
                .lineLimit(effectiveLineLimit)
                .frame(maxWidth: .infinity, alignment: frameAlignment)
                .if(textBlock.wrap == true || isInsideTableCell) { view in
                    view.fixedSize(horizontal: false, vertical: true)
                }
                .spacing(textBlock.spacing, hostConfig: hostConfig)
                .separator(textBlock.separator, hostConfig: hostConfig)
                .accessibilityElement(label: displayText)
                .if(textBlock.style == .heading || textBlock.style == .columnHeader) { view in
                    view.accessibilityAddTraits(.isHeader)
                }
        } else {
            // Render plain text
            Text(displayText)
                .font(font)
                .foregroundColor(foregroundColor)
                .lineSpacing(lineSpacing)
                .multilineTextAlignment(textAlignment)
                .lineLimit(effectiveLineLimit)
                .frame(maxWidth: .infinity, alignment: frameAlignment)
                .if(textBlock.wrap == true || isInsideTableCell) { view in
                    view.fixedSize(horizontal: false, vertical: true)
                }
                .spacing(textBlock.spacing, hostConfig: hostConfig)
                .separator(textBlock.separator, hostConfig: hostConfig)
                .accessibilityElement(label: displayText)
                .if(textBlock.style == .heading || textBlock.style == .columnHeader) { view in
                    view.accessibilityAddTraits(.isHeader)
                }
        }
    }

    private var font: Font {
        let size = CGFloat(fontSize)

        #if canImport(UIKit)
        let weight = uiFontWeight
        if textBlock.fontType == .monospace {
            return Font(UIFont.monospacedSystemFont(ofSize: size, weight: weight))
        } else {
            return Font(UIFont.systemFont(ofSize: size, weight: weight))
        }
        #else
        let weight = swiftUIFontWeight
        if textBlock.fontType == .monospace {
            return .system(size: size, weight: weight, design: .monospaced)
        } else {
            return .system(size: size, weight: weight)
        }
        #endif
    }

    #if canImport(UIKit)
    private var uiFontWeight: UIFont.Weight {
        // Style-based overrides per AC v1.5 spec
        if textBlock.style == .heading || textBlock.style == .columnHeader {
            return .bold
        }

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

    private var swiftUIFontWeight: Font.Weight {
        return fontWeight
    }

    private var fontSize: Int {
        // Style-based overrides per AC v1.5 spec
        switch textBlock.style {
        case .heading:
            return hostConfig.fontSizes.large
        case .columnHeader:
            return hostConfig.fontSizes.default
        default:
            break
        }
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

    /// Line spacing derived from Figma type ramp (lineHeight - fontSize).
    /// Figma spec: Small 12/16, Default 14/18, Large 16/24, ExtraLarge 20/24.
    private var lineSpacing: CGFloat {
        let size = CGFloat(fontSize)
        let lineHeight: CGFloat

        let fontSizeEnum = textBlock.size ?? .default
        switch fontSizeEnum {
        case .small:
            lineHeight = 16
        case .default, .medium:
            lineHeight = 18
        case .large:
            lineHeight = 24
        case .extraLarge:
            lineHeight = 24
        }

        return max(lineHeight - size, 0)
    }

    private var fontWeight: Font.Weight {
        // Style-based overrides per AC v1.5 spec
        if textBlock.style == .heading || textBlock.style == .columnHeader {
            let bolderWeight = hostConfig.fontWeights.bolder
            switch bolderWeight {
            case 100...199: return .ultraLight
            case 200...299: return .light
            case 300...399: return .regular
            case 400...499: return .regular
            case 500...599: return .medium
            case 600...699: return .semibold
            case 700...799: return .bold
            default: return .heavy
            }
        }

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
        // Use TextBlock's own alignment, falling back to table cell alignment
        if textBlock.horizontalAlignment != nil {
            return .from(textBlock.horizontalAlignment)
        }
        if let cellAlign = tableCellAlignment {
            return .from(cellAlign)
        }
        return .from(textBlock.horizontalAlignment)
    }

    private var frameAlignment: Alignment {
        // Use TextBlock's own alignment, falling back to table cell alignment
        if textBlock.horizontalAlignment != nil {
            return .from(horizontal: textBlock.horizontalAlignment, vertical: nil, layoutDirection: layoutDirection)
        }
        if let cellAlign = tableCellAlignment {
            return .from(horizontal: cellAlign, vertical: nil, layoutDirection: layoutDirection)
        }
        return .from(horizontal: textBlock.horizontalAlignment, vertical: nil, layoutDirection: layoutDirection)
    }

    /// Computes the effective line limit based on wrap and maxLines properties.
    /// When wrap is false/nil and no maxLines set, limit to 1 line (legacy behavior).
    /// Inside table cells, default to wrapping to match Android behavior.
    private var effectiveLineLimit: Int? {
        if let maxLines = textBlock.maxLines {
            return maxLines
        }
        if textBlock.wrap == true || isInsideTableCell {
            return nil
        }
        return 1
    }
}
