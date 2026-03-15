// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.Layout
import androidx.compose.ui.unit.Constraints
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.Dp
import com.microsoft.adaptivecards.core.models.AreaGridLayout
import com.microsoft.adaptivecards.core.models.Column
import com.microsoft.adaptivecards.core.models.ColumnSet
import com.microsoft.adaptivecards.core.models.FlowLayout
import com.microsoft.adaptivecards.core.models.VerticalContentAlignment
import com.microsoft.adaptivecards.core.models.WidthCategory
import com.microsoft.adaptivecards.core.models.shouldShowForTargetWidth
import com.microsoft.adaptivecards.rendering.theme.LocalHostConfig
import com.microsoft.adaptivecards.rendering.modifiers.SeparatorLine
import com.microsoft.adaptivecards.rendering.modifiers.containerStyle
import com.microsoft.adaptivecards.rendering.modifiers.parseSeparatorColor
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel

/**
 * Renders a ColumnSet element with proportional column layout.
 * Uses a custom Layout composable (like iOS ProportionalColumnLayout) that properly
 * distributes widths: auto columns get intrinsic size, weighted/stretch columns share
 * remaining space proportionally. This fixes auto-width columns inside weighted parents
 * (e.g., Agenda card nested ColumnSets) that collapsed with the previous Row approach.
 */
@Composable
fun ColumnSetView(
    element: ColumnSet,
    modifier: Modifier = Modifier,
    viewModel: CardViewModel,
    actionHandler: ActionHandler
) {
    val hostConfig = LocalHostConfig.current
    val widthCategory = LocalWidthCategory.current
    val allColumns = element.columns ?: emptyList()
    // Filter columns by targetWidth before rendering
    val columns = allColumns.filter { col ->
        shouldShowForTargetWidth(col.targetWidth, widthCategory)
    }
    // Use small spacing between columns (not default element spacing which is too wide
    // and can clip columns in ColumnSets with 5+ columns like WeatherLarge)
    val spacingDp = hostConfig.spacing.small.dp

    val cornerRadius = hostConfig.cornerRadius.columnSet

    val isScrollable = element.overflow?.equals("Scroll", ignoreCase = true) == true
    val isClipped = element.overflow?.equals("Hidden", ignoreCase = true) == true

    val outerModifier = modifier
        .then(if (cornerRadius > 0) Modifier.clip(RoundedCornerShape(cornerRadius.dp)) else Modifier)
        .containerStyle(element.style, cornerRadius)
        .then(if (isScrollable) Modifier.horizontalScroll(rememberScrollState()) else Modifier)
        .then(if (isClipped) Modifier.clip(RoundedCornerShape(0.dp)) else Modifier)
        .then(if (!isScrollable) Modifier.fillMaxWidth() else Modifier)

    ProportionalColumnLayout(
        columns = columns,
        spacingDp = spacingDp,
        modifier = outerModifier
    ) {
        columns.forEachIndexed { index, column ->
            val isAutoWidth = column.width == "auto"
            CompositionLocalProvider(LocalIsAutoWidthColumn provides isAutoWidth) {
                ColumnView(
                    column = column,
                    modifier = Modifier,
                    viewModel = viewModel,
                    actionHandler = actionHandler
                )
            }
        }
    }
}

/**
 * Custom layout that distributes column widths proportionally, matching iOS ProportionalColumnLayout.
 * - Pass 1: Fixed pixel widths get their exact size (capped at 60% if other columns exist)
 * - Pass 2: Auto columns get their intrinsic (wrap-content) width
 * - Pass 3: Weighted and stretch columns share remaining space proportionally
 */
