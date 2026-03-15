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
import androidx.compose.ui.layout.layoutId
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
 * Supports auto, stretch, weighted (numeric), and pixel (e.g. "100px") widths.
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
    val spacing = hostConfig.spacing.small.dp

    val cornerRadius = hostConfig.cornerRadius.columnSet

    val isScrollable = element.overflow?.equals("Scroll", ignoreCase = true) == true
    val isClipped = element.overflow?.equals("Hidden", ignoreCase = true) == true

    val separatorThickness = hostConfig.separator.lineThickness.dp

    ProportionalColumnLayout(
        columns = columns,
        columnSpacing = spacing,
        separatorThickness = separatorThickness,
        modifier = modifier
            .then(if (cornerRadius > 0) Modifier.clip(RoundedCornerShape(cornerRadius.dp)) else Modifier)
            .containerStyle(element.style, cornerRadius)
            .then(if (isScrollable) Modifier.horizontalScroll(rememberScrollState()) else Modifier)
            .then(if (isClipped) Modifier.clip(RoundedCornerShape(0.dp)) else Modifier)
            .then(if (!isScrollable) Modifier.fillMaxWidth() else Modifier)
    ) {
        columns.forEachIndexed { index, column ->
            if (index > 0 && column.separator) {
                Box(modifier = Modifier.layoutId("sep_$index")) {
                    VerticalSeparatorLine()
                }
            }
            val isAutoWidth = column.width == "auto"
            CompositionLocalProvider(LocalIsAutoWidthColumn provides isAutoWidth) {
                ColumnView(
                    column = column,
                    modifier = Modifier.layoutId("col_$index"),
                    viewModel = viewModel,
                    actionHandler = actionHandler
                )
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

/**
 * Custom layout that distributes column widths proportionally, matching iOS ProportionalColumnLayout.
 * Explicitly computes pixel, auto, and weighted column widths before measurement,
 * avoiding Compose IntrinsicSize.Max/weight() interaction issues that caused nested
 * ColumnSets (e.g. Agenda card) to collapse.
 */
@Composable
private fun ProportionalColumnLayout(
    columns: List<Column>,
    columnSpacing: Dp,
    separatorThickness: Dp,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    Layout(
        content = content,
        modifier = modifier
    ) { measurables, constraints ->
        if (columns.isEmpty()) {
            return@Layout layout(0, 0) {}
        }

        val spacingPx = columnSpacing.roundToPx()
        val sepThickPx = separatorThickness.roundToPx()

        // Count separators to subtract their width from available space
        val numSeparators = columns.drop(1).count { it.separator }
        val totalSpacing = if (columns.size > 1) (columns.size - 1) * spacingPx else 0
        val totalSepWidth = numSeparators * sepThickPx
        var remainingWidth = (constraints.maxWidth - totalSpacing - totalSepWidth).coerceAtLeast(0)

        // Map column indices to their measurables via layoutId
        val columnMeasurables = (0 until columns.size).map { i ->
            measurables.first { (it.layoutId as? String) == "col_$i" }
        }

        val widths = IntArray(columns.size)

        // Handle unbounded width (scrollable mode): all columns use intrinsic width
        if (constraints.maxWidth == Constraints.Infinity) {
            columns.forEachIndexed { i, col ->
                val w = col.width
                widths[i] = when {
                    w != null && w.endsWith("px") -> {
                        val dp = w.removeSuffix("px").toIntOrNull() ?: 0
                        dp.dp.roundToPx()
                    }
                    else -> columnMeasurables[i].maxIntrinsicWidth(constraints.maxHeight)
                }
            }
        } else {
            // Pass 1: Fixed pixel widths
            columns.forEachIndexed { i, col ->
                val w = col.width
                if (w != null && w.endsWith("px")) {
                    val dp = w.removeSuffix("px").toIntOrNull() ?: 0
                    widths[i] = dp.dp.roundToPx().coerceAtMost(remainingWidth)
                    remainingWidth -= widths[i]
                }
            }

            // Pass 2: Auto columns — use maxIntrinsicWidth (natural content size)
            columns.forEachIndexed { i, col ->
                if (col.width == "auto") {
                    val intrinsic = columnMeasurables[i].maxIntrinsicWidth(constraints.maxHeight)
                    widths[i] = intrinsic.coerceAtMost(remainingWidth.coerceAtLeast(0))
                    remainingWidth -= widths[i]
                }
            }

            // Pass 3: Weighted and stretch columns share remaining space
            var totalWeight = 0f
            columns.forEach { col ->
                val w = col.width
                when {
                    w == null || w == "stretch" -> totalWeight += 1f
                    w != "auto" && !w.endsWith("px") -> {
                        totalWeight += w.toFloatOrNull()?.takeIf { it > 0f } ?: 1f
                    }
                }
            }

            if (totalWeight > 0f && remainingWidth > 0) {
                columns.forEachIndexed { i, col ->
                    val w = col.width
                    val weight = when {
                        w == null || w == "stretch" -> 1f
                        w != "auto" && !w.endsWith("px") -> w.toFloatOrNull()?.takeIf { it > 0f } ?: 1f
                        else -> null
                    }
                    if (weight != null) {
                        widths[i] = (remainingWidth * weight / totalWeight).toInt()
                    }
                }
            }
        }

        // Measure columns with explicit widths
        val columnPlaceables = columnMeasurables.mapIndexed { i, measurable ->
            val w = widths[i]
            measurable.measure(constraints.copy(minWidth = w, maxWidth = w))
        }

        val maxHeight = columnPlaceables.maxOfOrNull { it.height } ?: 0

        // Measure separators at full column height
        val separatorPlaceables = mutableMapOf<Int, androidx.compose.ui.layout.Placeable>()
        columns.forEachIndexed { i, col ->
            if (i > 0 && col.separator) {
                val sepMeasurable = measurables.firstOrNull { (it.layoutId as? String) == "sep_$i" }
                if (sepMeasurable != null) {
                    separatorPlaceables[i] = sepMeasurable.measure(
                        Constraints(minHeight = maxHeight, maxHeight = maxHeight)
                    )
                }
            }
        }

        val totalWidth = if (constraints.maxWidth == Constraints.Infinity) {
            widths.sum() + totalSpacing + totalSepWidth
        } else {
            constraints.maxWidth
        }

        layout(totalWidth, maxHeight) {
            var x = 0
            columns.forEachIndexed { i, _ ->
                // Place separator before this column if present
                separatorPlaceables[i]?.let { sep ->
                    sep.place(x, 0)
                    x += sep.width
                }
                // Add spacing between columns
                if (i > 0) {
                    x += spacingPx
                }
                columnPlaceables[i].place(x, 0)
                x += columnPlaceables[i].width
            }
        }
    }
}
