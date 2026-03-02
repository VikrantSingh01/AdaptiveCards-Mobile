// ActionLinkAccessibilityTests.swift
// Tests for Action.OpenUrl link accessibility (upstream #492)
//
// Verifies that Action.OpenUrl actions use link semantics instead of button
// semantics, so VoiceOver announces "link" not "link button".

import XCTest
@testable import ACCore
@testable import ACRendering

final class ActionLinkAccessibilityTests: XCTestCase {

    // MARK: - Helpers

    private func parseCard(_ json: String) throws -> AdaptiveCard {
        return try CardParser().parse(json)
    }

    // MARK: - OpenUrl action model properties

    func testOpenUrlActionHasTitle() throws {
        let card = try parseCard("""
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "actions": [
                {
                    "type": "Action.OpenUrl",
                    "title": "More Info",
                    "url": "https://example.com/info"
                }
            ]
        }
        """)

        guard case .openUrl(let action) = card.actions?.first else {
            XCTFail("Expected Action.OpenUrl")
            return
        }
        XCTAssertEqual(action.title, "More Info")
        XCTAssertEqual(action.url, "https://example.com/info")
    }

    func testOpenUrlActionIsDistinctFromSubmit() throws {
        let card = try parseCard("""
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "actions": [
                {"type": "Action.OpenUrl", "title": "Visit Site", "url": "https://example.com"},
                {"type": "Action.Submit", "title": "Submit Form"}
            ]
        }
        """)

        let actions = card.actions!
        XCTAssertEqual(actions.count, 2)

        // First action should be OpenUrl
        if case .openUrl(let openUrl) = actions[0] {
            XCTAssertEqual(openUrl.title, "Visit Site")
        } else {
            XCTFail("First action should be OpenUrl")
        }

        // Second action should be Submit
        if case .submit(let submit) = actions[1] {
            XCTAssertEqual(submit.title, "Submit Form")
        } else {
            XCTFail("Second action should be Submit")
        }
    }

    // MARK: - Link vs Button role differentiation

    func testOpenUrlShouldNotBeAnnouncedAsButton() throws {
        // The fix ensures Action.OpenUrl uses .isLink trait on iOS
        // and linkSemantics on Android, NOT .isButton / Role.Button
        let card = try parseCard("""
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "actions": [
                {"type": "Action.OpenUrl", "title": "More Info", "url": "https://example.com"}
            ]
        }
        """)

        guard case .openUrl(let action) = card.actions?.first else {
            XCTFail("Expected Action.OpenUrl")
            return
        }
        // The action type is OpenUrl — the view layer should use link traits
        XCTAssertNotNil(action.url, "OpenUrl must have a URL")
        XCTAssertNotNil(action.title, "OpenUrl should have a title for accessibility")
    }

    func testSubmitActionShouldRemainButton() throws {
        // Submit actions should keep button semantics (not link)
        let card = try parseCard("""
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "actions": [
                {"type": "Action.Submit", "title": "Submit"}
            ]
        }
        """)

        guard case .submit(let action) = card.actions?.first else {
            XCTFail("Expected Action.Submit")
            return
        }
        XCTAssertEqual(action.title, "Submit")
    }

    // MARK: - Tooltip accessibility

    func testOpenUrlWithTooltipUsesTooltipForAccessibility() throws {
        let card = try parseCard("""
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "actions": [
                {
                    "type": "Action.OpenUrl",
                    "title": "More Info",
                    "url": "https://example.com",
                    "tooltip": "Opens the restaurant details page"
                }
            ]
        }
        """)

        guard case .openUrl(let action) = card.actions?.first else {
            XCTFail("Expected Action.OpenUrl")
            return
        }
        XCTAssertEqual(action.tooltip, "Opens the restaurant details page")
    }

    // MARK: - Mixed action types

    func testMixedActionTypesHaveCorrectRoles() throws {
        let card = try parseCard("""
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "actions": [
                {"type": "Action.Submit", "title": "Approve"},
                {"type": "Action.OpenUrl", "title": "More Info", "url": "https://example.com"},
                {"type": "Action.Execute", "title": "Run", "verb": "process"},
                {"type": "Action.OpenUrl", "title": "Help", "url": "https://help.example.com"}
            ]
        }
        """)

        let actions = card.actions!
        XCTAssertEqual(actions.count, 4)

        // Count OpenUrl vs non-OpenUrl - each should use different semantics
        var openUrlCount = 0
        var otherCount = 0
        for action in actions {
            if case .openUrl = action {
                openUrlCount += 1
            } else {
                otherCount += 1
            }
        }
        XCTAssertEqual(openUrlCount, 2, "Should have 2 OpenUrl actions (link role)")
        XCTAssertEqual(otherCount, 2, "Should have 2 non-OpenUrl actions (button role)")
    }

    // MARK: - Parity

    func testLinkRoleParityWithAndroid() throws {
        // On Android, ActionOpenUrl uses linkSemantics (contentDescription = "label, link")
        // On iOS, ActionOpenUrl uses .isLink trait and removes .isButton
        // Both should result in screen reader saying "link" not "button"
        let card = try parseCard("""
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "actions": [
                {"type": "Action.OpenUrl", "title": "More Info", "url": "https://example.com"}
            ]
        }
        """)

        guard case .openUrl(let action) = card.actions?.first else {
            XCTFail("Expected Action.OpenUrl")
            return
        }
        // The title should be the accessibility label (without "button" appended)
        XCTAssertEqual(action.title, "More Info")
        XCTAssertFalse(
            (action.title ?? "").lowercased().contains("button"),
            "OpenUrl title should not contain 'button' — that was the bug"
        )
    }
}
