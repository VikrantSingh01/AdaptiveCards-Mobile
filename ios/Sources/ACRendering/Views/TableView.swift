import SwiftUI
import ACCore
import ACAccessibility
import ACFluentUI

struct TableView: View {
    let table: ACCore.Table
    let hostConfig: HostConfig

    var body: some View {
        let rowSpacing: CGFloat = table.showGridLines == true ? 0 : CGFloat(hostConfig.table.cellSpacing / 2)

        VStack(spacing: rowSpacing) {
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
                    view.background(Color(hex: hostConfig.containerStyles.emphasis.backgroundColor))
                }

                if table.showGridLines == true && rowIndex < table.rows.count - 1 {
                    Rectangle()
                        .fill(Color(hex: hostConfig.separator.lineColor))
                        .frame(height: isHeaderRow ? 2 : CGFloat(hostConfig.separator.lineThickness))
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: CGFloat(hostConfig.cornerRadius["table"] ?? 0)))
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
                                .font(.system(size: CGFloat(hostConfig.fontSizes.default), weight: headerFontWeight))
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: verticalContentAlignment)
        .frame(minHeight: minHeight)
        .padding(.horizontal, CGFloat(hostConfig.table.cellSpacing))
        .padding(.vertical, CGFloat(hostConfig.table.cellSpacing))
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
