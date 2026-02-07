package com.microsoft.adaptivecards.rendering.registry

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.microsoft.adaptivecards.core.models.CardElement

/**
 * Type alias for element renderer functions
 */
typealias ElementRenderer = @Composable (element: CardElement, modifier: Modifier) -> Unit

/**
 * Registry for mapping element types to their renderers
 * Allows custom renderer registration and override
 */
class ElementRendererRegistry {
    
    private val renderers = mutableMapOf<String, ElementRenderer>()
    
    /**
     * Register a custom renderer for a specific element type
     * 
     * @param type The element type (e.g., "TextBlock", "CustomElement")
     * @param renderer The composable function to render the element
     */
    fun register(type: String, renderer: ElementRenderer) {
        renderers[type] = renderer
    }
    
    /**
     * Unregister a renderer for a specific element type
     */
    fun unregister(type: String) {
        renderers.remove(type)
    }
    
    /**
     * Get the renderer for a specific element type
     * 
     * @param type The element type
     * @return The renderer function, or null if not registered
     */
    fun getRenderer(type: String): ElementRenderer? {
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
         * Create a default registry with built-in renderers
         */
        fun createDefault(): ElementRendererRegistry {
            return ElementRendererRegistry()
        }
    }
}

/**
 * Global instance of the element renderer registry
 */
object GlobalElementRendererRegistry {
    private val registry = ElementRendererRegistry.createDefault()
    
    fun register(type: String, renderer: ElementRenderer) {
        registry.register(type, renderer)
    }
    
    fun getRenderer(type: String): ElementRenderer? {
        return registry.getRenderer(type)
    }
    
    fun hasRenderer(type: String): Boolean {
        return registry.hasRenderer(type)
    }
}
