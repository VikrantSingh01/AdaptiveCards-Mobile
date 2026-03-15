// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
import ACCore
import ACActions
import ACAccessibility
import ACInputs

/// Root SwiftUI view for rendering an Adaptive Card
public struct AdaptiveCardView: View {
    let cardJson: String?
    let preParsedCard: AdaptiveCard?
    let templateData: [String: Any]?
    let hostConfig: HostConfig
    let configuration: CardConfiguration?
    let actionDelegate: ActionDelegate?
    let onCardParsed: ((AdaptiveCard) -> Void)?
    let onCardParseError: ((Error) -> Void)?
    var pendingActionTitle: Binding<String?>?
    let onRefreshNeeded: ((CardAction) -> Void)?

    @StateObject private var viewModel = CardViewModel()
    @StateObject private var validationState = ValidationState()
    @State private var cardWidth: CGFloat = 0
    private let actionHandler: ActionHandler

    // MARK: - New API (Phase 2)

    /// Creates an Adaptive Card view from a pre-parsed card and configuration.
    ///
    /// ```swift
    /// let result = AdaptiveCards.parse(jsonString)
    /// if let card = result.card {
    ///     AdaptiveCardView(card: card, configuration: .teams(theme: .dark))
    /// }
    /// ```
    public init(
        card: AdaptiveCard,
        configuration: CardConfiguration = .default,
        onRefreshNeeded: ((CardAction) -> Void)? = nil
    ) {
        self.preParsedCard = card
        self.cardJson = nil
        self.templateData = nil
        self.hostConfig = configuration.hostConfig
        self.configuration = configuration
        self.actionDelegate = nil
        self.actionHandler = DefaultActionHandler()
        self.pendingActionTitle = nil
        self.onCardParsed = nil
        self.onCardParseError = nil
        self.onRefreshNeeded = onRefreshNeeded
    }

    /// Creates an Adaptive Card view from a JSON string and configuration.
    ///
    /// ```swift
    /// AdaptiveCardView(json: jsonString, configuration: .teams(theme: .dark))
    /// ```
    public init(
        json: String,
        data: [String: Any]? = nil,
        configuration: CardConfiguration = .default,
        onRefreshNeeded: ((CardAction) -> Void)? = nil
    ) {
        self.cardJson = json
        self.preParsedCard = nil
        self.templateData = data
        self.hostConfig = configuration.hostConfig
        self.configuration = configuration
        self.actionDelegate = nil
        self.actionHandler = DefaultActionHandler()
        self.pendingActionTitle = nil
        self.onCardParsed = nil
        self.onCardParseError = nil
        self.onRefreshNeeded = onRefreshNeeded
    }

    // MARK: - Legacy API (kept for backward compatibility)

    /// Creates an Adaptive Card view (legacy API).
    /// - Parameters:
    ///   - cardJson: The card JSON string (may contain `${expression}` template syntax)
    ///   - templateData: Optional data context for template expansion
    ///   - hostConfig: Host configuration for theming and layout
    ///   - actionDelegate: Delegate for handling card actions
    ///   - actionHandler: Internal action dispatcher
    ///   - pendingActionTitle: Binding to trigger an action by title (for test automation)
    ///   - onCardParsed: Called when the card is successfully parsed
    ///   - onCardParseError: Called when card parsing fails
    public init(
        cardJson: String,
        templateData: [String: Any]? = nil,
        hostConfig: HostConfig = TeamsHostConfig.create(),
        actionDelegate: ActionDelegate? = nil,
        actionHandler: ActionHandler = DefaultActionHandler(),
        pendingActionTitle: Binding<String?>? = nil,
        onCardParsed: ((AdaptiveCard) -> Void)? = nil,
        onCardParseError: ((Error) -> Void)? = nil
    ) {
        self.cardJson = cardJson
        self.preParsedCard = nil
        self.templateData = templateData
        self.hostConfig = hostConfig
        self.configuration = nil
        self.actionDelegate = actionDelegate
        self.actionHandler = actionHandler
        self.pendingActionTitle = pendingActionTitle
        self.onCardParsed = onCardParsed
        self.onCardParseError = onCardParseError
        self.onRefreshNeeded = nil
    }

