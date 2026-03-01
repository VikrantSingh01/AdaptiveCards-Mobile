import SwiftUI
import ACCore
import ACActions
import ACAccessibility
import ACInputs

/// Root SwiftUI view for rendering an Adaptive Card
public struct AdaptiveCardView: View {
    let cardJson: String
    let templateData: [String: Any]?
    let hostConfig: HostConfig
    let actionDelegate: ActionDelegate?
    let onCardParsed: ((AdaptiveCard) -> Void)?
    let onCardParseError: ((Error) -> Void)?

    @StateObject private var viewModel = CardViewModel()
    @StateObject private var validationState = ValidationState()
    private let actionHandler: ActionHandler

    /// Creates an Adaptive Card view
    /// - Parameters:
    ///   - cardJson: The card JSON string (may contain `${expression}` template syntax)
    ///   - templateData: Optional data context for template expansion
    ///   - hostConfig: Host configuration for theming and layout
    ///   - actionDelegate: Delegate for handling card actions
    ///   - actionHandler: Internal action dispatcher
    ///   - onCardParsed: Called when the card is successfully parsed
    ///   - onCardParseError: Called when card parsing fails
    public init(
        cardJson: String,
        templateData: [String: Any]? = nil,
        hostConfig: HostConfig = TeamsHostConfig.create(),
        actionDelegate: ActionDelegate? = nil,
        actionHandler: ActionHandler = DefaultActionHandler(),
        onCardParsed: ((AdaptiveCard) -> Void)? = nil,
        onCardParseError: ((Error) -> Void)? = nil
    ) {
        self.cardJson = cardJson
        self.templateData = templateData
        self.hostConfig = hostConfig
        self.actionDelegate = actionDelegate
        self.actionHandler = actionHandler
        self.onCardParsed = onCardParsed
        self.onCardParseError = onCardParseError
    }

    public var body: some View {
        content
            .environmentObject(viewModel)
            .environment(\.hostConfig, hostConfig)
            .environment(\.actionDelegate, actionDelegate)
            .environment(\.actionHandler, actionHandler)
            .environment(\.validationState, validationState)
            .onAppear {
                viewModel.parseCard(json: cardJson, templateData: templateData)
            }
            .onChange(of: viewModel.card) { card in
                if let card = card {
                    onCardParsed?(card)
                }
            }
            .onChange(of: viewModel.parsingError?.localizedDescription) { errorDesc in
                if let error = viewModel.parsingError {
                    onCardParseError?(error)
                }
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
                    ForEach(Array(body.enumerated()), id: \.element.id) { index, element in
                        if viewModel.isElementVisible(elementId: element.elementId) {
                            ElementView(element: element, hostConfig: hostConfig)
                                .padding(.top, index > 0 && element.spacing == nil ? CGFloat(hostConfig.spacing.default) : 0)
                        }
                    }
                }

                if let actions = card.actions, !actions.isEmpty {
                    ActionSetView(actions: actions, hostConfig: hostConfig)
                        .padding(.top, CGFloat(hostConfig.spacing.default))
                }
            }
            .padding(CGFloat(hostConfig.spacing.padding))
            .containerStyle(.default, hostConfig: hostConfig)
        }
        .environment(\.layoutDirection, card.rtl == true ? .rightToLeft : .leftToRight)
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
