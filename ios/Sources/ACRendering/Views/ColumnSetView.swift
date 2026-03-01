import SwiftUI
import ACCore
import ACAccessibility

/// Layout that distributes column widths proportionally based on weights.
/// - Weighted columns get space proportional to their weight
/// - Auto columns get their ideal size
/// - Stretch/default columns share remaining space equally
struct ProportionalColumnLayout: SwiftUI.Layout {
    let columns: [Column]
    let columnSpacing: CGFloat

    /// Total spacing consumed by gaps between columns
    private var totalSpacing: CGFloat {
        columns.count > 1 ? CGFloat(columns.count - 1) * columnSpacing : 0
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: SwiftUI.Layout.Subviews, cache: inout ()) -> CGSize {
        let widths = computeWidths(totalWidth: proposal.width ?? 0, subviews: subviews)
        // Use nil height proposal so columns report their natural/intrinsic height
        // rather than expanding to fill the proposed height from the parent
        let height = zip(subviews, widths).map { subview, width in
            subview.sizeThatFits(ProposedViewSize(width: width, height: nil)).height
        }.max() ?? 0
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: SwiftUI.Layout.Subviews, cache: inout ()) {
        let widths = computeWidths(totalWidth: bounds.width, subviews: subviews)
        var x = bounds.minX
        for (index, subview) in subviews.enumerated() {
            let width = widths[index]
            let childProposal = ProposedViewSize(width: width, height: bounds.height)
            subview.place(at: CGPoint(x: x, y: bounds.minY), proposal: childProposal)
            x += width + (index < subviews.count - 1 ? columnSpacing : 0)
        }
    }

    private func computeWidths(totalWidth: CGFloat, subviews: SwiftUI.Layout.Subviews) -> [CGFloat] {
        guard !columns.isEmpty else { return [] }

        var widths = [CGFloat](repeating: 0, count: columns.count)
        // Subtract inter-column spacing from available width
        var remainingWidth = totalWidth - totalSpacing

        // Pass 1: Fixed pixel widths
        for (i, col) in columns.enumerated() {
            if case .pixels(let v) = col.width {
                let px = CGFloat(Int(v.replacingOccurrences(of: "px", with: "")) ?? 0)
                widths[i] = px
                remainingWidth -= px
            }
        }

        // Pass 2: Auto columns get their ideal width
        for (i, col) in columns.enumerated() {
            if case .auto = col.width {
                let ideal = i < subviews.count
                    ? subviews[i].sizeThatFits(.unspecified).width
                    : 0
                widths[i] = ideal
                remainingWidth -= ideal
            }
        }

        // Pass 3: Weighted and stretch/default share remaining space
        let totalWeight = columns.reduce(0.0) { sum, col in
            guard let w = col.width else { return sum + 1.0 }
            switch w {
            case .weighted(let v): return sum + v
            case .stretch: return sum + 1.0
            case .pixels, .auto: return sum
            }
        }

        if totalWeight > 0 {
            for (i, col) in columns.enumerated() {
                let weight: Double
                if col.width == nil {
                    weight = 1.0
                } else if case .weighted(let v) = col.width {
                    weight = v
                } else if case .stretch = col.width {
                    weight = 1.0
                } else {
                    continue
                }
                widths[i] = max(0, remainingWidth * CGFloat(weight / totalWeight))
            }
        }

        return widths
    }
}

struct ColumnSetView: View {
    let columnSet: ColumnSet
    let hostConfig: HostConfig

    @Environment(\.actionHandler) var actionHandler
    @Environment(\.actionDelegate) var actionDelegate
    @EnvironmentObject var viewModel: CardViewModel

    var body: some View {
        ProportionalColumnLayout(columns: columnSet.columns, columnSpacing: 0) {
            ForEach(columnSet.columns, id: \.stableId) { column in
                ColumnView(column: column, hostConfig: hostConfig)
            }
        }
        .frame(minHeight: minHeight)
        .containerStyle(columnSet.style, hostConfig: hostConfig)
        .spacing(columnSet.spacing, hostConfig: hostConfig)
        .separator(columnSet.separator, hostConfig: hostConfig)
        .selectAction(columnSet.selectAction) { action in
            actionHandler.handle(action, delegate: actionDelegate, viewModel: viewModel)
        }
        .accessibilityContainer(label: "Column Set")
    }

    private var minHeight: CGFloat? {
        guard let minHeightStr = columnSet.minHeight else { return nil }
        return CGFloat(Int(minHeightStr.replacingOccurrences(of: "px", with: "")) ?? 0)
    }
}
