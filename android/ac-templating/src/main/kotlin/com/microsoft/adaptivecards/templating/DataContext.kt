// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.templating

/**
 * Represents a data context for template evaluation with support for nested contexts
 */
class DataContext(
    /**
     * The current data value
     */
    val data: Any?,
    
    /**
     * The root data value (top-level context)
     */
    val root: Any? = data,
    
    /**
     * The current index when iterating over arrays
     */
    val index: Int? = null,
    
    /**
     * Parent context for nested scopes
     */
    val parent: DataContext? = null
) {
    /**
     * Resolve a property path in the current context
     * @param path Property path (e.g., "user.name", "$root.title", "$index")
     * @return The resolved value or null if not found
     */
    fun resolve(path: String): Any? {
        // Handle special variables
        when (path) {
            "\$data" -> return data
            "\$root" -> return root
            "\$index" -> return index
        }
        
        // Handle path starting with $root
        if (path.startsWith("\$root.")) {
            val remainingPath = path.substring(6) // Remove "$root."
            return resolvePath(remainingPath, root)
        }
        
        // Handle path starting with $data
        if (path.startsWith("\$data.")) {
            val remainingPath = path.substring(6) // Remove "$data."
            return resolvePath(remainingPath, data)
        }
        
        // Regular property path - resolve from current data
        return resolvePath(path, data)
    }
    
    /**
     * Resolve a property path in a given object.
     *
     * Supports dot-separated paths with numeric array indices (e.g. "items.0.name")
     * and also inline bracket notation (e.g. "items[0].name") as a fallback.
     *
     * @param path Property path (e.g., "user.name", "menu.items.0.name")
     * @param obj The object to resolve from
     * @return The resolved value or null
     */
    private fun resolvePath(path: String, obj: Any?): Any? {
        if (obj == null) return null

        // Normalize bracket notation to dot notation for uniform handling:
        // "hasMenu.hasMenuSection[0].name" -> "hasMenu.hasMenuSection.0.name"
        val normalizedPath = path.replace(Regex("\\[(\\d+)\\]"), ".$1")

        val components = normalizedPath.split(".")
        var current: Any? = obj

        for (component in components) {
            if (current == null) return null
            if (component.isEmpty()) continue

            current = when (current) {
                is Map<*, *> -> {
                    @Suppress("UNCHECKED_CAST")
                    val map = current as? Map<String, Any?>
                    // Try key lookup first; if not found and key is numeric, this might
                    // be a map with string-number keys (rare but possible)
                    map?.get(component)
                }
                is List<*> -> {
                    val index = component.toIntOrNull()
                    if (index != null && index >= 0 && index < current.size) {
                        current[index]
                    } else null
                }
                else -> {
                    // Try to use reflection for custom objects
                    try {
                        val field = current.javaClass.getDeclaredField(component)
                        field.isAccessible = true
                        field.get(current)
                    } catch (e: Exception) {
                        null
                    }
                }
            }
        }

        return current
    }
    
    /**
     * Create a child context for iteration
     * @param itemData The item data
     * @param itemIndex The iteration index
     * @return A new child context
     */
    fun createChild(itemData: Any?, itemIndex: Int): DataContext {
        return DataContext(
            data = itemData,
            root = root,
            index = itemIndex,
            parent = this
        )
    }
}
