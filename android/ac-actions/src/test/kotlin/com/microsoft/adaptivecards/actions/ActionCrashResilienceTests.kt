package com.microsoft.adaptivecards.actions

import com.microsoft.adaptivecards.core.models.*
import com.microsoft.adaptivecards.core.parsing.CardParser
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test

/**
 * Tests that parsing and handling edge-case/malformed actions never crashes.
 * Covers all known crash-risk patterns for the 8 action types.
 */
class ActionCrashResilienceTests {

    private lateinit var delegate: MockActionDelegate

    @BeforeEach
    fun setUp() {
        delegate = MockActionDelegate()
    }

    // MARK: - Parsing Crash Resilience

    @Test
    fun `edge case actions card parses without crash`() {
        val json = """
        {
          "type": "AdaptiveCard",
          "version": "1.6",
          "body": [{"type": "TextBlock", "text": "Test"}],
          "actions": [
            {"type": "Action.OpenUrl", "title": "Empty URL", "url": ""},
            {"type": "Action.OpenUrl", "title": "Blocked", "url": "javascript:alert(1)"},
            {"type": "Action.ToggleVisibility", "title": "Empty targets", "targetElements": []},
            {"type": "Action.Submit", "title": "Null data"},
            {"type": "Action.Execute", "title": "No verb"},
            {"type": "Action.RunCommands", "title": "Empty", "commands": []},
            {"type": "Action.OpenUrlDialog", "title": "Empty URL", "url": ""},
            {"type": "Action.ShowCard", "title": "Nested", "card": {
              "type": "AdaptiveCard", "version": "1.6",
              "body": [{"type": "TextBlock", "text": "Level 1"}],
              "actions": [{"type": "Action.ShowCard", "title": "L2", "card": {
                "type": "AdaptiveCard", "version": "1.6",
                "body": [{"type": "TextBlock", "text": "Level 2"}]
              }}]
            }}
          ]
        }
        """.trimIndent()

        val card = CardParser.parse(json)
        assertNotNull(card)
        assertNotNull(card.actions)
        assertTrue(card.actions!!.isNotEmpty())
    }

    @Test
    fun `deeply nested ShowCard parses without stack overflow`() {
        val json = """
        {
          "type": "AdaptiveCard", "version": "1.6",
          "body": [{"type": "TextBlock", "text": "Root"}],
          "actions": [{"type": "Action.ShowCard", "title": "L1", "card": {
            "type": "AdaptiveCard", "version": "1.6",
            "body": [{"type": "TextBlock", "text": "L1"}],
            "actions": [{"type": "Action.ShowCard", "title": "L2", "card": {
              "type": "AdaptiveCard", "version": "1.6",
              "body": [{"type": "TextBlock", "text": "L2"}],
              "actions": [{"type": "Action.ShowCard", "title": "L3", "card": {
                "type": "AdaptiveCard", "version": "1.6",
                "body": [{"type": "TextBlock", "text": "L3"}],
                "actions": [{"type": "Action.ShowCard", "title": "L4", "card": {
                  "type": "AdaptiveCard", "version": "1.6",
                  "body": [{"type": "TextBlock", "text": "L4"}]
                }}]
              }}]
            }}]
          }}]
        }
        """.trimIndent()

        val card = CardParser.parse(json)
        assertNotNull(card)
    }

    // MARK: - Handler Crash Resilience

    @Test
    fun `submit with null data does not crash`() {
        val action = ActionSubmit()
        assertDoesNotThrow {
            SubmitActionHandler.handleSubmit(action, emptyMap(), delegate)
        }
        assertEquals(1, delegate.submitCalls.size)
    }

    @Test
    fun `execute with no verb does not crash`() {
        val action = ActionExecute()
        assertDoesNotThrow {
            ExecuteActionHandler.handleExecute(action, emptyMap(), delegate)
        }
        assertEquals(1, delegate.executeCalls.size)
    }

    @Test
    fun `toggleVisibility empty targets does not crash`() {
        val action = ActionToggleVisibility(targetElements = emptyList())
        assertDoesNotThrow {
            ToggleVisibilityHandler.handleToggleVisibility(action, delegate)
        }
        assertEquals(1, delegate.toggleVisibilityCalls.size)
        assertTrue(delegate.toggleVisibilityCalls[0].targetElementIds.isEmpty())
    }

    @Test
    fun `showCard handler does not crash`() {
        val action = ActionShowCard(card = AdaptiveCard())
        assertDoesNotThrow {
            ShowCardActionHandler.handleShowCard(action, "test", true, delegate)
        }
        assertEquals(1, delegate.showCardCalls.size)
    }

    // MARK: - Default Delegate does not crash

    @Test
    fun `DefaultActionDelegate methods are no-op without crash`() {
        val defaultDelegate = DefaultActionDelegate()
        assertDoesNotThrow {
            defaultDelegate.onSubmit(emptyMap(), null)
            defaultDelegate.onOpenUrl("", null)
            defaultDelegate.onExecute("", emptyMap(), null)
            defaultDelegate.onShowCard("", false)
            defaultDelegate.onToggleVisibility(emptyList())
        }
    }
}
