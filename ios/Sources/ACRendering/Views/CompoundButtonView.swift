// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
import ACCore
import ACAccessibility
import ACFluentUI

struct CompoundButtonView: View {
    let button: CompoundButton
    let hostConfig: HostConfig

    @Environment(\.actionHandler) var actionHandler
    @Environment(\.actionDelegate) var actionDelegate
    @EnvironmentObject var viewModel: CardViewModel

    private enum Layout {
        static let iconSize: CGFloat = 24
        static let iconTextSpacing: CGFloat = 12
        static let titleSubtitleSpacing: CGFloat = 4
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 12
        static let minHeight: CGFloat = 44
        static let badgeFontSize: CGFloat = 10
    }

    var body: some View {
        Button(action: handleAction) {
            content
        }
        .buttonStyle(CompoundButtonStyle(
            style: button.style ?? "default",
            isDisabled: button.selectAction == nil,
            hostConfig: hostConfig
        ))
        .disabled(button.selectAction == nil)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
    }

    private var isStyledButton: Bool {
        let s = button.style ?? "default"
        return ["emphasis", "positive", "destructive"].contains(s)
    }

    private var primaryTextColor: Color {
        isStyledButton ? .white : Color(hex: hostConfig.containerStyles.default.foregroundColors.default.default)
    }

    private var secondaryTextColor: Color {
        isStyledButton ? .white.opacity(0.8) : Color(hex: hostConfig.containerStyles.default.foregroundColors.default.subtle)
    }

    @ViewBuilder
    private var content: some View {
        HStack(alignment: .center, spacing: Layout.iconTextSpacing) {
            if button.iconPosition != "trailing" {
                iconView
            }

            VStack(alignment: .leading, spacing: Layout.titleSubtitleSpacing) {
                HStack {
                    Text(button.title)
                        .font(.system(size: CGFloat(hostConfig.fontSizes.large), weight: titleFontWeight))
                        .foregroundColor(primaryTextColor)
                        .lineLimit(2)
                        .truncationMode(.tail)

                    if let badge = button.badge {
                        Text(badge)
                            .font(.system(size: Layout.badgeFontSize, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: hostConfig.containerStyles.default.foregroundColors.accent.`default`))
                            .cornerRadius(4)
                            .lineLimit(1)
                    }
                }

                if let description = button.description {
                    Text(description)
                        .font(.system(size: CGFloat(hostConfig.fontSizes.default)))
                        .foregroundColor(secondaryTextColor)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if button.iconPosition == "trailing" {
                iconView
            }

            // Chevron indicator
            Image(systemName: "chevron.right")
                .font(.system(size: CGFloat(hostConfig.fontSizes.default), weight: titleFontWeight))
                .foregroundColor(secondaryTextColor)
        }
        .padding(.horizontal, Layout.horizontalPadding)
        .padding(.vertical, Layout.verticalPadding)
        .frame(minHeight: Layout.minHeight)
    }

    private var titleFontWeight: Font.Weight {
        let weightValue = hostConfig.fontWeights.bolder
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

    @ViewBuilder
    private var iconView: some View {
        if let iconName = button.iconName {
            if iconName.hasPrefix("http://") || iconName.hasPrefix("https://") {
                AsyncImage(url: URL(string: iconName)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: Layout.iconSize, height: Layout.iconSize)
                    case .failure:
                        iconPlaceholder
                    case .empty:
                        ProgressView()
                            .frame(width: Layout.iconSize, height: Layout.iconSize)
                    @unknown default:
                        iconPlaceholder
                    }
                }
            } else {
                // Map Fluent icon names to SF Symbols, then fall back to raw name
                let sfSymbol = Self.resolveFluentIcon(iconName)
                Image(systemName: sfSymbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Layout.iconSize, height: Layout.iconSize)
                    .foregroundColor(primaryTextColor)
            }
        }
    }

    /// Maps Fluent UI icon names to SF Symbol equivalents.
    private static func resolveFluentIcon(_ name: String) -> String {
        let baseName = name
            .replacingOccurrences(of: ",Filled", with: "")
            .replacingOccurrences(of: ",Regular", with: "")
            .trimmingCharacters(in: .whitespaces)
        let lookup: [String: String] = [
            "Calendar": "calendar",
            "Info": "info.circle",
            "InfoCircle": "info.circle",
            "Warning": "exclamationmark.triangle",
            "Error": "xmark.circle",
            "Checkmark": "checkmark.circle",
            "CheckmarkCircle": "checkmark.circle",
            "Search": "magnifyingglass",
            "Settings": "gearshape",
            "Person": "person",
            "People": "person.2",
            "Mail": "envelope",
            "Chat": "bubble.left",
            "Phone": "phone",
            "Video": "video",
            "Camera": "camera",
            "Document": "doc",
            "Folder": "folder",
            "Star": "star",
            "Heart": "heart",
            "Home": "house",
            "Location": "location",
            "Map": "map",
            "Clock": "clock",
            "Alert": "bell",
            "Add": "plus.circle",
            "Delete": "trash",
            "Edit": "pencil",
            "Share": "square.and.arrow.up",
            "Link": "link",
            "Globe": "globe",
            "Lock": "lock",
            "ArrowRight": "arrow.right",
            "ChevronRight": "chevron.right",
            "Dismiss": "xmark",
            "MoreHorizontal": "ellipsis",
            "Attach": "paperclip",
            "Send": "paperplane",
            "Airplane": "airplane",
            "Food": "fork.knife",
            "Gift": "gift",
            "Money": "dollarsign.circle",
            "Weather": "cloud.sun",
            "Flash": "bolt",
            "Play": "play",
            "Mic": "mic",
        ]
        return lookup[baseName] ?? name
    }

    private var iconPlaceholder: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(width: Layout.iconSize, height: Layout.iconSize)
            .foregroundColor(Color(hex: hostConfig.containerStyles.default.foregroundColors.default.subtle))
    }

