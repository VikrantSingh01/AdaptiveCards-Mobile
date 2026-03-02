package com.microsoft.adaptivecards.core

import com.microsoft.adaptivecards.core.models.InputChoiceSet
import com.microsoft.adaptivecards.core.models.Choice
import com.microsoft.adaptivecards.core.models.ChoiceInputStyle
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*

/**
 * Tests for ChoiceSet title display behavior (upstream #391).
 * Verifies that ChoiceSet renders choice.title to users,
 * while internally storing choice.value for submit payloads.
 */
class ChoiceSetTitleDisplayTest {

    private fun makeChoices(): List<Choice> = listOf(
        Choice(title = "Red", value = "1"),
        Choice(title = "Green", value = "2"),
        Choice(title = "Blue", value = "3")
    )

    private fun makeInput(
        style: ChoiceInputStyle = ChoiceInputStyle.Compact,
        isMultiSelect: Boolean = false,
        value: String? = null,
        placeholder: String? = null
    ): InputChoiceSet = InputChoiceSet(
        id = "colorPicker",
        choices = makeChoices(),
        value = value,
        style = style,
        isMultiSelect = isMultiSelect,
        placeholder = placeholder
    )

    // MARK: - Title resolution

    @Test
    fun `resolveTitle returns correct title for known value`() {
        val input = makeInput()
        assertEquals("Red", input.resolveTitle("1"))
        assertEquals("Green", input.resolveTitle("2"))
        assertEquals("Blue", input.resolveTitle("3"))
    }

    @Test
    fun `resolveTitle falls back to raw value for unknown`() {
        val input = makeInput()
        assertEquals("unknown", input.resolveTitle("unknown"))
        assertEquals("999", input.resolveTitle("999"))
    }

    @Test
    fun `resolveTitle returns empty string for empty input`() {
        val input = makeInput()
        assertEquals("", input.resolveTitle(""))
    }

    // MARK: - Multi-select title resolution

    @Test
    fun `resolveTitles returns correct titles for multi-select`() {
        val input = makeInput(isMultiSelect = true)
        val titles = input.resolveTitles("1,3")
        assertEquals(listOf("Red", "Blue"), titles)
    }

    @Test
    fun `resolveTitles handles single value`() {
        val input = makeInput(isMultiSelect = true)
        val titles = input.resolveTitles("2")
        assertEquals(listOf("Green"), titles)
    }

    @Test
    fun `resolveTitles falls back for unknown values`() {
        val input = makeInput(isMultiSelect = true)
        val titles = input.resolveTitles("1,4")
        assertEquals(listOf("Red", "4"), titles)
    }

    // MARK: - Display text

    @Test
    fun `displayText returns title for single select`() {
        val input = makeInput()
        assertEquals("Red", input.displayText("1"))
        assertEquals("Green", input.displayText("2"))
    }

    @Test
    fun `displayText returns joined titles for multi-select`() {
        val input = makeInput(isMultiSelect = true)
        assertEquals("Red, Blue", input.displayText("1,3"))
    }

    @Test
    fun `displayText returns placeholder when null value`() {
        val input = makeInput(placeholder = "Pick a color")
        assertEquals("Pick a color", input.displayText(null))
    }

    @Test
    fun `displayText returns default when null value and no placeholder`() {
        val input = makeInput()
        assertEquals("Select...", input.displayText(null))
    }

    @Test
    fun `displayText returns placeholder for empty string`() {
        val input = makeInput(placeholder = "Choose one")
        assertEquals("Choose one", input.displayText(""))
    }

    // MARK: - Core bug verification

    @Test
    fun `value is NOT used as display text`() {
        val input = makeInput()
        val storedValue = "1"
        val displayText = input.displayText(storedValue)
        assertEquals("Red", displayText)
        assertNotEquals(storedValue, displayText,
            "Display text must show title, not raw value")
    }

    @Test
    fun `submit payload uses value not title`() {
        val input = makeInput()
        val selectedChoice = input.choices[0]
        assertEquals("1", selectedChoice.value)
        assertEquals("Red", selectedChoice.title)
        assertNotEquals(selectedChoice.title, selectedChoice.value)
    }

    // MARK: - Edge cases

    @Test
    fun `choices with same title different values`() {
        val input = InputChoiceSet(
            id = "test",
            choices = listOf(
                Choice(title = "Option A", value = "opt_a_v1"),
                Choice(title = "Option A", value = "opt_a_v2")
            )
        )
        assertEquals("Option A", input.resolveTitle("opt_a_v1"))
        assertEquals("Option A", input.resolveTitle("opt_a_v2"))
    }

    @Test
    fun `choices with special characters in values`() {
        val input = InputChoiceSet(
            id = "test",
            choices = listOf(
                Choice(title = "Priority: High", value = "p:high"),
                Choice(title = "Priority: Low", value = "p:low")
            )
        )
        assertEquals("Priority: High", input.resolveTitle("p:high"))
    }

    @Test
    fun `empty choices array`() {
        val input = InputChoiceSet(id = "test", choices = emptyList())
        assertEquals("any", input.resolveTitle("any"))
        assertEquals("Select...", input.displayText(null))
    }
}
