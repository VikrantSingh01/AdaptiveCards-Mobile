package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.microsoft.adaptivecards.core.models.AreaGridLayout
import com.microsoft.adaptivecards.core.models.Container
import com.microsoft.adaptivecards.core.models.FlowLayout
import com.microsoft.adaptivecards.core.models.Layout
import com.microsoft.adaptivecards.core.models.VerticalContentAlignment
import com.microsoft.adaptivecards.core.models.ContainerStyle
import com.microsoft.adaptivecards.core.models.WidthCategory
import com.microsoft.adaptivecards.core.models.shouldShowForTargetWidth
import com.microsoft.adaptivecards.rendering.theme.LocalHostConfig
import com.microsoft.adaptivecards.rendering.modifiers.containerStyle
import com.microsoft.adaptivecards.rendering.modifiers.parseColor
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

    // Use corner radius when roundedCorners is explicitly true, or when style is set (default behavior)
    val useRoundedCorners = element.roundedCorners == true || element.style != null
    val cornerRadius = if (useRoundedCorners) hostConfig.cornerRadius.container else 0
    val shape = if (cornerRadius > 0) RoundedCornerShape(cornerRadius.dp) else RoundedCornerShape(0.dp)

    // Resolve border color from container style config
    val borderColor = if (element.showBorder == true) {
        val styleConfig = when (element.style) {
            ContainerStyle.Default -> hostConfig.containerStyles.default
            ContainerStyle.Emphasis -> hostConfig.containerStyles.emphasis
            ContainerStyle.Good -> hostConfig.containerStyles.good
            ContainerStyle.Attention -> hostConfig.containerStyles.attention
            ContainerStyle.Warning -> hostConfig.containerStyles.warning
            ContainerStyle.Accent -> hostConfig.containerStyles.accent
            null -> null
        }
        styleConfig?.let { parseColor(it.borderColor) }
    } else null

    Box(
        modifier = modifier
            .then(if (cornerRadius > 0) Modifier.clip(shape) else Modifier)
            .containerStyle(element.style, cornerRadius)
            .then(if (borderColor != null) Modifier.border(1.dp, borderColor, shape) else Modifier)
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

        // Resolve active layout: check responsive layouts array first, then singular layout
        val widthCategory = LocalWidthCategory.current
        val activeLayout = resolveLayout(element, widthCategory)

        // Content: dispatch to layout view or default stack
        when (activeLayout) {
            is FlowLayout -> FlowLayoutView(
                items = items,
                flowLayout = activeLayout,
                hostConfig = hostConfig,
                viewModel = viewModel,
                actionHandler = actionHandler,
                modifier = Modifier.fillMaxWidth().padding(padding)
            )
            is AreaGridLayout -> AreaGridLayoutView(
                items = items,
                gridLayout = activeLayout,
                hostConfig = hostConfig,
                viewModel = viewModel,
                actionHandler = actionHandler,
                modifier = Modifier.fillMaxWidth().padding(padding)
            )
            else -> Column(
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
}

/**
 * Resolve which layout to use for a container:
 * 1. Check `layouts` array — pick first whose targetWidth matches the current width category
 * 2. Fall back to singular `layout` field
 * 3. Fall back to null (default vertical stack)
 */
private fun resolveLayout(element: Container, widthCategory: WidthCategory): Layout? {
    // Check responsive layouts array first
    element.layouts?.forEach { layout ->
        if (layout.targetWidth == null || shouldShowForTargetWidth(layout.targetWidth, widthCategory)) {
            return layout
        }
    }
    // Fall back to singular layout
    return element.layout
}
