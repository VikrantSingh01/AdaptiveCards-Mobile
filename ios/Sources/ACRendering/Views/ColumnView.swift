// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
import ACCore
import ACAccessibility

struct ColumnView: View {
    let column: Column
    let hostConfig: HostConfig
    var depth: Int = 0

    @Environment(\.actionHandler) var actionHandler
    @Environment(\.actionDelegate) var actionDelegate
    @Environment(\.widthCategory) var widthCategory
    @EnvironmentObject var viewModel: CardViewModel

    var body: some View {
        let items = column.items ?? []
        let activeLayout = resolveLayout()

        Group {
            switch activeLayout {
            case .flow(let flowLayout):
                FlowLayoutView(items: items, flowLayout: flowLayout, hostConfig: hostConfig, depth: depth)
            case .areaGrid(let gridLayout):
                AreaGridLayoutView(items: items, gridLayout: gridLayout, hostConfig: hostConfig, depth: depth)
            case .none:
                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, element in
                        if viewModel.isElementVisible(elementId: element.elementId) {
                            ElementView(element: element, hostConfig: hostConfig, depth: depth)
                                .padding(.top, index > 0 ? spacingValue(for: element.spacing, hostConfig: hostConfig) : 0)
                                .if(isStretchHeight(element)) { view in
                                    view.frame(maxHeight: .infinity)
                                }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: verticalContentAlignment)
        .frame(minHeight: minHeight)
        .padding(column.style != nil ? CGFloat(hostConfig.spacing.padding) : 0)
        .containerStyle(column.style, hostConfig: hostConfig)
        .selectAction(column.selectAction) { action in
            actionHandler.handle(action, delegate: actionDelegate, viewModel: viewModel)
        }
    }

    private var verticalContentAlignment: Alignment {
        guard let alignment = column.verticalContentAlignment else {
            return .top
        }

        switch alignment {
        case .top:
            return .top
        case .center:
            return .center
        case .bottom:
            return .bottom
        }
    }

    private var minHeight: CGFloat? {
        guard let minHeightStr = column.minHeight else { return nil }
        return CGFloat(Int(minHeightStr.replacingOccurrences(of: "px", with: "")) ?? 0)
    }

    private func resolveLayout() -> ACCore.Layout? {
        guard let layouts = column.layouts else { return nil }
        for layout in layouts {
            let targetWidth: String?
            switch layout {
            case .flow(let flow): targetWidth = flow.targetWidth
            case .areaGrid(let grid): targetWidth = grid.targetWidth
            }
            if shouldShowForTargetWidth(targetWidth, currentCategory: widthCategory) {
                return layout
            }
        }
        return nil
    }

    private func isStretchHeight(_ element: CardElement) -> Bool {
        switch element {
        case .container(let c): return c.height == .stretch
        case .columnSet(let cs): return cs.height == .stretch
        default: return false
        }
    }

    private func spacingValue(for spacing: Spacing?, hostConfig: HostConfig) -> CGFloat {
        guard let spacing = spacing else {
            return CGFloat(hostConfig.spacing.default)
        }
        switch spacing {
        case .none: return 0
        case .extraSmall: return 4
        case .small: return CGFloat(hostConfig.spacing.small)
        case .default: return CGFloat(hostConfig.spacing.default)
        case .medium: return CGFloat(hostConfig.spacing.medium)
        case .large: return CGFloat(hostConfig.spacing.large)
        case .extraLarge: return CGFloat(hostConfig.spacing.extraLarge)
        case .padding: return CGFloat(hostConfig.spacing.padding)
        }
    }
}
