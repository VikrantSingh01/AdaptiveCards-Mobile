import XCTest
@testable import ACCore

/// Tests for SchemaValidator with v1.6 schema validation and round-trip serialization
final class SchemaValidatorTests: XCTestCase {
    
    var validator: SchemaValidator!
    
    override func setUp() {
        super.setUp()
        validator = SchemaValidator()
    }
    
    // MARK: - Basic Validation Tests
    
    func testValidSimpleCard() {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "TextBlock",
                    "text": "Hello World"
                }
            ]
        }
        """
        
        let errors = validator.validate(json: json)
        XCTAssertTrue(errors.isEmpty, "Valid card should have no errors")
    }
    
    func testMissingType() {
        let json = """
        {
            "version": "1.6",
            "body": []
        }
        """
        
        let errors = validator.validate(json: json)
        XCTAssertFalse(errors.isEmpty)
        XCTAssertTrue(errors.contains { $0.path == "$.type" })
    }
    
    func testMissingVersion() {
        let json = """
        {
            "type": "AdaptiveCard",
            "body": []
        }
        """
        
        let errors = validator.validate(json: json)
        XCTAssertFalse(errors.isEmpty)
        XCTAssertTrue(errors.contains { $0.path == "$.version" })
    }
    
    func testInvalidVersion() {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "invalid",
            "body": []
        }
        """
        
        let errors = validator.validate(json: json)
        XCTAssertFalse(errors.isEmpty)
        XCTAssertTrue(errors.contains { $0.path == "$.version" && $0.message.contains("Invalid version format") })
    }
    
    func testVersion16Accepted() {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": []
        }
        """
        
        let errors = validator.validate(json: json)
        XCTAssertTrue(errors.isEmpty, "Version 1.6 should be accepted")
    }
    
    func testUnknownElementType() {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "UnknownElement",
                    "text": "Test"
                }
            ]
        }
        """
        
        let errors = validator.validate(json: json)
        XCTAssertFalse(errors.isEmpty)
        XCTAssertTrue(errors.contains { $0.path.contains("body[0].type") })
    }
    
    // MARK: - v1.6 Element Tests
    
    func testTableElementValidation() {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "Table",
                    "columns": [],
                    "rows": []
                }
            ]
        }
        """
        
        let errors = validator.validate(json: json)
        XCTAssertTrue(errors.isEmpty, "Table element should be valid in v1.6")
    }
    
    func testCompoundButtonValidation() {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "CompoundButton",
                    "title": "Button Title"
                }
            ]
        }
        """
        
        let errors = validator.validate(json: json)
        XCTAssertTrue(errors.isEmpty, "CompoundButton should be valid in v1.6")
    }
    
    // MARK: - Action Validation Tests
    
    func testActionExecuteValidation() {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "actions": [
                {
                    "type": "Action.Execute",
                    "title": "Execute",
                    "verb": "doAction"
                }
            ]
        }
        """
        
        let errors = validator.validate(json: json)
        XCTAssertTrue(errors.isEmpty, "Action.Execute should be valid in v1.6")
    }
    
    func testUnknownActionType() {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "actions": [
                {
                    "type": "Action.Unknown",
                    "title": "Unknown"
                }
            ]
        }
        """
        
        let errors = validator.validate(json: json)
        XCTAssertFalse(errors.isEmpty)
        XCTAssertTrue(errors.contains { $0.path.contains("actions[0].type") })
    }
    
    func testAllValidActionTypes() {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "actions": [
                {"type": "Action.Submit", "title": "Submit"},
                {"type": "Action.OpenUrl", "title": "Open", "url": "https://example.com"},
                {"type": "Action.ShowCard", "title": "Show"},
                {"type": "Action.ToggleVisibility", "title": "Toggle"},
                {"type": "Action.Execute", "title": "Execute"}
            ]
        }
        """
        
        let errors = validator.validate(json: json)
        XCTAssertTrue(errors.isEmpty, "All standard action types should be valid")
    }
    
    // MARK: - Round-Trip Serialization Tests
    
    func testRoundTripSimpleCard() throws {
        let originalJSON = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "TextBlock",
                    "text": "Hello World",
                    "wrap": true
                }
            ]
        }
        """
        
        // Parse JSON to model
        let parser = CardParser()
        let card = try parser.parse(originalJSON)
        
        // Serialize back to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(card)
        let serializedJSON = String(data: data, encoding: .utf8)!
        
        // Validate serialized JSON
        let errors = validator.validate(json: serializedJSON)
        XCTAssertTrue(errors.isEmpty, "Serialized JSON should be valid")
        
        // Parse again to ensure consistency
        let reparsedCard = try parser.parse(serializedJSON)
        XCTAssertEqual(card.version, reparsedCard.version)
        XCTAssertEqual(card.body.count, reparsedCard.body.count)
    }
    
    func testRoundTripComplexCard() throws {
        let originalJSON = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "Container",
                    "items": [
                        {
                            "type": "TextBlock",
                            "text": "Title",
                            "size": "Large"
                        },
                        {
                            "type": "Image",
                            "url": "https://example.com/image.png"
                        }
                    ]
                },
                {
                    "type": "Input.Text",
                    "id": "name",
                    "placeholder": "Enter name"
                }
            ],
            "actions": [
                {
                    "type": "Action.Submit",
                    "title": "Submit"
                }
            ]
        }
        """
        
        // Parse, serialize, and validate
        let parser = CardParser()
        let card = try parser.parse(originalJSON)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(card)
        let serializedJSON = String(data: data, encoding: .utf8)!
        
        let errors = validator.validate(json: serializedJSON)
        XCTAssertTrue(errors.isEmpty, "Complex card round-trip should produce valid JSON")
        
        // Verify structure is preserved
        let reparsedCard = try parser.parse(serializedJSON)
        XCTAssertEqual(card.body?.count, reparsedCard.body?.count)
        XCTAssertEqual(card.actions?.count, reparsedCard.actions?.count)
    }
    
    func testRoundTripWithTable() throws {
        let originalJSON = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "Table",
                    "columns": [
                        {"width": "auto"},
                        {"width": "stretch"}
                    ],
                    "rows": [
                        {
                            "cells": [
                                {"items": [{"type": "TextBlock", "text": "Cell 1"}]},
                                {"items": [{"type": "TextBlock", "text": "Cell 2"}]}
                            ]
                        }
                    ]
                }
            ]
        }
        """
        
        let parser = CardParser()
        let card = try parser.parse(originalJSON)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(card)
        let serializedJSON = String(data: data, encoding: .utf8)!
        
        let errors = validator.validate(json: serializedJSON)
        XCTAssertTrue(errors.isEmpty, "Table round-trip should produce valid JSON")
    }
    
    // MARK: - Chart Extension Tests
    
    func testChartElementsValidation() {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {"type": "DonutChart", "data": []},
                {"type": "BarChart", "data": []},
                {"type": "LineChart", "data": []},
                {"type": "PieChart", "data": []}
            ]
        }
        """
        
        let errors = validator.validate(json: json)
        XCTAssertTrue(errors.isEmpty, "Chart elements should be recognized as valid extensions")
    }
    
    // MARK: - Edge Cases
    
    func testEmptyCard() {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.6"
        }
        """
        
        let errors = validator.validate(json: json)
        XCTAssertTrue(errors.isEmpty, "Empty card (no body/actions) should be valid")
    }
    
    func testInvalidJSON() {
        let json = "{ invalid json }"
        
        let errors = validator.validate(json: json)
        XCTAssertFalse(errors.isEmpty)
        XCTAssertTrue(errors.contains { $0.path == "$" })
    }
    
    func testNonObjectJSON() {
        let json = "[\"array\"]"
        
        let errors = validator.validate(json: json)
        XCTAssertFalse(errors.isEmpty)
    }
}
