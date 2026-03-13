// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

package com.microsoft.adaptivecards.rendering.state

import com.microsoft.adaptivecards.core.CardPerformanceMetrics
import com.microsoft.adaptivecards.core.ParseError
import com.microsoft.adaptivecards.core.models.AdaptiveCard
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * Host-facing state handle for an Adaptive Card.
 * Provides read-only access to card state and host-initiated operations.
 * Internal rendering state (visibility, showCards, popoverState) is NOT exposed.
 *
 * ```kotlin
 * val handle = CardHandle()
 *
 * AdaptiveCardView(
 *     card = myCard,
 *     configuration = config,
 *     handle = handle
 * )
 *
 * // Elsewhere:
 * val inputs = handle.inputValues.value
 * val result = handle.validateInputs()
 * ```
 */
class CardHandle {
    // Read-only state
    private val _card = MutableStateFlow<AdaptiveCard?>(null)
    val card: StateFlow<AdaptiveCard?> = _card.asStateFlow()

    private val _isRendered = MutableStateFlow(false)
    val isRendered: StateFlow<Boolean> = _isRendered.asStateFlow()

    private val _contentSize = MutableStateFlow(Pair(0f, 0f))
    val contentSize: StateFlow<Pair<Float, Float>> = _contentSize.asStateFlow()

    private val _parseError = MutableStateFlow<ParseError?>(null)
    val parseError: StateFlow<ParseError?> = _parseError.asStateFlow()

    // Input access
    val inputValues: StateFlow<Map<String, Any>>
        get() = internalViewModel?.inputValuesFlow
            ?: MutableStateFlow(emptyMap<String, Any>()).asStateFlow()

    // Host-initiated actions
    fun refreshData(newData: Map<String, Any?>) {
        internalViewModel?.refreshData(newData)
    }

    fun validateInputs(): ValidationResult {
        val vm = internalViewModel ?: return ValidationResult(isValid = true, errors = emptyMap())
        val isValid = vm.validateAllInputs()
        return ValidationResult(isValid = isValid, errors = vm.validationErrors.toMap())
    }

    fun triggerAction(actionId: String) {
        pendingActionId = actionId
    }

    fun reset() {
        internalViewModel?.clearValidationErrors()
    }

    // Internal (SDK use only)
    internal var internalViewModel: CardViewModel? = null
    internal var pendingActionId: String? = null

    internal fun didParseCard(card: AdaptiveCard) {
        _card.value = card
        _parseError.value = null
    }

    internal fun didFailParse(error: ParseError) {
        _parseError.value = error
        _card.value = null
    }

    internal fun didRender() {
        _isRendered.value = true
    }

    internal fun didChangeSize(width: Float, height: Float) {
        _contentSize.value = Pair(width, height)
    }
}

/**
 * Result of input validation
 */
data class ValidationResult(
    val isValid: Boolean,
    val errors: Map<String, String>
)
