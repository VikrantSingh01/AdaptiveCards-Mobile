import SwiftUI
import ACCore

// MARK: - FlowLayoutView

/// A SwiftUI view that renders items in a flow/wrap layout.
///
/// Items flow horizontally and wrap to new rows when they exceed the available width.
/// Supports configurable item sizing, spacing, and alignment.
///
/// Ported from production AdaptiveCards C++ ObjectModel's FlowLayout concept,
/// implemented natively in SwiftUI using GeometryReader-based layout calculation.
public struct FlowLayoutView: View {
    let items: [CardElement]
    let flowLayout: FlowLayout
    let hostConfig: HostConfig

    @State private var totalHeight: CGFloat = .zero

    public init(items: [CardElement], flowLayout: FlowLayout, hostConfig: HostConfig) {
        self.items = items
        self.flowLayout = flowLayout
        self.hostConfig = hostConfig
    }

    public var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        let colSpacing = spacingValue(flowLayout.columnSpacing ?? .default)
        let rowSpacing = spacingValue(flowLayout.rowSpacing ?? .default)

        return ZStack(alignment: alignment(for: flowLayout.horizontalAlignment ?? .left)) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                ElementView(element: item, hostConfig: hostConfig)
                    .fixedSize(horizontal: flowLayout.itemFit == .fit, vertical: false)
                    .frame(
                        minWidth: parseSize(flowLayout.minItemWidth),
                        maxWidth: parseSize(flowLayout.maxItemWidth) ?? .infinity
                    )
                    .modifier(
                        FlowItemModifier(
                            itemWidth: parseSize(flowLayout.itemWidth),
                            itemFit: flowLayout.itemFit ?? .fit
                        )
                    )
                    .alignmentGuide(.leading) { dimension in
                        if abs(width - dimension.width) > geometry.size.width {
                            width = 0
                            height -= rowSpacing + dimension.height
                        }
                        let result = width
                        if index == items.count - 1 {
                            width = 0
                        } else {
                            width -= dimension.width + colSpacing
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if index == items.count - 1 {
                            height = 0
                        }
                        return result
                    }
            }
        }
        .background(
            GeometryReader { geo -> Color in
                DispatchQueue.main.async {
                    totalHeight = geo.size.height
                }
                return Color.clear
            }
        )
    }

    private func alignment(for horizontal: ACCore.HorizontalAlignment) -> Alignment {
        switch horizontal {
        case .left: return .leading
        case .center: return .center
        case .right: return .trailing
        }
    }

    private func spacingValue(_ spacing: Spacing) -> CGFloat {
        switch spacing {
        case .none: return 0
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

// MARK: - FlowItemModifier

/// Applies width constraints based on FlowLayout's itemWidth and itemFit settings
private struct FlowItemModifier: ViewModifier {
    let itemWidth: CGFloat?
    let itemFit: ItemFit

    func body(content: Content) -> some View {
        if let width = itemWidth {
            content.frame(width: width)
        } else if itemFit == .fill {
            content.frame(maxWidth: .infinity)
        } else {
            content
        }
    }
}
