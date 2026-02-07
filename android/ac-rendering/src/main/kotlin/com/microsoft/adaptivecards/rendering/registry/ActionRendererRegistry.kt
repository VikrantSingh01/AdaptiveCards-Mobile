package com.microsoft.adaptivecards.rendering.registry

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.microsoft.adaptivecards.core.models.CardAction

/**
 * Type alias for action renderer functions
 */
typealias ActionRenderer = @Composable (action: CardAction, modifier: Modifier) -> Unit

/**
 * Registry for mapping action types to their renderers
 * Allows custom action button styling and override
 */
class ActionRendererRegistry {
    
    private val renderers = mutableMapOf<String, ActionRenderer>()
    
    /**
     * Register a custom renderer for a specific action type
     * 
     * @param type The action type (e.g., "Action.Submit", "Action.OpenUrl")
     * @param renderer The composable function to render the action
     */
    fun register(type: String, renderer: ActionRenderer) {
        renderers[type] = renderer
    }
    
    /**
     * Unregister a renderer for a specific action type
     */
    fun unregister(type: String) {
        renderers.remove(type)
    }
    
    /**
     * Get the renderer for a specific action type
     * 
     * @param type The action type
     * @return The renderer function, or null if not registered
     */
    fun getRenderer(type: String): ActionRenderer? {
        return renderers[type]
    }
    
    /**
     * Check if a renderer is registered for a specific type
     */
    fun hasRenderer(type: String): Boolean {
        return renderers.containsKey(type)
    }
    
    /**
     * Clear all registered renderers
     */
    fun clear() {
        renderers.clear()
    }
    
    /**
     * Get all registered types
     */
    fun getRegisteredTypes(): Set<String> {
        return renderers.keys.toSet()
    }
    
    companion object {
        /**
         * Create a default registry
         */
        fun createDefault(): ActionRendererRegistry {
            return ActionRendererRegistry()
        }
    }
}

/**
 * Global instance of the action renderer registry
 */
object GlobalActionRendererRegistry {
    private val registry = ActionRendererRegistry.createDefault()
    
    fun register(type: String, renderer: ActionRenderer) {
        registry.register(type, renderer)
    }
    
    fun getRenderer(type: String): ActionRenderer? {
        return registry.getRenderer(type)
    }
    
    fun hasRenderer(type: String): Boolean {
        return registry.hasRenderer(type)
    }
}
