import XCTest
@testable import ACCore

/// Integration tests for cross-platform rendering parity
/// Validates that all shared test cards parse correctly and handle edge cases
final class RenderingParityTests: XCTestCase {
    var parser: CardParser!
    
    override func setUp() {
        super.setUp()
        parser = CardParser()
    }
    
    // MARK: - Core Test Cards
    
    func testSimpleTextCard() throws {
        let json = try loadTestCard(named: "simple-text")
        let card = try parser.parse(json)
        
        XCTAssertEqual(card.version, "1.6")
        XCTAssertNotNil(card.body)
        XCTAssertEqual(card.body?.count, 2)
        XCTAssertNotNil(card.actions)
        XCTAssertEqual(card.actions?.count, 1)
    }
    
    func testContainersCard() throws {
        let json = try loadTestCard(named: "containers")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        XCTAssertEqual(card.body?.count, 2)
        
        // Verify container
        if case .container(let container) = card.body?[0] {
            XCTAssertNotNil(container.items)
            XCTAssertEqual(container.style, .emphasis)
        } else {
            XCTFail("Expected Container as first element")
        }
        
        // Verify column set
        if case .columnSet(let columnSet) = card.body?[1] {
            XCTAssertEqual(columnSet.columns.count, 2)
        } else {
            XCTFail("Expected ColumnSet as second element")
        }
    }
    
    func testAllInputsCard() throws {
        let json = try loadTestCard(named: "all-inputs")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        XCTAssertEqual(card.body?.count, 7)
        
        // Verify all input types exist
        var foundInputTypes: Set<String> = []
        for element in card.body ?? [] {
            switch element {
            case .textInput: foundInputTypes.insert("TextInput")
            case .numberInput: foundInputTypes.insert("NumberInput")
            case .dateInput: foundInputTypes.insert("DateInput")
            case .timeInput: foundInputTypes.insert("TimeInput")
            case .toggleInput: foundInputTypes.insert("ToggleInput")
            case .choiceSetInput: foundInputTypes.insert("ChoiceSetInput")
            default: break
            }
        }
        
        XCTAssertTrue(foundInputTypes.contains("TextInput"))
        XCTAssertTrue(foundInputTypes.contains("NumberInput"))
        XCTAssertTrue(foundInputTypes.contains("DateInput"))
        XCTAssertTrue(foundInputTypes.contains("TimeInput"))
        XCTAssertTrue(foundInputTypes.contains("ToggleInput"))
        XCTAssertTrue(foundInputTypes.contains("ChoiceSetInput"))
    }
    
    func testAllActionsCard() throws {
        let json = try loadTestCard(named: "all-actions")
        let card = try parser.parse(json)

        XCTAssertNotNil(card.actions)
        XCTAssertGreaterThanOrEqual(card.actions?.count ?? 0, 1)

        // Collect action types from both top-level actions and ActionSets in body
        var foundActionTypes: Set<String> = []
        for action in card.actions ?? [] {
            switch action {
            case .submit: foundActionTypes.insert("Submit")
            case .openUrl: foundActionTypes.insert("OpenUrl")
            case .showCard: foundActionTypes.insert("ShowCard")
            case .toggleVisibility: foundActionTypes.insert("ToggleVisibility")
            default: break
            }
        }

        for element in card.body ?? [] {
            if case .actionSet(let actionSet) = element {
                for action in actionSet.actions {
                    switch action {
                    case .submit: foundActionTypes.insert("Submit")
                    case .openUrl: foundActionTypes.insert("OpenUrl")
                    case .showCard: foundActionTypes.insert("ShowCard")
                    case .toggleVisibility: foundActionTypes.insert("ToggleVisibility")
                    default: break
                    }
                }
            }
        }

        XCTAssertTrue(foundActionTypes.contains("Submit"), "Expected Submit action type")
        XCTAssertTrue(foundActionTypes.contains("OpenUrl"), "Expected OpenUrl action type")
    }
    
    // MARK: - Advanced Elements Tests
    
    func testCarouselCard() throws {
        let json = try loadTestCard(named: "carousel")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        XCTAssertGreaterThan(card.body?.count ?? 0, 0)
        
        // Find carousel element
        var foundCarousel = false
        for element in card.body ?? [] {
            if case .carousel(let carousel) = element {
                foundCarousel = true
                XCTAssertGreaterThan(carousel.pages.count, 0)
            }
        }
        
        XCTAssertTrue(foundCarousel, "Carousel element not found")
    }
    
