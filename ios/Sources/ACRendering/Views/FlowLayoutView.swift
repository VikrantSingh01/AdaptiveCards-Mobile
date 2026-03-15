// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
import ACCore

// MARK: - FlowLayoutView

/// A SwiftUI view that renders items in a flow/wrap layout.
///
/// Items flow horizontally and wrap to new rows when they exceed the available width.
/// Supports configurable item sizing, spacing, and alignment.
///
/// Uses SwiftUI's Layout protocol (iOS 16+) for proper flow layout calculation.
public struct FlowLayoutView: View {
    let items: [CardElement]
    let flowLayout: FlowLayout
    let hostConfig: HostConfig
    var depth: Int = 0

    public init(items: [CardElement], flowLayout: FlowLayout, hostConfig: HostConfig, depth: Int = 0) {
        self.items = items
        self.flowLayout = flowLayout
        self.hostConfig = hostConfig
        self.depth = depth
    }

    public var body: some View {
        let colSpacing = spacingValue(flowLayout.columnSpacing ?? .default)
        let rowSpacing = spacingValue(flowLayout.rowSpacing ?? .default)

        FlowLayoutContainer(
            horizontalSpacing: colSpacing,
            verticalSpacing: rowSpacing,
            itemWidth: parseSize(flowLayout.itemWidth),
            minItemWidth: parseSize(flowLayout.minItemWidth),
            maxItemWidth: parseSize(flowLayout.maxItemWidth)
        ) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                ElementView(element: item, hostConfig: hostConfig, depth: depth)
            }
        }
    }

    private func spacingValue(_ spacing: Spacing) -> CGFloat {
        switch spacing {
        case .none: return 0
        case .extraSmall: return 4
        case .small: return CGFloat(hostConfig.spacing.small)
        case .default: return CGFloat(hostConfig.spacing.`default`)
        case .medium: return CGFloat(hostConfig.spacing.medium)
        case .large: return CGFloat(hostConfig.spacing.large)
        case .extraLarge: return CGFloat(hostConfig.spacing.extraLarge)
        case .padding: return CGFloat(hostConfig.spacing.padding)
        }
    }

    private func parseSize(_ value: String?) -> CGFloat? {
        guard let value = value else { return nil }
        let cleaned = value.replacingOccurrences(of: "px", with: "")
        return Double(cleaned).map { CGFloat($0) }
    }
}

// MARK: - FlowLayoutContainer (Layout protocol)

/// Custom Layout that arranges children in a flow/wrap pattern
private struct FlowLayoutContainer: SwiftUI.Layout {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    let itemWidth: CGFloat?
    let minItemWidth: CGFloat?
    let maxItemWidth: CGFloat?

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() where index < subviews.count {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: ProposedViewSize(result.sizes[index])
            )
        }
    }

    private struct LayoutResult {
        var size: CGSize
        var positions: [CGPoint]
        var sizes: [CGSize]
    }

    /// Calculate dynamic item width based on flow layout constraints.
    /// Matches Android FlowRow calculatedItemWidthPx logic.
    private func calculatedItemWidth(available: CGFloat) -> CGFloat? {
        guard available < .infinity else { return nil }

        // When itemWidth or minItemWidth is specified, calculate columns and distribute
        let minW = minItemWidth ?? itemWidth
        if let minW = minW, minW > 0 {
            let maxCols = max(1, Int((available + horizontalSpacing) / (minW + horizontalSpacing)))
            var w = (available - CGFloat(maxCols - 1) * horizontalSpacing) / CGFloat(maxCols)
            if let maxW = maxItemWidth { w = min(w, maxW) }
            return w
        }

        // When only maxItemWidth is specified, use it directly as item width constraint.
        // This matches Android behavior where items are measured at their intrinsic width
        // capped by maxItemWidth, allowing multiple columns when items fit.
        if let maxW = maxItemWidth, maxW > 0 {
            return maxW
        }

        return nil
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> LayoutResult {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var sizes: [CGSize] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        let dynWidth = calculatedItemWidth(available: maxWidth)

        for subview in subviews {
            // Measure with unspecified width to get ideal/natural size.
            let idealSize = subview.sizeThatFits(ProposedViewSize(width: nil, height: nil))

            // Determine item width using the Android FlowRow pattern:
            // Use ideal width when it's a reasonable intrinsic value (1..<maxWidth).
            // Fall back to measuring at available width for flexible items
            // (e.g., those using frame(maxWidth: .infinity)) that report
            // a tiny or oversized ideal width.
            var itemWidth: CGFloat
            if let dynWidth = dynWidth {
                // Use calculated dynamic width (from itemWidth/minItemWidth/maxItemWidth)
                itemWidth = dynWidth
            } else if idealSize.width >= 1 && idealSize.width < maxWidth && maxWidth < .infinity {
                itemWidth = idealSize.width
            } else if maxWidth < .infinity {
                let concreteSize = subview.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
                itemWidth = min(concreteSize.width, maxWidth)
            } else {
                itemWidth = idealSize.width
            }
            if itemWidth < 1 && maxWidth < .infinity {
                itemWidth = maxWidth
            }

            // Re-measure at final width to get correct height.
            // Nested flow layouts and tables need this to compute wrapped height.
            let clampedSize: CGSize
            let measured = subview.sizeThatFits(ProposedViewSize(width: itemWidth, height: nil))
            clampedSize = CGSize(width: itemWidth, height: measured.height)

            if currentX + clampedSize.width > maxWidth && currentX > 0 {
                // Wrap to next row
                currentX = 0
                currentY += rowHeight + verticalSpacing
                rowHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            sizes.append(clampedSize)
            rowHeight = max(rowHeight, clampedSize.height)
            currentX += clampedSize.width + horizontalSpacing
            totalWidth = max(totalWidth, currentX - horizontalSpacing)
        }

        let totalHeight = currentY + rowHeight
        return LayoutResult(
            size: CGSize(width: totalWidth, height: totalHeight),
            positions: positions,
            sizes: sizes
        )
    }
}

