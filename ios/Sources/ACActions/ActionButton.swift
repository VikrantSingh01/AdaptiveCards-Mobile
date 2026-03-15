// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

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
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .font(.system(size: 14, weight: .medium))
            .padding(.horizontal, CGFloat(hostConfig.spacing.small))
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
        case .resetInputs(let a): return a.title
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
        case .resetInputs(let a): return a.iconUrl
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
        case .resetInputs(let a): return a.style
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
        case .resetInputs(let a): return a.tooltip
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
        case .resetInputs(let a): return a.isEnabled
        case .unknown: return nil
        }
    }

    /// Button background — filled for positive/destructive, outlined for default
    private var buttonBackgroundColor: Color {
        let actionStyle = style ?? .default
        let colors = hostConfig.containerStyles.default.foregroundColors

        switch actionStyle {
        case .positive:
            return Color(hex: colors.good.`default`)
        case .destructive:
            return Color(hex: colors.attention.`default`)
        case .default, .other:
            return .clear
        }
    }

    /// Button text color — white for filled positive/destructive, accent for default
    private var buttonForegroundColor: Color {
        let actionStyle = style ?? .default
        let colors = hostConfig.containerStyles.default.foregroundColors

        switch actionStyle {
        case .positive, .destructive:
            return .white
        case .default, .other:
            return Color(hex: colors.accent.`default`)
        }
    }

    /// Button border color — matches background for filled, accent for outlined
    private var buttonBorderColor: Color {
        let actionStyle = style ?? .default
        let colors = hostConfig.containerStyles.default.foregroundColors

        switch actionStyle {
        case .positive:
            return Color(hex: colors.good.`default`)
        case .destructive:
            return Color(hex: colors.attention.`default`)
        case .default, .other:
            return Color(hex: colors.accent.`default`)
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
        "BellOff": "bell.slash",
        "ArrowReset": "arrow.counterclockwise",
        "ToggleLeft": "switch.2",
        "ArrowExport": "arrow.up.forward.square",
        "AccessTime": "clock",
        "Airplane": "airplane"
    ]

    /// Maps Fluent UI icon names to SF Symbols.
    /// Handles style suffixes like "Open,Filled" or "Send,Regular" by stripping the comma-separated style.
    static func sfSymbol(for fluentIcon: String) -> String {
        // Strip style suffix (e.g., ",Filled", ",Regular") if present
        let name = fluentIcon.split(separator: ",").first.map(String.init) ?? fluentIcon
        return fluentToSFSymbol[name] ?? "questionmark.square"
    }
}
