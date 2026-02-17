#if canImport(UIKit)
import SwiftUI
import ACCore
@testable import ACRendering
@testable import ACInputs

struct PreParsedCardView: View {
    let card: AdaptiveCard
    let hostConfig: HostConfig
    let viewModel: CardViewModel
    let validationState = ValidationState()

    init(card: AdaptiveCard, hostConfig: HostConfig = TeamsHostConfig.create()) {
        self.card = card
        self.hostConfig = hostConfig
        let vm = CardViewModel()
        vm.card = card
        self.viewModel = vm
    }

    var body: some View {
        VStack(spacing: 0) {
            if let body = card.body, !body.isEmpty {
                ForEach(body) { element in
                    ElementView(element: element, hostConfig: hostConfig)
                }
            }
            if let actions = card.actions, !actions.isEmpty {
                ActionSetView(actions: actions, hostConfig: hostConfig)
                    .padding(.top, CGFloat(hostConfig.spacing.default))
            }
        }
        .padding(CGFloat(hostConfig.spacing.padding))
        .containerStyle(nil, hostConfig: hostConfig)
        .environmentObject(viewModel)
        .environment(\.hostConfig, hostConfig)
        .environment(\.actionHandler, DefaultActionHandler())
        .environment(\.validationState, validationState)
        .environment(\.layoutDirection, card.rtl == true ? .rightToLeft : .leftToRight)
    }
}
#endif
