import SwiftUI
import ACCore

// MARK: - Dynamic Type Support

public extension View {
    /// Scales text based on Dynamic Type settings
    func dynamicTypeSize(for fontSize: FontSize, hostConfig: HostConfig) -> some View {
        self.modifier(DynamicTypeSizeModifier(fontSize: fontSize, hostConfig: hostConfig))
    }
}

private struct DynamicTypeSizeModifier: ViewModifier {
    let fontSize: FontSize
    let hostConfig: HostConfig
    @Environment(\.sizeCategory) var sizeCategory

    func body(content: Content) -> some View {
        content.font(scaledFont())
    }

    private func scaledFont() -> Font {
        let baseSize = baseFontSize()
        let scaleFactor = scaleFactor(for: sizeCategory)
        let scaledSize = CGFloat(baseSize) * scaleFactor

        return .system(size: scaledSize)
    }

    private func baseFontSize() -> Int {
        switch fontSize {
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

    private func scaleFactor(for sizeCategory: ContentSizeCategory) -> CGFloat {
        switch sizeCategory {
        case .extraSmall:
            return 0.8
        case .small:
            return 0.85
        case .medium:
            return 0.9
        case .large:
            return 1.0
        case .extraLarge:
            return 1.1
        case .extraExtraLarge:
            return 1.2
        case .extraExtraExtraLarge:
            return 1.3
        case .accessibilityMedium:
            return 1.4
        case .accessibilityLarge:
            return 1.5
        case .accessibilityExtraLarge:
            return 1.6
        case .accessibilityExtraExtraLarge:
            return 1.7
        case .accessibilityExtraExtraExtraLarge:
            return 1.8
        @unknown default:
            return 1.0
        }
    }
}

// MARK: - Font Weight Support

public extension View {
    func dynamicFontWeight(_ fontWeight: FontWeight, hostConfig: HostConfig) -> some View {
        let weight = weight(for: fontWeight, hostConfig: hostConfig)
        return self.fontWeight(weight)
    }

    private func weight(for fontWeight: FontWeight, hostConfig: HostConfig) -> Font.Weight {
        let weightValue = switch fontWeight {
        case .lighter:
            hostConfig.fontWeights.lighter
        case .default:
            hostConfig.fontWeights.default
        case .bolder:
            hostConfig.fontWeights.bolder
        }

        // Map CSS font-weight values to SwiftUI Font.Weight
        // CSS 400 = regular, 700 = bold, 800+ = heavy
        // Legacy C++ renderer uses UIKit .bold (700) for bolder,
        // so we map 800+ → .bold for parity
        switch weightValue {
        case ...299:
            return .light
        case 300...499:
            return .regular
        case 500...599:
            return .medium
        case 600...699:
            return .semibold
        default:
            return .bold
        }
    }
}
