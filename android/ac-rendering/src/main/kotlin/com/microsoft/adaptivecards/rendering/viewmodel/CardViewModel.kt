package com.microsoft.adaptivecards.rendering.viewmodel

import android.util.Log
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.snapshots.SnapshotStateMap
import androidx.compose.runtime.snapshotFlow
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.microsoft.adaptivecards.core.models.AdaptiveCard
import com.microsoft.adaptivecards.core.models.CardElement
import com.microsoft.adaptivecards.core.models.CardInput
import com.microsoft.adaptivecards.core.models.CardAction
import com.microsoft.adaptivecards.core.models.Container
import com.microsoft.adaptivecards.core.models.ColumnSet
import com.microsoft.adaptivecards.core.models.Column
import com.microsoft.adaptivecards.core.models.UnknownElement
import com.microsoft.adaptivecards.core.models.Carousel
import com.microsoft.adaptivecards.core.models.Accordion
import com.microsoft.adaptivecards.core.models.TabSet
import com.microsoft.adaptivecards.core.models.ListElement
import com.microsoft.adaptivecards.core.models.Table
import com.microsoft.adaptivecards.core.models.TableCell
import com.microsoft.adaptivecards.core.models.ActionShowCard
import com.microsoft.adaptivecards.core.models.ActionPopover
import com.microsoft.adaptivecards.core.models.ActionSet
import com.microsoft.adaptivecards.core.models.Image
import com.microsoft.adaptivecards.core.models.RichTextBlock
import com.microsoft.adaptivecards.core.parsing.CardParser
import com.microsoft.adaptivecards.templating.TemplateEngine
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.stateIn

/**
 * ViewModel for managing Adaptive Card state with dual API support for backward compatibility.
 * 
 * ## State Management APIs
 * 
 * This ViewModel provides two APIs for state management:
 * 
 * ### 1. SnapshotStateMap API (Recommended for Compose)
 * Direct access to mutable state maps that integrate with Compose's snapshot system.
 * - **Performance**: O(1) updates, no map copying overhead
 * - **Usage**: Direct property access in Compose (e.g., `viewModel.inputValues[id]`)
 * - **Properties**: `inputValues`, `visibilityState`, `showCardState`, `validationErrors`
 * 
 * ### 2. StateFlow API (Backward Compatible)
 * Observable StateFlow versions for compatibility with existing code.
 * - **Usage**: Flow collection (e.g., `viewModel.inputValuesFlow.collectAsState()`)
 * - **Properties**: `inputValuesFlow`, `visibilityStateFlow`, `showCardStateFlow`, `validationErrorsFlow`
 * - **Note**: These are read-only views; updates must use the ViewModel methods
 * 
 * ## Migration Guide
 * 
 * If you were using the old StateFlow<Map> API:
 * 
 * **Before:**
 * ```kotlin
 * val inputs by viewModel.inputValues.collectAsState()
 * val value = inputs["myInput"]
 * ```
 * 
 * **After (Option 1 - StateFlow for compatibility):**
 * ```kotlin
 * val inputs by viewModel.inputValuesFlow.collectAsState()
 * val value = inputs["myInput"]
 * ```
 * 
 * **After (Option 2 - Direct SnapshotStateMap for better performance):**
 * ```kotlin
 * val value = viewModel.inputValues["myInput"]
 * ```
 */
class CardViewModel : ViewModel() {

    companion object {
        private const val TAG = "CardViewModel"
    }

    private val _card = MutableStateFlow<AdaptiveCard?>(null)
    val card: StateFlow<AdaptiveCard?> = _card.asStateFlow()

    private val _parseError = MutableStateFlow<String?>(null)
    val parseError: StateFlow<String?> = _parseError.asStateFlow()

    private val templateEngine = TemplateEngine()

    /** Stored template for data refresh support */
    private var storedTemplate: String? = null
    private var storedTemplateData: Map<String, Any?>? = null

    // SnapshotStateMap API - Direct mutable access for Compose with O(1) performance
    val inputValues: SnapshotStateMap<String, Any> = mutableStateMapOf()
    val visibilityState: SnapshotStateMap<String, Boolean> = mutableStateMapOf()
    val showCardState: SnapshotStateMap<String, Boolean> = mutableStateMapOf()
    val validationErrors: SnapshotStateMap<String, String> = mutableStateMapOf()
    
    // StateFlow API - Read-only reactive views for backward compatibility
    val inputValuesFlow: StateFlow<Map<String, Any>> = snapshotFlow { 
        inputValues.toMap() 
    }.stateIn(viewModelScope, SharingStarted.Eagerly, emptyMap())
    
    val visibilityStateFlow: StateFlow<Map<String, Boolean>> = snapshotFlow { 
        visibilityState.toMap() 
    }.stateIn(viewModelScope, SharingStarted.Eagerly, emptyMap())
    
    val showCardStateFlow: StateFlow<Map<String, Boolean>> = snapshotFlow { 
        showCardState.toMap() 
    }.stateIn(viewModelScope, SharingStarted.Eagerly, emptyMap())
    
    val validationErrorsFlow: StateFlow<Map<String, String>> = snapshotFlow { 
        validationErrors.toMap() 
    }.stateIn(viewModelScope, SharingStarted.Eagerly, emptyMap())
    
    /**
     * Parse and set the card from JSON, optionally expanding template expressions with data
     * @param jsonString The card JSON string (may contain `${expression}` template syntax)
     * @param templateData Optional data context for template expansion
     */
    fun parseCard(jsonString: String, templateData: Map<String, Any?>? = null) {
        try {
            var cardJson = jsonString

            // If template data provided, expand template first
            if (templateData != null) {
                storedTemplate = jsonString
                storedTemplateData = templateData
                cardJson = templateEngine.expand(jsonString, templateData)
            } else {
                storedTemplate = null
                storedTemplateData = null
            }

            val parsedCard = CardParser.parse(cardJson)
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
            // Validate element type and check for inputs without IDs
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
                else -> { /* No special validation for other types */ }
            }

            // Recursively validate children in container elements and actions
            when (element) {
                is Container -> {
                    element.items?.forEach { validateElement(it) }
                }
                is ColumnSet -> {
                    element.columns?.forEach { column ->
                        column.items?.forEach { validateElement(it) }
                    }
                }
                is Carousel -> {
                    element.pages.forEach { page ->
                        page.items.forEach { validateElement(it) }
                    }
                }
                is Accordion -> {
                    element.panels.forEach { panel ->
                        panel.content.forEach { validateElement(it) }
                    }
                }
                is TabSet -> {
                    element.tabs.forEach { tab ->
                        tab.items.forEach { validateElement(it) }
                    }
                }
                is ListElement -> {
                    element.items.forEach { validateElement(it) }
                }
                is Table -> {
                    element.rows.forEach { row ->
                        row.cells.forEach { cell ->
                            cell.items?.forEach { validateElement(it) }
                        }
                    }
                }
                is ActionSet -> {
                    element.actions.forEach { action ->
                        when (action) {
                            is ActionShowCard -> action.card.body?.forEach { validateElement(it) }
                            is ActionPopover -> action.popoverBody.forEach { validateElement(it) }
                            else -> {}
                        }
                    }
                }
                else -> { /* No children to validate */ }
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
     * Re-expands the stored template with new data, preserving user input values.
     * Only works if the card was originally parsed with templateData.
     * @param newData New data context for template expansion
     */
    fun refreshData(newData: Map<String, Any?>) {
        val template = storedTemplate ?: return
        val savedInputs = inputValues.toMap()
        parseCard(template, newData)
        inputValues.putAll(savedInputs)
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
