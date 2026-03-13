// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#if canImport(UIKit)
import UIKit
import SwiftUI
import ACCore
import ACActions

/// Drop-in UIView for embedding Adaptive Cards in UIKit view hierarchies.
/// Wraps AdaptiveCardView (SwiftUI) via UIHostingController.
///
/// ```swift
/// let cardView = AdaptiveCardUIView(card: parsedCard, configuration: .teams(theme: .dark))
/// cardView.onAction = { event in handleAction(event) }
/// view.addSubview(cardView)
/// ```
public final class AdaptiveCardUIView: UIView {

    // MARK: - Public API

    /// Callback for action events
    public var onAction: ((CardActionEvent) -> Void)?

    /// Callback for lifecycle events
    public var onLifecycle: ((CardLifecycleEvent) -> Void)?

    /// Current input values
    public var inputValues: [String: Any] {
        handle.inputValues
    }

    /// Validate all inputs
    public func validateInputs() -> ValidationResult {
        handle.validateInputs()
    }

    /// Refresh card with new template data
    public func refreshData(_ newData: [String: Any]) {
        handle.refreshData(newData)
    }

    /// Update the card being displayed
    public func updateCard(_ card: AdaptiveCard) {
        self.card = card
        rebuildHostingController()
    }

    /// Update with JSON
    public func updateJSON(_ json: String, data: [String: Any]? = nil) {
        let result = AdaptiveCards.parse(json)
        if let card = result.card {
            self.card = card
            rebuildHostingController()
        }
    }

    public override var intrinsicContentSize: CGSize {
        handle.contentSize == .zero ? super.intrinsicContentSize : handle.contentSize
    }

    // MARK: - Init

    private var card: AdaptiveCard?
    private var json: String?
    private var configuration: CardConfiguration
    private let handle = CardHandle()
    private var hostingController: UIHostingController<AnyView>?

    /// Create from a pre-parsed card
    public init(card: AdaptiveCard, configuration: CardConfiguration = .default) {
        self.card = card
        self.configuration = configuration
        super.init(frame: .zero)
        setupHostingController()
    }

    /// Create from a JSON string
    public init(json: String, data: [String: Any]? = nil, configuration: CardConfiguration = .default) {
        self.configuration = configuration
        let result = AdaptiveCards.parse(json)
        self.card = result.card
        super.init(frame: .zero)
        setupHostingController()
    }

    required init?(coder: NSCoder) {
        self.configuration = .default
        super.init(coder: coder)
        setupHostingController()
    }

    // MARK: - Private

    private func setupHostingController() {
        guard let card = card else { return }
        let onAction: (CardActionEvent) -> Void = { [weak self] event in
            self?.onAction?(event)
        }
        let onLifecycle = { [weak self] (event: CardLifecycleEvent) in
            self?.onLifecycle?(event)
            if case .sizeChanged = event {
                self?.invalidateIntrinsicContentSize()
            }
        }

        let swiftUIView = AdaptiveCardView(card: card, configuration: configuration)
            .onCardAction(onAction)
            .onCardLifecycle(onLifecycle)
            .cardHandle(handle)

        let hc = UIHostingController(rootView: AnyView(swiftUIView))
        hc.view.backgroundColor = UIColor.clear
        hc.view.translatesAutoresizingMaskIntoConstraints = false

        addSubview(hc.view)
        NSLayoutConstraint.activate([
            hc.view.topAnchor.constraint(equalTo: topAnchor),
            hc.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hc.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hc.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        self.hostingController = hc
    }

    private func rebuildHostingController() {
        hostingController?.view.removeFromSuperview()
        hostingController = nil
        setupHostingController()
    }
}
#endif
