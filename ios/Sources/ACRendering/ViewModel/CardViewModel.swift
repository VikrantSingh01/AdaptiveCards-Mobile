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

    private let parser: CardParser
    private let templateEngine: TemplateEngine

    /// Stored template for data refresh support
    private var storedTemplate: String?
    private var storedTemplateData: [String: Any]?

    public init() {
        self.parser = CardParser()
        self.templateEngine = TemplateEngine()
    }

    /// Parses a card from JSON string, optionally expanding template expressions with data
    /// - Parameters:
    ///   - json: The card JSON string (may contain `${expression}` template syntax)
    ///   - templateData: Optional data context for template expansion
    public func parseCard(json: String, templateData: [String: Any]? = nil) {
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

                let parsedCard = try self.parser.parse(cardJson)
                DispatchQueue.main.async {
                    self.card = parsedCard
                    self.parsingError = nil
                    self.initializeVisibility(for: parsedCard)
                    self.initializeInputValues(for: parsedCard)
                }
            } catch {
                DispatchQueue.main.async {
                    self.parsingError = error
                    print("Failed to parse card: \(error)")
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
        parseCard(json: template, templateData: newData)
        // Restore user-entered input values after re-parse completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            for (key, value) in savedInputs {
                self.inputValues[key] = value
            }
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
