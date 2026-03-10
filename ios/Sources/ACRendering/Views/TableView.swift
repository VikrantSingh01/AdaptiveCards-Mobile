import SwiftUI
import ACCore
import ACAccessibility

struct TableView: View {
    let table: ACCore.Table
    let hostConfig: HostConfig

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(table.rows.enumerated()), id: \.element.id) { rowIndex, row in
                let isHeaderRow = table.firstRowAsHeaders == true && rowIndex == 0

                HStack(spacing: 0) {
                    ForEach(Array(row.cells.enumerated()), id: \.element.id) { cellIndex, cell in
                        TableCellView(
                            cell: cell,
                            isHeader: isHeaderRow,
                            hostConfig: hostConfig
                        )
                        .frame(maxWidth: .infinity)
                        .if(hasColumnWeight(at: cellIndex)) { view in
                            view.frame(maxWidth: .infinity)
                        }

                        if table.showGridLines == true && cellIndex < row.cells.count - 1 {
                            Divider()
                        }
                    }
                }
                .if(isHeaderRow) { view in
                    view.background(Color(hex: "#F5F5F5"))
                }

                if table.showGridLines == true && rowIndex < table.rows.count - 1 {
                    Rectangle()
                        .fill(Color(hex: hostConfig.separator.lineColor))
                        .frame(height: isHeaderRow ? 2 : CGFloat(hostConfig.separator.lineThickness))
                }
            }
        }
        .spacing(table.spacing, hostConfig: hostConfig)
        .separator(table.separator, hostConfig: hostConfig)
        .accessibilityContainer(label: "Table")
    }

    private func hasColumnWeight(at index: Int) -> Bool {
        guard let columns = table.columns, index < columns.count else { return true }
        return columns[index].width != nil
    }
}

struct TableCellView: View {
    let cell: TableCell
    let isHeader: Bool
    let hostConfig: HostConfig

    @EnvironmentObject var viewModel: CardViewModel

    var body: some View {
        VStack(spacing: 0) {
            if let items = cell.items {
                ForEach(items) { element in
                    if viewModel.isElementVisible(elementId: element.elementId) {
                        if isHeader {
                            ElementView(element: element, hostConfig: hostConfig)
                                .font(.system(size: CGFloat(hostConfig.fontSizes.default), weight: .bold))
                        } else {
                            ElementView(element: element, hostConfig: hostConfig)
                        }
                    }
                }
            } else {
                Text("")
                    .frame(minHeight: 20)
            }
        }
        .frame(maxWidth: .infinity, alignment: verticalContentAlignment)
        .frame(minHeight: minHeight)
        .padding(.horizontal, CGFloat(hostConfig.table.cellSpacing))
        .padding(.vertical, CGFloat(hostConfig.table.cellSpacing / 2))
        .containerStyle(cell.style, hostConfig: hostConfig)
    }

    private var verticalContentAlignment: Alignment {
        guard let alignment = cell.verticalContentAlignment else {
            return .center
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
        guard let minHeightStr = cell.minHeight else { return nil }
        return CGFloat(Int(minHeightStr.replacingOccurrences(of: "px", with: "")) ?? 0)
    }
}
