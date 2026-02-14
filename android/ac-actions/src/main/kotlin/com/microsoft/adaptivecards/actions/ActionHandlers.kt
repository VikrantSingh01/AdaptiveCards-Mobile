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
    private val ALLOWED_SCHEMES = setOf("http", "https", "mailto", "tel")

    /**
     * Open URL in browser or external app.
     * Only URLs with allowed schemes (http, https, mailto, tel) are opened.
     */
    fun handleOpenUrl(
        action: ActionOpenUrl,
        context: android.content.Context,
        delegate: ActionDelegate
    ) {
        try {
            val uri = android.net.Uri.parse(action.url)
            val scheme = uri.scheme?.lowercase()
            if (scheme == null || scheme !in ALLOWED_SCHEMES) {
                return
            }
            val intent = android.content.Intent(android.content.Intent.ACTION_VIEW, uri)
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
