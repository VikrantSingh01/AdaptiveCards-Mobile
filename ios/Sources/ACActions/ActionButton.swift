import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import ACCore
import ACAccessibility
import ACFluentUI

public struct ActionButton: View {
    let action: CardAction
    let hostConfig: HostConfig
    let onTap: () -> Void

    public init(
        action: CardAction,
        hostConfig: HostConfig,
        onTap: @escaping () -> Void
    ) {
        self.action = action
        self.hostConfig = hostConfig
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                if let iconUrl = iconUrl {
                    AsyncImage(url: URL(string: iconUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                    } placeholder: {
                        EmptyView()
                    }
                }

                if let title = title {
                    Text(title)
                        .lineLimit(1)
                }
            }
            .font(.system(size: CGFloat(hostConfig.fontSizes.default), weight: .medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .foregroundColor(buttonForegroundColor)
            .background(buttonBackgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(buttonBorderColor, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.plain)
        .disabled(!(isEnabled ?? true))
        .accessibilityAction(label: title, hint: tooltip)
    }

    private var title: String? {
        switch action {
        case .submit(let a): return a.title
        case .openUrl(let a): return a.title
        case .showCard(let a): return a.title
        case .execute(let a): return a.title
        case .toggleVisibility(let a): return a.title
        case .popover(let a): return a.title
        case .runCommands(let a): return a.title
        case .openUrlDialog(let a): return a.title
        }
    }

    private var iconUrl: String? {
        switch action {
        case .submit(let a): return a.iconUrl
        case .openUrl(let a): return a.iconUrl
        case .showCard(let a): return a.iconUrl
        case .execute(let a): return a.iconUrl
        case .toggleVisibility(let a): return a.iconUrl
        case .popover(let a): return a.iconUrl
        case .runCommands(let a): return a.iconUrl
        case .openUrlDialog(let a): return a.iconUrl
        }
    }

    private var style: ActionStyle? {
        switch action {
        case .submit(let a): return a.style
        case .openUrl(let a): return a.style
        case .showCard(let a): return a.style
        case .execute(let a): return a.style
        case .toggleVisibility(let a): return a.style
        case .popover(let a): return a.style
        case .runCommands(let a): return a.style
        case .openUrlDialog(let a): return a.style
        }
    }

    private var tooltip: String? {
        switch action {
        case .submit(let a): return a.tooltip
        case .openUrl(let a): return a.tooltip
        case .showCard(let a): return a.tooltip
        case .execute(let a): return a.tooltip
        case .toggleVisibility(let a): return a.tooltip
        case .popover(let a): return a.tooltip
        case .runCommands(let a): return a.tooltip
        case .openUrlDialog(let a): return a.tooltip
        }
    }

    private var isEnabled: Bool? {
        switch action {
        case .submit(let a): return a.isEnabled
        case .openUrl(let a): return a.isEnabled
        case .showCard(let a): return a.isEnabled
        case .execute(let a): return a.isEnabled
        case .toggleVisibility(let a): return a.isEnabled
        case .popover(let a): return a.isEnabled
        case .runCommands(let a): return a.isEnabled
        case .openUrlDialog(let a): return a.isEnabled
        }
    }

    /// Outlined button background — transparent for all styles per Figma
    private var buttonBackgroundColor: Color {
        return .clear
    }

    /// Outlined button text color per Figma spec
    private var buttonForegroundColor: Color {
        let actionStyle = style ?? .default
        let colors = hostConfig.containerStyles.default.foregroundColors

        switch actionStyle {
        case .default:
            return Color(hex: colors.accent.`default`)
        case .positive:
            return Color(hex: colors.good.`default`)
        case .destructive:
            return Color(hex: colors.attention.`default`)
        }
    }

    /// Outlined button border color per Figma spec
    private var buttonBorderColor: Color {
        let actionStyle = style ?? .default
        let colors = hostConfig.containerStyles.default.foregroundColors

        switch actionStyle {
        case .default:
            return Color(hex: colors.accent.`default`)
        case .positive:
            return Color(hex: colors.good.`default`)
        case .destructive:
            return Color(hex: colors.attention.`default`)
        }
    }
}
