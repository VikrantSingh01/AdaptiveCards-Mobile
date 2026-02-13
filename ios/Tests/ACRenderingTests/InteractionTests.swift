import XCTest
@testable import ACRendering
@testable import ACCore

/// Tests for CardViewModel state management and action dispatch.
/// Validates visibility toggling, input collection, show card expansion,
/// and the full submit-action input gathering pipeline.
final class InteractionTests: XCTestCase {
    var viewModel: CardViewModel!

    override func setUp() {
        super.setUp()
        viewModel = CardViewModel()
    }

    // MARK: - Input Value Management

    func testSetAndGetInputValue() {
        viewModel.setInputValue(id: "name", value: "John")
        XCTAssertEqual(viewModel.getInputValue(forId: "name") as? String, "John")
    }

    func testMultipleInputValues() {
        viewModel.setInputValue(id: "name", value: "Jane")
        viewModel.setInputValue(id: "age", value: 30)
        viewModel.setInputValue(id: "subscribe", value: true)

        let gathered = viewModel.gatherInputValues()
        XCTAssertEqual(gathered.count, 3)
        XCTAssertEqual(gathered["name"] as? String, "Jane")
        XCTAssertEqual(gathered["age"] as? Int, 30)
        XCTAssertEqual(gathered["subscribe"] as? Bool, true)
    }

    func testOverwriteInputValue() {
        viewModel.setInputValue(id: "name", value: "Alice")
        viewModel.setInputValue(id: "name", value: "Bob")
        XCTAssertEqual(viewModel.getInputValue(forId: "name") as? String, "Bob")
    }

    func testGetMissingInputReturnsNil() {
        XCTAssertNil(viewModel.getInputValue(forId: "nonexistent"))
    }

    // MARK: - Visibility Toggling

    func testToggleVisibilityExplicit() {
        viewModel.toggleVisibility(elementId: "elem1", isVisible: false)
        XCTAssertFalse(viewModel.isElementVisible(elementId: "elem1"))

        viewModel.toggleVisibility(elementId: "elem1", isVisible: true)
        XCTAssertTrue(viewModel.isElementVisible(elementId: "elem1"))
    }

    func testToggleVisibilityToggle() {
        // Default is visible (true)
        XCTAssertTrue(viewModel.isElementVisible(elementId: "elem1"))

        // Toggle should make it invisible
        viewModel.toggleVisibility(elementId: "elem1", isVisible: nil)
        XCTAssertFalse(viewModel.isElementVisible(elementId: "elem1"))

        // Toggle again should make it visible
        viewModel.toggleVisibility(elementId: "elem1", isVisible: nil)
        XCTAssertTrue(viewModel.isElementVisible(elementId: "elem1"))
    }

    func testNilElementIdAlwaysVisible() {
        XCTAssertTrue(viewModel.isElementVisible(elementId: nil))
    }

    // MARK: - Show Card State

    func testToggleShowCard() {
        XCTAssertFalse(viewModel.isShowCardExpanded(actionId: "action1"))

        viewModel.toggleShowCard(cardId: "action1")
        XCTAssertTrue(viewModel.isShowCardExpanded(actionId: "action1"))

        viewModel.toggleShowCard(cardId: "action1")
        XCTAssertFalse(viewModel.isShowCardExpanded(actionId: "action1"))
    }

    func testMultipleShowCards() {
        viewModel.toggleShowCard(cardId: "card1")
        viewModel.toggleShowCard(cardId: "card2")

        XCTAssertTrue(viewModel.isShowCardExpanded(actionId: "card1"))
        XCTAssertTrue(viewModel.isShowCardExpanded(actionId: "card2"))
    }

    // MARK: - Card Parsing Integration

    func testParseSimpleCard() {
        let expectation = expectation(description: "Card parsed")
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {"type": "TextBlock", "text": "Hello", "id": "text1"},
                {"type": "Input.Text", "id": "input1", "placeholder": "Name"}
            ]
        }
        """

        viewModel.parseCard(json: json)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertNotNil(self.viewModel.card)
            XCTAssertNil(self.viewModel.parsingError)
            XCTAssertEqual(self.viewModel.card?.body?.count, 2)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testParseInvalidJsonSetsError() {
        let expectation = expectation(description: "Parse error set")
        viewModel.parseCard(json: "{ invalid }")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertNotNil(self.viewModel.parsingError)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Submit Action Input Gathering

    func testGatherInputsForSubmit() {
        viewModel.setInputValue(id: "firstName", value: "John")
        viewModel.setInputValue(id: "lastName", value: "Doe")
        viewModel.setInputValue(id: "email", value: "john@example.com")

        let inputs = viewModel.gatherInputValues()

        XCTAssertEqual(inputs.count, 3)
        XCTAssertEqual(inputs["firstName"] as? String, "John")
        XCTAssertEqual(inputs["lastName"] as? String, "Doe")
        XCTAssertEqual(inputs["email"] as? String, "john@example.com")
    }

    func testGatherInputsReturnsSnapshot() {
        viewModel.setInputValue(id: "field1", value: "value1")
        let snapshot = viewModel.gatherInputValues()

        // Modify after gathering
        viewModel.setInputValue(id: "field2", value: "value2")

        // Snapshot should not be affected (it's a copy)
        XCTAssertEqual(snapshot.count, 1)
        XCTAssertNil(snapshot["field2"])
    }
}
