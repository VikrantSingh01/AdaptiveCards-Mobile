import XCTest
@testable import ACCore

/// Tests that Adaptive Card elements produce correct accessibility metadata.
///
/// Validates that parsed elements retain the properties needed for
/// VoiceOver (iOS) to announce cards correctly:
/// - TextBlock text for accessibility labels
/// - Image altText for accessibility descriptions
/// - Input labels and required state
/// - Action titles for button announcements
final class AccessibilityTests: XCTestCase {

    // MARK: - TextBlock Accessibility

    func testTextBlockProvidesTextForScreenReader() throws {
        let card = try parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "TextBlock", "text": "Important announcement", "id": "heading1"}
            ]}
        """)

        if case .textBlock(let tb) = card.body?[0] {
            XCTAssertEqual(tb.text, "Important announcement")
            XCTAssertNotNil(tb.id)
        } else {
            XCTFail("Expected TextBlock")
        }
    }

    // MARK: - Image Accessibility

    func testImageProvidesAltText() throws {
        let card = try parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "Image", "url": "https://example.com/photo.jpg", "altText": "Profile photo of John"}
            ]}
        """)

        if case .image(let img) = card.body?[0] {
            XCTAssertEqual(img.altText, "Profile photo of John")
        } else {
            XCTFail("Expected Image")
        }
    }

    func testImageWithoutAltTextHasNilDescription() throws {
        let card = try parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "Image", "url": "https://example.com/decorative.jpg"}
            ]}
        """)

        if case .image(let img) = card.body?[0] {
            XCTAssertNil(img.altText, "Decorative images should have nil altText")
        } else {
            XCTFail("Expected Image")
        }
    }

    // MARK: - Input Accessibility

    func testInputTextHasLabelAndRequiredState() throws {
        let card = try parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "Input.Text", "id": "name", "label": "Full Name", "isRequired": true, "placeholder": "Enter name"}
            ]}
        """)

        if case .textInput(let input) = card.body?[0] {
            XCTAssertEqual(input.label, "Full Name")
            XCTAssertEqual(input.isRequired, true)
            XCTAssertEqual(input.placeholder, "Enter name")
            XCTAssertEqual(input.id, "name")
        } else {
            XCTFail("Expected TextInput")
        }
    }

    func testAllInputTypesHaveIDs() throws {
        let card = try parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "Input.Text", "id": "t1"},
                {"type": "Input.Number", "id": "n1"},
                {"type": "Input.Date", "id": "d1"},
                {"type": "Input.Time", "id": "tm1"},
                {"type": "Input.Toggle", "id": "tg1", "title": "Accept"},
                {"type": "Input.ChoiceSet", "id": "cs1", "choices": []}
            ]}
        """)

        let expectedIds = ["t1", "n1", "d1", "tm1", "tg1", "cs1"]
        let actualIds = (card.body ?? []).compactMap { $0.elementId }
        XCTAssertEqual(actualIds, expectedIds, "Input IDs should match JSON specifications")
    }

    // MARK: - Action Accessibility

    func testActionsHaveTitlesForButtonLabels() throws {
        let card = try parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "actions": [
                {"type": "Action.Submit", "title": "Submit Form"},
                {"type": "Action.OpenUrl", "title": "Learn More", "url": "https://example.com"}
            ]}
        """)

        XCTAssertEqual(card.actions?.count, 2)

        if case .submit(let action) = card.actions?[0] {
            XCTAssertEqual(action.title, "Submit Form")
        } else {
            XCTFail("Expected Submit action")
        }

        if case .openUrl(let action) = card.actions?[1] {
            XCTAssertEqual(action.title, "Learn More")
        } else {
            XCTFail("Expected OpenUrl action")
        }
    }

    // MARK: - Visibility

    func testHiddenElementsShouldNotBeAnnounced() throws {
        let card = try parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "TextBlock", "text": "Visible", "isVisible": true},
                {"type": "TextBlock", "text": "Hidden", "isVisible": false}
            ]}
        """)

        let visible = card.body?[0]
        let hidden = card.body?[1]

        XCTAssertTrue(visible?.isVisible ?? false)
        XCTAssertFalse(hidden?.isVisible ?? true)
    }

    // MARK: - Container Grouping

    func testContainerGroupsChildrenForAccessibility() throws {
        let card = try parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "Container", "id": "group1", "items": [
                    {"type": "TextBlock", "text": "Title"},
                    {"type": "TextBlock", "text": "Subtitle"}
                ]}
            ]}
        """)

        if case .container(let container) = card.body?[0] {
            XCTAssertEqual(container.id, "group1")
            XCTAssertEqual(container.items?.count, 2)
        } else {
            XCTFail("Expected Container")
        }
    }

    // MARK: - Stable IDs for SwiftUI Accessibility

    func testElementIdsAreStableForAccessibility() {
        let element1 = CardElement.textBlock(TextBlock(id: "myId", text: "Hello"))
        let element2 = CardElement.textBlock(TextBlock(id: "myId", text: "Hello"))

        XCTAssertEqual(element1.id, "myId")
        XCTAssertEqual(element1.id, element2.id, "Same element should produce same ID")
    }

    func testGeneratedIdsAreStable() {
        let element = CardElement.textBlock(TextBlock(text: "No explicit ID"))
        let id1 = element.id
        let id2 = element.id
        XCTAssertEqual(id1, id2, "Generated IDs must be stable across accesses")
    }

    // MARK: - Helper

    private func parseCard(_ json: String) throws -> AdaptiveCard {
        let parser = CardParser()
        return try parser.parse(json)
    }
}
