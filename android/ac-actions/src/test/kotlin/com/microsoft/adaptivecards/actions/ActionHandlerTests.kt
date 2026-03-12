package com.microsoft.adaptivecards.actions

import com.microsoft.adaptivecards.core.models.*
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test

/**
 * Mock delegate that records all action callbacks for verification
 */
class MockActionDelegate : ActionDelegate {
    data class SubmitCall(val data: Map<String, Any>, val actionId: String?)
    data class OpenUrlCall(val url: String, val actionId: String?)
    data class ExecuteCall(val verb: String, val data: Map<String, Any>, val actionId: String?)
    data class ShowCardCall(val actionId: String, val isExpanded: Boolean)
    data class ToggleVisibilityCall(val targetElementIds: List<String>)

    val submitCalls = mutableListOf<SubmitCall>()
    val openUrlCalls = mutableListOf<OpenUrlCall>()
    val executeCalls = mutableListOf<ExecuteCall>()
    val showCardCalls = mutableListOf<ShowCardCall>()
    val toggleVisibilityCalls = mutableListOf<ToggleVisibilityCall>()

    override fun onSubmit(data: Map<String, Any>, actionId: String?) {
        submitCalls.add(SubmitCall(data, actionId))
    }

    override fun onOpenUrl(url: String, actionId: String?) {
        openUrlCalls.add(OpenUrlCall(url, actionId))
    }

    override fun onExecute(verb: String, data: Map<String, Any>, actionId: String?) {
        executeCalls.add(ExecuteCall(verb, data, actionId))
    }

    override fun onShowCard(actionId: String, isExpanded: Boolean) {
        showCardCalls.add(ShowCardCall(actionId, isExpanded))
    }

    override fun onToggleVisibility(targetElementIds: List<String>) {
        toggleVisibilityCalls.add(ToggleVisibilityCall(targetElementIds))
    }
}

/**
 * Tests for all action handler types using MockActionDelegate.
 * Covers Submit, Execute, ShowCard, ToggleVisibility handlers.
 * OpenUrl requires Android Context so is tested separately.
 */
class ActionHandlerTests {

    private lateinit var delegate: MockActionDelegate

    @BeforeEach
    fun setUp() {
        delegate = MockActionDelegate()
    }

    // MARK: - Action.Submit

    @Test
    fun `submit with data and inputs merges both`() {
        val inputs = mapOf<String, Any>("name" to "John", "email" to "john@test.com")
        val actionData = JsonObject(mapOf("key" to JsonPrimitive("value")))
        val action = ActionSubmit(
            id = "submit1",
            data = actionData
        )

        SubmitActionHandler.handleSubmit(action, inputs, delegate)

        assertEquals(1, delegate.submitCalls.size)
        val call = delegate.submitCalls[0]
        assertEquals("submit1", call.actionId)
        assertEquals("John", call.data["name"])
        assertEquals("john@test.com", call.data["email"])
        assertEquals("value", call.data["key"])
    }

    @Test
    fun `submit with associatedInputs None excludes inputs`() {
        val inputs = mapOf<String, Any>("input1" to "should_not_appear")
        val actionData = JsonObject(mapOf("only" to JsonPrimitive("this")))
        val action = ActionSubmit(
            id = "submit2",
            data = actionData,
            associatedInputs = AssociatedInputs.None
        )

        SubmitActionHandler.handleSubmit(action, inputs, delegate)

        assertEquals(1, delegate.submitCalls.size)
        val call = delegate.submitCalls[0]
        assertNull(call.data["input1"])
        assertEquals("this", call.data["only"])
    }

    @Test
    fun `submit with null data sends empty map`() {
        val action = ActionSubmit(id = "submit3")

        SubmitActionHandler.handleSubmit(action, emptyMap(), delegate)

        assertEquals(1, delegate.submitCalls.size)
        assertTrue(delegate.submitCalls[0].data.isEmpty())
    }

