package com.microsoft.adaptivecards.rendering.viewmodel

import com.microsoft.adaptivecards.core.models.CardAction

/**
 * Interface for handling actions in Adaptive Cards
 */
interface ActionHandler {
    /**
     * Called when a Submit action is triggered
     * @param data Map of input IDs to their values
     * @param actionId Optional ID of the action that was triggered
     */
    fun onSubmit(data: Map<String, Any>, actionId: String? = null)

    /**
     * Called when an OpenUrl action is triggered
     * @param url The URL to open
     * @param actionId Optional ID of the action that was triggered
     */
    fun onOpenUrl(url: String, actionId: String? = null)

    /**
     * Called when an Execute action is triggered
     * @param verb The action verb
     * @param data Map of input IDs to their values plus any action data
     * @param actionId Optional ID of the action that was triggered
     */
    fun onExecute(verb: String, data: Map<String, Any>, actionId: String? = null)

    /**
     * Called when a ShowCard action is triggered
     */
    fun onShowCard(cardAction: CardAction)

    /**
     * Called when a ToggleVisibility action is triggered
     */
    fun onToggleVisibility(targetElementIds: List<String>)
}

/**
 * Default implementation of ActionHandler that does nothing
 */
class DefaultActionHandler : ActionHandler {
    override fun onSubmit(data: Map<String, Any>, actionId: String?) {
        // Default: no-op
    }

    override fun onOpenUrl(url: String, actionId: String?) {
        // Default: no-op
    }

    override fun onExecute(verb: String, data: Map<String, Any>, actionId: String?) {
        // Default: no-op
    }

    override fun onShowCard(cardAction: CardAction) {
        // Default: no-op
    }

    override fun onToggleVisibility(targetElementIds: List<String>) {
        // Default: no-op
    }
}