    func testAccordionCard() throws {
        let json = try loadTestCard(named: "accordion")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        
        // Find accordion element
        var foundAccordion = false
        for element in card.body ?? [] {
            if case .accordion(let accordion) = element {
                foundAccordion = true
                XCTAssertGreaterThan(accordion.panels.count, 0)
            }
        }
        
        XCTAssertTrue(foundAccordion, "Accordion element not found")
    }
    
    func testCodeBlockCard() throws {
        let json = try loadTestCard(named: "code-block")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        
        // Find code block element
        var foundCodeBlock = false
        for element in card.body ?? [] {
            if case .codeBlock(let codeBlock) = element {
                foundCodeBlock = true
                XCTAssertNotNil(codeBlock.code)
            }
        }
        
        XCTAssertTrue(foundCodeBlock, "CodeBlock element not found")
    }
    
    func testRatingCard() throws {
        let json = try loadTestCard(named: "rating")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        
        // Find rating elements
        var foundRatingDisplay = false
        var foundRatingInput = false
        for element in card.body ?? [] {
            if case .ratingDisplay = element {
                foundRatingDisplay = true
            }
            if case .ratingInput = element {
                foundRatingInput = true
            }
        }
        
        XCTAssertTrue(foundRatingDisplay || foundRatingInput, "Rating element not found")
    }
    
    func testProgressIndicatorsCard() throws {
        let json = try loadTestCard(named: "progress-indicators")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        
        // Find progress indicators
        var foundProgressBar = false
        var foundSpinner = false
        for element in card.body ?? [] {
            if case .progressBar = element {
                foundProgressBar = true
            }
            if case .spinner = element {
                foundSpinner = true
            }
        }
        
        XCTAssertTrue(foundProgressBar || foundSpinner, "Progress indicator not found")
    }
    
    func testTabSetCard() throws {
        let json = try loadTestCard(named: "tab-set")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        
        // Find tab set element
        var foundTabSet = false
        for element in card.body ?? [] {
            if case .tabSet(let tabSet) = element {
                foundTabSet = true
                XCTAssertGreaterThan(tabSet.tabs.count, 0)
            }
        }
        
        XCTAssertTrue(foundTabSet, "TabSet element not found")
    }
    
    // MARK: - Edge Case Tests
    
    func testEdgeEmptyCard() throws {
        let json = try loadTestCard(named: "edge-empty-card")
        let card = try parser.parse(json)
        
        XCTAssertEqual(card.version, "1.6")
        XCTAssertNotNil(card.body)
        XCTAssertEqual(card.body?.count, 0, "Empty card should have 0 body elements")
    }
    
    func testEdgeDeeplyNested() throws {
        let json = try loadTestCard(named: "edge-deeply-nested")
        let card = try parser.parse(json)
        
        XCTAssertEqual(card.version, "1.6")
        XCTAssertNotNil(card.body)
        XCTAssertGreaterThan(card.body?.count ?? 0, 0)
        
        // Verify deep nesting doesn't cause crash
        if case .container = card.body?[0] {
            // Successfully parsed deeply nested container
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected Container as first element")
        }
    }
    
    func testEdgeAllUnknownTypes() throws {
        let json = try loadTestCard(named: "edge-all-unknown-types")
        let card = try parser.parse(json)
        
        XCTAssertEqual(card.version, "1.6")
        XCTAssertNotNil(card.body)
        XCTAssertGreaterThan(card.body?.count ?? 0, 0)
        
        // Count unknown elements
        var unknownCount = 0
        var knownCount = 0
        for element in card.body ?? [] {
            if case .unknown = element {
                unknownCount += 1
            } else {
                knownCount += 1
            }
        }
        
        XCTAssertGreaterThan(unknownCount, 0, "Should have unknown elements")
        XCTAssertGreaterThan(knownCount, 0, "Should have at least one known element")
    }
    
    func testEdgeMaxActions() throws {
        let json = try loadTestCard(named: "edge-max-actions")
        let card = try parser.parse(json)
        
        XCTAssertEqual(card.version, "1.6")
        XCTAssertNotNil(card.actions)
        XCTAssertGreaterThanOrEqual(card.actions?.count ?? 0, 10, "Should have 10+ actions")
    }
    
