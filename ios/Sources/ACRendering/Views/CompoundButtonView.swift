import SwiftUI
import ACCore
import ACAccessibility

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
        static let cornerRadius: CGFloat = 8
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
            isDisabled: button.action == nil
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
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .truncationMode(.tail)

                if let subtitle = button.subtitle {
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
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
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, Layout.horizontalPadding)
        .padding(.vertical, Layout.verticalPadding)
        .frame(minHeight: Layout.minHeight)
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
                    .foregroundColor(.primary)
            }
        }
    }

    private var iconPlaceholder: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(width: Layout.iconSize, height: Layout.iconSize)
            .foregroundColor(.gray)
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

// Custom button style for different variants
struct CompoundButtonStyle: ButtonStyle {
    let style: String
    let isDisabled: Bool

    private enum Colors {
        #if os(iOS)
        static let defaultBackground = Color(.systemBackground)
        #else
        static let defaultBackground = Color(nsColor: .windowBackgroundColor)
        #endif
        static let emphasisBackground = Color.accentColor
        static let positiveBackground = Color.green
        static let destructiveBackground = Color.red

        static let defaultText = Color.primary
        static let emphasisText = Color.white
        static let positiveText = Color.white
        static let destructiveText = Color.white
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(backgroundColor.opacity(configuration.isPressed ? 0.8 : 1.0))
            .cornerRadius(8)
            .shadow(
                color: Color.black.opacity(isDisabled ? 0 : 0.1),
                radius: 2,
                x: 0,
                y: 1
            )
            .opacity(isDisabled ? 0.5 : 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: style == "default" ? 1 : 0)
            )
    }

    private var backgroundColor: Color {
        switch style {
        case "emphasis":
            return Colors.emphasisBackground
        case "positive":
            return Colors.positiveBackground
        case "destructive":
            return Colors.destructiveBackground
        default:
            return Colors.defaultBackground
        }
    }
}
