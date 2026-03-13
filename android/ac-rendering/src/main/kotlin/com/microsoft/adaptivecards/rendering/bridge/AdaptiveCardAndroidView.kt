// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

package com.microsoft.adaptivecards.rendering.bridge

import android.content.Context
import android.util.AttributeSet
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.AbstractComposeView
import com.microsoft.adaptivecards.core.*
import com.microsoft.adaptivecards.core.models.AdaptiveCard
import com.microsoft.adaptivecards.rendering.composables.AdaptiveCardView
import com.microsoft.adaptivecards.rendering.state.CardHandle
import com.microsoft.adaptivecards.rendering.state.ValidationResult
import com.microsoft.adaptivecards.rendering.viewmodel.DefaultActionHandler

/**
 * Drop-in Android View for embedding Adaptive Cards in View-based layouts.
 * Wraps the Compose-based AdaptiveCardView via AbstractComposeView.
 *
 * ```kotlin
 * val cardView = AdaptiveCardAndroidView(context)
 * cardView.card = parsedCard
 * cardView.configuration = CardConfiguration.teams(TeamsTheme.Dark)
 * cardView.onAction = { event -> handleAction(event) }
 * layout.addView(cardView)
 * ```
 */
class AdaptiveCardAndroidView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : AbstractComposeView(context, attrs, defStyleAttr) {

    /** The card to render */
    var card: AdaptiveCard? by mutableStateOf(null)

    /** Configuration for theming, image loading, and rendering */
    var configuration: CardConfiguration by mutableStateOf(CardConfiguration.Default)

    /** Callback for action events */
    var onAction: ((CardActionEvent) -> Unit)? = null

    /** Callback for lifecycle events */
    var onLifecycle: ((CardLifecycleEvent) -> Unit)? = null

    /** State handle for host-facing state access */
    val handle = CardHandle()

    /** Set card from JSON string */
    fun setCardJson(json: String, data: Map<String, Any?>? = null) {
        val result = AdaptiveCards.parse(json)
        card = result.card
    }

    /** Get current input values */
    fun getInputValues(): Map<String, Any> = handle.inputValues.value

    /** Validate all inputs */
    fun validateInputs(): ValidationResult = handle.validateInputs()

    /** Refresh card with new template data */
    fun refreshData(newData: Map<String, Any?>) = handle.refreshData(newData)

    @Composable
    override fun Content() {
        val currentCard = card ?: return

        AdaptiveCardView(
            card = currentCard,
            configuration = configuration,
            actionHandler = DefaultActionHandler(),
            onCardParsed = { handle.didParseCard(it) }
        )
    }
}
