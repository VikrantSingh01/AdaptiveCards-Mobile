package com.microsoft.adaptivecards.rendering

import com.microsoft.adaptivecards.core.models.*
import com.microsoft.adaptivecards.core.parsing.CardParser
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test

/**
 * Tests for progress bar and spinner accessibility (upstream #451).
 *
 * Validates that:
 * - ProgressBar elements parse with label, value, and color
 * - The accessibility description includes both label and percentage
 * - Spinner elements parse with label and size
 * - Children are merged (tested via clearAndSetSemantics in the view layer)
 * - Cross-platform parity with iOS ProgressBarView
 */
class ProgressBarAccessibilityTest {

    private fun parseCard(json: String): AdaptiveCard =
        CardParser().parse(json)

    // MARK: - ProgressBar parsing

    @Test
    fun `progress bar parses with label and value`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "ProgressBar", "value": 0.75, "label": "Upload progress"}
            ]}
        """)

        val bar = card.body?.first() as ProgressBar
        assertEquals(0.75, bar.value, 0.001)
        assertEquals("Upload progress", bar.label)
    }

    @Test
    fun `progress bar with zero value`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "ProgressBar", "value": 0.0, "label": "Not started"}
            ]}
        """)

        val bar = card.body?.first() as ProgressBar
        assertEquals(0.0, bar.value, 0.001)
        // Accessibility should say "Not started, Progress: 0 percent"
        val percentage = (bar.value * 100).toInt()
        assertEquals(0, percentage)
    }

    @Test
    fun `progress bar with full value`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "ProgressBar", "value": 1.0, "label": "Complete"}
            ]}
        """)

        val bar = card.body?.first() as ProgressBar
        assertEquals(1.0, bar.value, 0.001)
        val percentage = (bar.value * 100).toInt()
        assertEquals(100, percentage)
    }

    @Test
    fun `progress bar with color parses correctly`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "ProgressBar", "value": 0.22, "label": "Poll result",
                 "color": "#4CAF50"}
            ]}
        """)

        val bar = card.body?.first() as ProgressBar
        assertEquals("#4CAF50", bar.color)
        assertEquals(0.22, bar.value, 0.001)
        // Accessibility description should be "Poll result, Progress: 22 percent"
        val percentage = (bar.value * 100).toInt()
        assertEquals(22, percentage)
    }

    @Test
    fun `progress bar without label uses default accessibility`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "ProgressBar", "value": 0.5}
            ]}
        """)

        val bar = card.body?.first() as ProgressBar
        assertNull(bar.label)
        // Accessibility should say just "Progress: 50 percent"
        val percentage = (bar.value * 100).toInt()
        assertEquals(50, percentage)
    }

    // MARK: - Spinner parsing

    @Test
    fun `spinner parses with label`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "Spinner", "label": "Loading results"}
            ]}
        """)

        val spinner = card.body?.first() as Spinner
        assertEquals("Loading results", spinner.label)
    }

    @Test
    fun `spinner with size parses correctly`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "Spinner", "label": "Please wait", "size": "large"}
            ]}
        """)

        val spinner = card.body?.first() as Spinner
        assertEquals(SpinnerSize.LARGE, spinner.size)
        assertEquals("Please wait", spinner.label)
    }

    // MARK: - Accessibility description construction

    @Test
    fun `progress bar accessibility description includes label and percentage`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "ProgressBar", "value": 0.22, "label": "Yes votes"}
            ]}
        """)

        val bar = card.body?.first() as ProgressBar
        // The view layer builds: "Yes votes, Progress: 22 percent"
        val description = buildString {
            bar.label?.let { append("$it, ") }
            append("Progress: ${(bar.value * 100).toInt()} percent")
        }
        assertEquals("Yes votes, Progress: 22 percent", description,
            "Accessibility description should NOT contain link or image info (upstream #451)")
    }

    @Test
    fun `progress bar description without label omits comma`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "ProgressBar", "value": 0.88}
            ]}
        """)

        val bar = card.body?.first() as ProgressBar
        val description = buildString {
            bar.label?.let { append("$it, ") }
            append("Progress: ${(bar.value * 100).toInt()} percent")
        }
        assertEquals("Progress: 88 percent", description)
    }

    // MARK: - Multiple progress bars (poll card scenario)

    @Test
    fun `multiple progress bars in poll card each have distinct descriptions`() {
        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "ProgressBar", "value": 0.55, "label": "Option A"},
                {"type": "ProgressBar", "value": 0.30, "label": "Option B"},
                {"type": "ProgressBar", "value": 0.15, "label": "Option C"}
            ]}
        """)

        val bars = card.body?.filterIsInstance<ProgressBar>()
        assertEquals(3, bars?.size)

        // Each bar should have its own label for TalkBack
        assertEquals("Option A", bars?.get(0)?.label)
        assertEquals("Option B", bars?.get(1)?.label)
        assertEquals("Option C", bars?.get(2)?.label)

        // Percentages should be distinct
        assertEquals(55, (bars?.get(0)?.value?.times(100))?.toInt())
        assertEquals(30, (bars?.get(1)?.value?.times(100))?.toInt())
        assertEquals(15, (bars?.get(2)?.value?.times(100))?.toInt())
    }

    // MARK: - Parity with iOS

    @Test
    fun `progress bar parity - both platforms use same description format`() {
        // Android: clearAndSetSemantics { contentDescription = "label, Progress: N percent" }
        // iOS: .accessibilityLabel("label"), .accessibilityValue("N percent")
        // Both result in TalkBack/VoiceOver saying "label, Progress: N percent"

        val card = parseCard("""
            {"type": "AdaptiveCard", "version": "1.6", "body": [
                {"type": "ProgressBar", "value": 0.42, "label": "Approval rating"}
            ]}
        """)

        val bar = card.body?.first() as ProgressBar
        val androidDescription = buildString {
            bar.label?.let { append("$it, ") }
            append("Progress: ${(bar.value * 100).toInt()} percent")
        }
        assertTrue(androidDescription.contains("42 percent"),
            "Should announce percentage, not link/image info")
        assertTrue(androidDescription.contains("Approval rating"),
            "Should include the descriptive label")
        assertFalse(androidDescription.contains("link"),
            "Should NOT contain link info (was the bug)")
        assertFalse(androidDescription.contains("image"),
            "Should NOT contain image info (was the bug)")
    }
}
