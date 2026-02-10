import SwiftUI
import ACCore
import ACActions
import ACAccessibility

struct ActionSetView: View {
    let actions: [CardAction]
    let hostConfig: HostConfig
    
    @Environment(\.actionHandler) var actionHandler
    @Environment(\.actionDelegate) var actionDelegate
    @EnvironmentObject var viewModel: CardViewModel
    
    var body: some View {
        Group {
            if orientation == .horizontal {
                HStack(spacing: CGFloat(hostConfig.actions.buttonSpacing)) {
                    actionButtons
                }
            } else {
                VStack(spacing: CGFloat(hostConfig.actions.buttonSpacing)) {
                    actionButtons
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: alignment)
        .accessibilityContainer(label: "Actions")
    }
    
    @ViewBuilder
    private var actionButtons: some View {
<<<<<<< HEAD
        ForEach(Array(actions.prefix(hostConfig.actions.maxActions))) { action in
=======
        ForEach(Array(actions.prefix(hostConfig.actions.maxActions).enumerated()), id: \.element) { index, action in
>>>>>>> main
            ActionButton(action: action, hostConfig: hostConfig) {
                actionHandler.handle(action, delegate: actionDelegate, viewModel: viewModel)
            }
        }
    }
    
    private var orientation: Orientation {
        hostConfig.actions.actionsOrientation.lowercased() == "vertical" ? .vertical : .horizontal
    }
    
    private var alignment: Alignment {
        let alignmentStr = hostConfig.actions.actionAlignment.lowercased()
        switch alignmentStr {
        case "center":
            return .center
        case "right":
            return .trailing
        default:
            return .leading
        }
    }
    
    enum Orientation {
        case horizontal
        case vertical
    }
}
