import SwiftUI
import ACCore
import ACAccessibility

struct ContainerView: View {
    let container: Container
    let hostConfig: HostConfig

    @Environment(\.actionHandler) var actionHandler
    @Environment(\.actionDelegate) var actionDelegate
    @EnvironmentObject var viewModel: CardViewModel

    var body: some View {
        VStack(spacing: 0) {
            if let items = container.items {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, element in
                    if viewModel.isElementVisible(elementId: element.elementId) {
                        ElementView(element: element, hostConfig: hostConfig)
                            .padding(.top, index > 0 && element.spacing == nil ? CGFloat(hostConfig.spacing.default) : 0)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: verticalContentAlignment)
        .frame(minHeight: minHeight)
        .padding(container.bleed == true ? 0 : (container.style != nil ? CGFloat(hostConfig.spacing.padding) : 0))
        .containerStyle(container.style, hostConfig: hostConfig)
        .spacing(container.spacing, hostConfig: hostConfig)
        .separator(container.separator, hostConfig: hostConfig)
        .selectAction(container.selectAction) { action in
            actionHandler.handle(action, delegate: actionDelegate, viewModel: viewModel)
        }
        .accessibilityContainer(label: "Container")
    }

    private var verticalContentAlignment: Alignment {
        guard let alignment = container.verticalContentAlignment else {
            return .top
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
        guard let minHeightStr = container.minHeight else { return nil }
        return CGFloat(Int(minHeightStr.replacingOccurrences(of: "px", with: "")) ?? 0)
    }
}
