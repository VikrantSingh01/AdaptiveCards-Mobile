package com.microsoft.adaptivecards.rendering.viewmodel

import com.microsoft.adaptivecards.core.models.CardAction

/**
 * Interface for handling actions in Adaptive Cards
 */
interface ActionHandler {
    /**
     * Called when a Submit action is triggered
     */
    fun onSubmit(data: Map<String, Any>)
    
    /**
     * Called when an OpenUrl action is triggered
     */
    fun onOpenUrl(url: String)
    
    /**
     * Called when an Execute action is triggered
     */
    fun onExecute(verb: String, data: Map<String, Any>)
    
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
    override fun onSubmit(data: Map<String, Any>) {
        // Default: no-op
    }
    
    override fun onOpenUrl(url: String) {
        // Default: no-op
    }
    
    override fun onExecute(verb: String, data: Map<String, Any>) {
        // Default: no-op
    }
    
    override fun onShowCard(cardAction: CardAction) {
        // Default: no-op
    }
    
    override fun onToggleVisibility(targetElementIds: List<String>) {
        // Default: no-op
    }
}
