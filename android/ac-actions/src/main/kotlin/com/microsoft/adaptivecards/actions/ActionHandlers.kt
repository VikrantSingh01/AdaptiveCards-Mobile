package com.microsoft.adaptivecards.actions

import com.microsoft.adaptivecards.core.models.*
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive

/**
 * Handler for Submit actions
 */
object SubmitActionHandler {
    /**
     * Collect input values and execute submit
     */
    fun handleSubmit(
        action: ActionSubmit,
        inputValues: Map<String, Any>,
        delegate: ActionDelegate
    ) {
        val submitData = mutableMapOf<String, Any>()
        
        // Add input values based on associatedInputs
        when (action.associatedInputs) {
            AssociatedInputs.Auto, null -> {
                // Include all inputs
                submitData.putAll(inputValues)
            }
            AssociatedInputs.None -> {
                // Don't include any inputs
            }
        }
        
        // Add action data if present
        action.data?.let { data ->
            // Convert JsonElement to Map (simplified)
            // In a real implementation, this would properly handle nested structures
            if (data is JsonObject) {
                data.forEach { (key, value) ->
                    when (value) {
                        is JsonPrimitive -> {
                            submitData[key] = value.toString().trim('"')
                        }
                        else -> {
                            submitData[key] = value.toString()
                        }
                    }
                }
            }
        }
        
        delegate.onSubmit(submitData)
    }
}

/**
 * Handler for OpenUrl actions
 */
object OpenUrlActionHandler {
    /**
     * Open URL in browser or external app
     */
    fun handleOpenUrl(
        action: ActionOpenUrl,
        context: android.content.Context,
        delegate: ActionDelegate
    ) {
        try {
            val intent = android.content.Intent(android.content.Intent.ACTION_VIEW, android.net.Uri.parse(action.url))
            context.startActivity(intent)
            delegate.onOpenUrl(action.url)
        } catch (e: Exception) {
            // Handle error
        }
    }
}

/**
 * Handler for Execute actions
 */
object ExecuteActionHandler {
    /**
     * Execute action with verb and data
     */
    fun handleExecute(
        action: ActionExecute,
        inputValues: Map<String, Any>,
        delegate: ActionDelegate
    ) {
        val executeData = mutableMapOf<String, Any>()
        
        // Add input values based on associatedInputs
        when (action.associatedInputs) {
            AssociatedInputs.Auto, null -> {
                executeData.putAll(inputValues)
            }
            AssociatedInputs.None -> {
                // Don't include any inputs
            }
        }
        
        // Add action data if present
        action.data?.let { data ->
            if (data is JsonObject) {
                data.forEach { (key, value) ->
                    when (value) {
                        is JsonPrimitive -> {
                            executeData[key] = value.toString().trim('"')
                        }
                        else -> {
                            executeData[key] = value.toString()
                        }
                    }
                }
            }
        }
        
        delegate.onExecute(action.verb ?: "", executeData)
    }
}

/**
 * Handler for ShowCard actions
 */
object ShowCardActionHandler {
    /**
     * Toggle inline card visibility
     */
    fun handleShowCard(
        action: ActionShowCard,
        actionId: String,
        isExpanded: Boolean,
        delegate: ActionDelegate
    ) {
        delegate.onShowCard(actionId, isExpanded)
    }
}

/**
 * Handler for ToggleVisibility actions
 */
object ToggleVisibilityHandler {
    /**
     * Toggle visibility of target elements
     */
    fun handleToggleVisibility(
        action: ActionToggleVisibility,
        delegate: ActionDelegate
    ) {
        val targetIds = action.targetElements.map { it.elementId }
        delegate.onToggleVisibility(targetIds)
    }
}
