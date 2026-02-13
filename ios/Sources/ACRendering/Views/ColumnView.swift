import SwiftUI
import ACCore
import ACAccessibility

struct ColumnView: View {
    let column: Column
    let hostConfig: HostConfig
    
    @Environment(\.actionHandler) var actionHandler
    @Environment(\.actionDelegate) var actionDelegate
    @EnvironmentObject var viewModel: CardViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if let items = column.items {
                ForEach(items) { element in
                    if viewModel.isElementVisible(elementId: element.elementId) {
                        ElementView(element: element, hostConfig: hostConfig)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: verticalContentAlignment)
        .frame(minHeight: minHeight)
        .padding(column.bleed == true ? 0 : CGFloat(hostConfig.spacing.padding))
        .containerStyle(column.style, hostConfig: hostConfig)
        .selectAction(column.selectAction) { action in
            actionHandler.handle(action, delegate: actionDelegate, viewModel: viewModel)
        }
    }
    
    private var verticalContentAlignment: Alignment {
        guard let alignment = column.verticalContentAlignment else {
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
        guard let minHeightStr = column.minHeight else { return nil }
        return CGFloat(Int(minHeightStr.replacingOccurrences(of: "px", with: "")) ?? 0)
    }
}
