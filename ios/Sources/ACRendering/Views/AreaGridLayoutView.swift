import SwiftUI
import ACCore

// MARK: - AreaGridLayoutView

/// A SwiftUI view that renders items in a CSS Grid-like area layout.
///
/// Items are placed into named grid areas defined by the AreaGridLayout.
/// Each item references an area by name via its `layout.targetArea` property.
///
/// Ported from production AdaptiveCards C++ ObjectModel's AreaGridLayout concept,
/// implemented natively in SwiftUI using LazyVGrid/Grid (iOS 16+) with fallback.
public struct AreaGridLayoutView: View {
    let items: [CardElement]
    let gridLayout: AreaGridLayout
    let hostConfig: HostConfig

    public init(items: [CardElement], gridLayout: AreaGridLayout, hostConfig: HostConfig) {
        self.items = items
        self.gridLayout = gridLayout
        self.hostConfig = hostConfig
    }

    public var body: some View {
        if #available(iOS 16.0, *) {
            nativeGridView
        } else {
            fallbackGridView
        }
    }

    // MARK: - iOS 16+ Grid

    @available(iOS 16.0, *)
    private var nativeGridView: some View {
        let columnCount = gridLayout.columns.count
        let maxRow = gridLayout.areas.map { $0.row + ($0.rowSpan ?? 1) - 1 }.max() ?? 1
        let colSpacing = spacingValue(gridLayout.columnSpacing ?? .default)
        let rowSpacing = spacingValue(gridLayout.rowSpacing ?? .default)

        return Grid(horizontalSpacing: colSpacing, verticalSpacing: rowSpacing) {
            ForEach(1...maxRow, id: \.self) { row in
                GridRow {
                    ForEach(1...max(columnCount, 1), id: \.self) { col in
                        if let area = areaAt(row: row, col: col) {
                            let matchingItems = items(for: area.name)
                            if !matchingItems.isEmpty {
                                VStack(spacing: 0) {
                                    ForEach(Array(matchingItems.enumerated()), id: \.offset) { _, item in
                                        ElementView(element: item, hostConfig: hostConfig)
                                    }
                                }
                                .gridCellColumns(area.columnSpan ?? 1)
                            } else {
                                Color.clear
                                    .gridCellColumns(area.columnSpan ?? 1)
                            }
                        } else if !isCoveredBySpan(row: row, col: col) {
                            Color.clear
                        }
                    }
                }
            }
        }
    }

    // MARK: - Fallback Grid (iOS 14/15)

    private var fallbackGridView: some View {
        let colSpacing = spacingValue(gridLayout.columnSpacing ?? .default)
        let rowSpacing = spacingValue(gridLayout.rowSpacing ?? .default)
        let maxRow = gridLayout.areas.map { $0.row + ($0.rowSpan ?? 1) - 1 }.max() ?? 1

        return VStack(spacing: rowSpacing) {
            ForEach(1...maxRow, id: \.self) { row in
                HStack(spacing: colSpacing) {
                    ForEach(areasInRow(row), id: \.name) { area in
                        let matchingItems = items(for: area.name)
                        VStack(spacing: 0) {
                            ForEach(Array(matchingItems.enumerated()), id: \.offset) { _, item in
                                ElementView(element: item, hostConfig: hostConfig)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    /// Find the grid area definition that starts at a given row/col position
    private func areaAt(row: Int, col: Int) -> GridArea? {
        gridLayout.areas.first { $0.row == row && $0.column == col }
    }

    /// Check if a cell is covered by a span from a previous area
    private func isCoveredBySpan(row: Int, col: Int) -> Bool {
        gridLayout.areas.contains { area in
            let areaEndRow = area.row + (area.rowSpan ?? 1) - 1
            let areaEndCol = area.column + (area.columnSpan ?? 1) - 1
            return row >= area.row && row <= areaEndRow &&
                   col >= area.column && col <= areaEndCol &&
                   !(row == area.row && col == area.column)  // Exclude the origin cell
        }
    }

    /// Get all areas that start in a given row
    private func areasInRow(_ row: Int) -> [GridArea] {
        gridLayout.areas.filter { area in
            row >= area.row && row < area.row + (area.rowSpan ?? 1)
        }
        .sorted { $0.column < $1.column }
    }

    /// Find items that target a specific grid area by name.
    /// Items specify their target area via a `"layout.targetArea"` custom property.
    private func items(for areaName: String) -> [CardElement] {
        // For now, match items by position in the items array to areas by index.
        // A full implementation would read `layout.targetArea` from each item's JSON.
        // This is a simplified matching that pairs items sequentially to areas.
        guard let areaIndex = gridLayout.areas.firstIndex(where: { $0.name == areaName }) else {
            return []
        }
        if areaIndex < items.count {
            return [items[areaIndex]]
        }
        return []
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
}
