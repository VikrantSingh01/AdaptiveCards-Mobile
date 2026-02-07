import SwiftUI
import ACCore

public extension View {
    /// Applies spacing based on the element's spacing property
    func spacing(_ spacing: Spacing?, hostConfig: HostConfig) -> some View {
        self.modifier(SpacingModifier(spacing: spacing, hostConfig: hostConfig))
    }
}

struct SpacingModifier: ViewModifier {
    let spacing: Spacing?
    let hostConfig: HostConfig
    
    func body(content: Content) -> some View {
        content.padding(.top, CGFloat(spacingValue))
    }
    
    private var spacingValue: Int {
        guard let spacing = spacing else { return 0 }
        
        switch spacing {
        case .none:
            return 0
        case .small:
            return hostConfig.spacing.small
        case .default:
            return hostConfig.spacing.default
        case .medium:
            return hostConfig.spacing.medium
        case .large:
            return hostConfig.spacing.large
        case .extraLarge:
            return hostConfig.spacing.extraLarge
        case .padding:
            return hostConfig.spacing.padding
        }
    }
}
