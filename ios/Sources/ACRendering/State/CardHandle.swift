// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

import Foundation
import SwiftUI
import ACCore

/// Host-facing state handle for an Adaptive Card.
/// Provides read-only access to card state and host-initiated operations.
/// Internal rendering state (visibility, showCards, popoverState) is NOT exposed.
///
/// ```swift
/// @StateObject private var handle = CardHandle()
///
/// AdaptiveCardView(card: myCard, configuration: config)
///     .cardHandle(handle)
///
/// // Elsewhere:
/// let inputs = handle.inputValues
/// let result = handle.validateInputs()
/// ```
public final class CardHandle: ObservableObject {
    // MARK: - Read-only state

    /// The parsed card model, if available
    @Published public private(set) var card: AdaptiveCard?

    /// Whether the card has completed its first render pass
    @Published public private(set) var isRendered: Bool = false

    /// The current intrinsic content size of the card
    @Published public private(set) var contentSize: CGSize = .zero

    /// Parse error, if the card failed to parse
    @Published public private(set) var parseError: ParseError?

    // MARK: - Input access

    /// Current input values (read-only to host, managed by SDK)
    public var inputValues: [String: Any] {
        internalViewModel?.gatherInputValues() ?? [:]
    }

    /// Whether any inputs have been modified from their defaults
    public var hasInputChanges: Bool {
        !inputValues.isEmpty
    }

    // MARK: - Host-initiated actions

    /// Re-expand the stored template with new data, preserving user input values
    public func refreshData(_ newData: [String: Any]) {
        internalViewModel?.refreshData(newData)
    }

    /// Validate all inputs and return the result
    public func validateInputs() -> ValidationResult {
        guard let vm = internalViewModel else {
            return ValidationResult(isValid: true, errors: [:])
        }
        let isValid = vm.validateAllInputs()
        return ValidationResult(isValid: isValid, errors: vm.validationErrors)
    }

    /// Programmatically trigger an action by its ID (for test automation)
    public func triggerAction(withId actionId: String) {
        guard card != nil else { return }
        pendingActionId = actionId
    }

    /// Reset the card to its initial state
    public func reset() {
        internalViewModel?.clearValidationErrors()
    }

    // MARK: - Internal (SDK use only, not public)

    /// The internal ViewModel — wired by AdaptiveCardView
    internal weak var internalViewModel: CardViewModel?

    /// Pending action ID for programmatic triggering
    internal var pendingActionId: String?

    /// Called by SDK when card is parsed
    internal func didParseCard(_ card: AdaptiveCard) {
        self.card = card
        self.parseError = nil
    }

    /// Called by SDK when parse fails
    internal func didFailParse(_ error: ParseError) {
        self.parseError = error
        self.card = nil
    }

    /// Called by SDK after first render pass
    internal func didRender() {
        self.isRendered = true
    }

    /// Called by SDK when content size changes
    internal func didChangeSize(_ size: CGSize) {
        self.contentSize = size
    }

    public init() {}
}

/// Result of input validation
public struct ValidationResult: Sendable {
    /// Whether all inputs passed validation
    public let isValid: Bool

    /// Validation errors keyed by input ID
    public let errors: [String: String]

    public init(isValid: Bool, errors: [String: String]) {
        self.isValid = isValid
        self.errors = errors
    }
}
