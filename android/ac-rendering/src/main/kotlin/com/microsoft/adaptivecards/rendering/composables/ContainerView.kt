package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.Container
import com.microsoft.adaptivecards.core.models.VerticalContentAlignment
import com.microsoft.adaptivecards.rendering.modifiers.containerStyle
import com.microsoft.adaptivecards.rendering.modifiers.selectAction
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel

/**
 * Renders a Container element
 */
@Composable
fun ContainerView(
    element: Container,
    modifier: Modifier = Modifier,
    viewModel: CardViewModel,
    actionHandler: ActionHandler
) {
    val items = element.items ?: emptyList()
    
    // Parse minHeight
    val minHeight = element.minHeight?.toIntOrNull()?.dp
    
    // Determine vertical alignment
    val verticalArrangement = when (element.verticalContentAlignment) {
        VerticalContentAlignment.Top -> Arrangement.Top
        VerticalContentAlignment.Center -> Arrangement.Center
        VerticalContentAlignment.Bottom -> Arrangement.Bottom
        null -> Arrangement.Top
    }
    
    Column(
        modifier = modifier
            .containerStyle(element.style)
            .then(if (minHeight != null) Modifier.heightIn(min = minHeight) else Modifier)
            .selectAction(element.selectAction, actionHandler)
            .fillMaxWidth(),
        verticalArrangement = verticalArrangement
    ) {
        items.forEachIndexed { index, item ->
            RenderElement(
                element = item,
                isFirst = index == 0,
                viewModel = viewModel,
                actionHandler = actionHandler
            )
        }
    }
}
