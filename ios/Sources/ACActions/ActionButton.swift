import SwiftUI
import UIKit
import ACCore
import ACAccessibility
import ACFluentUI

public struct ActionButton: View {
    let action: CardAction
    let hostConfig: HostConfig
    let isExpanded: Bool?
    let onTap: () -> Void

    public init(
        action: CardAction,
        hostConfig: HostConfig,
        isExpanded: Bool? = nil,
        onTap: @escaping () -> Void
    ) {
        self.action = action
        self.hostConfig = hostConfig
        self.isExpanded = isExpanded
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
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
            .font(.system(size: 15))
            .frame(maxWidth: .infinity)
            .padding(10)
            .foregroundColor(buttonForegroundColor)
            .background(buttonBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .disabled(!(isEnabled ?? true))
        .accessibilityAction(label: title, hint: tooltip)
        .accessibilityRemoveTraits(isOpenUrl ? .isButton : [])
        .accessibilityAddTraits(isOpenUrl ? .isLink : [])
        .accessibilityValue(expandedValue)
    }

    /// Accessibility value for expanded/collapsed state
    private var expandedValue: String {
        if let isExpanded = isExpanded {
            return isExpanded ? "expanded" : "collapsed"
        }
        return ""
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

    /// Whether this action opens a URL (should use link trait, not button)
    private var isOpenUrl: Bool {
        switch action {
        case .openUrl, .openUrlDialog: return true
        default: return false
        }
    }

    /// Whether this action is a ShowCard toggle
    private var isShowCard: Bool {
        switch action {
        case .showCard: return true
        default: return false
        }
    }

    private var backgroundColor: Color {
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

    private var foregroundColor: Color {
        return .white
    }

    /// Background color for filled button style matching legacy renderer
    private var buttonBackgroundColor: Color {
        let actionStyle = style ?? .default
        let colors = hostConfig.containerStyles.default.foregroundColors
        switch actionStyle {
        case .default:
            return Color(uiColor: .systemBlue)
        case .positive:
            return Color(hex: colors.accent.`default`)
        case .destructive:
            return .clear
        }
    }

    /// Foreground text color matching legacy renderer
    private var buttonForegroundColor: Color {
        let actionStyle = style ?? .default
        let colors = hostConfig.containerStyles.default.foregroundColors
        switch actionStyle {
        case .default, .positive:
            return .white
        case .destructive:
            return Color(hex: colors.attention.`default`)
        }
    }
}
