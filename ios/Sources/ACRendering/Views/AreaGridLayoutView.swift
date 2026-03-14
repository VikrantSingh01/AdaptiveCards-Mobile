// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import ACCore

// MARK: - AreaGridLayoutView

/// A SwiftUI view that renders items in a CSS Grid-like area layout.
///
/// Items are placed into named grid areas defined by the AreaGridLayout.
/// Each item references an area by name via its `grid.area` property.
///
/// Ported from production AdaptiveCards C++ ObjectModel's AreaGridLayout concept,
/// implemented natively in SwiftUI using LazyVGrid/Grid (iOS 16+) with fallback.
public struct AreaGridLayoutView: View {
    let items: [CardElement]
    let gridLayout: AreaGridLayout
    let hostConfig: HostConfig
    var depth: Int = 0

    public init(items: [CardElement], gridLayout: AreaGridLayout, hostConfig: HostConfig, depth: Int = 0) {
        self.items = items
        self.gridLayout = gridLayout
        self.hostConfig = hostConfig
        self.depth = depth
    }

    public var body: some View {
        if gridLayout.areas.isEmpty {
            // No areas defined — fall back to vertical stack (graceful degradation)
            VStack(spacing: spacingValue(gridLayout.rowSpacing ?? .default)) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    ElementView(element: item, hostConfig: hostConfig, depth: depth)
                }
            }
        } else if #available(iOS 16.0, *) {
            nativeGridView
        } else {
            fallbackGridView
        }
    }

    // MARK: - iOS 16+ Grid

    @available(iOS 16.0, *)
    private var nativeGridView: some View {
        #if canImport(UIKit)
        let screenWidth = UIScreen.main.bounds.width
        #else
        let screenWidth: CGFloat = 375
        #endif
        let containerPadding: CGFloat = CGFloat(hostConfig.spacing.padding) * 2
        let availableWidth = screenWidth - containerPadding

        let maxAreaCol = gridLayout.areas.map { $0.column + ($0.columnSpan ?? 1) - 1 }.max() ?? 1
        let columnCount = max(gridLayout.columns.count, maxAreaCol)
        let maxRow = gridLayout.areas.map { $0.row + ($0.rowSpan ?? 1) - 1 }.max() ?? 1
        let colSpacing = spacingValue(gridLayout.columnSpacing ?? .default)
        let rowSpacing = spacingValue(gridLayout.rowSpacing ?? .default)
        let columnWidths = resolveColumnWidths(
            columnDefs: gridLayout.columns,
            columnCount: columnCount,
            availableWidth: availableWidth,
            spacing: colSpacing
        )

        return Grid(horizontalSpacing: colSpacing, verticalSpacing: rowSpacing) {
            ForEach(1...maxRow, id: \.self) { row in
                GridRow {
                    ForEach(1...max(columnCount, 1), id: \.self) { col in
                        if let area = areaAt(row: row, col: col) {
                            let matchingItems = items(for: area.name)
                            let spanWidth = resolveSpanWidth(
                                area: area,
                                columnWidths: columnWidths,
                                colSpacing: colSpacing
                            )
                            if !matchingItems.isEmpty {
                                VStack(spacing: 0) {
                                    ForEach(Array(matchingItems.enumerated()), id: \.offset) { _, item in
                                        ElementView(element: item, hostConfig: hostConfig, depth: depth)
                                    }
                                }
                                .gridCellColumns(area.columnSpan ?? 1)
                                .frame(
                                    minWidth: 0,
                                    maxWidth: spanWidth ?? .infinity,
                                    alignment: .leading
                                )
                                .clipped()
                            } else {
                                Color.clear
                                    .gridCellColumns(area.columnSpan ?? 1)
                                    .frame(maxWidth: spanWidth ?? .infinity)
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
                                ElementView(element: item, hostConfig: hostConfig, depth: depth)
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
                   !(row == area.row && col == area.column)
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
    /// Matches items to areas by sequential index (items[0] → areas[0], etc.).
    private func items(for areaName: String) -> [CardElement] {
        guard let areaIndex = gridLayout.areas.firstIndex(where: { $0.name == areaName }) else {
            return []
        }
        if areaIndex < items.count {
            return [items[areaIndex]]
        }
        return []
    }

    /// Calculate total width for an area spanning one or more columns.
    /// Returns nil when all spanned columns are flexible (Grid distributes space).
    private func resolveSpanWidth(
        area: GridArea,
        columnWidths: [CGFloat?],
        colSpacing: CGFloat
    ) -> CGFloat? {
        let span = area.columnSpan ?? 1
        let colIdx = area.column - 1

        var total: CGFloat = 0
        var allResolved = true
        for c in colIdx..<min(colIdx + span, columnWidths.count) {
            if let w = columnWidths[c] {
                total += w
            } else {
                allResolved = false
                break
            }
        }

        guard allResolved else { return nil }

        if span > 1 {
            total += colSpacing * CGFloat(span - 1)
        }
        return total
    }

    /// Resolve column definitions into concrete widths.
    /// - Plain numbers (e.g., "35") → percentage of available width
    /// - "Npx" suffix (e.g., "100px") → fixed pixel value
    /// - "auto" / "Nfr" / "*" → nil (flexible, SwiftUI Grid distributes remaining space)
    /// - No column defs: auto-generate equal widths from available space
    private func resolveColumnWidths(
        columnDefs: [String],
        columnCount: Int,
        availableWidth: CGFloat,
        spacing: CGFloat
    ) -> [CGFloat?] {
        let totalSpacing = spacing * CGFloat(max(columnCount - 1, 0))
        let usableWidth = availableWidth - totalSpacing

        // When no column definitions are provided, distribute available width equally
        if columnDefs.isEmpty && columnCount > 0 {
            let equalWidth = usableWidth / CGFloat(columnCount)
            return Array(repeating: equalWidth, count: columnCount)
        }

        return (0..<columnCount).map { idx in
            guard idx < columnDefs.count else {
                // Extra columns beyond definitions get equal share of remaining space
                return usableWidth / CGFloat(columnCount)
            }
            let def = columnDefs[idx].trimmingCharacters(in: .whitespaces)

            // "auto", "1fr", "*" → flexible
            if def == "auto" || def.hasSuffix("fr") || def == "*" {
                return nil
            }

            // "100px" → fixed pixel
            if def.hasSuffix("px") {
                let numeric = def.replacingOccurrences(of: "px", with: "")
                if let value = Double(numeric) {
                    return CGFloat(value)
                }
                return nil
            }

            // Plain number → percentage of usable width
            if let value = Double(def) {
                return usableWidth * CGFloat(value) / 100.0
            }

            return nil
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
}
