// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.ui.graphics.drawscope.translate
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.Canvas
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

    // Parse minHeight / maxHeight (supports "100px" or plain number)
    val minHeight = element.minHeight
        ?.replace("px", "")
        ?.toIntOrNull()?.dp
    val maxHeight = element.maxHeight
        ?.replace("px", "")
        ?.toIntOrNull()?.dp
    val isScrollOverflow = element.overflow?.lowercase() == "scroll"
    val isHiddenOverflow = element.overflow?.lowercase() == "hidden"

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
            .then(if (maxHeight != null) Modifier.heightIn(max = maxHeight) else Modifier)
            .then(if (isHiddenOverflow && maxHeight != null) Modifier.clipToBounds() else Modifier)
            .selectAction(element.selectAction, actionHandler)
            .fillMaxWidth()
    ) {
        // Background image (rendered behind content)
        element.backgroundImage?.let { bgImage ->
            val fillMode = bgImage.fillMode?.lowercase()
            if (fillMode == "repeat" || fillMode == "repeathorizontally" || fillMode == "repeatvertically") {
                // Tiling modes: use SubcomposeAsyncImage to get the bitmap for shader-based tiling
                TiledBackgroundImage(bgImage, Modifier.matchParentSize())
            } else {
                // Cover (default): scale to fill, clip overflow
                AsyncImage(
                    model = bgImage.url,
                    contentDescription = null,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier.matchParentSize()
                )
            }
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
            is AreaGridLayout -> {
                // Expand columns list to cover all referenced area columns (matching iOS behavior).
                // When areas reference column N but columns has fewer entries, the missing columns
                // get equal share of remaining space — prevents content being squeezed to near-zero width.
                val maxAreaCol = activeLayout.areas.maxOfOrNull { it.column + (it.columnSpan ?: 1) - 1 } ?: 1
                val effectiveLayout = if (maxAreaCol > activeLayout.columns.size) {
                    val expandedColumns = activeLayout.columns.toMutableList()
                    val usedPct = activeLayout.columns.sumOf { it.trim().removeSuffix("px").removeSuffix("fr").toDoubleOrNull() ?: 0.0 }
                    val remainingPct = ((100.0 - usedPct) / (maxAreaCol - activeLayout.columns.size)).coerceAtLeast(1.0)
                    repeat(maxAreaCol - activeLayout.columns.size) {
                        expandedColumns.add(remainingPct.toInt().toString())
                    }
                    activeLayout.copy(columns = expandedColumns)
                } else activeLayout

                AreaGridLayoutView(
                    items = items,
                    gridLayout = effectiveLayout,
                    hostConfig = hostConfig,
                    viewModel = viewModel,
                    actionHandler = actionHandler,
                    modifier = Modifier.fillMaxWidth().padding(padding)
                )
            }
            else -> Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .then(if (isScrollOverflow) Modifier.verticalScroll(rememberScrollState()) else Modifier)
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
 * Renders a tiled background image using Coil's AsyncImagePainter and Canvas.
 * Supports repeat, repeatHorizontally, and repeatVertically fill modes.
 */
@Composable
private fun TiledBackgroundImage(
    bgImage: com.microsoft.adaptivecards.core.models.BackgroundImage,
    modifier: Modifier = Modifier
) {
    val fillMode = bgImage.fillMode?.lowercase() ?: "cover"
    val painter = coil.compose.rememberAsyncImagePainter(model = bgImage.url)
    val painterState = painter.state

    if (painterState is coil.compose.AsyncImagePainter.State.Success) {
        Canvas(modifier = modifier.fillMaxSize()) {
            val srcWidth = painter.intrinsicSize.width
            val srcHeight = painter.intrinsicSize.height
            if (srcWidth <= 0f || srcHeight <= 0f) return@Canvas

            val repeatX = fillMode == "repeat" || fillMode == "repeathorizontally"
            val repeatY = fillMode == "repeat" || fillMode == "repeatvertically"

            val cols = if (repeatX) kotlin.math.ceil(size.width / srcWidth).toInt().coerceAtLeast(1) else 1
            val rows = if (repeatY) kotlin.math.ceil(size.height / srcHeight).toInt().coerceAtLeast(1) else 1

            for (row in 0 until rows) {
                for (col in 0 until cols) {
                    translate(left = col * srcWidth, top = row * srcHeight) {
                        with(painter) {
                            draw(size = androidx.compose.ui.geometry.Size(srcWidth, srcHeight))
                        }
                    }
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
