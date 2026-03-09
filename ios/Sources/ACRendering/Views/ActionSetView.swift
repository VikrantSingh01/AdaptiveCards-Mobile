import SwiftUI
import ACCore
import ACActions
import ACAccessibility

struct ActionSetView: View {
    let actions: [CardAction]
    let hostConfig: HostConfig

    @Environment(\.actionHandler) var actionHandler
    @Environment(\.actionDelegate) var actionDelegate
    @EnvironmentObject var viewModel: CardViewModel

    var body: some View {
        Group {
            if orientation == .horizontal {
                HStack(spacing: CGFloat(hostConfig.actions.buttonSpacing)) {
                    actionContent
                }
            } else {
                VStack(spacing: CGFloat(hostConfig.actions.buttonSpacing)) {
                    actionContent
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: alignment)
        .accessibilityContainer(label: "Actions")
    }

    // MARK: - Overflow logic

    /// Primary actions that fit within maxActions limit
    private var visibleActions: [CardAction] {
        let primary = actions.filter { $0.mode != .secondary }
        let maxActions = hostConfig.actions.maxActions
        if primary.count > maxActions {
            return Array(primary.prefix(maxActions))
        }
        return primary
    }

    /// Overflow actions: explicit secondary + primary actions exceeding maxActions
    private var overflowActions: [CardAction] {
        let primary = actions.filter { $0.mode != .secondary }
        let secondary = actions.filter { $0.mode == .secondary }
        let maxActions = hostConfig.actions.maxActions
        var overflow = [CardAction]()
        if primary.count > maxActions {
            overflow.append(contentsOf: primary.dropFirst(maxActions))
        }
        overflow.append(contentsOf: secondary)
        return overflow
    }

    @ViewBuilder
    private var actionContent: some View {
        ForEach(visibleActions) { action in
            ActionButton(action: action, hostConfig: hostConfig) {
                actionHandler.handle(action, delegate: actionDelegate, viewModel: viewModel)
            }
        }

        if !overflowActions.isEmpty {
            overflowMenu
        }
    }

    /// Overflow "..." button that opens a dropdown with secondary actions
    private var overflowMenu: some View {
        Menu {
            ForEach(overflowActions) { action in
                Button(action.title ?? "") {
                    actionHandler.handle(action, delegate: actionDelegate, viewModel: viewModel)
                }
            }
        } label: {
            Text("\u{2026}")
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.secondary.opacity(0.2))
                .foregroundColor(.primary)
                .cornerRadius(4)
        }
        .accessibilityLabel("More actions")
    }

    // MARK: - Layout helpers

    private var orientation: Orientation {
        hostConfig.actions.actionsOrientation.lowercased() == "vertical" ? .vertical : .horizontal
    }

    private var alignment: Alignment {
        let alignmentStr = hostConfig.actions.actionAlignment.lowercased()
        switch alignmentStr {
        case "center":
            return .center
        case "right":
            return .trailing
        default:
            return .leading
        }
    }

    enum Orientation {
        case horizontal
        case vertical
    }
}
