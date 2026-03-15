// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
import ACCore
import ACActions
import ACAccessibility
import ACFluentUI

struct ActionSetView: View {
    let actions: [CardAction]
    let hostConfig: HostConfig
    var depth: Int = 0

    @Environment(\.actionHandler) var actionHandler
    @Environment(\.actionDelegate) var actionDelegate
    @Environment(\.layoutDirection) var layoutDirection
    @EnvironmentObject var viewModel: CardViewModel

    var body: some View {
        VStack(spacing: CGFloat(hostConfig.actions.buttonSpacing)) {
            Group {
                if orientation == .horizontal {
                    ActionFlowLayout(spacing: CGFloat(hostConfig.actions.buttonSpacing), isRTL: layoutDirection == .rightToLeft) {
                        actionContent
                    }
                } else {
                    VStack(spacing: CGFloat(hostConfig.actions.buttonSpacing)) {
                        actionContent
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: alignment)

            // Render expanded ShowCard sub-cards inline
            ForEach(showCardActions, id: \.id) { action in
                if case .showCard(let showCardAction) = action,
                   viewModel.isShowCardExpanded(actionId: action.id) {
                    VStack(alignment: .leading, spacing: CGFloat(hostConfig.spacing.default)) {
                        ForEach(Array((showCardAction.card.body ?? []).enumerated()), id: \.offset) { _, element in
                            ElementView(element: element, hostConfig: hostConfig, depth: depth)
                        }
                        // Render sub-card actions if present
                        if let subActions = showCardAction.card.actions, !subActions.isEmpty {
                            ActionSetView(actions: subActions, hostConfig: hostConfig, depth: depth)
                        }
                    }
                    .padding(CGFloat(hostConfig.spacing.padding))
                    .background(
                        RoundedRectangle(cornerRadius: CGFloat(hostConfig.cornerRadius["container"] ?? 4))
                            .fill(Color(hex: hostConfig.containerStyles.emphasis.backgroundColor))
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .accessibilityContainer(label: "Actions")
    }

    /// All ShowCard actions from the action list
    private var showCardActions: [CardAction] {
        actions.filter {
            if case .showCard = $0 { return true }
            return false
        }
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
            actionButtonView(for: action)
                .fixedSize(horizontal: !isStretch, vertical: false)
                .if(isStretch) { view in
                    view.frame(maxWidth: .infinity)
                }
        }

        if !overflowActions.isEmpty {
            overflowMenu
        }
    }

    @ViewBuilder
    private func actionButtonView(for action: CardAction) -> some View {
        if case .popover(let popoverAction) = action {
            let actionId = popoverAction.id ?? "popover_\(popoverAction.title ?? action.id)"
            ActionButton(action: action, hostConfig: hostConfig) {
                actionHandler.handle(action, delegate: actionDelegate, viewModel: viewModel)
            }
            .sheet(isPresented: viewModel.popoverBinding(actionId: actionId)) {
                PopoverContentView(
                    content: popoverAction.content,
                    title: popoverAction.title,
                    hostConfig: hostConfig,
                    depth: depth
                )
                .environmentObject(viewModel)
                .environment(\.actionHandler, actionHandler)
                .environment(\.actionDelegate, actionDelegate)
            }
        } else {
            ActionButton(action: action, hostConfig: hostConfig) {
                actionHandler.handle(action, delegate: actionDelegate, viewModel: viewModel)
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
                .padding(.horizontal, CGFloat(hostConfig.spacing.medium))
                .padding(.vertical, CGFloat(hostConfig.spacing.small) * 0.75)
                .foregroundColor(Color(hex: hostConfig.containerStyles.default.foregroundColors.default.default))
                .overlay(
                    RoundedRectangle(cornerRadius: CGFloat(hostConfig.cornerRadius["container"] ?? 4))
                        .stroke(Color(hex: hostConfig.containerStyles.default.foregroundColors.default.subtle), lineWidth: CGFloat(hostConfig.separator.lineThickness))
                )
                .clipShape(RoundedRectangle(cornerRadius: CGFloat(hostConfig.cornerRadius["container"] ?? 4)))
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

// MARK: - ActionFlowLayout

/// A wrapping flow layout for action buttons, matching Android's FlowRow behavior.
/// Buttons flow horizontally and wrap to the next row when they exceed available width.
private struct ActionFlowLayout: SwiftUI.Layout {
    let spacing: CGFloat
    let isRTL: Bool

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() where index < subviews.count {
            let x: CGFloat
            if isRTL {
                x = bounds.maxX - position.x - result.sizes[index].width
            } else {
                x = bounds.minX + position.x
            }
            subviews[index].place(
                at: CGPoint(x: x, y: bounds.minY + position.y),
                proposal: ProposedViewSize(result.sizes[index])
            )
        }
    }

    private struct LayoutResult {
        var size: CGSize
        var positions: [CGPoint]
        var sizes: [CGSize]
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> LayoutResult {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var sizes: [CGSize] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        // Cap each item to 1/3 of available width when 3+ items, matching Android's 3-column FlowRow
        let maxItemWidth: CGFloat? = subviews.count >= 3 && maxWidth.isFinite
            ? (maxWidth - 2 * spacing) / 3
            : nil

        for subview in subviews {
            let intrinsicSize = subview.sizeThatFits(ProposedViewSize(width: nil, height: nil))
            let cappedWidth = maxItemWidth.map { min(intrinsicSize.width, $0) } ?? intrinsicSize.width
            let size = CGSize(width: cappedWidth, height: subview.sizeThatFits(ProposedViewSize(width: cappedWidth, height: nil)).height)

            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            sizes.append(size)
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX - spacing)
        }

        let totalHeight = currentY + rowHeight
        return LayoutResult(
            size: CGSize(width: totalWidth, height: totalHeight),
            positions: positions,
            sizes: sizes
        )
    }
}
