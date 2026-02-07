import SwiftUI
import ACCore
import ACActions
import ACAccessibility
import ACInputs

/// Root SwiftUI view for rendering an Adaptive Card
public struct AdaptiveCardView: View {
    let cardJson: String
    let hostConfig: HostConfig
    let actionDelegate: ActionDelegate?
    
    @StateObject private var viewModel = CardViewModel()
    @StateObject private var validationState = ValidationState()
    private let actionHandler: ActionHandler
    
    public init(
        cardJson: String,
        hostConfig: HostConfig = TeamsHostConfig.create(),
        actionDelegate: ActionDelegate? = nil,
        actionHandler: ActionHandler = DefaultActionHandler()
    ) {
        self.cardJson = cardJson
        self.hostConfig = hostConfig
        self.actionDelegate = actionDelegate
        self.actionHandler = actionHandler
    }
    
    public var body: some View {
        content
            .environmentObject(viewModel)
            .environment(\.hostConfig, hostConfig)
            .environment(\.actionDelegate, actionDelegate)
            .environment(\.actionHandler, actionHandler)
            .environment(\.validationState, validationState)
            .onAppear {
                viewModel.parseCard(json: cardJson)
            }
    }
    
    @ViewBuilder
    private var content: some View {
        if let error = viewModel.parsingError {
            errorView(error: error)
        } else if let card = viewModel.card {
            cardContent(card: card)
        } else {
            ProgressView()
        }
    }
    
    private func cardContent(card: AdaptiveCard) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if let body = card.body, !body.isEmpty {
                    ForEach(body) { element in
                        if viewModel.isElementVisible(elementId: element.elementId) {
                            ElementView(element: element, hostConfig: hostConfig)
                        }
                    }
                }
                
                if let actions = card.actions, !actions.isEmpty {
                    ActionSetView(actions: actions, hostConfig: hostConfig)
                        .padding(.top, CGFloat(hostConfig.spacing.default))
                }
            }
            .padding(CGFloat(hostConfig.spacing.padding))
            .containerStyle(nil, hostConfig: hostConfig)
        }
    }
    
    private func errorView(error: Error) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("Failed to parse card")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - Environment Keys

private struct HostConfigKey: EnvironmentKey {
    static let defaultValue: HostConfig = TeamsHostConfig.create()
}

private struct ActionDelegateKey: EnvironmentKey {
    static let defaultValue: ActionDelegate? = nil
}

private struct ActionHandlerKey: EnvironmentKey {
    static let defaultValue: ActionHandler = DefaultActionHandler()
}

private struct ValidationStateKey: EnvironmentKey {
    static let defaultValue: ValidationState = ValidationState()
}

extension EnvironmentValues {
    var hostConfig: HostConfig {
        get { self[HostConfigKey.self] }
        set { self[HostConfigKey.self] = newValue }
    }
    
    var actionDelegate: ActionDelegate? {
        get { self[ActionDelegateKey.self] }
        set { self[ActionDelegateKey.self] = newValue }
    }
    
    var actionHandler: ActionHandler {
        get { self[ActionHandlerKey.self] }
        set { self[ActionHandlerKey.self] = newValue }
    }
    
    var validationState: ValidationState {
        get { self[ValidationStateKey.self] }
        set { self[ValidationStateKey.self] = newValue }
    }
}
