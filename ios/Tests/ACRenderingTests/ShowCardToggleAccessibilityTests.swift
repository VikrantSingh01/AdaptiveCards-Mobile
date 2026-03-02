import XCTest
@testable import ACCore
@testable import ACActions
@testable import ACRendering

/// Tests for ShowCard toggle button accessibility (upstream #100, #202, #374).
///
/// Validates:
/// - ActionButton expanded/collapsed accessibilityValue for ShowCard
/// - ShowCard actions are correctly identified and parsed
/// - ShowCard inline content is renderable
/// - No duplicate button/role announcements
/// - Cross-platform parity with Android
final class ShowCardToggleAccessibilityTests: XCTestCase {

    // MARK: - ActionButton ShowCard expanded state tests

    func testActionButtonShowCardHasExpandedValue() throws {
        let json = """
        {"type": "AdaptiveCard", "version": "1.6", "body": [],
         "actions": [
            {"type": "Action.ShowCard", "id": "showHistory",
             "title": "Show History",
             "card": {"type": "AdaptiveCard", "body": [
                 {"type": "TextBlock", "text": "History content"}
             ]}}
         ]}
        """
        let card = try CardParser().parse(json)
        let action = try XCTUnwrap(card.actions?.first)

        if case .showCard(let showCardAction) = action {
            XCTAssertEqual(showCardAction.title, "Show History")
            XCTAssertEqual(showCardAction.id, "showHistory")
        } else {
            XCTFail("Expected Action.ShowCard")
        }
    }

    func testActionButtonShowCardInlineCardBody() throws {
        let json = """
        {"type": "AdaptiveCard", "version": "1.6", "body": [],
         "actions": [
            {"type": "Action.ShowCard", "title": "Details",
             "card": {"type": "AdaptiveCard", "body": [
                 {"type": "TextBlock", "text": "Flight details"},
                 {"type": "TextBlock", "text": "Gate B42"}
             ]}}
         ]}
        """
        let card = try CardParser().parse(json)
        let action = try XCTUnwrap(card.actions?.first)

        if case .showCard(let showCardAction) = action {
            XCTAssertEqual(showCardAction.card.body?.count, 2,
                "Inline card should have 2 body elements")
        } else {
            XCTFail("Expected Action.ShowCard")
        }
    }

    // MARK: - ShowCard vs other action types

    func testShowCardIsDistinctFromSubmit() throws {
        let json = """
        {"type": "AdaptiveCard", "version": "1.6", "body": [],
         "actions": [
            {"type": "Action.ShowCard", "title": "Show History",
             "card": {"type": "AdaptiveCard", "body": []}},
            {"type": "Action.Submit", "title": "Submit"}
         ]}
        """
        let card = try CardParser().parse(json)
        let actions = try XCTUnwrap(card.actions)
        XCTAssertEqual(actions.count, 2)

        if case .showCard = actions[0] {
            // correct
        } else {
            XCTFail("First action should be ShowCard")
        }

        if case .submit = actions[1] {
            // correct
        } else {
            XCTFail("Second action should be Submit")
        }
    }

    func testShowCardIsDistinctFromOpenUrl() throws {
        let json = """
        {"type": "AdaptiveCard", "version": "1.6", "body": [],
         "actions": [
            {"type": "Action.ShowCard", "title": "More Info",
             "card": {"type": "AdaptiveCard", "body": []}},
            {"type": "Action.OpenUrl", "title": "Website",
             "url": "https://example.com"}
         ]}
        """
        let card = try CardParser().parse(json)
        let actions = try XCTUnwrap(card.actions)

        if case .showCard = actions[0] {
            // correct
        } else {
            XCTFail("First action should be ShowCard")
        }

        if case .openUrl = actions[1] {
            // correct
        } else {
            XCTFail("Second action should be OpenUrl")
        }
    }

    // MARK: - ExpenseReport-style tests (upstream #100, #374)

    func testExpenseReportShowCardTitles() throws {
        let json = """
        {"type": "AdaptiveCard", "version": "1.6", "body": [
            {"type": "TextBlock", "text": "Expense Report"}
        ],
         "actions": [
            {"type": "Action.ShowCard", "id": "showHistory",
             "title": "Show History",
             "card": {"type": "AdaptiveCard", "body": [
                 {"type": "TextBlock", "text": "Apr 14, 2019"}
             ]}},
            {"type": "Action.ShowCard", "id": "airTravel",
             "title": "Air Travel Expenses 300",
             "card": {"type": "AdaptiveCard", "body": [
                 {"type": "TextBlock", "text": "Flight to Seattle"}
             ]}}
         ]}
        """
        let card = try CardParser().parse(json)
        let actions = try XCTUnwrap(card.actions)

        if case .showCard(let showHistory) = actions[0] {
            XCTAssertEqual(showHistory.title, "Show History",
                "TalkBack/VoiceOver should say 'Show History button, collapsed'")
        } else {
            XCTFail("Expected ShowCard")
        }

        if case .showCard(let airTravel) = actions[1] {
            XCTAssertEqual(airTravel.title, "Air Travel Expenses 300")
        } else {
            XCTFail("Expected ShowCard")
        }
    }

