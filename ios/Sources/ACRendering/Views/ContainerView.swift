import SwiftUI
import ACCore
import ACAccessibility

struct ContainerView: View {
    let container: Container
    let hostConfig: HostConfig

    @Environment(\.actionHandler) var actionHandler
    @Environment(\.actionDelegate) var actionDelegate
    @EnvironmentObject var viewModel: CardViewModel

    var body: some View {
        let content = VStack(spacing: 0) {
            if let items = container.items {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, element in
                    if viewModel.isElementVisible(elementId: element.elementId) {
                        ElementView(element: element, hostConfig: hostConfig)
                            .padding(.top, index > 0 ? spacingValue(for: element.spacing, hostConfig: hostConfig) : 0)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: verticalContentAlignment)
        .frame(minHeight: minHeight)
        .padding(container.bleed == true ? 0 : (container.style != nil ? CGFloat(hostConfig.spacing.padding) : 0))

        Group {
            if let bgImage = container.backgroundImage {
                content
                    .background(
                        BackgroundImageView(backgroundImage: bgImage)
                    )
                    .clipped()
            } else {
                content
                    .containerStyle(container.style, hostConfig: hostConfig)
            }
        }
        .overlay(borderOverlay)
        .spacing(container.spacing, hostConfig: hostConfig)
        .separator(container.separator, hostConfig: hostConfig)
        .selectAction(container.selectAction) { action in
            actionHandler.handle(action, delegate: actionDelegate, viewModel: viewModel)
        }
        .accessibilityContainer(label: "Container")
    }

    @ViewBuilder
    private var borderOverlay: some View {
        if container.showBorder == true, let style = container.style {
            let radius = CGFloat(hostConfig.cornerRadius["container"] ?? 0)
            let borderColor = borderColorForStyle(style)
            RoundedRectangle(cornerRadius: radius)
                .stroke(borderColor, lineWidth: 1)
        }
    }

    private func borderColorForStyle(_ style: ContainerStyle) -> Color {
        let styleConfig: ContainerStyleConfig
        switch style {
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
        return Color(hex: styleConfig.borderColor)
    }

    private var verticalContentAlignment: Alignment {
        guard let alignment = container.verticalContentAlignment else {
            return .top
        }

        switch alignment {
        case .top:
            return .top
        case .center:
            return .center
        case .bottom:
            return .bottom
        }
    }

    private var minHeight: CGFloat? {
        guard let minHeightStr = container.minHeight else { return nil }
        return CGFloat(Int(minHeightStr.replacingOccurrences(of: "px", with: "")) ?? 0)
    }

    /// Resolves element spacing to a CGFloat value, falling back to hostConfig default.
    private func spacingValue(for spacing: Spacing?, hostConfig: HostConfig) -> CGFloat {
        guard let spacing = spacing else {
            return CGFloat(hostConfig.spacing.default)
        }
        switch spacing {
        case .none: return 0
        case .extraSmall: return 4
        case .small: return CGFloat(hostConfig.spacing.small)
        case .default: return CGFloat(hostConfig.spacing.default)
        case .medium: return CGFloat(hostConfig.spacing.medium)
        case .large: return CGFloat(hostConfig.spacing.large)
        case .extraLarge: return CGFloat(hostConfig.spacing.extraLarge)
        case .padding: return CGFloat(hostConfig.spacing.padding)
        }
    }
}

/// Renders a background image for a container using AsyncImage.
private struct BackgroundImageView: View {
    let backgroundImage: BackgroundImage

    var body: some View {
        AsyncImage(url: URL(string: backgroundImage.url)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failure:
                Color.gray.opacity(0.1)
            case .empty:
                Color.clear
            @unknown default:
                Color.clear
            }
        }
    }

    private var contentMode: ContentMode {
        switch backgroundImage.fillMode {
        case .repeatHorizontally, .repeatVertically, .repeat:
            return .fill
        default:
            return .fill
        }
    }
}
