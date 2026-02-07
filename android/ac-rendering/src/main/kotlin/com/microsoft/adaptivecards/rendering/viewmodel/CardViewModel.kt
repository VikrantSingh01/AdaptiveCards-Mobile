package com.microsoft.adaptivecards.rendering.viewmodel

import androidx.lifecycle.ViewModel
import com.microsoft.adaptivecards.core.models.AdaptiveCard
import com.microsoft.adaptivecards.core.parsing.CardParser
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * ViewModel for managing Adaptive Card state
 */
class CardViewModel : ViewModel() {
    
    private val _card = MutableStateFlow<AdaptiveCard?>(null)
    val card: StateFlow<AdaptiveCard?> = _card.asStateFlow()
    
    private val _inputValues = MutableStateFlow<Map<String, Any>>(emptyMap())
    val inputValues: StateFlow<Map<String, Any>> = _inputValues.asStateFlow()
    
    private val _visibilityState = MutableStateFlow<Map<String, Boolean>>(emptyMap())
    val visibilityState: StateFlow<Map<String, Boolean>> = _visibilityState.asStateFlow()
    
    private val _showCardState = MutableStateFlow<Map<String, Boolean>>(emptyMap())
    val showCardState: StateFlow<Map<String, Boolean>> = _showCardState.asStateFlow()
    
    private val _validationErrors = MutableStateFlow<Map<String, String>>(emptyMap())
    val validationErrors: StateFlow<Map<String, String>> = _validationErrors.asStateFlow()
    
    /**
     * Parse and set the card from JSON
     */
    fun parseCard(jsonString: String) {
        try {
            val parsedCard = CardParser.parse(jsonString)
            _card.value = parsedCard
            initializeVisibilityState(parsedCard)
        } catch (e: Exception) {
            // Handle parsing error
            _card.value = null
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
     * Update input value
     */
    fun updateInputValue(id: String, value: Any) {
        _inputValues.value = _inputValues.value.toMutableMap().apply {
            put(id, value)
        }
    }
    
    /**
     * Get input value by ID
     */
    fun getInputValue(id: String): Any? {
        return _inputValues.value[id]
    }
    
    /**
     * Get all input values
     */
    fun getAllInputValues(): Map<String, Any> {
        return _inputValues.value
    }
    
    /**
     * Toggle visibility of an element
     */
    fun toggleVisibility(elementId: String, isVisible: Boolean? = null) {
        _visibilityState.value = _visibilityState.value.toMutableMap().apply {
            put(elementId, isVisible ?: !(_visibilityState.value[elementId] ?: true))
        }
    }
    
    /**
     * Check if element is visible
     */
    fun isElementVisible(elementId: String): Boolean {
        return _visibilityState.value[elementId] ?: true
    }
    
    /**
     * Toggle ShowCard state
     */
    fun toggleShowCard(actionId: String) {
        _showCardState.value = _showCardState.value.toMutableMap().apply {
            val currentState = get(actionId) ?: false
            put(actionId, !currentState)
        }
    }
    
    /**
     * Check if ShowCard is expanded
     */
    fun isShowCardExpanded(actionId: String): Boolean {
        return _showCardState.value[actionId] ?: false
    }
    
    /**
     * Set validation error for an input
     */
    fun setValidationError(id: String, error: String?) {
        _validationErrors.value = _validationErrors.value.toMutableMap().apply {
            if (error != null) {
                put(id, error)
            } else {
                remove(id)
            }
        }
    }
    
    /**
     * Get validation error for an input
     */
    fun getValidationError(id: String): String? {
        return _validationErrors.value[id]
    }
    
    /**
     * Clear all validation errors
     */
    fun clearValidationErrors() {
        _validationErrors.value = emptyMap()
    }
    
    /**
     * Validate all inputs
     */
    fun validateAllInputs(): Boolean {
        clearValidationErrors()
        // Validation logic would be implemented here
        // For now, return true
        return _validationErrors.value.isEmpty()
    }
    
    /**
     * Reset the card state
     */
    fun reset() {
        _card.value = null
        _inputValues.value = emptyMap()
        _visibilityState.value = emptyMap()
        _showCardState.value = emptyMap()
        _validationErrors.value = emptyMap()
    }
    
    private fun initializeVisibilityState(card: AdaptiveCard) {
        val initialState = mutableMapOf<String, Boolean>()
        // Initialize visibility state for all elements
        // This would be enhanced to walk the card tree
        _visibilityState.value = initialState
    }
}
