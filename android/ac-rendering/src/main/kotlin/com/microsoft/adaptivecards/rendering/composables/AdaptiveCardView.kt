// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.MutableState
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.compositionLocalOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.microsoft.adaptivecards.core.hostconfig.HostConfig
import com.microsoft.adaptivecards.core.models.*
import com.microsoft.adaptivecards.rendering.theme.HostConfigProvider
import com.microsoft.adaptivecards.rendering.modifiers.adaptiveSeparator
import com.microsoft.adaptivecards.rendering.modifiers.adaptiveSpacing
import com.microsoft.adaptivecards.rendering.modifiers.SeparatorLine
import com.microsoft.adaptivecards.charts.BarChartView
import com.microsoft.adaptivecards.charts.DonutChartView
import com.microsoft.adaptivecards.charts.LineChartView
import com.microsoft.adaptivecards.charts.PieChartView
import com.microsoft.adaptivecards.rendering.registry.GlobalElementRendererRegistry
import com.microsoft.adaptivecards.core.CardConfiguration
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel
import com.microsoft.adaptivecards.rendering.viewmodel.DefaultActionHandler
import com.microsoft.adaptivecards.accessibility.RTLSupport
import com.microsoft.adaptivecards.core.models.WidthCategory
import com.microsoft.adaptivecards.core.models.shouldShowForTargetWidth
import com.microsoft.adaptivecards.core.models.targetWidth

/**
 * CompositionLocal providing the current card width category for targetWidth filtering.
 * Defaults to Narrow (typical phone width).
 */
val LocalWidthCategory = compositionLocalOf { WidthCategory.Narrow }

/**
 * CompositionLocal providing the feature flags for fallback/requires evaluation.
 */
val LocalFeatureFlags = compositionLocalOf { com.microsoft.adaptivecards.core.FeatureFlags() }

/**
 * CompositionLocal providing the CardViewModel to input renderers registered via the
 * GlobalElementRendererRegistry. This avoids a circular dependency between ac-rendering
 * and ac-inputs while allowing host apps to wire up actual input composables.
 */
val LocalCardViewModel = compositionLocalOf<CardViewModel?> { null }

/**
 * Main entry point for rendering an Adaptive Card
 *
 * @param cardJson The JSON string of the adaptive card (may contain `${expression}` template syntax)
 * @param templateData Optional data context for template expansion
 * @param hostConfig Optional host configuration
 * @param actionHandler Handler for card actions
 * @param modifier Modifier for the card container
 * @param viewModel Optional ViewModel for state management
 * @param pendingActionTitle Mutable state to trigger an action by title (for test automation)
 * @param onCardParsed Called when the card is successfully parsed
 * @param onCardParseError Called when card parsing fails
 */
