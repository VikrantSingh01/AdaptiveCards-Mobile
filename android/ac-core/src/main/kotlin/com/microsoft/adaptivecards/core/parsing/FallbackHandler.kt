package com.microsoft.adaptivecards.core.parsing

import com.microsoft.adaptivecards.core.models.CardElement
import kotlinx.serialization.json.JsonElement

/**
 * Handles fallback behavior when an element can't be rendered
 */
object FallbackHandler {
    /**
     * Process fallback for an element
     * Returns the fallback element if available, null otherwise
     */
    fun processFallback(element: CardElement): CardElement? {
        return when (val fallback = element.fallback) {
            null -> null
            else -> {
                // In a full implementation, this would parse the fallback JsonElement
                // into a CardElement. For now, return null to skip the element.
                // This can be enhanced to support "drop" keyword or actual element fallback
                null
            }
        }
    }

    /**
     * Check if the element's requirements are met
     */
    fun requirementsMet(element: CardElement, hostCapabilities: Map<String, String> = emptyMap()): Boolean {
        val requires = element.requires ?: return true
        
        return requires.all { (capability, version) ->
            val hostVersion = hostCapabilities[capability] ?: return@all false
            // Simple version comparison (can be enhanced with semantic versioning)
            hostVersion >= version
        }
    }

    /**
     * Filter elements based on requirements
     */
    fun filterByRequirements(
        elements: List<CardElement>,
        hostCapabilities: Map<String, String> = emptyMap()
    ): List<CardElement> {
        return elements.mapNotNull { element ->
            when {
                requirementsMet(element, hostCapabilities) -> element
                else -> processFallback(element)
            }
        }
    }
}
