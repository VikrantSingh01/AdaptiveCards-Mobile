import Foundation
import Combine
import ACCore
import ACTemplating

public class CardViewModel: ObservableObject {
    @Published public var card: AdaptiveCard?
    @Published public var inputValues: [String: Any] = [:]
    @Published public var visibility: [String: Bool] = [:]
    @Published public var showCards: [String: Bool] = [:]
    @Published public var parsingError: Error?
    /// Incremented each time a new parsing error occurs, used for change detection
    @Published public var parsingErrorId: Int = 0

    /// Duration of the last parse operation in milliseconds (0 if served from cache)
    @Published public var lastParseTimeMs: Double = 0

    private let parser: CardParser
    private let templateEngine: TemplateEngine

    /// Stored template for data refresh support
    private var storedTemplate: String?
    private var storedTemplateData: [String: Any]?

    // MARK: - Parse Cache

    /// Thread-safe in-memory cache for parsed AdaptiveCard objects.
    /// Keyed by JSON string hash to avoid redundant parsing on re-renders.
    private static let parseCache = NSCache<NSString, AdaptiveCardWrapper>()
    private static let cacheLock = NSLock()

    /// Wrapper to store AdaptiveCard in NSCache (requires NSObject subclass)
    private class AdaptiveCardWrapper: NSObject {
        let card: AdaptiveCard
        init(_ card: AdaptiveCard) { self.card = card }
    }

    /// Returns a cache key for the given JSON string
    private static func cacheKey(for json: String) -> NSString {
        // Use a stable hash for cache lookup
        let hash = json.hashValue
        return NSString(string: String(hash))
    }

    /// Clears the parse cache. Call when memory warnings are received.
    public static func clearParseCache() {
        cacheLock.lock()
        parseCache.removeAllObjects()
        cacheLock.unlock()
    }

    public init() {
        self.parser = CardParser()
        self.templateEngine = TemplateEngine()
    }

