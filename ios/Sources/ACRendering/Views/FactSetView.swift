// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
import ACCore
import ACAccessibility
import ACMarkdown

struct FactSetView: View {
    let factSet: FactSet
    let hostConfig: HostConfig

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat(hostConfig.factSet.spacing)) {
            ForEach(factSet.facts) { fact in
                HStack(alignment: .top, spacing: 8) {
                    factText(fact.title, config: hostConfig.factSet.title)
                        .lineLimit(hostConfig.factSet.title.wrap ? nil : 1)
                        .frame(width: titleMaxWidth > 0 ? CGFloat(titleMaxWidth) : nil, alignment: .leading)
                    factText(fact.value, config: hostConfig.factSet.value)
                        .lineLimit(hostConfig.factSet.value.wrap ? nil : 1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .spacing(factSet.spacing, hostConfig: hostConfig)
        .separator(factSet.separator, hostConfig: hostConfig)
        .accessibilityContainer(label: "Fact Set")
    }

    /// Renders fact text with markdown support (bold, italic, links) when markdown is detected.
    @ViewBuilder
    private func factText(_ text: String, config: FactSetTextConfig) -> some View {
        let expanded = DateTimeMacroExpander.expand(text)
        if expanded.containsMarkdown {
            let tokens = MarkdownParser.parse(expanded)
            let attributed = MarkdownRenderer.render(
                tokens: tokens,
                font: resolveFont(config),
                color: resolveColor(config)
            )
            Text(attributed)
        } else {
            Text(expanded)
                .font(resolveFont(config))
                .fontWeight(resolveWeight(config.weight))
                .foregroundColor(resolveColor(config))
        }
    }

    private var titleMaxWidth: Int {
        hostConfig.factSet.title.maxWidth
    }

    private func resolveWeight(_ weightString: String) -> Font.Weight {
        let weightValue: Int
        switch weightString.lowercased() {
        case "lighter":
            weightValue = hostConfig.fontWeights.lighter
        case "bolder":
            weightValue = hostConfig.fontWeights.bolder
        default:
            weightValue = hostConfig.fontWeights.default
        }

        switch weightValue {
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

    private func resolveFont(_ config: FactSetTextConfig) -> Font {
        let size = CGFloat(resolveFontSize(config.size))
        if config.fontType.lowercased() == "monospace" {
            return .system(size: size, design: .monospaced)
        }
        return .system(size: size)
    }

    private func resolveColor(_ config: FactSetTextConfig) -> Color {
        let styleConfig = hostConfig.containerStyles.default
        let colorConfig: ColorConfig

        switch config.color.lowercased() {
        case "dark": colorConfig = styleConfig.foregroundColors.dark
        case "light": colorConfig = styleConfig.foregroundColors.light
        case "accent": colorConfig = styleConfig.foregroundColors.accent
        case "good": colorConfig = styleConfig.foregroundColors.good
        case "warning": colorConfig = styleConfig.foregroundColors.warning
        case "attention": colorConfig = styleConfig.foregroundColors.attention
        default: colorConfig = styleConfig.foregroundColors.default
        }

        let hex = config.isSubtle ? colorConfig.subtle : colorConfig.default
        return Color(hex: hex)
    }

    private func resolveFontSize(_ sizeString: String) -> Int {
        switch sizeString.lowercased() {
        case "small": return hostConfig.fontSizes.small
        case "medium": return hostConfig.fontSizes.medium
        case "large": return hostConfig.fontSizes.large
        case "extralarge": return hostConfig.fontSizes.extraLarge
        default: return hostConfig.fontSizes.`default`
        }
    }
}
