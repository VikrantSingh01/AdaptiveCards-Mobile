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
                ForEach(Array(body.enumerated()), id: \.element.id) { index, element in
                    ElementView(element: element, hostConfig: hostConfig)
                        .padding(.top, index > 0 && element.spacing == nil ? CGFloat(hostConfig.spacing.default) : 0)
                }
            }
            if let actions = card.actions, !actions.isEmpty {
                ActionSetView(actions: actions, hostConfig: hostConfig)
                    .padding(.top, CGFloat(hostConfig.spacing.default))
            }
        }
        .padding(CGFloat(hostConfig.spacing.padding))
        .containerStyle(.default, hostConfig: hostConfig)
        .environmentObject(viewModel)
        .environment(\.hostConfig, hostConfig)
        .environment(\.actionHandler, DefaultActionHandler())
        .environment(\.validationState, validationState)
        .environment(\.layoutDirection, card.rtl == true ? .rightToLeft : .leftToRight)
    }
}
#endif
