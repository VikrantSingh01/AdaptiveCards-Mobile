package com.microsoft.adaptivecards.actions

/**
 * Delegate interface for host app to handle action callbacks
 */
interface ActionDelegate {
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
     * @param actionId The ID of the action
     * @param isExpanded Whether the card is now expanded
     */
    fun onShowCard(actionId: String, isExpanded: Boolean)

    /**
     * Called when a ToggleVisibility action is triggered
     * @param targetElementIds List of element IDs whose visibility was toggled
     */
    fun onToggleVisibility(targetElementIds: List<String>)
}

/**
 * Default implementation of ActionDelegate that does nothing
 */
class DefaultActionDelegate : ActionDelegate {
    override fun onSubmit(data: Map<String, Any>, actionId: String?) {
        // Default: no-op
    }

    override fun onOpenUrl(url: String, actionId: String?) {
        // Default: no-op
    }

    override fun onExecute(verb: String, data: Map<String, Any>, actionId: String?) {
        // Default: no-op
    }

    override fun onShowCard(actionId: String, isExpanded: Boolean) {
        // Default: no-op
    }

    override fun onToggleVisibility(targetElementIds: List<String>) {
        // Default: no-op
    }
}
