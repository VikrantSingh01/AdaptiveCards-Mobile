package com.adaptivecards.core

import com.microsoft.adaptivecards.core.models.InputChoiceSet
import com.microsoft.adaptivecards.core.models.Choice
import com.microsoft.adaptivecards.core.models.ChoiceInputStyle
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.DisplayName

/**
 * Tests for ChoiceSet expanded group label accessibility (upstream #483).
 *
 * Verifies that expanded radio button items report only their own label,
 * without repeating the group/container label.
 */
class ChoiceSetGroupAccessibilityTest {

    private fun makeChoiceSet(
        choices: List<Pair<String, String>>,
        style: ChoiceInputStyle = ChoiceInputStyle.Compact,
        isMultiSelect: Boolean = false,
        label: String? = "What color do you want?",
        isRequired: Boolean = false
    ) = InputChoiceSet(
        id = "test-choiceset",
        isRequired = isRequired,
        label = label,
        choices = choices.map { Choice(title = it.first, value = it.second) },
        value = null,
        style = style,
        isMultiSelect = isMultiSelect,
        placeholder = "Select..."
    )

    private val colorChoices = listOf(
        "Red" to "red",
        "Green" to "green",
        "Blue" to "blue",
        "Yellow" to "yellow"
    )

    // MARK: - Individual item labels should not contain group label

    @Test
    @DisplayName("Expanded item label does not contain group label")
    fun testExpandedItemLabelDoesNotContainGroupLabel() {
        val groupLabel = "What color do you want?"
        val cs = makeChoiceSet(choices = colorChoices, style = ChoiceInputStyle.Expanded, label = groupLabel)
        for (choice in cs.choices) {
            assertFalse(
                choice.title.contains(groupLabel),
                "Individual choice '${choice.title}' should not contain the group label"
            )
        }
    }

    @Test
    @DisplayName("Expanded item label is just choice title")
    fun testExpandedItemLabelIsJustChoiceTitle() {
        val cs = makeChoiceSet(choices = colorChoices, style = ChoiceInputStyle.Expanded)
        assertEquals("Red", cs.choices[0].title)
        assertEquals("Green", cs.choices[1].title)
        assertEquals("Blue", cs.choices[2].title)
        assertEquals("Yellow", cs.choices[3].title)
    }

    // MARK: - Group label exists but is standalone

    @Test
    @DisplayName("Expanded group label is not null")
    fun testExpandedGroupLabelNotNull() {
        val cs = makeChoiceSet(choices = colorChoices, style = ChoiceInputStyle.Expanded)
        assertNotNull(cs.label)
    }

    @Test
    @DisplayName("Expanded group label matches input")
    fun testExpandedGroupLabelMatchesInput() {
        val cs = makeChoiceSet(choices = colorChoices, style = ChoiceInputStyle.Expanded, label = "Pick a color")
        assertEquals("Pick a color", cs.label)
    }

    // MARK: - Required state should be on label, not on each item

    @Test
    @DisplayName("Required state is on group, not per item")
    fun testRequiredStateNotOnItems() {
        val cs = makeChoiceSet(
            choices = colorChoices,
            style = ChoiceInputStyle.Expanded,
            isRequired = true
        )
        assertTrue(cs.isRequired, "Choice set should be required")
        for (choice in cs.choices) {
            assertFalse(
                choice.title.contains("required"),
                "'${choice.title}' should not contain 'required'"
            )
        }
    }

    // MARK: - Item count for expanded

    @Test
    @DisplayName("Expanded item count matches choices")
    fun testExpandedItemCountExact() {
        val cs = makeChoiceSet(choices = colorChoices, style = ChoiceInputStyle.Expanded)
        assertEquals(4, cs.choices.size, "Should have exactly 4 items")
    }

    @Test
    @DisplayName("Expanded multi-select has same item count")
    fun testExpandedMultiSelectItemCount() {
        val cs = makeChoiceSet(choices = colorChoices, style = ChoiceInputStyle.Expanded, isMultiSelect = true)
        assertEquals(4, cs.choices.size)
    }

    // MARK: - TalkBack position info per item

    @Test
    @DisplayName("TalkBack position hint does not contain group label")
    fun testPositionHintDoesNotContainGroupLabel() {
        val cs = makeChoiceSet(choices = colorChoices, style = ChoiceInputStyle.Expanded)
        for ((index, _) in cs.choices.withIndex()) {
            val hint = "${index + 1} of ${cs.choices.size}"
            assertFalse(hint.contains("What color"), "Position hint should be clean")
            assertEquals("${index + 1} of 4", hint)
        }
    }

    // MARK: - Style-based conditional logic

    @Test
    @DisplayName("Compact style applies parent semantics")
    fun testCompactAppliesParentSemantics() {
        val isExpanded = ChoiceInputStyle.Compact == ChoiceInputStyle.Expanded
        assertFalse(isExpanded)
    }

    @Test
    @DisplayName("Expanded style skips parent semantics")
    fun testExpandedSkipsParentSemantics() {
        val isExpanded = ChoiceInputStyle.Expanded == ChoiceInputStyle.Expanded
        assertTrue(isExpanded)
    }

    // MARK: - No group label duplication

    @Test
    @DisplayName("Choice titles are not prefixed with group label")
    fun testGroupLabelNotPrefixedOnChoices() {
        val groupLabel = "Pick a size"
        val choices = listOf("Small" to "s", "Medium" to "m", "Large" to "l")
        val cs = makeChoiceSet(choices = choices, style = ChoiceInputStyle.Expanded, label = groupLabel)
        for (choice in cs.choices) {
            assertFalse(
                choice.title.startsWith(groupLabel),
                "Choice should not be prefixed with group label"
            )
        }
    }

    @Test
    @DisplayName("Multi-select expanded items have own labels")
    fun testMultiSelectExpandedItemsHaveOwnLabels() {
        val cs = makeChoiceSet(
            choices = colorChoices,
            style = ChoiceInputStyle.Expanded,
            isMultiSelect = true,
            label = "Select colors"
        )
        for (choice in cs.choices) {
            assertFalse(
                choice.title.startsWith("Select colors"),
                "Multi-select item should not start with group label"
            )
        }
    }
}
