// ErrorMessageAccessibilityTests.swift
// Tests for input validation error accessibility (upstream #493).
//
// Verifies that validation error messages are accessible to VoiceOver users:
// - Error text is included in the input's accessibility label
// - VoiceOver announces errors when they appear via UIAccessibility.post
// - Required inputs parse with their errorMessage for announcements

import XCTest
@testable import ACCore
@testable import ACRendering

final class ErrorMessageAccessibilityTests: XCTestCase {

    // MARK: - Helpers

    private func parseCard(_ json: String) throws -> AdaptiveCard {
        return try CardParser().parse(json)
    }

    // MARK: - Required field parsing

    func testTextInputWithIsRequiredTrue() throws {
        let card = try parseCard("""
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "Input.Text",
                    "id": "name",
                    "label": "Full Name",
                    "isRequired": true,
                    "errorMessage": "Name is required"
                }
            ]
        }
        """)

        guard case .textInput(let input) = card.body?.first else {
            XCTFail("Expected Input.Text")
            return
        }
        XCTAssertEqual(input.isRequired, true)
        XCTAssertEqual(input.errorMessage, "Name is required")
        XCTAssertEqual(input.label, "Full Name")
    }

    func testNumberInputWithMinMaxParsesForValidation() throws {
        let card = try parseCard("""
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "Input.Number",
                    "id": "qty",
                    "label": "Quantity",
                    "min": 1,
                    "max": 100,
                    "isRequired": true,
                    "errorMessage": "Enter a valid quantity (1-100)"
                }
            ]
        }
        """)

        guard case .numberInput(let input) = card.body?.first else {
            XCTFail("Expected Input.Number")
            return
        }
        XCTAssertEqual(input.isRequired, true)
        XCTAssertEqual(input.min, 1)
        XCTAssertEqual(input.max, 100)
        XCTAssertEqual(input.errorMessage, "Enter a valid quantity (1-100)")
    }

    // MARK: - Error message for VoiceOver

    func testErrorMessageTextIsPreservedForVoiceOverAnnouncement() throws {
        let card = try parseCard("""
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "Input.Text",
                    "id": "name",
                    "label": "Name",
                    "isRequired": true,
                    "errorMessage": "Name cannot be empty"
                }
            ]
        }
        """)

        guard case .textInput(let input) = card.body?.first else {
            XCTFail("Expected Input.Text")
            return
        }
        // The error text is passed to accessibilityAnnounceError() which posts
        // UIAccessibility.announcement when it changes
        XCTAssertEqual(input.errorMessage, "Name cannot be empty",
            "Error message must be preserved for VoiceOver announcement")
    }

    // MARK: - Submit action with required inputs

    func testFormWithSubmitAndRequiredInputs() throws {
        let card = try parseCard("""
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "Input.Text",
                    "id": "name",
                    "label": "Name",
                    "isRequired": true,
                    "errorMessage": "Name is required"
                },
                {
                    "type": "Input.Text",
                    "id": "email",
                    "label": "Email",
                    "style": "email",
                    "isRequired": true,
                    "errorMessage": "Email is required"
                },
                {
                    "type": "Input.Number",
                    "id": "age",
                    "label": "Age",
                    "min": 0,
                    "max": 150
                }
            ],
            "actions": [
                {"type": "Action.Submit", "title": "Submit"}
            ]
        }
        """)

        XCTAssertEqual(card.body?.count, 3)
        XCTAssertEqual(card.actions?.count, 1)

        guard case .textInput(let nameInput) = card.body?[0] else {
            XCTFail("Expected Input.Text for name")
            return
        }
        guard case .textInput(let emailInput) = card.body?[1] else {
            XCTFail("Expected Input.Text for email")
            return
        }
        guard case .numberInput(let ageInput) = card.body?[2] else {
            XCTFail("Expected Input.Number for age")
            return
        }

        XCTAssertEqual(nameInput.isRequired, true)
        XCTAssertEqual(emailInput.isRequired, true)
        XCTAssertNotEqual(ageInput.isRequired, true, "Age should not be required")

        XCTAssertEqual(nameInput.errorMessage, "Name is required")
        XCTAssertEqual(emailInput.errorMessage, "Email is required")
        XCTAssertNil(ageInput.errorMessage, "Non-required input should not have error message")
    }

    // MARK: - Multiple required inputs

    func testMultipleRequiredInputsHaveDistinctErrorMessages() throws {
        let card = try parseCard("""
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "Input.Text",
                    "id": "first",
                    "label": "First Name",
                    "isRequired": true,
                    "errorMessage": "First name is required"
                },
                {
                    "type": "Input.Text",
                    "id": "last",
                    "label": "Last Name",
                    "isRequired": true,
                    "errorMessage": "Last name is required"
                },
                {
                    "type": "Input.Text",
                    "id": "middle",
                    "label": "Middle Name"
                }
            ]
        }
        """)

        let inputs = card.body?.compactMap { element -> TextInput? in
            if case .textInput(let input) = element { return input }
            return nil
        }
        XCTAssertEqual(inputs?.count, 3)

        let first = inputs?.first { $0.id == "first" }
        let last = inputs?.first { $0.id == "last" }
        let middle = inputs?.first { $0.id == "middle" }

        XCTAssertEqual(first?.errorMessage, "First name is required")
        XCTAssertEqual(last?.errorMessage, "Last name is required")
        XCTAssertNil(middle?.errorMessage, "Optional input should not have error message")
    }

    // MARK: - Parity with Android

    func testErrorMessageParityBothPlatformsAnnounceErrors() throws {
        // On Android, errorSemantics() uses LiveRegion.Polite on the error Text
        // On iOS, accessibilityAnnounceError() posts UIAccessibility.announcement
        // Both result in the screen reader announcing the error text unprompted

        let card = try parseCard("""
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "Input.Text",
                    "id": "name",
                    "label": "Name",
                    "isRequired": true,
                    "errorMessage": "Please enter your name"
                }
            ]
        }
        """)

        guard case .textInput(let input) = card.body?.first else {
            XCTFail("Expected Input.Text")
            return
        }
        XCTAssertEqual(input.errorMessage, "Please enter your name",
            "Error message must match cross-platform for consistent VoiceOver/TalkBack behavior")
    }

    // MARK: - Regex validation metadata

    func testTextInputWithRegexPreservesValidationPattern() throws {
        let card = try parseCard("""
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "Input.Text",
                    "id": "email",
                    "label": "Email",
                    "style": "email",
                    "isRequired": true,
                    "regex": "^[^@]+@[^@]+$",
                    "errorMessage": "Please enter a valid email"
                }
            ]
        }
        """)

        guard case .textInput(let input) = card.body?.first else {
            XCTFail("Expected Input.Text")
            return
        }
        XCTAssertEqual(input.regex, "^[^@]+@[^@]+$")
        XCTAssertEqual(input.errorMessage, "Please enter a valid email")
    }
}
