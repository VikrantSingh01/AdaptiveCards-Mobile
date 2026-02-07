import Foundation
import Combine
import ACCore

public class CardViewModel: ObservableObject {
    @Published public var card: AdaptiveCard?
    @Published public var inputValues: [String: Any] = [:]
    @Published public var visibility: [String: Bool] = [:]
    @Published public var showCards: [String: Bool] = [:]
    @Published public var parsingError: Error?
    
    private let parser: CardParser
    
    public init() {
        self.parser = CardParser()
    }
    
    /// Parses a card from JSON string
    public func parse(json: String) {
        do {
            let parsedCard = try parser.parse(json)
            self.card = parsedCard
            self.parsingError = nil
            initializeVisibility(for: parsedCard)
            initializeInputValues(for: parsedCard)
        } catch {
            self.parsingError = error
            print("Failed to parse card: \(error)")
        }
    }
    
    /// Sets an input value
    public func setInputValue(_ value: Any, forId id: String) {
        inputValues[id] = value
    }
    
    /// Gets an input value
    public func getInputValue(forId id: String) -> Any? {
        return inputValues[id]
    }
    
    /// Gathers all input values for submission
    public func gatherInputs() -> [String: Any] {
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
    public func isVisible(elementId: String?) -> Bool {
        guard let elementId = elementId else { return true }
        return visibility[elementId] ?? true
    }
    
    /// Toggles show card visibility
    public func toggleShowCard(cardId: String) {
        showCards[cardId] = !(showCards[cardId] ?? false)
    }
    
    /// Checks if a show card is visible
    public func isShowCardVisible(cardId: String) -> Bool {
        return showCards[cardId] ?? false
    }
    
    // MARK: - Private Helpers
    
    private func initializeVisibility(for card: AdaptiveCard) {
        guard let body = card.body else { return }
        
        for element in body {
            if let id = element.id {
                visibility[id] = element.isVisible
            }
            
            // Recursively initialize for nested containers
            initializeVisibilityForElement(element)
        }
    }
    
    private func initializeVisibilityForElement(_ element: CardElement) {
        switch element {
        case .container(let container):
            for item in container.items {
                if let id = item.id {
                    visibility[id] = item.isVisible
                }
                initializeVisibilityForElement(item)
            }
        case .columnSet(let columnSet):
            for column in columnSet.columns {
                for item in column.items {
                    if let id = item.id {
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
            for item in container.items {
                initializeInputValue(for: item)
            }
        case .columnSet(let columnSet):
            for column in columnSet.columns {
                for item in column.items {
                    initializeInputValue(for: item)
                }
            }
        default:
            break
        }
    }
}
