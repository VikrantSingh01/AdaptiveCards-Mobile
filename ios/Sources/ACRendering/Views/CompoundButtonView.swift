import SwiftUI
import ACCore
import ACAccessibility
import ACFluentUI

struct CompoundButtonView: View {
    let button: CompoundButton
    let hostConfig: HostConfig

    @EnvironmentObject var viewModel: CardViewModel

    private enum Layout {
        static let iconSize: CGFloat = 24
        static let iconTextSpacing: CGFloat = 12
        static let titleSubtitleSpacing: CGFloat = 4
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 12
        static let minHeight: CGFloat = 44
        static let shadowRadius: CGFloat = 2
        static let shadowY: CGFloat = 1
    }

    var body: some View {
        Button(action: handleAction) {
            content
        }
        .buttonStyle(CompoundButtonStyle(
            style: button.style ?? "default",
            isDisabled: button.action == nil,
            hostConfig: hostConfig
        ))
        .disabled(button.action == nil)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
    }

    @ViewBuilder
    private var content: some View {
        HStack(alignment: .center, spacing: Layout.iconTextSpacing) {
            if button.iconPosition != "trailing" {
                iconView
            }

            VStack(alignment: .leading, spacing: Layout.titleSubtitleSpacing) {
                Text(button.title)
                    .font(.system(size: CGFloat(hostConfig.fontSizes.large), weight: titleFontWeight))
                    .foregroundColor(Color(hex: hostConfig.containerStyles.default.foregroundColors.default.default))
                    .lineLimit(2)
                    .truncationMode(.tail)

                if let subtitle = button.subtitle {
                    Text(subtitle)
                        .font(.system(size: CGFloat(hostConfig.fontSizes.default)))
                        .foregroundColor(Color(hex: hostConfig.containerStyles.default.foregroundColors.default.subtle))
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
                .foregroundColor(Color(hex: hostConfig.containerStyles.default.foregroundColors.default.subtle))
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
        if let iconString = button.icon {
            if iconString.hasPrefix("http://") || iconString.hasPrefix("https://") {
                AsyncImage(url: URL(string: iconString)) { phase in
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
                // SF Symbol
                Image(systemName: iconString)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Layout.iconSize, height: Layout.iconSize)
                    .foregroundColor(Color(hex: hostConfig.containerStyles.default.foregroundColors.default.default))
            }
        }
    }

    private var iconPlaceholder: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(width: Layout.iconSize, height: Layout.iconSize)
            .foregroundColor(Color(hex: hostConfig.containerStyles.default.foregroundColors.default.subtle))
    }

    private var accessibilityLabel: String {
        if let subtitle = button.subtitle {
            return "\(button.title). \(subtitle)"
        }
        return button.title
    }

    private var accessibilityHint: String {
        guard let action = button.action else {
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
        }
    }

    private func handleAction() {
        guard let action = button.action else { return }
        // TODO: Implement action handling through CardViewModel
        print("CompoundButton action triggered: \(action)")
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
                    .stroke(Color(hex: hostConfig.compoundButton.borderColor), lineWidth: 1)
            )
    }

    private var backgroundColor: Color {
        switch style {
        case "emphasis":
            return Color(hex: hostConfig.containerStyles.accent.backgroundColor)
        case "positive":
            return Color(hex: hostConfig.containerStyles.good.backgroundColor)
        case "destructive":
            return Color(hex: hostConfig.containerStyles.attention.backgroundColor)
        default:
            return Color(hex: hostConfig.containerStyles.default.backgroundColor)
        }
    }
}
