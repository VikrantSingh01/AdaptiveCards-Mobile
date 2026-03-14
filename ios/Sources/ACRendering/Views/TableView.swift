// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
import ACCore
import ACAccessibility
import ACFluentUI

struct TableView: View {
    let table: ACCore.Table
    let hostConfig: HostConfig
    var depth: Int = 0

    var body: some View {
        let rowSpacing: CGFloat = table.showGridLines == true ? 0 : CGFloat(hostConfig.table.cellSpacing / 2)

        VStack(spacing: rowSpacing) {
            ForEach(Array(table.rows.enumerated()), id: \.offset) { rowIndex, row in
                let isHeaderRow = table.firstRowAsHeaders == true && rowIndex == 0

                HStack(spacing: 0) {
                    ForEach(Array(row.cells.enumerated()), id: \.offset) { cellIndex, cell in
                        let weight = columnWeight(at: cellIndex)
                        TableCellView(
                            cell: cell,
                            isHeader: isHeaderRow,
                            hostConfig: hostConfig,
                            depth: depth,
                            table: table,
                            row: row,
                            columnDef: table.columns?.indices.contains(cellIndex) == true ? table.columns?[cellIndex] : nil
                        )
                        .frame(maxWidth: .infinity)
                        .layoutPriority(columnWeight(at: cellIndex))

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

    private func columnWeight(at index: Int) -> Double {
        guard let columns = table.columns, index < columns.count,
              let width = columns[index].width else { return 1.0 }
        switch width {
        case .weighted(let w): return w
        case .pixels(let px):
            return Double(Int(px.replacingOccurrences(of: "px", with: "")) ?? 1)
        case .auto: return 0.5
        case .stretch: return 1.0
        }
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
                }
            } else {
                Text("")
                    .frame(minHeight: 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: combinedAlignment)
        .frame(minHeight: minHeight)
        .padding(.horizontal, CGFloat(hostConfig.table.cellSpacing))
        .padding(.vertical, CGFloat(hostConfig.table.cellSpacing))
        .containerStyle(cell.style, hostConfig: hostConfig)
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
