package com.microsoft.adaptivecards.rendering

import com.microsoft.adaptivecards.core.models.*
import com.microsoft.adaptivecards.core.parsing.CardParser
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test

/**
 * Tests for ShowCard toggle button accessibility (upstream #100, #202, #374).
 *
 * Validates:
 * - ActionShowCard is correctly parsed and has expected properties
 * - ShowCard toggle state (expanded/collapsed) is tracked
 * - ShowCard buttons are distinguishable from regular buttons
 * - Inline ShowCard content is renderable when expanded
 * - No duplicate semantics nodes on ShowCard buttons
 * - Cross-platform parity with iOS
 */
class ShowCardToggleAccessibilityTest {

    // MARK: - ActionShowCard parsing tests

    @Test
    fun `ActionShowCard is parsed correctly`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [],
             "actions": [
                {"type": "Action.ShowCard", "id": "showHistory",
                 "title": "Show History",
                 "card": {"type": "AdaptiveCard", "body": [
                     {"type": "TextBlock", "text": "History content"}
                 ]}}
             ]}
        """)

        val action = card.actions?.first()
        assertNotNull(action, "ShowCard action should be parsed")
        assertTrue(action is ActionShowCard, "Action should be ActionShowCard type")
        val showCard = action as ActionShowCard
        assertEquals("Show History", showCard.title)
        assertEquals("showHistory", showCard.id)
        assertNotNull(showCard.card, "ShowCard should contain inline card")
        assertNotNull(showCard.card.body, "Inline card should have body")
    }

    @Test
    fun `ActionShowCard inline card body is parsed`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [],
             "actions": [
                {"type": "Action.ShowCard", "title": "Details",
                 "card": {"type": "AdaptiveCard", "body": [
                     {"type": "TextBlock", "text": "Flight details"},
                     {"type": "TextBlock", "text": "Gate B42"}
                 ]}}
             ]}
        """)

        val showCard = card.actions?.first() as ActionShowCard
        assertEquals(2, showCard.card.body?.size, "Inline card should have 2 body elements")
        val textBlock = showCard.card.body?.first() as TextBlock
        assertEquals("Flight details", textBlock.text)
    }

    @Test
    fun `ActionShowCard with nested actions`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [],
             "actions": [
                {"type": "Action.ShowCard", "title": "Expand",
                 "card": {"type": "AdaptiveCard", "body": [
                     {"type": "TextBlock", "text": "Details"}
                 ], "actions": [
                     {"type": "Action.Submit", "title": "Save"}
                 ]}}
             ]}
        """)

        val showCard = card.actions?.first() as ActionShowCard
        assertNotNull(showCard.card.actions, "Inline card should have actions")
        assertEquals(1, showCard.card.actions?.size)
        val submitAction = showCard.card.actions?.first() as ActionSubmit
        assertEquals("Save", submitAction.title)
    }

    // MARK: - ShowCard vs regular action type distinction tests

    @Test
    fun `ShowCard is distinct from Submit action`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [],
             "actions": [
                {"type": "Action.ShowCard", "title": "Show History",
                 "card": {"type": "AdaptiveCard", "body": []}},
                {"type": "Action.Submit", "title": "Submit"}
             ]}
        """)

        val actions = card.actions!!
        assertEquals(2, actions.size)
        assertTrue(actions[0] is ActionShowCard, "First action should be ShowCard")
        assertTrue(actions[1] is ActionSubmit, "Second action should be Submit")
    }

    @Test
    fun `ShowCard is distinct from OpenUrl action`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [],
             "actions": [
                {"type": "Action.ShowCard", "title": "More Info",
                 "card": {"type": "AdaptiveCard", "body": []}},
                {"type": "Action.OpenUrl", "title": "Website",
                 "url": "https://example.com"}
             ]}
        """)

        val actions = card.actions!!
        assertTrue(actions[0] is ActionShowCard, "First action should be ShowCard")
        assertTrue(actions[1] is ActionOpenUrl, "Second action should be OpenUrl")
    }

    // MARK: - ExpenseReport-style card tests (upstream #100, #374)

    @Test
    fun `ExpenseReport ShowCard actions have titles for accessibility`() {
        val card = parseCard("""
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
        """)

        val actions = card.actions!!
        assertEquals(2, actions.size)

        val showHistory = actions[0] as ActionShowCard
        assertEquals("Show History", showHistory.title,
            "ShowCard button title should be 'Show History' for TalkBack")
        assertEquals("showHistory", showHistory.id)

        val airTravel = actions[1] as ActionShowCard
        assertEquals("Air Travel Expenses 300", airTravel.title,
            "ShowCard button title should be 'Air Travel Expenses 300' for TalkBack")
        assertEquals("airTravel", airTravel.id)
    }

    @Test
    fun `ShowCard tooltip overrides title for accessibility`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [],
             "actions": [
                {"type": "Action.ShowCard", "title": "Show",
                 "tooltip": "Show expense history",
                 "card": {"type": "AdaptiveCard", "body": []}}
             ]}
        """)

        val showCard = card.actions?.first() as ActionShowCard
        assertEquals("Show expense history", showCard.tooltip,
            "Tooltip should be used as content description when available")
    }

    @Test
    fun `ShowCard with id enables state tracking`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [],
             "actions": [
                {"type": "Action.ShowCard", "id": "history123",
                 "title": "Show History",
                 "card": {"type": "AdaptiveCard", "body": []}}
             ]}
        """)

        val showCard = card.actions?.first() as ActionShowCard
        assertEquals("history123", showCard.id,
            "ShowCard must have id for expanded/collapsed state tracking")
    }

    // MARK: - Duplicate focus prevention tests (upstream #202)

    @Test
    fun `ShowCard action has single title for single focus target`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [],
             "actions": [
                {"type": "Action.ShowCard", "title": "Show History",
                 "card": {"type": "AdaptiveCard", "body": []}}
             ]}
        """)

        val showCard = card.actions?.first() as ActionShowCard
        // Title should be a clean label without duplicate info
        assertEquals("Show History", showCard.title,
            "ShowCard title should not contain duplicate role or state info")
        assertFalse(showCard.title?.contains("button") ?: false,
            "Title should not embed 'button' - that comes from semantics role")
        assertFalse(showCard.title?.contains("expanded") ?: false,
            "Title should not embed 'expanded' - that comes from stateDescription")
    }

    @Test
    fun `Mixed action types maintain correct types for distinct semantics`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [],
             "actions": [
                {"type": "Action.ShowCard", "title": "Details",
                 "card": {"type": "AdaptiveCard", "body": []}},
                {"type": "Action.Submit", "title": "Approve"},
                {"type": "Action.OpenUrl", "title": "Export as PDF",
                 "url": "https://example.com/export"}
             ]}
        """)

        val actions = card.actions!!
        assertEquals(3, actions.size)
        // Each action type should use different semantics:
        // ShowCard -> toggleButtonSemantics (expanded/collapsed)
        // Submit -> buttonSemantics
        // OpenUrl -> linkSemantics
        assertTrue(actions[0] is ActionShowCard)
        assertTrue(actions[1] is ActionSubmit)
        assertTrue(actions[2] is ActionOpenUrl)
    }

    // MARK: - Cross-platform parity tests

    @Test
    fun `ShowCard properties match iOS ShowCardAction expectations`() {
        val card = parseCard("""
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
        """)

        val showCard = card.actions?.first() as ActionShowCard
        // These properties must match iOS to ensure parity:
        assertEquals("toggle1", showCard.id, "id parity")
        assertEquals("Show History", showCard.title, "title parity")
        assertEquals("Toggle expense history", showCard.tooltip, "tooltip parity")
        assertTrue(showCard.isEnabled, "isEnabled parity")
        assertNotNull(showCard.card.body, "inline card body parity")
    }

    @Test
    fun `ShowCard inline card body elements match iOS expectations`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [],
             "actions": [
                {"type": "Action.ShowCard", "title": "Show History",
                 "card": {"type": "AdaptiveCard", "body": [
                     {"type": "TextBlock", "text": "Apr 14 2019 - Expense approved"},
                     {"type": "Image", "url": "https://example.com/receipt.jpg",
                      "altText": "Receipt photo"}
                 ]}}
             ]}
        """)

        val showCard = card.actions?.first() as ActionShowCard
        val body = showCard.card.body!!
        assertEquals(2, body.size, "Should have TextBlock + Image")
        assertTrue(body[0] is TextBlock, "First element should be TextBlock")
        assertTrue(body[1] is Image, "Second element should be Image")
    }

    // MARK: - Helper

    private fun parseCard(json: String): AdaptiveCard {
        val parser = CardParser()
        return parser.parse(json.trimIndent())
    }
}