    func testEdgeLongText() throws {
        let json = try loadTestCard(named: "edge-long-text")
        let card = try parser.parse(json)
        
        XCTAssertEqual(card.version, "1.6")
        XCTAssertNotNil(card.body)
        XCTAssertGreaterThan(card.body?.count ?? 0, 0)
        
        // Find text block with extremely long text
        var foundLongText = false
        for element in card.body ?? [] {
            if case .textBlock(let textBlock) = element {
                if textBlock.text.count > 500 {
                    foundLongText = true
                }
            }
        }
        
        XCTAssertTrue(foundLongText, "Should have text block with very long text")
    }
    
    func testEdgeRTLContent() throws {
        let json = try loadTestCard(named: "edge-rtl-content")
        let card = try parser.parse(json)
        
        XCTAssertEqual(card.version, "1.6")
        XCTAssertNotNil(card.body)
        XCTAssertGreaterThan(card.body?.count ?? 0, 0)
        
        // Verify card parses successfully with RTL content
        XCTAssertTrue(true, "RTL content parsed successfully")
    }
    
    func testEdgeMixedInputs() throws {
        let json = try loadTestCard(named: "edge-mixed-inputs")
        let card = try parser.parse(json)
        
        XCTAssertEqual(card.version, "1.6")
        XCTAssertNotNil(card.body)
        XCTAssertGreaterThan(card.body?.count ?? 0, 5)
        
        // Count input elements
        var inputCount = 0
        var displayCount = 0
        for element in card.body ?? [] {
            switch element {
            case .textInput, .numberInput, .dateInput, .timeInput, .toggleInput, .choiceSetInput, .ratingInput:
                inputCount += 1
            case .textBlock, .image, .container, .factSet:
                displayCount += 1
            default:
                break
            }
        }
        
        XCTAssertGreaterThan(inputCount, 0, "Should have input elements")
        XCTAssertGreaterThan(displayCount, 0, "Should have display elements")
    }
    
    func testEdgeEmptyContainers() throws {
        let json = try loadTestCard(named: "edge-empty-containers")
        let card = try parser.parse(json)
        
        XCTAssertEqual(card.version, "1.6")
        XCTAssertNotNil(card.body)
        XCTAssertGreaterThan(card.body?.count ?? 0, 0)
        
        // Find empty containers
        var foundEmptyContainer = false
        for element in card.body ?? [] {
            if case .container(let container) = element {
                if container.items.isEmpty {
                    foundEmptyContainer = true
                }
            }
        }
        
        XCTAssertTrue(foundEmptyContainer, "Should have at least one empty container")
    }
    
    // MARK: - Round-Trip Tests
    
    func testRoundTripSimpleCard() throws {
        let json = try loadTestCard(named: "simple-text")
        let card = try parser.parse(json)
        
        // Encode back to JSON
        let encodedJson = try parser.encode(card)
        
        // Parse again
        let reparsedCard = try parser.parse(encodedJson)
        
        XCTAssertEqual(card.version, reparsedCard.version)
        XCTAssertEqual(card.body?.count, reparsedCard.body?.count)
        XCTAssertEqual(card.actions?.count, reparsedCard.actions?.count)
    }
    
    func testRoundTripAdvancedCard() throws {
        let json = try loadTestCard(named: "advanced-combined")
        let card = try parser.parse(json)
        
        // Encode back to JSON
        let encodedJson = try parser.encode(card)
        
        // Parse again
        let reparsedCard = try parser.parse(encodedJson)
        
        XCTAssertEqual(card.version, reparsedCard.version)
        XCTAssertEqual(card.body?.count, reparsedCard.body?.count)
    }
    
    func testRoundTripEdgeCard() throws {
        let json = try loadTestCard(named: "edge-mixed-inputs")
        let card = try parser.parse(json)
        
        // Encode back to JSON
        let encodedJson = try parser.encode(card)
        
        // Parse again
        let reparsedCard = try parser.parse(encodedJson)
        
        XCTAssertEqual(card.version, reparsedCard.version)
        XCTAssertEqual(card.body?.count, reparsedCard.body?.count)
    }
    
    // MARK: - Performance Tests
    
    func testParsingPerformance() throws {
        let json = try loadTestCard(named: "advanced-combined")
        
        measure {
            do {
                _ = try parser.parse(json)
            } catch {
                XCTFail("Parsing failed: \(error)")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadTestCard(named name: String) throws -> String {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Resources") else {
            throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test card not found: \(name)"])
        }
        
        let data = try Data(contentsOf: url)
        guard let json = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "TestError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to string"])
        }
        
        return json
    }
}