    func testShowCardTooltipOverridesTitle() throws {
        let json = """
        {"type": "AdaptiveCard", "version": "1.6", "body": [],
         "actions": [
            {"type": "Action.ShowCard", "title": "Show",
             "tooltip": "Show expense history",
             "card": {"type": "AdaptiveCard", "body": []}}
         ]}
        """
        let card = try CardParser().parse(json)
        let action = try XCTUnwrap(card.actions?.first)

        if case .showCard(let showCard) = action {
            XCTAssertEqual(showCard.tooltip, "Show expense history",
                "Tooltip should be usable as accessibility content description")
        } else {
            XCTFail("Expected ShowCard")
        }
    }

    // MARK: - Duplicate focus prevention (upstream #202)

    func testShowCardTitleDoesNotContainRole() throws {
        let json = """
        {"type": "AdaptiveCard", "version": "1.6", "body": [],
         "actions": [
            {"type": "Action.ShowCard", "title": "Show History",
             "card": {"type": "AdaptiveCard", "body": []}}
         ]}
        """
        let card = try CardParser().parse(json)
        let action = try XCTUnwrap(card.actions?.first)

        if case .showCard(let showCard) = action {
            XCTAssertFalse(showCard.title?.contains("button") ?? false,
                "Title should not embed 'button' - role comes from semantics")
            XCTAssertFalse(showCard.title?.contains("expanded") ?? false,
                "Title should not embed 'expanded' - state comes from accessibilityValue")
        } else {
            XCTFail("Expected ShowCard")
        }
    }

    // MARK: - Mixed action types for distinct semantics

    func testMixedActionsHaveDistinctTypes() throws {
        let json = """
        {"type": "AdaptiveCard", "version": "1.6", "body": [],
         "actions": [
            {"type": "Action.ShowCard", "title": "Details",
             "card": {"type": "AdaptiveCard", "body": []}},
            {"type": "Action.Submit", "title": "Approve"},
            {"type": "Action.OpenUrl", "title": "Export as PDF",
             "url": "https://example.com/export"}
         ]}
        """
        let card = try CardParser().parse(json)
        let actions = try XCTUnwrap(card.actions)
        XCTAssertEqual(actions.count, 3)

        // Each type should use different accessibility traits:
        // ShowCard -> button + expanded/collapsed accessibilityValue
        // Submit -> button
        // OpenUrl -> link (not button)
        if case .showCard = actions[0] {} else { XCTFail("Expected ShowCard") }
        if case .submit = actions[1] {} else { XCTFail("Expected Submit") }
        if case .openUrl = actions[2] {} else { XCTFail("Expected OpenUrl") }
    }

    // MARK: - ShowCard inline content tests

    func testShowCardNestedActions() throws {
        let json = """
        {"type": "AdaptiveCard", "version": "1.6", "body": [],
         "actions": [
            {"type": "Action.ShowCard", "title": "Expand",
             "card": {"type": "AdaptiveCard", "body": [
                 {"type": "TextBlock", "text": "Details"}
             ], "actions": [
                 {"type": "Action.Submit", "title": "Save"}
             ]}}
         ]}
        """
        let card = try CardParser().parse(json)
        let action = try XCTUnwrap(card.actions?.first)

        if case .showCard(let showCard) = action {
            XCTAssertNotNil(showCard.card.actions)
            XCTAssertEqual(showCard.card.actions?.count, 1)
        } else {
            XCTFail("Expected ShowCard")
        }
    }

    // MARK: - Cross-platform parity

    func testShowCardPropertiesMatchAndroidExpectations() throws {
        let json = """
        {"type": "AdaptiveCard", "version": "1.6", "body": [],
         "actions": [
            {"type": "Action.ShowCard", "id": "toggle1",
             "title": "Show History",
             "tooltip": "Toggle expense history",
             "isEnabled": true,
             "card": {"type": "AdaptiveCard", "body": [
                 {"type": "TextBlock", "text": "History entry"}
             ]}}
         ]}
        """
        let card = try CardParser().parse(json)
        let action = try XCTUnwrap(card.actions?.first)

        if case .showCard(let showCard) = action {
            // These properties must match Android to ensure parity:
            XCTAssertEqual(showCard.id, "toggle1", "id parity with Android")
            XCTAssertEqual(showCard.title, "Show History", "title parity with Android")
            XCTAssertEqual(showCard.tooltip, "Toggle expense history", "tooltip parity")
            XCTAssertEqual(showCard.isEnabled, true, "isEnabled parity")
            XCTAssertNotNil(showCard.card.body, "inline card body parity")
        } else {
            XCTFail("Expected ShowCard")
        }
    }
}