@Composable
private fun ProportionalColumnLayout(
    columns: List<Column>,
    spacingDp: Dp,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    Layout(
        content = content,
        modifier = modifier
    ) { measurables, constraints ->
        if (measurables.isEmpty() || columns.isEmpty()) {
            val emptyWidth = if (constraints.maxWidth == Constraints.Infinity) 0 else constraints.maxWidth
            return@Layout layout(emptyWidth, 0) {}
        }

        val spacingPx = spacingDp.roundToPx()
        val totalSpacing = if (columns.size > 1) (columns.size - 1) * spacingPx else 0
        val isUnbounded = constraints.maxWidth == Constraints.Infinity
        val totalWidth = if (isUnbounded) constraints.minWidth.coerceAtLeast(0) else constraints.maxWidth
        var remainingWidth = if (isUnbounded) Int.MAX_VALUE / 2 else totalWidth - totalSpacing

        val columnWidths = IntArray(columns.size)
        val placeables = arrayOfNulls<androidx.compose.ui.layout.Placeable>(measurables.size)

        // Pass 1: Fixed pixel widths
        val nonPixelCount = columns.count { col ->
            val w = col.width
            w == null || !w.endsWith("px")
        }
        val maxPixelShare = if (nonPixelCount > 0) (remainingWidth * 0.6f).toInt() else remainingWidth
        columns.forEachIndexed { i, col ->
            val w = col.width
            if (w != null && w.endsWith("px")) {
                val px = w.removeSuffix("px").toIntOrNull() ?: 0
                columnWidths[i] = px.coerceAtMost(maxPixelShare)
                remainingWidth -= columnWidths[i]
            }
        }

        // Pass 2: Auto columns — measure with loose constraints to get actual desired width.
        // maxIntrinsicWidth underestimates for async images and nested layouts, so we
        // measure directly (matching iOS sizeThatFits(.unspecified) approach).
        columns.forEachIndexed { i, col ->
            if (col.width == "auto" && i < measurables.size) {
                val maxAvail = remainingWidth.coerceAtLeast(0)
                val placeable = measurables[i].measure(Constraints(
                    minWidth = 0,
                    maxWidth = if (isUnbounded) Constraints.Infinity else maxAvail,
                    minHeight = 0,
                    maxHeight = constraints.maxHeight
                ))
                placeables[i] = placeable
                columnWidths[i] = placeable.width.coerceAtMost(maxAvail)
                remainingWidth -= columnWidths[i]
            }
        }

        // Pass 3: Weighted and stretch columns share remaining space
        var totalWeight = 0f
        columns.forEachIndexed { i, col ->
            val w = col.width
            if (w == null || w == "stretch") {
                totalWeight += 1f
            } else if (w != "auto" && !w.endsWith("px")) {
                val weight = w.toFloatOrNull()
                if (weight != null && weight > 0f) {
                    totalWeight += weight
                } else {
                    totalWeight += 1f // Default to stretch
                }
            }
        }

        if (totalWeight > 0f && remainingWidth > 0) {
            columns.forEachIndexed { i, col ->
                val w = col.width
                val weight = when {
                    w == null || w == "stretch" -> 1f
                    w == "auto" || w.endsWith("px") -> 0f
                    else -> w.toFloatOrNull()?.takeIf { it > 0f } ?: 1f
                }
                if (weight > 0f) {
                    columnWidths[i] = ((remainingWidth * weight) / totalWeight).toInt().coerceAtLeast(0)
                }
            }
        }

        // Measure non-auto children at their computed widths (auto columns already measured in Pass 2)
        measurables.forEachIndexed { i, measurable ->
            if (placeables[i] == null) {
                val w = if (i < columnWidths.size) columnWidths[i] else 0
                placeables[i] = measurable.measure(Constraints(
                    minWidth = w.coerceAtLeast(0),
                    maxWidth = w.coerceAtLeast(0),
                    minHeight = 0,
                    maxHeight = constraints.maxHeight
                ))
            }
        }

        val resolvedPlaceables = placeables.map { it!! }
        val maxHeight = resolvedPlaceables.maxOfOrNull { it.height } ?: 0

        // When unconstrained, use actual content width; otherwise use total allocated width
        val layoutWidth = if (isUnbounded) {
            val contentWidth = resolvedPlaceables.sumOf { it.width } + totalSpacing
            contentWidth.coerceIn(constraints.minWidth, constraints.maxWidth.coerceAtMost(16777215))
        } else {
            totalWidth
        }

        layout(layoutWidth, maxHeight) {
            var x = 0
            resolvedPlaceables.forEachIndexed { i, placeable ->
                placeable.placeRelative(x, 0)
                x += placeable.width + if (i < resolvedPlaceables.size - 1) spacingPx else 0
            }
        }
    }
}

/**
 * Renders a single Column with vertical alignment and minHeight.
 */
@Composable
fun ColumnView(
    column: Column,
    modifier: Modifier = Modifier,
    viewModel: CardViewModel,
    actionHandler: ActionHandler
) {
    val hostConfig = LocalHostConfig.current
    val items = column.items ?: emptyList()
    val minHeight = column.minHeight?.replace("px", "")?.toIntOrNull()?.dp
    val cornerRadius = hostConfig.cornerRadius.column

    val widthCategory = LocalWidthCategory.current
    val activeLayout = resolveColumnLayout(column, widthCategory)

    Column(
        modifier = modifier
            .then(if (cornerRadius > 0) Modifier.clip(RoundedCornerShape(cornerRadius.dp)) else Modifier)
            .containerStyle(column.style, cornerRadius)
            .then(if (minHeight != null) Modifier.heightIn(min = minHeight) else Modifier),
        verticalArrangement = when (column.verticalContentAlignment) {
            VerticalContentAlignment.Center -> Arrangement.Center
            VerticalContentAlignment.Bottom -> Arrangement.Bottom
            else -> Arrangement.Top
        }
    ) {
        when (activeLayout) {
            is FlowLayout -> FlowLayoutView(
                items = items,
                flowLayout = activeLayout,
                hostConfig = hostConfig,
                viewModel = viewModel,
                actionHandler = actionHandler,
                modifier = Modifier.fillMaxWidth()
            )
            is AreaGridLayout -> AreaGridLayoutView(
                items = items,
                gridLayout = activeLayout,
                hostConfig = hostConfig,
                viewModel = viewModel,
                actionHandler = actionHandler,
                modifier = Modifier.fillMaxWidth()
            )
            else -> {
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

private fun resolveColumnLayout(column: Column, widthCategory: WidthCategory): com.microsoft.adaptivecards.core.models.Layout? {
    column.layouts?.forEach { layout ->
        if (layout.targetWidth == null || shouldShowForTargetWidth(layout.targetWidth, widthCategory)) {
            return layout
        }
    }
    return null
}

/**
 * Vertical separator line for use between columns in a Row (ColumnSet).
 * Unlike SeparatorLine which is horizontal (fillMaxWidth), this fills height.
 */
@Composable
private fun VerticalSeparatorLine() {
    val hostConfig = LocalHostConfig.current
    val lineColor = parseSeparatorColor(hostConfig.separator.lineColor)
    val lineThickness = hostConfig.separator.lineThickness.dp

    Canvas(
        modifier = Modifier
            .fillMaxHeight()
            .width(lineThickness)
    ) {
        drawLine(
            color = lineColor,
            start = androidx.compose.ui.geometry.Offset(size.width / 2, 0f),
            end = androidx.compose.ui.geometry.Offset(size.width / 2, size.height),
            strokeWidth = size.width
        )
    }
}