    /// Parses a card from JSON string, optionally expanding template expressions with data.
    /// Uses an in-memory cache to skip redundant parsing for the same JSON.
    /// - Parameters:
    ///   - json: The card JSON string (may contain `${expression}` template syntax)
    ///   - templateData: Optional data context for template expansion
    public func parseCard(json: String, templateData: [String: Any]? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            do {
                var cardJson = json

                // If template data provided, expand template first
                if let data = templateData {
                    self.storedTemplate = json
                    self.storedTemplateData = data
                    cardJson = try self.templateEngine.expand(template: json, data: data)
                } else {
                    self.storedTemplate = nil
                    self.storedTemplateData = nil
                }

                let key = Self.cacheKey(for: cardJson)

                // Check cache first
                Self.cacheLock.lock()
                let cached = Self.parseCache.object(forKey: key)
                Self.cacheLock.unlock()

                let parsedCard: AdaptiveCard
                let parseTimeMs: Double

                if let cached = cached {
                    parsedCard = cached.card
                    parseTimeMs = 0 // Cache hit — no parse cost
                } else {
                    let start = CFAbsoluteTimeGetCurrent()
                    parsedCard = try self.parser.parse(cardJson)
                    parseTimeMs = (CFAbsoluteTimeGetCurrent() - start) * 1000

                    // Store in cache
                    Self.cacheLock.lock()
                    Self.parseCache.setObject(AdaptiveCardWrapper(parsedCard), forKey: key)
                    Self.cacheLock.unlock()
                }

                DispatchQueue.main.async {
                    self.lastParseTimeMs = parseTimeMs
                    self.card = parsedCard
                    self.parsingError = nil
                    self.initializeVisibility(for: parsedCard)
                    self.initializeInputValues(for: parsedCard)
                    completion?()
                }
            } catch {
                DispatchQueue.main.async {
                    self.parsingError = error
                    self.parsingErrorId += 1
                    print("Failed to parse card: \(error)")
                    completion?()
                }
            }
        }
    }

    /// Sets an input value
    public func setInputValue(id: String, value: Any) {
        inputValues[id] = value
    }

    /// Gets an input value
    public func getInputValue(forId id: String) -> Any? {
        return inputValues[id]
    }

    /// Gathers all input values for submission
    public func gatherInputValues() -> [String: Any] {
        return inputValues
    }

    /// Toggles visibility for an element
    public func toggleVisibility(elementId: String, isVisible: Bool?) {
        if let isVisible = isVisible {
            visibility[elementId] = isVisible
        } else {
            // Toggle current state
            visibility[elementId] = !(visibility[elementId] ?? true)
        }
    }

    /// Checks if an element is visible
    public func isElementVisible(elementId: String?) -> Bool {
        guard let elementId = elementId else { return true }
        return visibility[elementId] ?? true
    }

    /// Toggles show card visibility
    public func toggleShowCard(cardId: String) {
        showCards[cardId] = !(showCards[cardId] ?? false)
    }

    /// Checks if a show card is expanded
    public func isShowCardExpanded(actionId: String) -> Bool {
        return showCards[actionId] ?? false
    }

    // MARK: - Validation

    /// Validation errors keyed by input ID (parity with Android CardViewModel)
    @Published public var validationErrors: [String: String] = [:]

    /// Sets a validation error for an input
    public func setValidationError(id: String, error: String?) {
        if let error = error {
            validationErrors[id] = error
        } else {
            validationErrors.removeValue(forKey: id)
        }
    }

    /// Gets a validation error for an input
    public func getValidationError(id: String) -> String? {
        return validationErrors[id]
    }

    /// Clears all validation errors
    public func clearValidationErrors() {
        validationErrors.removeAll()
    }

    /// Validates all inputs and returns whether the card is valid
    public func validateAllInputs() -> Bool {
        clearValidationErrors()
        guard let card = card, let body = card.body else { return true }

        for element in body {
            validateInputElement(element)
        }
        return validationErrors.isEmpty
    }

    private func validateInputElement(_ element: CardElement) {
        switch element {
        case .textInput(let input):
            if input.isRequired == true {
                let value = inputValues[input.id] as? String ?? ""
                if value.isEmpty {
                    validationErrors[input.id] = input.errorMessage ?? "This field is required"
                }
            }
        case .numberInput(let input):
            if input.isRequired == true {
                if inputValues[input.id] == nil {
                    validationErrors[input.id] = input.errorMessage ?? "This field is required"
                }
            }
        case .dateInput(let input):
            if input.isRequired == true {
                let value = inputValues[input.id] as? String ?? ""
                if value.isEmpty {
                    validationErrors[input.id] = input.errorMessage ?? "This field is required"
                }
            }
        case .timeInput(let input):
            if input.isRequired == true {
                let value = inputValues[input.id] as? String ?? ""
                if value.isEmpty {
                    validationErrors[input.id] = input.errorMessage ?? "This field is required"
                }
            }
        case .choiceSetInput(let input):
            if input.isRequired == true {
                let value = inputValues[input.id] as? String ?? ""
                if value.isEmpty {
                    validationErrors[input.id] = input.errorMessage ?? "This field is required"
                }
            }
        case .container(let container):
            for item in container.items ?? [] {
                validateInputElement(item)
            }
        case .columnSet(let columnSet):
            for column in columnSet.columns {
                for item in column.items ?? [] {
                    validateInputElement(item)
                }
            }
        default:
            break
        }
    }

    // MARK: - Data Refresh

    /// Re-expands the stored template with new data, preserving user input values
    /// - Parameter newData: New data context for template expansion
    public func refreshData(_ newData: [String: Any]) {
        guard let template = storedTemplate else { return }
        let savedInputs = inputValues
        let savedVisibility = visibility
        let savedShowCards = showCards
        parseCard(json: template, templateData: newData) { [weak self] in
            guard let self = self else { return }
            // Restore user-entered state after re-parse completes
            for (key, value) in savedInputs {
                self.inputValues[key] = value
            }
            self.visibility.merge(savedVisibility) { _, kept in kept }
            self.showCards.merge(savedShowCards) { _, kept in kept }
        }
    }

    // MARK: - Private Helpers

    private func initializeVisibility(for card: AdaptiveCard) {
        guard let body = card.body else { return }

        for element in body {
            if let id = element.elementId {
                visibility[id] = element.isVisible
            }

            // Recursively initialize for nested containers
            initializeVisibilityForElement(element)
        }
    }

    private func initializeVisibilityForElement(_ element: CardElement) {
        switch element {
        case .container(let container):
            for item in container.items ?? [] {
                if let id = item.elementId {
                    visibility[id] = item.isVisible
                }
                initializeVisibilityForElement(item)
            }
        case .columnSet(let columnSet):
            for column in columnSet.columns {
                for item in column.items ?? [] {
                    if let id = item.elementId {
                        visibility[id] = item.isVisible
                    }
                    initializeVisibilityForElement(item)
                }
            }
        default:
            break
        }
    }

    private func initializeInputValues(for card: AdaptiveCard) {
        guard let body = card.body else { return }

        for element in body {
            initializeInputValue(for: element)
        }
    }

    private func initializeInputValue(for element: CardElement) {
        switch element {
        case .textInput(let input):
            if let value = input.value {
                inputValues[input.id] = value
            }
        case .numberInput(let input):
            if let value = input.value {
                inputValues[input.id] = value
            }
        case .dateInput(let input):
            if let value = input.value {
                inputValues[input.id] = value
            }
        case .timeInput(let input):
            if let value = input.value {
                inputValues[input.id] = value
            }
        case .toggleInput(let input):
            let valueOn = input.valueOn ?? "true"
            let valueOff = input.valueOff ?? "false"
            let isOn = input.value == valueOn
            inputValues[input.id] = isOn
        case .choiceSetInput(let input):
            if let value = input.value {
                inputValues[input.id] = value
            }
        case .container(let container):
            for item in container.items ?? [] {
                initializeInputValue(for: item)
            }
        case .columnSet(let columnSet):
            for column in columnSet.columns {
                for item in column.items ?? [] {
                    initializeInputValue(for: item)
                }
            }
        default:
            break
        }
    }
}
