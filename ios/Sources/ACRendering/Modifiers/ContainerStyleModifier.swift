import SwiftUI
import ACCore

public extension View {
    /// Applies container style background color
    func containerStyle(_ style: ContainerStyle?, hostConfig: HostConfig) -> some View {
        self.modifier(ContainerStyleModifier(style: style, hostConfig: hostConfig))
    }
}

struct ContainerStyleModifier: ViewModifier {
    let style: ContainerStyle?
    let hostConfig: HostConfig

    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
    }

    private var backgroundColor: Color {
        let containerStyle = style ?? .default
        let styleConfig: ContainerStyleConfig

        switch containerStyle {
        case .default:
            styleConfig = hostConfig.containerStyles.default
        case .emphasis:
            styleConfig = hostConfig.containerStyles.emphasis
        case .good:
            styleConfig = hostConfig.containerStyles.good
        case .attention:
            styleConfig = hostConfig.containerStyles.attention
        case .warning:
            styleConfig = hostConfig.containerStyles.warning
        case .accent:
            styleConfig = hostConfig.containerStyles.accent
        }

        return Color(hex: styleConfig.backgroundColor)
    }
}
