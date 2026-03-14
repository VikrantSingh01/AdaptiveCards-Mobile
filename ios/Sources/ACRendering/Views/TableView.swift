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
        let rowSpacing: CGFloat = table.showGridLines == true ? 0 : CGFloat(hostConfig.table.cellSpacing / 2)
        let weights = resolveColumnWeights()

        VStack(spacing: rowSpacing) {
            ForEach(Array(table.rows.enumerated()), id: \.offset) { rowIndex, row in
                let isHeaderRow = table.firstRowAsHeaders == true && rowIndex == 0

                HStack(spacing: 0) {
                    ForEach(Array(row.cells.enumerated()), id: \.offset) { cellIndex, cell in
                        let weight = cellIndex < weights.count ? weights[cellIndex] : 1.0
                        let totalWeight = weights.reduce(0, +)
                        TableCellView(
                            cell: cell,
                            isHeader: isHeaderRow,
                            hostConfig: hostConfig,
                            depth: depth,
                            table: table,
                            row: row,
                            columnDef: table.columns?.indices.contains(cellIndex) == true ? table.columns?[cellIndex] : nil,
                            proportionalWidth: totalWeight > 0 ? weight / totalWeight : nil
                        )

                        if table.showGridLines == true && cellIndex < row.cells.count - 1 {
                            Divider()
                        }
                    }
                }
                .if(isHeaderRow) { view in
                    view.background(Color(hex: hostConfig.containerStyles.emphasis.backgroundColor))
                }

                if table.showGridLines == true && rowIndex < table.rows.count - 1 {
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
                // Normalize pixel values to proportional weights
                return max(Double(Int(px.replacingOccurrences(of: "px", with: "")) ?? 1) / 100.0, 0.1)
            case .auto: return 0.5
            case .stretch: return 1.0
            }
        }
    }
}

// MARK: - Table Cell Alignment Environment

/// Environment key to pass table cell horizontal alignment down to child TextBlocks
struct TableCellAlignmentKey: EnvironmentKey {
    static let defaultValue: ACCore.HorizontalAlignment? = nil
}

extension EnvironmentValues {
    var tableCellHorizontalAlignment: ACCore.HorizontalAlignment? {
        get { self[TableCellAlignmentKey.self] }
        set { self[TableCellAlignmentKey.self] = newValue }
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
    var proportionalWidth: Double? = nil

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
                }
            } else {
                Text("")
                    .frame(minHeight: 20)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: combinedAlignment)
        .frame(width: proportionalCellWidth, alignment: combinedAlignment)
        .frame(minHeight: minHeight)
        .padding(.horizontal, CGFloat(hostConfig.table.cellSpacing))
        .padding(.vertical, CGFloat(hostConfig.table.cellSpacing))
        .containerStyle(cell.style, hostConfig: hostConfig)
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
            case .bottom: return .bottom
            default: return .center
            }
        }()

        return Alignment(horizontal: h, vertical: v)
    }

    /// Calculate proportional cell width from the weight ratio and available screen width
    private var proportionalCellWidth: CGFloat? {
        guard let ratio = proportionalWidth, ratio > 0 else { return nil }
        #if canImport(UIKit)
        let screenWidth = UIScreen.main.bounds.width
        #else
        let screenWidth: CGFloat = 375
        #endif
        // Account for card padding + table cell spacing + safe area margins
        let cardPadding = CGFloat(hostConfig.spacing.padding) * 2
        let extraMargin: CGFloat = 16 // scroll view + safe area insets
        let cellSpacing = CGFloat(hostConfig.table.cellSpacing) * 2 // per-cell horizontal padding
        let numCols = max(CGFloat(table?.columns?.count ?? 1), 1)
        let totalCellPadding = cellSpacing * numCols
        let available = screenWidth - cardPadding - extraMargin - totalCellPadding
        return max(available * CGFloat(ratio), 20)
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
