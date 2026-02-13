package com.microsoft.adaptivecards.rendering

import com.microsoft.adaptivecards.core.models.*
import com.microsoft.adaptivecards.core.parsing.CardParser
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test

/**
 * Tests that Adaptive Card elements produce correct accessibility metadata.
 *
 * Validates that parsed elements retain the properties needed for
 * TalkBack (Android) to announce cards correctly:
 * - TextBlock text for screen reader labels
 * - Image altText for content descriptions
 * - Input labels and required state
 * - Action titles for button announcements
 */
class AccessibilityTests {

    // MARK: - TextBlock Accessibility

    @Test
    fun `TextBlock provides text for screen reader`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "TextBlock", "text": "Important announcement", "id": "heading1"}
            ]}
        """)

        val textBlock = card.body?.first() as TextBlock
        assertEquals("Important announcement", textBlock.text)
        assertNotNull(textBlock.id, "TextBlock should have ID for accessibility targeting")
    }

    // MARK: - Image Accessibility

    @Test
    fun `Image provides altText for content description`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "Image", "url": "https://example.com/photo.jpg", "altText": "Profile photo of John"}
            ]}
        """)

        val image = card.body?.first() as Image
        assertEquals("Profile photo of John", image.altText)
    }

    @Test
    fun `Image without altText has null description`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "Image", "url": "https://example.com/decorative.jpg"}
            ]}
        """)

        val image = card.body?.first() as Image
        assertNull(image.altText, "Decorative images should have null altText")
    }

    // MARK: - Input Accessibility

    @Test
    fun `Input Text has label and required state for accessibility`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "Input.Text", "id": "name", "label": "Full Name", "isRequired": true, "placeholder": "Enter name"}
            ]}
        """)

        val input = card.body?.first() as InputText
        assertEquals("Full Name", input.label)
        assertTrue(input.isRequired)
        assertEquals("Enter name", input.placeholder)
        assertEquals("name", input.id)
    }

    @Test
    fun `All input types have IDs for form submission`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "Input.Text", "id": "t1"},
                {"type": "Input.Number", "id": "n1"},
                {"type": "Input.Date", "id": "d1"},
                {"type": "Input.Time", "id": "tm1"},
                {"type": "Input.Toggle", "id": "tg1", "title": "Accept"},
                {"type": "Input.ChoiceSet", "id": "cs1", "choices": []}
            ]}
        """)

        val inputs = card.body?.filterIsInstance<CardInput>() ?: emptyList()
        assertEquals(6, inputs.size)

        val expectedIds = listOf("t1", "n1", "d1", "tm1", "tg1", "cs1")
        val actualIds = inputs.map { it.id }
        assertEquals(expectedIds, actualIds, "Input IDs should match JSON specifications")
    }

    // MARK: - Action Accessibility

    @Test
    fun `Actions have titles for button labels`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "actions": [
                {"type": "Action.Submit", "title": "Submit Form"},
                {"type": "Action.OpenUrl", "title": "Learn More", "url": "https://example.com"}
            ]}
        """)

        assertNotNull(card.actions)
        assertEquals(2, card.actions?.size)

        val submit = card.actions?.get(0) as ActionSubmit
        assertEquals("Submit Form", submit.title)

        val openUrl = card.actions?.get(1) as ActionOpenUrl
        assertEquals("Learn More", openUrl.title)
    }

    @Test
    fun `Action styles convey semantic meaning`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "actions": [
                {"type": "Action.Submit", "title": "Approve", "style": "Positive"},
                {"type": "Action.Submit", "title": "Delete", "style": "Destructive"}
            ]}
        """)

        val approve = card.actions?.get(0) as ActionSubmit
        assertEquals(ActionStyle.Positive, approve.style)

        val delete = card.actions?.get(1) as ActionSubmit
        assertEquals(ActionStyle.Destructive, delete.style)
    }

    // MARK: - Visibility & Structure

    @Test
    fun `Hidden elements should not be announced`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "TextBlock", "text": "Visible", "isVisible": true},
                {"type": "TextBlock", "text": "Hidden", "isVisible": false}
            ]}
        """)

        val visible = card.body?.get(0) as TextBlock
        val hidden = card.body?.get(1) as TextBlock

        assertTrue(visible.isVisible)
        assertFalse(hidden.isVisible)
    }

    @Test
    fun `Container groups children for accessibility`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "Container", "id": "group1", "items": [
                    {"type": "TextBlock", "text": "Title"},
                    {"type": "TextBlock", "text": "Subtitle"}
                ]}
            ]}
        """)

        val container = card.body?.first() as Container
        assertEquals("group1", container.id)
        assertEquals(2, container.items?.size)
    }

    // MARK: - Helper

    private fun parseCard(json: String): AdaptiveCard {
        return CardParser.parse(json.trimIndent())
    }
}