@Composable
fun AdaptiveCardView(
    cardJson: String,
    templateData: Map<String, Any?>? = null,
    hostConfig: HostConfig? = null,
    actionHandler: ActionHandler = DefaultActionHandler(),
    modifier: Modifier = Modifier,
    viewModel: CardViewModel = viewModel(),
    pendingActionTitle: MutableState<String?>? = null,
    onCardParsed: ((AdaptiveCard) -> Unit)? = null,
    onCardParseError: ((String) -> Unit)? = null
) {
    val card by viewModel.card.collectAsState()
    val parseError by viewModel.parseError.collectAsState()

    LaunchedEffect(cardJson, templateData) {
        viewModel.parseCard(cardJson, templateData)
    }

    // Lifecycle callbacks
    LaunchedEffect(card) {
        card?.let { onCardParsed?.invoke(it) }
    }
    LaunchedEffect(parseError) {
        parseError?.let { onCardParseError?.invoke(it) }
    }

    // Handle pending action trigger (for test automation deep links)
    val pendingTitle = pendingActionTitle?.value
    LaunchedEffect(pendingTitle, card) {
        if (pendingTitle != null && card != null) {
            val allActions = collectAllActions(card)
            val matchingAction = allActions.firstOrNull { it.title == pendingTitle }
            if (matchingAction != null) {
                handleAction(matchingAction, actionHandler, viewModel)
            }
            pendingActionTitle?.value = null
        }
    }

    // Display error if parsing failed
    parseError?.let { errorMessage ->
        androidx.compose.material3.Text(
            text = "Failed to render card: $errorMessage",
            color = androidx.compose.material3.MaterialTheme.colorScheme.error,
            modifier = modifier
        )
        return
    }

    card?.let { adaptiveCard ->
        HostConfigProvider(hostConfig = hostConfig ?: com.microsoft.adaptivecards.core.hostconfig.HostConfigParser.default()) {
            RTLSupport(isRTL = adaptiveCard.rtl == true) {
                BoxWithConstraints(modifier = modifier.fillMaxWidth()) {
                    val density = LocalDensity.current
                    val hc = com.microsoft.adaptivecards.rendering.theme.LocalHostConfig.current
                    val widthDp = with(density) { constraints.maxWidth.toDp().value }
                    val widthCategory = WidthCategory.fromDp(
                        widthDp,
                        veryNarrowBreakpoint = hc.hostWidth.veryNarrow,
                        narrowBreakpoint = hc.hostWidth.narrow,
                        standardBreakpoint = hc.hostWidth.standard
                    )

                    CompositionLocalProvider(
                        LocalWidthCategory provides widthCategory,
                        LocalCardViewModel provides viewModel
                    ) {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .verticalScroll(rememberScrollState())
                        ) {
                            // Render body elements
                            adaptiveCard.body?.forEachIndexed { index, element ->
                                RenderElement(
                                    element = element,
                                    isFirst = index == 0,
                                    viewModel = viewModel,
                                    actionHandler = actionHandler
                                )
                            }

                            // Render actions
                            adaptiveCard.actions?.let { actions ->
                                if (actions.isNotEmpty()) {
                                    ActionSetView(
                                        actions = actions,
                                        actionHandler = actionHandler,
                                        viewModel = viewModel,
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

/**
 * New API (Phase 2): Render a pre-parsed Adaptive Card with a CardConfiguration.
 *
 * ```kotlin
 * val result = AdaptiveCards.parse(jsonString)
 * result.card?.let { card ->
 *     AdaptiveCardView(
 *         card = card,
 *         configuration = CardConfiguration.teams(TeamsTheme.Dark),
 *         onAction = { event -> handleAction(event) }
 *     )
 * }
 * ```
 */
@Composable
fun AdaptiveCardView(
    card: AdaptiveCard,
    configuration: CardConfiguration = CardConfiguration.Default,
    actionHandler: ActionHandler = DefaultActionHandler(),
    modifier: Modifier = Modifier,
    viewModel: CardViewModel = viewModel(),
    onCardParsed: ((AdaptiveCard) -> Unit)? = null,
    onRefreshNeeded: ((CardAction) -> Unit)? = null
) {
    // Set the pre-parsed card directly
    LaunchedEffect(card) {
        viewModel.setCard(card)
        onCardParsed?.invoke(card)
    }

    // Auto-refresh: schedule callback when card expires
    if (onRefreshNeeded != null && card.refresh?.expires != null) {
        LaunchedEffect(card.refresh?.expires) {
            val expiresStr = card.refresh?.expires ?: return@LaunchedEffect
            val refreshAction = card.refresh?.action ?: return@LaunchedEffect
            try {
                val expiresInstant = java.time.Instant.parse(expiresStr)
                val delayMs = java.time.Duration.between(java.time.Instant.now(), expiresInstant).toMillis()
                if (delayMs > 0) {
                    kotlinx.coroutines.delay(delayMs)
                }
                onRefreshNeeded(refreshAction)
            } catch (_: Exception) {
                // Invalid date format — ignore
            }
        }
    }

    val currentCard by viewModel.card.collectAsState()

    currentCard?.let { adaptiveCard ->
        HostConfigProvider(hostConfig = configuration.hostConfig) {
            RTLSupport(isRTL = adaptiveCard.rtl == true) {
                BoxWithConstraints(modifier = modifier.fillMaxWidth()) {
                    val density = LocalDensity.current
                    val hc = com.microsoft.adaptivecards.rendering.theme.LocalHostConfig.current
                    val widthDp = with(density) { constraints.maxWidth.toDp().value }
                    val widthCategory = WidthCategory.fromDp(
                        widthDp,
                        veryNarrowBreakpoint = hc.hostWidth.veryNarrow,
                        narrowBreakpoint = hc.hostWidth.narrow,
                        standardBreakpoint = hc.hostWidth.standard
                    )

                    CompositionLocalProvider(
                        LocalWidthCategory provides widthCategory,
                        LocalCardViewModel provides viewModel,
                        LocalFeatureFlags provides configuration.featureFlags
                    ) {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .verticalScroll(rememberScrollState())
                        ) {
                            adaptiveCard.body?.forEachIndexed { index, element ->
                                RenderElement(
                                    element = element,
                                    isFirst = index == 0,
                                    viewModel = viewModel,
                                    actionHandler = actionHandler
                                )
                            }

                            adaptiveCard.actions?.let { actions ->
                                if (actions.isNotEmpty()) {
                                    ActionSetView(
                                        actions = actions,
                                        actionHandler = actionHandler,
                                        viewModel = viewModel,
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

/**
 * Renders a single card element based on its type
 */
@Composable
fun RenderElement(
    element: CardElement,
    isFirst: Boolean = false,
    viewModel: CardViewModel,
    actionHandler: ActionHandler,
    modifier: Modifier = Modifier
) {
    // Check visibility
    if (!element.isVisible) return

    val elementId = element.id
    if (elementId != null && !viewModel.isElementVisible(elementId)) {
        return
    }

    // Check requires against host feature flags
    val featureFlags = LocalFeatureFlags.current
    if (!featureFlags.meetsRequirements(element.requires)) {
        // Requirements not met — render fallback or nothing
        val fallbackElement = resolveFallback(element.fallback)
        if (fallbackElement != null && fallbackElement !is UnknownElement) {
            RenderElement(fallbackElement, isFirst, viewModel, actionHandler, modifier)
        } else if (fallbackElement is UnknownElement && fallbackElement.unknownType == "drop") {
            // "drop" — render nothing
        } else if (fallbackElement != null) {
            RenderElement(fallbackElement, isFirst, viewModel, actionHandler, modifier)
        }
        return
    }

    // Check targetWidth constraint
    val widthCategory = LocalWidthCategory.current
    if (!shouldShowForTargetWidth(element.targetWidth, widthCategory)) {
        return
    }

    Column(modifier = modifier) {
        // Render separator
        if (element.separator && !isFirst) {
            SeparatorLine()
        }

        // Apply spacing and render element
        val elementModifier = Modifier.adaptiveSpacing(element.spacing, isFirst)

        when (element) {
            is TextBlock -> TextBlockView(element, elementModifier)
            is Image -> ImageView(element, elementModifier, actionHandler)
            is Container -> ContainerView(element, elementModifier, viewModel, actionHandler)
            is ColumnSet -> ColumnSetView(element, elementModifier, viewModel, actionHandler)
            is FactSet -> FactSetView(element, elementModifier)
            is ImageSet -> ImageSetView(element, elementModifier, actionHandler)
            is ActionSet -> ActionSetView(element.actions, actionHandler, viewModel, elementModifier)
            is RichTextBlock -> RichTextBlockView(element, elementModifier, actionHandler)
            is Media -> MediaView(element, elementModifier)
            is Table -> TableView(element, elementModifier, viewModel, actionHandler)
            is Icon -> IconView(element, elementModifier, actionHandler)
            is Badge -> BadgeView(element, elementModifier)
            // Input elements - check registry for host-provided renderers first
            is InputText, is InputNumber, is InputDate, is InputTime,
            is InputToggle, is InputChoiceSet, is InputDataGrid, is RatingInput -> {
                val inputRenderer = GlobalElementRendererRegistry.getRenderer(element.type)
                if (inputRenderer != null) {
                    inputRenderer(element, elementModifier)
                } else {
                    // Fallback placeholder — register input renderers via
                    // GlobalElementRendererRegistry to replace this
                    androidx.compose.material3.Text(
                        text = "[Input: ${element::class.simpleName}]",
                        modifier = elementModifier,
                        color = androidx.compose.material3.MaterialTheme.colorScheme.outline
                    )
                }
            }
            // Advanced elements
            is Carousel -> CarouselView(element, viewModel, actionHandler, elementModifier)
            is Accordion -> AccordionView(element, viewModel, actionHandler, elementModifier)
            is CodeBlock -> CodeBlockView(element, elementModifier)
            is RatingDisplay -> RatingDisplayView(element, elementModifier)
            is ProgressBar -> ProgressBarView(element, elementModifier)
            is ProgressRing -> ProgressRingView(element, elementModifier)
            is Spinner -> SpinnerView(element, elementModifier)
            is TabSet -> TabSetView(element, viewModel, actionHandler, elementModifier)
            is ListElement -> ListView(element, viewModel, actionHandler, elementModifier)
            is CompoundButton -> CompoundButtonView(element, actionHandler, elementModifier)
            // Chart elements
            is BarChart -> BarChartView(chart = element)
            is DonutChart -> DonutChartView(chart = element)
            is LineChart -> LineChartView(chart = element)
            is PieChart -> PieChartView(chart = element)
            else -> {
                // Check custom element registry for host-registered renderers
                val customRenderer = GlobalElementRendererRegistry.getRenderer(element.type)
                if (customRenderer != null) {
                    customRenderer(element, elementModifier)
                } else if (element is UnknownElement) {
                    // Unknown element type — try to render fallback
                    val fallbackElement = resolveFallback(element.fallback)
                    if (fallbackElement != null && !(fallbackElement is UnknownElement && fallbackElement.unknownType == "drop")) {
                        RenderElement(fallbackElement, isFirst, viewModel, actionHandler, elementModifier)
                    }
                    // else: no fallback or "drop" — render nothing
                }
            }
        }
    }
}

/**
 * Resolves a fallback JsonElement into a CardElement for rendering.
 * Handles both the "drop" string shorthand and full element objects.
 * Returns null if the fallback is null or cannot be parsed.
 */
private fun resolveFallback(fallback: kotlinx.serialization.json.JsonElement?): CardElement? {
    if (fallback == null) return null
    return try {
        // Handle "drop" string shorthand
        if (fallback is kotlinx.serialization.json.JsonPrimitive && fallback.isString) {
            val value = fallback.content
            if (value.equals("drop", ignoreCase = true)) {
                return UnknownElement(unknownType = "drop")
            }
            return null
        }
        // Parse full element object
        kotlinx.serialization.json.Json { ignoreUnknownKeys = true }
            .decodeFromJsonElement(com.microsoft.adaptivecards.core.parsing.CardElementSerializer, fallback)
    } catch (_: Exception) {
        null
    }
}

/**
 * Recursively collects all actions from a card (card-level + body ActionSets).
 */
fun collectAllActionsForCard(card: AdaptiveCard): List<CardAction> {
    val actions = mutableListOf<CardAction>()
    card.actions?.let { actions.addAll(it) }
    card.body?.let { body -> collectActionsFromElements(body, actions) }
    return actions
}

private fun collectAllActions(card: AdaptiveCard?): List<CardAction> {
    if (card == null) return emptyList()
    return collectAllActionsForCard(card)
}

private fun collectActionsFromElements(elements: List<CardElement>, actions: MutableList<CardAction>) {
    for (element in elements) {
        if (element is ActionSet) {
            actions.addAll(element.actions)
        }
        if (element is Container) {
            element.items?.let { collectActionsFromElements(it, actions) }
        }
        if (element is ColumnSet) {
            element.columns?.forEach { column ->
                column.items?.let { collectActionsFromElements(it, actions) }
            }
        }
    }
}