    private var accessibilityLabel: String {
        if let description = button.description {
            return "\(button.title). \(description)"
        }
        return button.title
    }

    private var accessibilityHint: String {
        guard let action = button.selectAction else {
            return ""
        }

        switch action {
        case .openUrl:
            return "Opens URL"
        case .submit:
            return "Submits form"
        case .showCard:
            return "Shows card"
        case .toggleVisibility:
            return "Toggles visibility"
        case .execute:
            return "Executes action"
        case .popover:
            return "Shows popover"
        case .runCommands:
            return "Runs commands"
        case .openUrlDialog:
            return "Opens URL dialog"
        case .unknown:
            return ""
        }
    }

    private func handleAction() {
        guard let action = button.selectAction else { return }
        actionHandler.handle(action, delegate: actionDelegate, viewModel: viewModel)
    }
}

// Custom button style using hostConfig for theming
struct CompoundButtonStyle: ButtonStyle {
    let style: String
    let isDisabled: Bool
    let hostConfig: HostConfig

    func makeBody(configuration: Configuration) -> some View {
        let cornerRadius = CGFloat(hostConfig.cornerRadius["container"] ?? 4)

        configuration.label
            .background(backgroundColor.opacity(configuration.isPressed ? 0.8 : 1.0))
            .cornerRadius(cornerRadius)
            .shadow(
                color: Color.black.opacity(isDisabled ? 0 : 0.1),
                radius: 2,
                x: 0,
                y: 1
            )
            .opacity(isDisabled ? 0.5 : 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color(hex: hostConfig.compoundButton.borderColor), lineWidth: CGFloat(hostConfig.separator.lineThickness))
            )
    }

    private var isStyledButton: Bool {
        ["emphasis", "positive", "destructive"].contains(style)
    }

    private var backgroundColor: Color {
        let colors = hostConfig.containerStyles.default.foregroundColors
        switch style {
        case "emphasis":
            return Color(hex: colors.accent.`default`)
        case "positive":
            return Color(hex: colors.good.`default`)
        case "destructive":
            return Color(hex: colors.attention.`default`)
        default:
            return Color(hex: hostConfig.containerStyles.default.backgroundColor)
        }
    }
}
