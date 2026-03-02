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
            ActionButton(
                action: action,
                hostConfig: hostConfig
            ) {
                actionHandler.handle(action, delegate: actionDelegate, viewModel: viewModel)
            }
            .accessibilityValue(showCardExpandedState(for: action).map { $0 ? "expanded" : "collapsed" } ?? "")
            .if(isStretch) { view in
                view.frame(maxWidth: .infinity)
            }
        }

        if !overflowActions.isEmpty {
            overflowMenu
        }

        // Render inline ShowCard content for expanded cards (upstream #100, #374)
        ForEach(showCardActions, id: \.actionId) { showCardInfo in
            if viewModel.isShowCardExpanded(actionId: showCardInfo.actionId) {
                VStack(spacing: 0) {
                    if let body = showCardInfo.card.body {
                        ForEach(Array(body.enumerated()), id: \.element.id) { index, element in
                            ElementView(element: element, hostConfig: hostConfig)
                        }
                    }
                    if let subActions = showCardInfo.card.actions, !subActions.isEmpty {
                        ActionSetView(actions: subActions, hostConfig: hostConfig)
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("\(showCardInfo.title) content")
            }
        }
    }

    /// Returns expanded state for ShowCard actions, nil for others
    private func showCardExpandedState(for action: CardAction) -> Bool? {
        switch action {
        case .showCard(let showCardAction):
            let actionId = showCardAction.id ?? ""
            return viewModel.isShowCardExpanded(actionId: actionId)
        default:
            return nil
        }
    }

    /// Extracts ShowCard actions with their IDs and cards
    private var showCardActions: [ShowCardInfo] {
        actions.compactMap { action in
            switch action {
            case .showCard(let showCardAction):
                let actionId = showCardAction.id ?? ""
                return ShowCardInfo(
                    actionId: actionId,
                    title: showCardAction.title ?? "Card",
                    card: showCardAction.card
                )
            default:
                return nil
            }
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

    private var isStretch: Bool {
        hostConfig.actions.actionAlignment.lowercased() == "stretch"
    }

    private var alignment: Alignment {
        let alignmentStr = hostConfig.actions.actionAlignment.lowercased()
        switch alignmentStr {
        case "center":
            return .center
        case "right":
            return .trailing
        case "stretch":
            return .leading
        default:
            return .leading
        }
    }

    enum Orientation {
        case horizontal
        case vertical
    }
}

/// Helper for tracking ShowCard action metadata
private struct ShowCardInfo: Identifiable {
    let actionId: String
    let title: String
    let card: AdaptiveCard
    var id: String { actionId }
}
