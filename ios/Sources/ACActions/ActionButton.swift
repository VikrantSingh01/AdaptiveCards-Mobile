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
            HStack(spacing: CGFloat(hostConfig.spacing.small)) {
                if let iconUrl = iconUrl {
                    let iconSize = CGFloat(hostConfig.actions.iconSize)
                    if iconUrl.hasPrefix("icon:") {
                        let iconName = String(iconUrl.dropFirst("icon:".count))
                        Image(systemName: Self.sfSymbol(for: iconName))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: iconSize, height: iconSize)
                    } else {
                        AsyncImage(url: URL(string: iconUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: iconSize, height: iconSize)
                        } placeholder: {
                            EmptyView()
                        }
                    }
                }

                if let title = title {
                    Text(title)
                        .lineLimit(1)
                }
            }
            .font(.system(size: CGFloat(hostConfig.fontSizes.default), weight: .medium))
            .padding(.horizontal, CGFloat(hostConfig.spacing.medium))
            .padding(.vertical, CGFloat(hostConfig.spacing.small) * 0.75)
            .foregroundColor(buttonForegroundColor)
            .background(buttonBackgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: CGFloat(hostConfig.cornerRadius["container"] ?? 4))
                    .stroke(buttonBorderColor, lineWidth: CGFloat(hostConfig.separator.lineThickness))
            )
            .clipShape(RoundedRectangle(cornerRadius: CGFloat(hostConfig.cornerRadius["container"] ?? 4)))
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
        case .unknown: return nil
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
        case .unknown: return nil
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
        case .unknown: return nil
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
        case .unknown: return nil
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
        case .unknown: return nil
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
        case .default, .other:
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
        case .default, .other:
            return Color(hex: colors.accent.`default`)
        case .positive:
            return Color(hex: colors.good.`default`)
        case .destructive:
            return Color(hex: colors.attention.`default`)
        }
    }

    /// Fluent UI icon name → SF Symbol mapping table
    private static let fluentToSFSymbol: [String: String] = [
        "Calendar": "calendar", "PeopleTeam": "person.2",
        "ArrowDown": "arrow.down", "ArrowUp": "arrow.up",
        "Link": "link", "Clock": "clock", "Send": "paperplane",
        "Edit": "pencil", "Delete": "trash", "Add": "plus",
        "Search": "magnifyingglass", "Share": "square.and.arrow.up",
        "Star": "star", "StarFilled": "star.fill",
        "Heart": "heart", "HeartFilled": "heart.fill",
        "Bookmark": "bookmark", "BookmarkFilled": "bookmark.fill",
        "Comment": "bubble.right", "ThumbLike": "hand.thumbsup",
        "Eye": "eye", "EyeOff": "eye.slash",
        "CheckmarkCircle": "checkmark.circle", "DismissCircle": "xmark.circle",
        "Info": "info.circle", "Warning": "exclamationmark.triangle",
        "ErrorCircle": "exclamationmark.circle",
        "ChevronRight": "chevron.right", "ChevronDown": "chevron.down",
        "ChevronUp": "chevron.up", "Open": "arrow.up.right.square",
        "Copy": "doc.on.doc", "Receipt": "doc.text",
        "Flag": "flag", "FlagFilled": "flag.fill",
        "Location": "location", "Phone": "phone", "Mail": "envelope",
        "Video": "video", "Camera": "camera", "Attach": "paperclip",
        "Document": "doc", "Folder": "folder", "Settings": "gearshape",
        "Filter": "line.3.horizontal.decrease", "MoreHorizontal": "ellipsis",
        "Cart": "cart", "CartFilled": "cart.fill",
        "Save": "square.and.arrow.down",
        "Navigation": "arrow.triangle.turn.up.right.diamond",
        "AlertUrgent": "bell.badge",
        "Alert": "exclamationmark.triangle",
        "Bell": "bell",
        "BellOff": "bell.slash"
    ]

    /// Maps Fluent UI icon names to SF Symbols
    static func sfSymbol(for fluentIcon: String) -> String {
        fluentToSFSymbol[fluentIcon] ?? "questionmark.square"
    }
}
