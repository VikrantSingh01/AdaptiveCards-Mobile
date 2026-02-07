import SwiftUI
import ACCore
import ACAccessibility

struct ColumnSetView: View {
    let columnSet: ColumnSet
    let hostConfig: HostConfig
    
    @Environment(\.actionHandler) var actionHandler
    @Environment(\.actionDelegate) var actionDelegate
    @EnvironmentObject var viewModel: CardViewModel
    
    var body: some View {
        HStack(alignment: .top, spacing: CGFloat(hostConfig.spacing.default)) {
            ForEach(Array(columnSet.columns.enumerated()), id: \.offset) { index, column in
                ColumnView(column: column, hostConfig: hostConfig)
                    .frame(width: columnWidth(for: column))
            }
        }
        .frame(minHeight: minHeight)
        .padding(columnSet.bleed == true ? 0 : CGFloat(hostConfig.spacing.padding))
        .containerStyle(columnSet.style, hostConfig: hostConfig)
        .spacing(columnSet.spacing, hostConfig: hostConfig)
        .separator(columnSet.separator, hostConfig: hostConfig)
        .selectAction(columnSet.selectAction) { action in
            actionHandler.handle(action, delegate: actionDelegate, viewModel: viewModel)
        }
        .accessibilityContainer(label: "Column Set")
    }
    
    private func columnWidth(for column: Column) -> CGFloat? {
        guard let width = column.width else { return nil }
        
        switch width {
        case .auto:
            return nil
        case .stretch:
            return nil
        case .weighted(let value):
            // This is a simplified implementation
            // Proper implementation would calculate based on total weights
            return nil
        case .pixels(let value):
            return CGFloat(Int(value.replacingOccurrences(of: "px", with: "")) ?? 0)
        }
    }
    
    private var minHeight: CGFloat? {
        guard let minHeightStr = columnSet.minHeight else { return nil }
        return CGFloat(Int(minHeightStr.replacingOccurrences(of: "px", with: "")) ?? 0)
    }
}