    public var body: some View {
        content
            .environmentObject(viewModel)
            .environment(\.hostConfig, hostConfig)
            .environment(\.actionDelegate, actionDelegate)
            .environment(\.actionHandler, actionHandler)
            .environment(\.validationState, validationState)
            .environment(\.featureFlags, configuration?.featureFlags ?? FeatureFlags())
            .onAppear {
                if let preParsedCard = preParsedCard {
                    // Pre-parsed card — set directly without parsing
                    viewModel.card = preParsedCard
                } else if let cardJson = cardJson {
                    viewModel.parseCard(json: cardJson, templateData: templateData)
                }
            }
            .onChange(of: cardJson) { newJson in
                if let newJson = newJson {
                    viewModel.parseCard(json: newJson, templateData: templateData)
                }
            }
            .onChange(of: viewModel.card) { card in
                if let card = card {
                    onCardParsed?(card)
                    // Handle pending action that arrived before the card was parsed
                    if let title = pendingActionTitle?.wrappedValue {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.triggerAction(byTitle: title, in: card)
                            self.pendingActionTitle?.wrappedValue = nil
                        }
                    }
                }
            }
            .onChange(of: viewModel.parsingErrorId) { _ in
                if let error = viewModel.parsingError {
                    onCardParseError?(error)
                }
            }
            .onChange(of: pendingActionTitle?.wrappedValue) { title in
                guard let title = title, let card = viewModel.card else { return }
                triggerAction(byTitle: title, in: card)
                pendingActionTitle?.wrappedValue = nil
            }
    }

    /// Finds an action by title in the card and triggers it via the action handler.
    @MainActor
    private func triggerAction(byTitle title: String, in card: AdaptiveCard) {
        let allActions = Self.collectAllActions(from: card)
        if let action = allActions.first(where: { $0.title == title }) {
            actionHandler.handle(action, delegate: actionDelegate, viewModel: viewModel)
        }
    }

    /// Recursively collects all actions from the card (card-level + body ActionSets).
    private static func collectAllActions(from card: AdaptiveCard) -> [CardAction] {
        var actions: [CardAction] = card.actions ?? []
        if let body = card.body {
            actions.append(contentsOf: collectActionsFromElements(body))
        }
        return actions
    }

    private static func collectActionsFromElements(_ elements: [CardElement]) -> [CardAction] {
        var actions: [CardAction] = []
        for element in elements {
            if case .actionSet(let actionSet) = element {
                actions.append(contentsOf: actionSet.actions)
            }
            // Recurse into containers
            if case .container(let container) = element, let items = container.items {
                actions.append(contentsOf: collectActionsFromElements(items))
            }
            if case .columnSet(let columnSet) = element {
                for column in columnSet.columns {
                    if let items = column.items {
                        actions.append(contentsOf: collectActionsFromElements(items))
                    }
                }
            }
        }
        return actions
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
        let showDiagnostics = configuration?.diagnosticsEnabled == true

        return VStack(spacing: 0) {
            if let body = card.body, !body.isEmpty {
                ForEach(Array(body.enumerated()), id: \.element.id) { index, element in
                    if viewModel.isElementVisible(elementId: element.elementId) {
                        ElementView(element: element, hostConfig: hostConfig)
                            .padding(.top, index > 0 ? Self.spacingValue(for: element.spacing, hostConfig: hostConfig) : 0)
                    }
                }
            }

            if let actions = card.actions, !actions.isEmpty {
                ActionSetView(actions: actions, hostConfig: hostConfig)
                    .padding(.top, CGFloat(hostConfig.spacing.default))
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .clipped()
        .padding(CGFloat(hostConfig.spacing.padding))
        .fixedSize(horizontal: false, vertical: true)
        .background(Color(hex: hostConfig.containerStyles.default.backgroundColor))
        .background(
            GeometryReader { geometry in
                Color.clear.preference(key: CardWidthPreferenceKey.self, value: geometry.size.width)
            }
        )
        .onPreferenceChange(CardWidthPreferenceKey.self) { width in
            if width > 0 { cardWidth = width }
        }
        .environment(\.widthCategory, WidthCategory.from(width: cardWidth, hostConfig: hostConfig))
        .environment(\.layoutDirection, card.rtl == true ? .rightToLeft : .leftToRight)
        .overlay(alignment: .topTrailing) {
            if showDiagnostics {
                DiagnosticsOverlayView(
                    card: card,
                    parseTimeMs: viewModel.lastParseTimeMs
                )
                .padding(4)
            }
        }
        .task(id: card.refresh?.expires) {
            // Auto-refresh: schedule callback when card expires
            guard let onRefreshNeeded = onRefreshNeeded,
                  let refresh = card.refresh,
                  let expiresString = refresh.expires else { return }
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            guard let expiresDate = formatter.date(from: expiresString) ?? ISO8601DateFormatter().date(from: expiresString) else { return }
            let delay = expiresDate.timeIntervalSinceNow
            if delay > 0 {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                onRefreshNeeded(refresh.action)
            } else {
                // Already expired — notify immediately
                onRefreshNeeded(refresh.action)
            }
        }
    }

    private static func spacingValue(for spacing: Spacing?, hostConfig: HostConfig) -> CGFloat {
        guard let spacing = spacing else {
            return CGFloat(hostConfig.spacing.default)
        }
        switch spacing {
        case .none: return 0
        case .extraSmall: return 4
        case .small: return CGFloat(hostConfig.spacing.small)
        case .default: return CGFloat(hostConfig.spacing.default)
        case .medium: return CGFloat(hostConfig.spacing.medium)
        case .large: return CGFloat(hostConfig.spacing.large)
        case .extraLarge: return CGFloat(hostConfig.spacing.extraLarge)
        case .padding: return CGFloat(hostConfig.spacing.padding)
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

// MARK: - Preference Keys

private struct CardWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
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

private struct WidthCategoryKey: EnvironmentKey {
    static let defaultValue: WidthCategory = .narrow
}

private struct FeatureFlagsKey: EnvironmentKey {
    static let defaultValue: FeatureFlags = FeatureFlags()
}

extension EnvironmentValues {
    /// Current card width category for targetWidth responsive filtering.
    public var widthCategory: WidthCategory {
        get { self[WidthCategoryKey.self] }
        set { self[WidthCategoryKey.self] = newValue }
    }

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

    /// Feature flags for fallback/requires evaluation
    public var featureFlags: FeatureFlags {
        get { self[FeatureFlagsKey.self] }
        set { self[FeatureFlagsKey.self] = newValue }
    }
}
