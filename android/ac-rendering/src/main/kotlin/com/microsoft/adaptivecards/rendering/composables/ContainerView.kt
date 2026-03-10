package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.microsoft.adaptivecards.core.models.Container
import com.microsoft.adaptivecards.core.models.VerticalContentAlignment
import com.microsoft.adaptivecards.hostconfig.LocalHostConfig
import com.microsoft.adaptivecards.rendering.modifiers.containerStyle
import com.microsoft.adaptivecards.rendering.modifiers.selectAction
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel

/**
 * Renders a Container element with full spec support:
 * style, backgroundImage, bleed, minHeight, verticalContentAlignment, selectAction.
 */
@Composable
fun ContainerView(
    element: Container,
    modifier: Modifier = Modifier,
    viewModel: CardViewModel,
    actionHandler: ActionHandler
) {
    val hostConfig = LocalHostConfig.current
    val items = element.items ?: emptyList()

    // Parse minHeight (supports "100px" or plain number)
    val minHeight = element.minHeight
        ?.replace("px", "")
        ?.toIntOrNull()?.dp

    val verticalArrangement = when (element.verticalContentAlignment) {
        VerticalContentAlignment.Top -> Arrangement.Top
        VerticalContentAlignment.Center -> Arrangement.Center
        VerticalContentAlignment.Bottom -> Arrangement.Bottom
        null -> Arrangement.Top
    }

    // Padding: apply hostConfig padding when container has a style and bleed is not true
    val padding = if (element.style != null && element.bleed != true) {
        hostConfig.spacing.padding.dp
    } else {
        0.dp
    }

    Box(
        modifier = modifier
            .containerStyle(element.style)
            .then(if (minHeight != null) Modifier.heightIn(min = minHeight) else Modifier)
            .selectAction(element.selectAction, actionHandler)
            .fillMaxWidth()
    ) {
        // Background image (rendered behind content)
        element.backgroundImage?.let { bgImage ->
            AsyncImage(
                model = bgImage.url,
                contentDescription = null,
                contentScale = ContentScale.Crop,
                modifier = Modifier.matchParentSize()
            )
        }

        // Content column
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(padding),
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
}
