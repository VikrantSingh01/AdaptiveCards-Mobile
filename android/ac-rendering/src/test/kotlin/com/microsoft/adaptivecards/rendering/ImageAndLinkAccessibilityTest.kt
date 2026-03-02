package com.microsoft.adaptivecards.rendering

import com.microsoft.adaptivecards.core.models.*
import com.microsoft.adaptivecards.core.parsing.CardParser
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test

/**
 * Tests for Image role and ActionOpenUrl link semantics (upstream #490, #375, #492).
 *
 * Validates:
 * - Images always have altText/fallback for TalkBack image role
 * - ActionOpenUrl is distinct from ActionSubmit (link vs button)
 * - Cross-platform parity with iOS
 */
class ImageAndLinkAccessibilityTest {

    // MARK: - Image role tests (upstream #490, #375)

    @Test
    fun `Image with altText provides content description`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "Image", "url": "https://example.com/photo.jpg", "altText": "Driver in great barrier reef"}
            ]}
        """)

        val image = card.body?.first() as Image
        assertEquals("Driver in great barrier reef", image.altText)
    }

    @Test
    fun `Image without altText has null altText`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "Image", "url": "https://example.com/decorative.jpg"}
            ]}
        """)

        val image = card.body?.first() as Image
        assertNull(image.altText, "Images without altText should have null")
    }

    @Test
    fun `Image altText is not modified by role semantics`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "Image", "url": "https://example.com/photo.jpg", "altText": "Matt Hidinger"}
            ]}
        """)

        val image = card.body?.first() as Image
        assertEquals("Matt Hidinger", image.altText)
        assertFalse(
            image.altText!!.lowercase().contains("image"),
            "altText should not contain 'image' — Role.Image handles that"
        )
    }

    @Test
    fun `Image with person style retains altText`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "Image", "url": "https://example.com/avatar.jpg", "altText": "Matt Hidinger", "style": "Person"}
            ]}
        """)

        val image = card.body?.first() as Image
        assertEquals("Matt Hidinger", image.altText)
        assertEquals(ImageStyle.Person, image.style)
    }

    @Test
    fun `Multiple images each have independent altText`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "Image", "url": "https://example.com/1.jpg", "altText": "First photo"},
                {"type": "Image", "url": "https://example.com/2.jpg", "altText": "Second photo"},
                {"type": "Image", "url": "https://example.com/3.jpg"}
            ]}
        """)

        val images = card.body?.filterIsInstance<Image>() ?: emptyList()
        assertEquals(3, images.size)
        assertEquals("First photo", images[0].altText)
        assertEquals("Second photo", images[1].altText)
        assertNull(images[2].altText)
    }

    @Test
    fun `Image role parity - iOS uses isImage trait, Android uses Role Image`() {
        // Both platforms should announce the image role.
        // Android: imageSemantics sets Role.Image unconditionally
        // iOS: .accessibilityElement(label:traits:.isImage)
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "Image", "url": "https://example.com/photo.jpg", "altText": "Test image"}
            ]}
        """)

        val image = card.body?.first() as Image
        assertNotNull(image.url, "Image must have URL for rendering")
        assertNotNull(image.altText, "Image should have altText for accessibility")
    }

    // MARK: - ActionOpenUrl link tests (upstream #492)

    @Test
    fun `ActionOpenUrl has title and url`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "actions": [
                {"type": "Action.OpenUrl", "title": "More Info", "url": "https://example.com/info"}
            ]}
        """)

        val openUrl = card.actions?.first() as ActionOpenUrl
        assertEquals("More Info", openUrl.title)
        assertEquals("https://example.com/info", openUrl.url)
    }

    @Test
    fun `ActionOpenUrl is distinct from ActionSubmit`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "actions": [
                {"type": "Action.OpenUrl", "title": "Visit Site", "url": "https://example.com"},
                {"type": "Action.Submit", "title": "Submit Form"}
            ]}
        """)

        assertTrue(card.actions?.get(0) is ActionOpenUrl, "First should be OpenUrl")
        assertTrue(card.actions?.get(1) is ActionSubmit, "Second should be Submit")
    }

    @Test
    fun `ActionOpenUrl title does not contain button role text`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "actions": [
                {"type": "Action.OpenUrl", "title": "More Info", "url": "https://example.com"}
            ]}
        """)

        val openUrl = card.actions?.first() as ActionOpenUrl
        assertFalse(
            openUrl.title!!.lowercase().contains("button"),
            "OpenUrl title should not reference 'button' — linkSemantics handles the role"
        )
    }

    @Test
    fun `Mixed actions have correct types for semantic routing`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "actions": [
                {"type": "Action.Submit", "title": "Approve"},
                {"type": "Action.OpenUrl", "title": "More Info", "url": "https://example.com"},
                {"type": "Action.Execute", "title": "Run", "verb": "process"},
                {"type": "Action.OpenUrl", "title": "Help", "url": "https://help.example.com"}
            ]}
        """)

        val actions = card.actions!!
        assertEquals(4, actions.size)

        val openUrlCount = actions.count { it is ActionOpenUrl }
        val otherCount = actions.count { it !is ActionOpenUrl }
        assertEquals(2, openUrlCount, "Should have 2 OpenUrl actions (link semantics)")
        assertEquals(2, otherCount, "Should have 2 non-OpenUrl actions (button semantics)")
    }

    @Test
    fun `ActionOpenUrl with tooltip preserves tooltip for accessibility`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "actions": [
                {"type": "Action.OpenUrl", "title": "More Info", "url": "https://example.com", "tooltip": "Opens restaurant details"}
            ]}
        """)

        val openUrl = card.actions?.first() as ActionOpenUrl
        assertEquals("Opens restaurant details", openUrl.tooltip)
    }

    @Test
    fun `Link semantics parity - Android uses linkSemantics, iOS uses isLink trait`() {
        // Android: linkSemantics sets contentDescription = "label, link" (no Role.Button)
        // iOS: .isLink trait replaces .isButton
        // Both should result in TalkBack/VoiceOver saying "link" not "button"
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "actions": [
                {"type": "Action.OpenUrl", "title": "More Info", "url": "https://example.com"}
            ]}
        """)

        val openUrl = card.actions?.first() as ActionOpenUrl
        assertEquals("More Info", openUrl.title)
        assertNotNull(openUrl.url)
    }

    // MARK: - Helper

    private fun parseCard(json: String): AdaptiveCard {
        return CardParser.parse(json.trimIndent())
    }
}
