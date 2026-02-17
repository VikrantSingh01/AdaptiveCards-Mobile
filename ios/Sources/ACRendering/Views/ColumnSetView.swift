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
            ForEach(columnSet.columns, id: \.stableId) { column in
                ColumnView(column: column, hostConfig: hostConfig)
                    .frame(width: fixedWidth(for: column))
                    .if(isWeighted(column)) { view in
                        view.frame(maxWidth: .infinity)
                    }
                    .if(isStretch(column)) { view in
                        view.frame(maxWidth: .infinity)
                    }
                    .if(isAuto(column)) { view in
                        view.fixedSize(horizontal: true, vertical: false)
                    }
            }
        }
        .frame(minHeight: minHeight)
        .containerStyle(columnSet.style, hostConfig: hostConfig)
        .spacing(columnSet.spacing, hostConfig: hostConfig)
        .separator(columnSet.separator, hostConfig: hostConfig)
        .selectAction(columnSet.selectAction) { action in
            actionHandler.handle(action, delegate: actionDelegate, viewModel: viewModel)
        }
        .accessibilityContainer(label: "Column Set")
    }

    private func fixedWidth(for column: Column) -> CGFloat? {
        guard let width = column.width else { return nil }

        switch width {
        case .pixels(let value):
            return CGFloat(Int(value.replacingOccurrences(of: "px", with: "")) ?? 0)
        default:
            return nil
        }
    }

    private func isWeighted(_ column: Column) -> Bool {
        guard let width = column.width else { return true } // default is stretch-like
        switch width {
        case .weighted: return true
        default: return false
        }
    }

    private func isStretch(_ column: Column) -> Bool {
        guard let width = column.width else { return true }
        switch width {
        case .stretch: return true
        default: return false
        }
    }

    private func isAuto(_ column: Column) -> Bool {
        guard let width = column.width else { return false }
        switch width {
        case .auto: return true
        default: return false
        }
    }

    private var minHeight: CGFloat? {
        guard let minHeightStr = columnSet.minHeight else { return nil }
        return CGFloat(Int(minHeightStr.replacingOccurrences(of: "px", with: "")) ?? 0)
    }
}
