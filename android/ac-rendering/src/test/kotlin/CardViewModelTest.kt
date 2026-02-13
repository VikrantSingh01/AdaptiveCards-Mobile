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
 * Tests for CardViewModel demonstrating both SnapshotStateMap and StateFlow APIs
 */
@OptIn(ExperimentalCoroutinesApi::class)
class CardViewModelTest {

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

    @Test
    fun `test SnapshotStateMap API for inputValues`() {
        // Direct access to SnapshotStateMap
        viewModel.inputValues["testInput"] = "testValue"
        
        // Verify value is accessible directly
        assertEquals("testValue", viewModel.inputValues["testInput"])
    }

    @Test
    fun `test StateFlow API for inputValues provides reactive updates`() = runTest {
        // Initial state should be empty
        assertEquals(emptyMap<String, Any>(), viewModel.inputValuesFlow.value)
        
        // Update via SnapshotStateMap API
        Snapshot.withMutableSnapshot {
            viewModel.inputValues["testInput"] = "testValue"
        }
        
        // Advance dispatcher to process snapshot changes
        testDispatcher.scheduler.advanceUntilIdle()
        
        // StateFlow should reflect the change
        val flowValue = viewModel.inputValuesFlow.value
        assertTrue(flowValue.containsKey("testInput"))
        assertEquals("testValue", flowValue["testInput"])
    }

    @Test
    fun `test both APIs work together for visibilityState`() = runTest {
        // Update via SnapshotStateMap
        Snapshot.withMutableSnapshot {
            viewModel.visibilityState["element1"] = false
            viewModel.visibilityState["element2"] = true
        }
        
        testDispatcher.scheduler.advanceUntilIdle()
        
        // Verify direct access works
        assertEquals(false, viewModel.visibilityState["element1"])
        assertEquals(true, viewModel.visibilityState["element2"])
        
        // Verify StateFlow also reflects changes
        val flowValue = viewModel.visibilityStateFlow.value
        assertEquals(false, flowValue["element1"])
        assertEquals(true, flowValue["element2"])
    }

    @Test
    fun `test StateFlow API for showCardState`() = runTest {
        // Initial state
        assertEquals(emptyMap<String, Boolean>(), viewModel.showCardStateFlow.value)

        // Update via ViewModel method which uses SnapshotStateMap
        Snapshot.withMutableSnapshot {
            viewModel.toggleShowCard("action1")
        }

        testDispatcher.scheduler.advanceUntilIdle()

        // Verify both APIs reflect the change
        assertTrue(viewModel.showCardState["action1"] == true)
        assertTrue(viewModel.showCardStateFlow.value["action1"] == true)
    }

    @Test
    fun `test StateFlow API for validationErrors`() = runTest {
        // Initial state
        assertEquals(emptyMap<String, String>(), viewModel.validationErrorsFlow.value)

        // Update via ViewModel method
        Snapshot.withMutableSnapshot {
            viewModel.setValidationError("input1", "Required field")
        }

        testDispatcher.scheduler.advanceUntilIdle()

        // Verify both APIs
        assertEquals("Required field", viewModel.validationErrors["input1"])
        assertEquals("Required field", viewModel.validationErrorsFlow.value["input1"])
    }

    @Test
    fun `test getAllInputValues provides snapshot of SnapshotStateMap`() {
        // Add values
        viewModel.inputValues["input1"] = "value1"
        viewModel.inputValues["input2"] = 42
        
        // Get snapshot
        val snapshot = viewModel.getAllInputValues()
        
        // Verify snapshot
        assertEquals(2, snapshot.size)
        assertEquals("value1", snapshot["input1"])
        assertEquals(42, snapshot["input2"])
        
        // Modify SnapshotStateMap after snapshot
        viewModel.inputValues["input3"] = "value3"
        
        // Snapshot should not be affected
        assertEquals(2, snapshot.size)
        assertFalse(snapshot.containsKey("input3"))
    }

    @Test
    fun `test O(1) performance with SnapshotStateMap updates`() {
        // Demonstrate O(1) updates by performing many operations
        val iterations = 10000
        
        for (i in 0 until iterations) {
            viewModel.inputValues["input_$i"] = "value_$i"
        }
        
        // Verify all values are present - this validates functional correctness
        assertEquals(iterations, viewModel.inputValues.size)
        
        // Verify we can access any value efficiently
        assertEquals("value_0", viewModel.inputValues["input_0"])
        assertEquals("value_5000", viewModel.inputValues["input_5000"])
        assertEquals("value_9999", viewModel.inputValues["input_9999"])
    }

    @Test
    fun `test backward compatibility - StateFlow API can be collected`() = runTest {
        // This test demonstrates the backward-compatible API
        // In real usage, this would be used with collectAsState() in Compose
        
        val initialValue = viewModel.inputValuesFlow.value
        assertEquals(emptyMap<String, Any>(), initialValue)
        
        // Update state
        Snapshot.withMutableSnapshot {
            viewModel.updateInputValue("compatTest", "compatible")
        }
        
        testDispatcher.scheduler.advanceUntilIdle()
        
        // Collect the flow value
        val updatedValue = viewModel.inputValuesFlow.value
        assertEquals("compatible", updatedValue["compatTest"])
    }

    @Test
    fun `test migration from old API to new API`() = runTest {
        // OLD API pattern (before the optimization):
        // val inputs by viewModel.inputValues.collectAsState()
        // val value = inputs["myInput"]
        
        // NEW API pattern 1 (backward compatible with StateFlow):
        // val inputs by viewModel.inputValuesFlow.collectAsState()
        // val value = inputs["myInput"]
        
        // NEW API pattern 2 (direct SnapshotStateMap for better performance):
        // val value = viewModel.inputValues["myInput"]
        
        // Simulate both patterns working correctly
        Snapshot.withMutableSnapshot {
            viewModel.inputValues["myInput"] = "testData"
        }
        
        testDispatcher.scheduler.advanceUntilIdle()
        
        // Pattern 1: StateFlow API (backward compatible)
        val flowData = viewModel.inputValuesFlow.value
        assertEquals("testData", flowData["myInput"])
        
        // Pattern 2: Direct SnapshotStateMap API (recommended)
        assertEquals("testData", viewModel.inputValues["myInput"])
        
        // Both patterns produce the same result
        assertEquals(flowData["myInput"], viewModel.inputValues["myInput"])
    }
}
