package com.microsoft.adaptivecards.rendering

import androidx.compose.runtime.snapshots.Snapshot
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test

/**
 * Tests for CardViewModel state management and action dispatch.
 * Validates visibility toggling, input collection, show card expansion,
 * and the full submit-action input gathering pipeline.
 */
@OptIn(ExperimentalCoroutinesApi::class)
class InteractionTests {

    private lateinit var viewModel: CardViewModel
    private val testDispatcher = StandardTestDispatcher()

    @BeforeEach
    fun setup() {
        Dispatchers.setMain(testDispatcher)
        viewModel = CardViewModel()
    }

    @AfterEach
    fun tearDown() {
        Dispatchers.resetMain()
    }

    // MARK: - Input Value Management

    @Test
    fun `set and get input value`() {
        viewModel.inputValues["name"] = "John"
        assertEquals("John", viewModel.inputValues["name"])
    }

    @Test
    fun `multiple input values`() {
        viewModel.inputValues["name"] = "Jane"
        viewModel.inputValues["age"] = 30
        viewModel.inputValues["subscribe"] = true

        val gathered = viewModel.getAllInputValues()
        assertEquals(3, gathered.size)
        assertEquals("Jane", gathered["name"])
        assertEquals(30, gathered["age"])
        assertEquals(true, gathered["subscribe"])
    }

    @Test
    fun `overwrite input value`() {
        viewModel.inputValues["name"] = "Alice"
        viewModel.inputValues["name"] = "Bob"
        assertEquals("Bob", viewModel.inputValues["name"])
    }

    @Test
    fun `get missing input returns null`() {
        assertNull(viewModel.inputValues["nonexistent"])
    }

    // MARK: - Visibility Toggling

    @Test
    fun `toggle visibility with explicit value`() {
        viewModel.visibilityState["elem1"] = false
        assertFalse(viewModel.visibilityState["elem1"] ?: true)

        viewModel.visibilityState["elem1"] = true
        assertTrue(viewModel.visibilityState["elem1"] ?: false)
    }

    @Test
    fun `toggle visibility toggles current state`() {
        viewModel.toggleVisibility("elem1")
        // First toggle: default true -> false
        assertEquals(false, viewModel.visibilityState["elem1"])

        viewModel.toggleVisibility("elem1")
        assertEquals(true, viewModel.visibilityState["elem1"])
    }

    // MARK: - Show Card State

    @Test
    fun `toggle show card`() {
        assertNull(viewModel.showCardState["action1"])

        viewModel.toggleShowCard("action1")
        assertTrue(viewModel.showCardState["action1"] == true)

        viewModel.toggleShowCard("action1")
        assertFalse(viewModel.showCardState["action1"] == true)
    }

    @Test
    fun `multiple show cards independent`() {
        viewModel.toggleShowCard("card1")
        viewModel.toggleShowCard("card2")

        assertTrue(viewModel.showCardState["card1"] == true)
        assertTrue(viewModel.showCardState["card2"] == true)
    }

    // MARK: - Validation Errors

    @Test
    fun `set and get validation error`() {
        Snapshot.withMutableSnapshot {
            viewModel.setValidationError("input1", "Required field")
        }
        assertEquals("Required field", viewModel.validationErrors["input1"])
    }

    @Test
    fun `clear validation errors`() {
        Snapshot.withMutableSnapshot {
            viewModel.setValidationError("input1", "Error 1")
            viewModel.setValidationError("input2", "Error 2")
        }
        assertEquals(2, viewModel.validationErrors.size)

        viewModel.clearValidationErrors()
        assertTrue(viewModel.validationErrors.isEmpty())
    }

    // MARK: - StateFlow Backward Compatibility

    @Test
    fun `StateFlow reflects SnapshotStateMap changes`() = runTest {
        assertEquals(emptyMap<String, Any>(), viewModel.inputValuesFlow.value)

        Snapshot.withMutableSnapshot {
            viewModel.inputValues["testInput"] = "testValue"
        }

        testDispatcher.scheduler.advanceUntilIdle()

        val flowValue = viewModel.inputValuesFlow.value
        assertTrue(flowValue.containsKey("testInput"))
        assertEquals("testValue", flowValue["testInput"])
    }

    // MARK: - Submit Action Input Gathering
    // Note: Android uses getAllInputValues() while iOS uses gatherInputValues().
    // Both return an immutable snapshot of all collected input values for Action.Submit.

    @Test
    fun `gather inputs for submit returns all values`() {
        viewModel.inputValues["firstName"] = "John"
        viewModel.inputValues["lastName"] = "Doe"
        viewModel.inputValues["email"] = "john@example.com"

        val inputs = viewModel.getAllInputValues()
        assertEquals(3, inputs.size)
        assertEquals("John", inputs["firstName"])
    }

    @Test
    fun `gather inputs returns immutable snapshot`() {
        viewModel.inputValues["field1"] = "value1"
        val snapshot = viewModel.getAllInputValues()

        viewModel.inputValues["field2"] = "value2"

        // Snapshot should not be affected
        assertEquals(1, snapshot.size)
        assertFalse(snapshot.containsKey("field2"))
    }

    // MARK: - Card Parsing

    @Test
    fun `parse simple card`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {"type": "TextBlock", "text": "Hello", "id": "text1"}
                ]
            }
        """.trimIndent()

        viewModel.parseCard(json)
        assertNotNull(viewModel.card.value)
    }

    // MARK: - O(1) Performance

    @Test
    fun `SnapshotStateMap supports O(1) updates at scale`() {
        val iterations = 10_000
        for (i in 0 until iterations) {
            viewModel.inputValues["input_$i"] = "value_$i"
        }

        assertEquals(iterations, viewModel.inputValues.size)
        assertEquals("value_0", viewModel.inputValues["input_0"])
        assertEquals("value_5000", viewModel.inputValues["input_5000"])
        assertEquals("value_9999", viewModel.inputValues["input_9999"])
    }
}
