import SwiftUI
import ACCore

public extension View {
    /// Applies container style background color and corner radius
    func containerStyle(_ style: ContainerStyle?, hostConfig: HostConfig) -> some View {
        self.modifier(ContainerStyleModifier(style: style, hostConfig: hostConfig))
    }
}

struct ContainerStyleModifier: ViewModifier {
    let style: ContainerStyle?
    let hostConfig: HostConfig

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var backgroundColor: Color {
        guard let containerStyle = style else { return .clear }
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

    private var cornerRadius: CGFloat {
        guard let containerStyle = style else { return 0 }
        let key: String

        switch containerStyle {
        case .default:
            key = "container"
        case .emphasis:
            key = "container"
        case .good:
            key = "container"
        case .attention:
            key = "container"
        case .warning:
            key = "container"
        case .accent:
            key = "container"
        }

        return CGFloat(hostConfig.cornerRadius[key] ?? 0)
    }
}
