import SwiftUI
import ACCore
import ACAccessibility

struct TableView: View {
    let table: Table
    let hostConfig: HostConfig
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(table.rows) { row in
                HStack(spacing: 0) {
                    ForEach(row.cells) { cell in
                        TableCellView(
                            cell: cell,
                            isHeader: table.firstRowAsHeaders == true && table.rows.first?.id == row.id,
                            hostConfig: hostConfig
                        )
                        .frame(maxWidth: .infinity)
                        
                        if table.showGridLines == true && cell.id != row.cells.last?.id {
                            Divider()
                        }
                    }
                }
                
                if table.showGridLines == true && row.id != table.rows.last?.id {
                    Divider()
                }
            }
        }
        .spacing(table.spacing, hostConfig: hostConfig)
        .separator(table.separator, hostConfig: hostConfig)
        .accessibilityContainer(label: "Table")
    }
}

struct TableCellView: View {
    let cell: TableCell
    let isHeader: Bool
    let hostConfig: HostConfig
    
    @EnvironmentObject var viewModel: CardViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(cell.items) { element in
                if viewModel.isElementVisible(elementId: element.elementId) {
                    ElementView(element: element, hostConfig: hostConfig)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: verticalContentAlignment)
        .frame(minHeight: minHeight)
        .padding(8)
        .containerStyle(cell.style, hostConfig: hostConfig)
        .font(isHeader ? .headline : .body)
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
