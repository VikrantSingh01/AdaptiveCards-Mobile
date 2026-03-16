// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import ACCore
import ACAccessibility
import ACFluentUI

struct TableView: View {
    let table: ACCore.Table
    let hostConfig: HostConfig
    var depth: Int = 0

    var body: some View {
        let rowSpacing: CGFloat = 0
        let weights = resolveColumnWeights()
        let showGrid = table.showGridLines == true

        VStack(spacing: rowSpacing) {
            ForEach(Array(table.rows.enumerated()), id: \.offset) { rowIndex, row in
                let isHeaderRow = table.firstRowAsHeaders == true && rowIndex == 0

                WeightedRow(weights: weights, spacing: showGrid ? 1 : 0) {
                    ForEach(Array(row.cells.enumerated()), id: \.offset) { cellIndex, cell in
                        TableCellView(
                            cell: cell,
                            isHeader: isHeaderRow,
                            hostConfig: hostConfig,
                            depth: depth,
                            table: table,
                            row: row,
                            columnDef: table.columns?.indices.contains(cellIndex) == true ? table.columns?[cellIndex] : nil
                        )
                        .overlay(alignment: .trailing) {
                            if showGrid && cellIndex < row.cells.count - 1 {
                                Rectangle()
                                    .fill(Color(hex: hostConfig.separator.lineColor))
                                    .frame(width: 1)
                            }
                        }
                    }
                }
                .if(isHeaderRow) { view in
                    view.background(Color(hex: hostConfig.containerStyles.emphasis.backgroundColor))
                }
                .if(!isHeaderRow && row.style != nil) { view in
                    view.background(resolveStyleBackground(row.style))
                }

                if showGrid && rowIndex < table.rows.count - 1 {
                    Rectangle()
                        .fill(Color(hex: hostConfig.separator.lineColor))
                        .frame(height: isHeaderRow ? 2 : CGFloat(hostConfig.separator.lineThickness))
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .containerStyle(table.gridStyle, hostConfig: hostConfig)
        .clipShape(RoundedRectangle(cornerRadius: CGFloat(hostConfig.cornerRadius["table"] ?? 0)))
        .spacing(table.spacing, hostConfig: hostConfig)
        .separator(table.separator, hostConfig: hostConfig)
        .accessibilityContainer(label: "Table")
    }

    /// Resolves a ContainerStyle to its background color (no corner radius for table rows).
    private func resolveStyleBackground(_ style: ContainerStyle?) -> Color {
        guard let style = style else { return .clear }
        let styleConfig: ContainerStyleConfig
        switch style {
        case .default: styleConfig = hostConfig.containerStyles.default
        case .emphasis: styleConfig = hostConfig.containerStyles.emphasis
        case .good: styleConfig = hostConfig.containerStyles.good
        case .attention: styleConfig = hostConfig.containerStyles.attention
        case .warning: styleConfig = hostConfig.containerStyles.warning
        case .accent: styleConfig = hostConfig.containerStyles.accent
        }
        return Color(hex: styleConfig.backgroundColor)
    }

    /// Resolve all column weights for proportional sizing.
    /// Uses the max cell count across all rows if columns aren't explicitly defined.
    private func resolveColumnWeights() -> [Double] {
        let maxCells = table.rows.map { $0.cells.count }.max() ?? 0
        let columnCount = max(table.columns?.count ?? 0, maxCells)
        return (0..<columnCount).map { index in
            guard let columns = table.columns, index < columns.count,
                  let width = columns[index].width else { return 1.0 }
            switch width {
            case .weighted(let w): return w
            case .pixels(let px):
                return max(Double(Int(px.replacingOccurrences(of: "px", with: "")) ?? 1) / 100.0, 0.1)
            case .auto: return 0.5
            case .stretch: return 1.0
            }
        }
    }
}

// MARK: - WeightedRow Layout

/// Custom Layout that distributes available width proportionally based on column weights.
/// This replaces the old screen-width-based calculation and correctly handles tables
/// nested inside flow layouts, containers, or other constrained parents.
private struct WeightedRow: SwiftUI.Layout {
    let weights: [Double]
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let availableWidth = proposal.width ?? 300
        let totalSpacing = spacing * CGFloat(max(subviews.count - 1, 0))
        let contentWidth = max(availableWidth - totalSpacing, 0)
        let totalWeight = weights.reduce(0, +)

        var maxHeight: CGFloat = 0
        for (index, subview) in subviews.enumerated() {
            let weight = index < weights.count ? weights[index] : 1.0
            let cellWidth = totalWeight > 0 ? contentWidth * (weight / totalWeight) : contentWidth / CGFloat(max(subviews.count, 1))
            let size = subview.sizeThatFits(ProposedViewSize(width: cellWidth, height: nil))
            maxHeight = max(maxHeight, size.height)
        }

        return CGSize(width: availableWidth, height: maxHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let totalSpacing = spacing * CGFloat(max(subviews.count - 1, 0))
        let contentWidth = max(bounds.width - totalSpacing, 0)
        let totalWeight = weights.reduce(0, +)

        var x = bounds.minX
        for (index, subview) in subviews.enumerated() {
            let weight = index < weights.count ? weights[index] : 1.0
            let cellWidth = totalWeight > 0 ? contentWidth * (weight / totalWeight) : contentWidth / CGFloat(max(subviews.count, 1))
            subview.place(
                at: CGPoint(x: x, y: bounds.minY),
                proposal: ProposedViewSize(width: cellWidth, height: bounds.height)
            )
            x += cellWidth + spacing
        }
    }
}

// MARK: - Table Cell Environment

/// Environment key to pass table cell horizontal alignment down to child TextBlocks
struct TableCellAlignmentKey: EnvironmentKey {
    static let defaultValue: ACCore.HorizontalAlignment? = nil
}

/// Environment key to indicate we're inside a table cell (enables text wrapping)
struct IsInsideTableCellKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var tableCellHorizontalAlignment: ACCore.HorizontalAlignment? {
        get { self[TableCellAlignmentKey.self] }
        set { self[TableCellAlignmentKey.self] = newValue }
    }

    var isInsideTableCell: Bool {
        get { self[IsInsideTableCellKey.self] }
        set { self[IsInsideTableCellKey.self] = newValue }
    }
}

struct TableCellView: View {
    let cell: TableCell
    let isHeader: Bool
    let hostConfig: HostConfig
    var depth: Int = 0
    var table: ACCore.Table? = nil
    var row: ACCore.TableRow? = nil
    var columnDef: TableColumnDefinition? = nil

    @EnvironmentObject var viewModel: CardViewModel

    var body: some View {
        Group {
            if let items = cell.items {
                if let layout = cell.layout {
                    switch layout {
                    case .flow(let flowLayout):
                        FlowLayoutView(items: items, flowLayout: flowLayout, hostConfig: hostConfig, depth: depth)
                    case .areaGrid(let gridLayout):
                        AreaGridLayoutView(items: items, gridLayout: gridLayout, hostConfig: hostConfig, depth: depth)
                    }
                } else {
                    VStack(alignment: resolvedHStackAlignment, spacing: 0) {
                        ForEach(items) { element in
                            if viewModel.isElementVisible(elementId: element.elementId) {
                                if isHeader {
                                    ElementView(element: element, hostConfig: hostConfig, depth: depth)
                                        .font(.system(size: CGFloat(hostConfig.fontSizes.default), weight: headerFontWeight))
                                } else {
                                    ElementView(element: element, hostConfig: hostConfig, depth: depth)
                                }
                            }
                        }
                    }
                    .environment(\.tableCellHorizontalAlignment, resolvedACHorizontalAlignment)
                    .environment(\.isInsideTableCell, true)
                }
            } else {
                Text("")
                    .frame(minHeight: 20)
            }
        }
        .frame(maxHeight: .infinity, alignment: combinedAlignment)
        .frame(minHeight: minHeight)
        .clipped()
        .frame(maxWidth: .infinity, alignment: combinedAlignment)
        .padding(.horizontal, CGFloat(hostConfig.table.cellSpacing))
        .padding(.vertical, 4)
        .background(cellStyleBackground)
    }

    /// Resolved horizontal alignment as ACCore enum, for environment propagation
    private var resolvedACHorizontalAlignment: ACCore.HorizontalAlignment? {
        cell.horizontalCellContentAlignment
            ?? columnDef?.horizontalCellContentAlignment
            ?? row?.horizontalCellContentAlignment
            ?? table?.horizontalCellContentAlignment
    }

    private var resolvedHStackAlignment: SwiftUI.HorizontalAlignment {
        let alignment = cell.horizontalCellContentAlignment
            ?? columnDef?.horizontalCellContentAlignment
            ?? row?.horizontalCellContentAlignment
            ?? table?.horizontalCellContentAlignment
        switch alignment {
        case .center: return .center
        case .right: return .trailing
        default: return .leading
        }
    }

    private var combinedAlignment: Alignment {
        let h: SwiftUI.HorizontalAlignment = {
            let alignment = cell.horizontalCellContentAlignment
                ?? columnDef?.horizontalCellContentAlignment
                ?? row?.horizontalCellContentAlignment
                ?? table?.horizontalCellContentAlignment
            switch alignment {
            case .center: return .center
            case .right: return .trailing
            default: return .leading
            }
        }()

        let v: SwiftUI.VerticalAlignment = {
            let alignment = cell.verticalContentAlignment
                ?? columnDef?.verticalCellContentAlignment
                ?? row?.verticalCellContentAlignment
                ?? table?.verticalCellContentAlignment
            switch alignment {
            case .top: return .top
            case .center: return .center
            case .bottom: return .bottom
            default: return .top
            }
        }()

        return Alignment(horizontal: h, vertical: v)
    }

    /// Cell style background color without corner radius (flat for table cells)
    private var cellStyleBackground: Color {
        guard let style = cell.style else { return .clear }
        let styleConfig: ContainerStyleConfig
        switch style {
        case .default: styleConfig = hostConfig.containerStyles.default
        case .emphasis: styleConfig = hostConfig.containerStyles.emphasis
        case .good: styleConfig = hostConfig.containerStyles.good
        case .attention: styleConfig = hostConfig.containerStyles.attention
        case .warning: styleConfig = hostConfig.containerStyles.warning
        case .accent: styleConfig = hostConfig.containerStyles.accent
        }
        return Color(hex: styleConfig.backgroundColor)
    }

    private var minHeight: CGFloat? {
        guard let minHeightStr = cell.minHeight else { return nil }
        return CGFloat(Int(minHeightStr.replacingOccurrences(of: "px", with: "")) ?? 0)
    }

    private var headerFontWeight: Font.Weight {
        let weightValue = hostConfig.fontWeights.bolder
        switch weightValue {
        case 100...199: return .ultraLight
        case 200...299: return .light
        case 300...399: return .regular
        case 400...499: return .regular
        case 500...599: return .medium
        case 600...699: return .semibold
        case 700...799: return .bold
        default: return .heavy
        }
    }
}
