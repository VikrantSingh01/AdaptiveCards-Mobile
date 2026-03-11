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

    public init(items: [CardElement], flowLayout: FlowLayout, hostConfig: HostConfig) {
        self.items = items
        self.flowLayout = flowLayout
        self.hostConfig = hostConfig
    }

    public var body: some View {
        let colSpacing = spacingValue(flowLayout.columnSpacing ?? .default)
        let rowSpacing = spacingValue(flowLayout.rowSpacing ?? .default)

        FlowLayoutContainer(horizontalSpacing: colSpacing, verticalSpacing: rowSpacing) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                ElementView(element: item, hostConfig: hostConfig)
                    .modifier(
                        FlowItemModifier(
                            itemWidth: parseSize(flowLayout.itemWidth),
                            minWidth: parseSize(flowLayout.minItemWidth),
                            maxWidth: parseSize(flowLayout.maxItemWidth),
                            itemFit: flowLayout.itemFit ?? .fit
                        )
                    )
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

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> LayoutResult {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var sizes: [CGSize] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))

            if currentX + size.width > maxWidth && currentX > 0 {
                // Wrap to next row
                currentX = 0
                currentY += rowHeight + verticalSpacing
                rowHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            sizes.append(size)
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + horizontalSpacing
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

// MARK: - FlowItemModifier

/// Applies width constraints based on FlowLayout's itemWidth and itemFit settings
private struct FlowItemModifier: ViewModifier {
    let itemWidth: CGFloat?
    let minWidth: CGFloat?
    let maxWidth: CGFloat?
    let itemFit: ItemFit

    func body(content: Content) -> some View {
        content
            .frame(width: itemWidth)
            .frame(minWidth: minWidth, maxWidth: maxWidth ?? .infinity)
    }
}
