package com.microsoft.adaptivecards.rendering.viewmodel

import android.util.Log
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.snapshots.SnapshotStateMap
import androidx.lifecycle.ViewModel
import com.microsoft.adaptivecards.core.models.AdaptiveCard
import com.microsoft.adaptivecards.core.models.CardElement
import com.microsoft.adaptivecards.core.models.CardInput
import com.microsoft.adaptivecards.core.models.Container
import com.microsoft.adaptivecards.core.models.ColumnSet
import com.microsoft.adaptivecards.core.models.Column
import com.microsoft.adaptivecards.core.models.UnknownElement
import com.microsoft.adaptivecards.core.parsing.CardParser
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * ViewModel for managing Adaptive Card state with optimized state management
 */
class CardViewModel : ViewModel() {

    companion object {
        private const val TAG = "CardViewModel"
    }

    private val _card = MutableStateFlow<AdaptiveCard?>(null)
    val card: StateFlow<AdaptiveCard?> = _card.asStateFlow()

    private val _parseError = MutableStateFlow<String?>(null)
    val parseError: StateFlow<String?> = _parseError.asStateFlow()

    // Use SnapshotStateMap for O(1) updates instead of O(n) map copying
    val inputValues: SnapshotStateMap<String, Any> = mutableStateMapOf()
    val visibilityState: SnapshotStateMap<String, Boolean> = mutableStateMapOf()
    val showCardState: SnapshotStateMap<String, Boolean> = mutableStateMapOf()
    val validationErrors: SnapshotStateMap<String, String> = mutableStateMapOf()
    
    /**
     * Parse and set the card from JSON
     */
    fun parseCard(jsonString: String) {
        try {
            val parsedCard = CardParser.parse(jsonString)
            _card.value = parsedCard
            _parseError.value = null
            validateCardStructure(parsedCard)
            initializeVisibilityState(parsedCard)
        } catch (e: Exception) {
            _card.value = null
            _parseError.value = e.message ?: "Unknown parsing error"
            Log.e(TAG, "Failed to parse card", e)
        }
    }

    /**
     * Validate card structure and log warnings for potential issues
     */
    private fun validateCardStructure(card: AdaptiveCard) {
        // Check for unknown elements
        val unknownElements = mutableListOf<String>()
        // Check for input elements without IDs
        val inputsWithoutIds = mutableListOf<String>()

        fun validateElement(element: CardElement) {
            when (element) {
                is UnknownElement -> {
                    val typeName = element.unknownType ?: "Unknown"
                    unknownElements.add(typeName)
                    Log.w(TAG, "Unknown element type encountered: $typeName")
                }
                is CardInput -> {
                    if (element.id.isNullOrBlank()) {
                        inputsWithoutIds.add(element.type)
                        Log.w(TAG, "Input element of type '${element.type}' is missing required 'id' property")
                    }
                }
                is Container -> {
                    element.items?.forEach { validateElement(it) }
                }
                is ColumnSet -> {
                    element.columns?.forEach { column ->
                        column.items?.forEach { validateElement(it) }
                    }
                }
            }
        }

        card.body?.forEach { validateElement(it) }

        if (unknownElements.isNotEmpty()) {
            Log.w(TAG, "Card contains ${unknownElements.size} unknown element type(s): ${unknownElements.distinct()}")
        }
        if (inputsWithoutIds.isNotEmpty()) {
            Log.w(TAG, "Card contains ${inputsWithoutIds.size} input element(s) without IDs. Input data cannot be collected from these elements.")
        }
    }
    
    /**
     * Set the card directly
     */
    fun setCard(card: AdaptiveCard) {
        _card.value = card
        initializeVisibilityState(card)
    }
    
    /**
     * Update input value - O(1) operation with SnapshotStateMap
     */
    fun updateInputValue(id: String, value: Any) {
        inputValues[id] = value
    }

    /**
     * Get input value by ID
     */
    fun getInputValue(id: String): Any? {
        return inputValues[id]
    }

    /**
     * Get all input values as a snapshot
     */
    fun getAllInputValues(): Map<String, Any> {
        return inputValues.toMap()
    }
    
    /**
     * Toggle visibility of an element - O(1) operation with SnapshotStateMap
     */
    fun toggleVisibility(elementId: String, isVisible: Boolean? = null) {
        visibilityState[elementId] = isVisible ?: !(visibilityState[elementId] ?: true)
    }

    /**
     * Check if element is visible
     */
    fun isElementVisible(elementId: String): Boolean {
        return visibilityState[elementId] ?: true
    }
    
    /**
     * Toggle ShowCard state - O(1) operation with SnapshotStateMap
     */
    fun toggleShowCard(actionId: String) {
        val currentState = showCardState[actionId] ?: false
        showCardState[actionId] = !currentState
    }

    /**
     * Check if ShowCard is expanded
     */
    fun isShowCardExpanded(actionId: String): Boolean {
        return showCardState[actionId] ?: false
    }
    
    /**
     * Set validation error for an input - O(1) operation with SnapshotStateMap
     */
    fun setValidationError(id: String, error: String?) {
        if (error != null) {
            validationErrors[id] = error
        } else {
            validationErrors.remove(id)
        }
    }

    /**
     * Get validation error for an input
     */
    fun getValidationError(id: String): String? {
        return validationErrors[id]
    }

    /**
     * Clear all validation errors
     */
    fun clearValidationErrors() {
        validationErrors.clear()
    }

    /**
     * Validate all inputs
     */
    fun validateAllInputs(): Boolean {
        clearValidationErrors()
        // Validation logic would be implemented here
        // For now, return true
        return validationErrors.isEmpty()
    }
    
    /**
     * Reset the card state
     */
    fun reset() {
        _card.value = null
        inputValues.clear()
        visibilityState.clear()
        showCardState.clear()
        validationErrors.clear()
    }

    private fun initializeVisibilityState(card: AdaptiveCard) {
        // Clear existing state
        visibilityState.clear()
        // Initialize visibility state for all elements
        // This would be enhanced to walk the card tree
    }
}
