import XCTest
@testable import ACCore

final class CardParserTests: XCTestCase {
    var parser: CardParser!
    
    override func setUp() {
        super.setUp()
        parser = CardParser()
    }
    
    func testParseSimpleCard() throws {
        let json = try loadTestCard(named: "simple-text")
        let card = try parser.parse(json)
        
        XCTAssertEqual(card.version, "1.6")
        XCTAssertNotNil(card.body)
        XCTAssertEqual(card.body?.count, 2)
        XCTAssertNotNil(card.actions)
        XCTAssertEqual(card.actions?.count, 1)
    }
    
    func testParseInputForm() throws {
        let json = try loadTestCard(named: "input-form")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        XCTAssertEqual(card.body?.count, 4)
        
        // Verify text input
        if case .textBlock(let textBlock) = card.body?[0] {
            XCTAssertEqual(textBlock.text, "Input Form")
        } else {
            XCTFail("Expected TextBlock as first element")
        }
        
        // Verify text input element
        if case .textInput(let input) = card.body?[1] {
            XCTAssertEqual(input.id, "name")
            XCTAssertEqual(input.isRequired, true)
        } else {
            XCTFail("Expected TextInput as second element")
        }
    }
    
    func testParseContainerColumnSet() throws {
        let json = try loadTestCard(named: "containers")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        XCTAssertEqual(card.body?.count, 2)
        
        // Verify container
        if case .container(let container) = card.body?[0] {
            XCTAssertEqual(container.style, .emphasis)
            XCTAssertEqual(container.items.count, 2)
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
    
    func testParseActions() throws {
        let json = try loadTestCard(named: "all-actions")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        XCTAssertNotNil(card.actions)
        
        // Verify action set
        if case .actionSet(let actionSet) = card.body?[1] {
            XCTAssertEqual(actionSet.actions.count, 2)
        } else {
            XCTFail("Expected ActionSet")
        }
        
        // Verify toggle visibility action
        if case .toggleVisibility(let action) = card.actions?[0] {
            XCTAssertEqual(action.title, "Toggle Text")
            XCTAssertEqual(action.targetElements.count, 1)
        } else {
            XCTFail("Expected ToggleVisibility action")
        }
    }
    
    func testParseRichContent() throws {
        let json = try loadTestCard(named: "rich-text")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        
        // Verify rich text block
        if case .richTextBlock(let richText) = card.body?[0] {
            XCTAssertEqual(richText.inlines.count, 5)
        } else {
            XCTFail("Expected RichTextBlock")
        }
        
        // Verify fact set
        if case .factSet(let factSet) = card.body?[1] {
            XCTAssertEqual(factSet.facts.count, 3)
        } else {
            XCTFail("Expected FactSet")
        }
        
        // Verify image set
        if case .imageSet(let imageSet) = card.body?[2] {
            XCTAssertEqual(imageSet.images.count, 3)
        } else {
            XCTFail("Expected ImageSet")
        }
    }
    
    func testParseAllInputs() throws {
        let json = try loadTestCard(named: "all-inputs")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        XCTAssertEqual(card.body?.count, 7)
        
        // Verify all input types
        if case .textInput = card.body?[1] {} else {
            XCTFail("Expected TextInput")
        }
        if case .numberInput = card.body?[2] {} else {
            XCTFail("Expected NumberInput")
        }
        if case .dateInput = card.body?[3] {} else {
            XCTFail("Expected DateInput")
        }
        if case .timeInput = card.body?[4] {} else {
            XCTFail("Expected TimeInput")
        }
        if case .toggleInput = card.body?[5] {} else {
            XCTFail("Expected ToggleInput")
        }
        if case .choiceSetInput = card.body?[6] {} else {
            XCTFail("Expected ChoiceSetInput")
        }
    }
    
    func testParseTable() throws {
        let json = try loadTestCard(named: "table")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        
        // Verify table
        if case .table(let table) = card.body?[1] {
            XCTAssertEqual(table.rows.count, 3)
            XCTAssertEqual(table.firstRowAsHeaders, true)
            XCTAssertEqual(table.showGridLines, true)
        } else {
            XCTFail("Expected Table")
        }
    }
    
    func testParseMedia() throws {
        let json = try loadTestCard(named: "media")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        
        // Verify media
        if case .media(let media) = card.body?[1] {
            XCTAssertNotNil(media.poster)
            XCTAssertEqual(media.sources.count, 1)
        } else {
            XCTFail("Expected Media")
        }
    }
    
    func testRoundTripEncoding() throws {
        let json = try loadTestCard(named: "simple-text")
        let card = try parser.parse(json)
        
        // Encode back to JSON
        let encodedJson = try parser.encode(card)
        
        // Parse again
        let reparsedCard = try parser.parse(encodedJson)
        
        XCTAssertEqual(card.version, reparsedCard.version)
        XCTAssertEqual(card.body?.count, reparsedCard.body?.count)
    }
    
    func testUnknownElementTypeFallback() throws {
        // Test JSON with an unknown element type
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "TextBlock",
                    "text": "Before unknown"
                },
                {
                    "type": "FutureElement",
                    "someProperty": "value"
                },
                {
                    "type": "TextBlock",
                    "text": "After unknown"
                }
            ]
        }
        """
        
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        XCTAssertEqual(card.body?.count, 3)
        
        // Verify first element is TextBlock
        if case .textBlock(let textBlock) = card.body?[0] {
            XCTAssertEqual(textBlock.text, "Before unknown")
        } else {
            XCTFail("Expected TextBlock as first element")
        }
        
        // Verify second element is unknown
        if case .unknown(let type) = card.body?[1] {
            XCTAssertEqual(type, "FutureElement")
        } else {
            XCTFail("Expected unknown element as second element")
        }
        
        // Verify third element is TextBlock
        if case .textBlock(let textBlock) = card.body?[2] {
            XCTAssertEqual(textBlock.text, "After unknown")
        } else {
            XCTFail("Expected TextBlock as third element")
        }
        
        // Verify unknown element properties
        let unknownElement = card.body?[1]
        XCTAssertNil(unknownElement?.elementId)
        XCTAssertFalse(unknownElement?.isVisible ?? true)
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
