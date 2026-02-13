package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.compose.viewModel
import com.microsoft.adaptivecards.core.hostconfig.HostConfig
import com.microsoft.adaptivecards.core.models.*
import com.microsoft.adaptivecards.hostconfig.HostConfigProvider
import com.microsoft.adaptivecards.rendering.modifiers.adaptiveSeparator
import com.microsoft.adaptivecards.rendering.modifiers.adaptiveSpacing
import com.microsoft.adaptivecards.rendering.modifiers.SeparatorLine
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel
import com.microsoft.adaptivecards.rendering.viewmodel.DefaultActionHandler
import com.microsoft.adaptivecards.accessibility.RTLSupport

/**
 * Main entry point for rendering an Adaptive Card
 * 
 * @param cardJson The JSON string of the adaptive card
 * @param hostConfig Optional host configuration
 * @param actionHandler Handler for card actions
 * @param modifier Modifier for the card container
 * @param viewModel Optional ViewModel for state management
 */
@Composable
fun AdaptiveCardView(
    cardJson: String,
    hostConfig: HostConfig? = null,
    actionHandler: ActionHandler = DefaultActionHandler(),
    modifier: Modifier = Modifier,
    viewModel: CardViewModel = viewModel()
) {
    val card by viewModel.card.collectAsState()
    val parseError by viewModel.parseError.collectAsState()

    LaunchedEffect(cardJson) {
        viewModel.parseCard(cardJson)
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
                Column(modifier = modifier.fillMaxWidth()) {
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
    
    Column {
        // Render separator
        if (element.separator && !isFirst) {
            SeparatorLine()
        }
        
        // Apply spacing and render element
        val elementModifier = modifier.adaptiveSpacing(element.spacing, isFirst)
        
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
            // Input elements - to be wired up by host application to avoid circular dependency
            // The sample-app includes both ac-rendering and ac-inputs and can wire these up
            is InputText, is InputNumber, is InputDate, is InputTime,
            is InputToggle, is InputChoiceSet, is RatingInput -> {
                // Placeholder rendering - host app should wire up actual input views
                androidx.compose.material3.Text(
                    text = "[Input: ${element::class.simpleName}]",
                    modifier = elementModifier,
                    color = androidx.compose.material3.MaterialTheme.colorScheme.outline
                )
            }
            // Advanced elements
            is Carousel -> CarouselView(element, viewModel, actionHandler, elementModifier)
            is Accordion -> AccordionView(element, viewModel, actionHandler, elementModifier)
            is CodeBlock -> CodeBlockView(element, elementModifier)
            is RatingDisplay -> RatingDisplayView(element, elementModifier)
            is ProgressBar -> ProgressBarView(element, elementModifier)
            is Spinner -> SpinnerView(element, elementModifier)
            is TabSet -> TabSetView(element, viewModel, actionHandler, elementModifier)
            is ListElement -> ListView(element, viewModel, actionHandler, elementModifier)
            is CompoundButton -> CompoundButtonView(element, actionHandler, elementModifier)
            else -> {
                // Unknown element type - could check custom registry here
            }
        }
    }
}
