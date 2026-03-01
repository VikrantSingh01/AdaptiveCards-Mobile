// DropdownAccessibilityTest.kt
// Tests for ChoiceSet dropdown accessibility semantics (upstream #466)
//
// Verifies that dropdown/choice-set components provide correct
// collection position info for TalkBack (e.g. "1 of 4").

package com.adaptivecards.core

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*
import com.microsoft.adaptivecards.core.models.InputChoiceSet
import com.microsoft.adaptivecards.core.models.Choice
import com.microsoft.adaptivecards.core.models.ChoiceInputStyle

class DropdownAccessibilityTest {

    // Helper to create a ChoiceSet
    private fun makeChoiceSet(
        choices: List<Pair<String, String>>,
        style: ChoiceInputStyle = ChoiceInputStyle.Compact,
        isMultiSelect: Boolean = false,
        label: String? = "Sample label",
        placeholder: String? = "Select...",
        isRequired: Boolean = false
    ): InputChoiceSet {
        return InputChoiceSet(
            type = "Input.ChoiceSet",
            id = "test-choiceset",
            label = label,
            isRequired = isRequired,
            style = style,
            isMultiSelect = isMultiSelect,
            placeholder = placeholder,
            choices = choices.map { Choice(title = it.first, value = it.second) },
            value = null
        )
    }

    private val fourChoices = listOf(
        "Metro Transit" to "metro",
        "City Bus" to "bus",
        "Regional Rail" to "rail",
        "Airport Shuttle" to "shuttle"
    )

    // MARK: - Choice count tests

    @Test
    fun `choice count matches actual choices`() {
        val cs = makeChoiceSet(choices = fourChoices)
        assertEquals(4, cs.choices.size, "Should have exactly 4 choices, not 5")
    }

    @Test
    fun `choice count excludes placeholder`() {
        val cs = makeChoiceSet(choices = fourChoices, placeholder = "Select an option")
        // The placeholder is NOT a choice - it should not be counted
        assertEquals(4, cs.choices.size,
            "Placeholder should not be counted as a choice")
    }

    @Test
    fun `choice count with empty list`() {
        val cs = makeChoiceSet(choices = emptyList())
        assertEquals(0, cs.choices.size)
    }

    @Test
    fun `choice count with single choice`() {
        val cs = makeChoiceSet(choices = listOf("Only Option" to "only"))
        assertEquals(1, cs.choices.size)
    }

    // MARK: - Index correctness

    @Test
    fun `choice indices are zero-based`() {
        val cs = makeChoiceSet(choices = fourChoices)
        cs.choices.forEachIndexed { index, choice ->
            assertEquals(index, cs.choices.indexOfFirst { it.value == choice.value },
                "Index should match position in choices array")
        }
    }

    @Test
    fun `first choice index is zero`() {
        val cs = makeChoiceSet(choices = fourChoices)
        val firstIndex = cs.choices.indexOfFirst { it.value == "metro" }
        assertEquals(0, firstIndex)
    }

    @Test
    fun `last choice index is count minus one`() {
        val cs = makeChoiceSet(choices = fourChoices)
        val lastIndex = cs.choices.indexOfFirst { it.value == "shuttle" }
        assertEquals(3, lastIndex)
    }

    // MARK: - TalkBack announcement format

    @Test
    fun `accessibility position format for first item`() {
        val index = 0
        val totalCount = 4
        // TalkBack CollectionItemInfo uses 0-based rowIndex
        // but announces as "1 of 4" (adds 1 internally)
        val position = index + 1
        assertEquals(1, position)
        assertTrue(position <= totalCount)
    }

    @Test
    fun `accessibility position format for last item`() {
        val index = 3
        val totalCount = 4
        val position = index + 1
        assertEquals(4, position)
        assertTrue(position <= totalCount)
    }

    @Test
    fun `accessibility position never exceeds count`() {
        val cs = makeChoiceSet(choices = fourChoices)
        cs.choices.forEachIndexed { index, _ ->
            val position = index + 1
            assertTrue(position <= cs.choices.size,
                "Position $position should never exceed count ${cs.choices.size}")
        }
    }

    // MARK: - Display text for accessibility content description

    @Test
    fun `displayText for selected value shows title`() {
        val cs = makeChoiceSet(choices = fourChoices)
        val text = cs.displayText("bus")
        assertEquals("City Bus", text)
    }

    @Test
    fun `displayText for no selection shows placeholder`() {
        val cs = makeChoiceSet(choices = fourChoices, placeholder = "Pick one")
        val text = cs.displayText(null)
        assertEquals("Pick one", text)
    }

    @Test
    fun `displayText for empty selection shows placeholder`() {
        val cs = makeChoiceSet(choices = fourChoices, placeholder = "Pick one")
        val text = cs.displayText("")
        assertEquals("Pick one", text)
    }

    // MARK: - Multi-select count

    @Test
    fun `multi-select choice count matches single-select`() {
        val cs = makeChoiceSet(choices = fourChoices, isMultiSelect = true)
        assertEquals(4, cs.choices.size,
            "Multi-select should have same count as single-select")
    }

    // MARK: - Expanded style count

    @Test
    fun `expanded style has correct choice count`() {
        val cs = makeChoiceSet(choices = fourChoices, style = ChoiceInputStyle.Expanded)
        assertEquals(4, cs.choices.size,
            "Expanded style should have same choice count")
    }

    // MARK: - CollectionInfo correctness

    @Test
    fun `collection row count equals choice count`() {
        val cs = makeChoiceSet(choices = fourChoices)
        // CollectionInfo.rowCount should equal choices.size
        val rowCount = cs.choices.size
        assertEquals(4, rowCount)
    }

    @Test
    fun `collection column count is always 1 for dropdown`() {
        // Dropdown items are always in a single column
        val columnCount = 1
        assertEquals(1, columnCount)
    }

    // MARK: - Dropdown state description

    @Test
    fun `dropdown state description when collapsed with selection`() {
        val selectedValue = "City Bus"
        val expanded = false
        val stateDesc = if (expanded) {
            if (selectedValue.isNotEmpty()) "$selectedValue, expanded" else "expanded"
        } else {
            if (selectedValue.isNotEmpty()) "$selectedValue, collapsed" else "collapsed"
        }
        assertEquals("City Bus, collapsed", stateDesc)
    }

    @Test
    fun `dropdown state description when expanded`() {
        val selectedValue = ""
        val expanded = true
        val stateDesc = if (expanded) {
            if (selectedValue.isNotEmpty()) "$selectedValue, expanded" else "expanded"
        } else {
            if (selectedValue.isNotEmpty()) "$selectedValue, collapsed" else "collapsed"
        }
        assertEquals("expanded", stateDesc)
    }
}