    @Test
    fun `submit with auto associatedInputs includes inputs`() {
        val inputs = mapOf<String, Any>("field1" to "val1")
        val action = ActionSubmit(
            id = "submit4",
            associatedInputs = AssociatedInputs.Auto
        )

        SubmitActionHandler.handleSubmit(action, inputs, delegate)

        assertEquals(1, delegate.submitCalls.size)
        assertEquals("val1", delegate.submitCalls[0].data["field1"])
    }

    // MARK: - Action.Execute

    @Test
    fun `execute with verb and data`() {
        val inputs = mapOf<String, Any>("field1" to "val1")
        val actionData = JsonObject(mapOf("action" to JsonPrimitive("test")))
        val action = ActionExecute(
            id = "exec1",
            verb = "doSomething",
            data = actionData
        )

        ExecuteActionHandler.handleExecute(action, inputs, delegate)

        assertEquals(1, delegate.executeCalls.size)
        val call = delegate.executeCalls[0]
        assertEquals("doSomething", call.verb)
        assertEquals("val1", call.data["field1"])
        assertEquals("test", call.data["action"])
        assertEquals("exec1", call.actionId)
    }

    @Test
    fun `execute with no verb sends empty string`() {
        val action = ActionExecute(id = "exec2")

        ExecuteActionHandler.handleExecute(action, emptyMap(), delegate)

        assertEquals(1, delegate.executeCalls.size)
        assertEquals("", delegate.executeCalls[0].verb)
    }

    // MARK: - Action.ShowCard

    @Test
    fun `showCard delegates with actionId and expanded state`() {
        val action = ActionShowCard(
            id = "showcard1",
            card = AdaptiveCard()
        )

        ShowCardActionHandler.handleShowCard(action, "showcard1", true, delegate)

        assertEquals(1, delegate.showCardCalls.size)
        assertEquals("showcard1", delegate.showCardCalls[0].actionId)
        assertTrue(delegate.showCardCalls[0].isExpanded)
    }

    @Test
    fun `showCard toggle false`() {
        val action = ActionShowCard(card = AdaptiveCard())

        ShowCardActionHandler.handleShowCard(action, "card1", false, delegate)

        assertEquals(1, delegate.showCardCalls.size)
        assertFalse(delegate.showCardCalls[0].isExpanded)
    }

    // MARK: - Action.ToggleVisibility

    @Test
    fun `toggleVisibility sends all target element IDs`() {
        val action = ActionToggleVisibility(
            targetElements = listOf(
                TargetElement(elementId = "elem1", isVisible = true),
                TargetElement(elementId = "elem2", isVisible = false),
                TargetElement(elementId = "elem3")
            )
        )

        ToggleVisibilityHandler.handleToggleVisibility(action, delegate)

        assertEquals(1, delegate.toggleVisibilityCalls.size)
        val ids = delegate.toggleVisibilityCalls[0].targetElementIds
        assertEquals(3, ids.size)
        assertEquals("elem1", ids[0])
        assertEquals("elem2", ids[1])
        assertEquals("elem3", ids[2])
    }

    @Test
    fun `toggleVisibility with empty targets is no-op`() {
        val action = ActionToggleVisibility(targetElements = emptyList())

        ToggleVisibilityHandler.handleToggleVisibility(action, delegate)

        assertEquals(1, delegate.toggleVisibilityCalls.size)
        assertTrue(delegate.toggleVisibilityCalls[0].targetElementIds.isEmpty())
    }

    // MARK: - Crash resilience (no-crash assertions)

    @Test
    fun `submit handler does not crash with null delegate fields`() {
        val action = ActionSubmit()
        assertDoesNotThrow {
            SubmitActionHandler.handleSubmit(action, emptyMap(), delegate)
        }
    }

    @Test
    fun `execute handler does not crash with null verb`() {
        val action = ActionExecute()
        assertDoesNotThrow {
            ExecuteActionHandler.handleExecute(action, emptyMap(), delegate)
        }
    }
}
