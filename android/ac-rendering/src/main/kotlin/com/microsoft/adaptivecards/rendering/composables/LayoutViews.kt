// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.Layout
import androidx.compose.ui.layout.Placeable
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.hostconfig.HostConfig
import com.microsoft.adaptivecards.core.models.*
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel
import com.microsoft.adaptivecards.rendering.viewmodel.DefaultActionHandler

/**
 * A Jetpack Compose view that renders items in a flow/wrap layout.
 *
 * Items flow horizontally and wrap to new rows when they exceed the available width.
 * Ported from production AdaptiveCards C++ ObjectModel's FlowLayout concept.
 */
@Composable
fun FlowLayoutView(
    items: List<CardElement>,
    flowLayout: FlowLayout,
    hostConfig: HostConfig,
    viewModel: CardViewModel,
    actionHandler: ActionHandler = DefaultActionHandler(),
    modifier: Modifier = Modifier
) {
    val colSpacing = spacingToDp(flowLayout.columnSpacing ?: Spacing.Default, hostConfig)
    val rowSpacing = spacingToDp(flowLayout.rowSpacing ?: Spacing.Default, hostConfig)

    FlowRow(
        horizontalSpacing = colSpacing,
        verticalSpacing = rowSpacing,
        itemWidth = parseSizeDp(flowLayout.itemWidth),
        minItemWidth = parseSizeDp(flowLayout.minItemWidth),
        maxItemWidth = parseSizeDp(flowLayout.maxItemWidth),
        horizontalAlignment = when (flowLayout.horizontalAlignment) {
            HorizontalAlignment.Center -> Alignment.CenterHorizontally
            HorizontalAlignment.Right -> Alignment.End
            else -> Alignment.Start
        },
        modifier = modifier
    ) {
        items.forEach { item ->
            Box {
                RenderElement(
                    element = item,
                    viewModel = viewModel,
                    actionHandler = actionHandler
                )
            }
        }
    }
}

/**
 * Custom flow row layout that wraps children to the next row when they don't fit.
 * Similar to CSS flexbox with wrap enabled.
 */
@Composable
private fun FlowRow(
    horizontalSpacing: Dp,
    verticalSpacing: Dp,
    itemWidth: Dp? = null,
    minItemWidth: Dp? = null,
    maxItemWidth: Dp? = null,
    horizontalAlignment: Alignment.Horizontal = Alignment.Start,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    Layout(
        content = content,
        modifier = modifier
    ) { measurables, constraints ->
        val hSpacingPx = horizontalSpacing.roundToPx()
        val vSpacingPx = verticalSpacing.roundToPx()
        val available = constraints.maxWidth

        // Calculate dynamic item width when itemWidth/minItemWidth are specified.
        // Use minItemWidth to determine max columns, then distribute width evenly.
        val calculatedItemWidthPx: Int? = run {
            val preferredPx = itemWidth?.roundToPx()
            val minPx = minItemWidth?.roundToPx() ?: preferredPx
            if (minPx != null && minPx > 0) {
                val maxCols = ((available + hSpacingPx) / (minPx + hSpacingPx)).coerceAtLeast(1)
                val w = (available - (maxCols - 1) * hSpacingPx) / maxCols
                val maxPx = maxItemWidth?.roundToPx()
                if (maxPx != null) w.coerceAtMost(maxPx) else w
            } else null
        }

        data class RowInfo(
            val placeables: MutableList<Placeable> = mutableListOf(),
            var width: Int = 0,
            var height: Int = 0
        )

        val rows = mutableListOf(RowInfo())
        var currentRow = rows.first()

        measurables.forEach { measurable ->
            val childMaxWidth = if (calculatedItemWidthPx != null) {
                calculatedItemWidthPx
            } else {
                // Fallback: use intrinsic width so fillMaxWidth() children don't
                // consume the entire row width.
                val intrinsicWidth = measurable.maxIntrinsicWidth(constraints.maxHeight)
                if (intrinsicWidth in 1 until available) intrinsicWidth else available
            }
            val placeable = measurable.measure(
                constraints.copy(minWidth = 0, maxWidth = childMaxWidth, minHeight = 0)
            )

            val neededWidth = if (currentRow.placeables.isEmpty()) {
                placeable.width
            } else {
                currentRow.width + hSpacingPx + placeable.width
            }

            if (neededWidth > available && currentRow.placeables.isNotEmpty()) {
                currentRow = RowInfo()
                rows.add(currentRow)
            }

            currentRow.placeables.add(placeable)
            currentRow.width = if (currentRow.placeables.size == 1) {
                placeable.width
            } else {
                currentRow.width + hSpacingPx + placeable.width
            }
            currentRow.height = maxOf(currentRow.height, placeable.height)
        }

        val totalHeight = rows.sumOf { it.height } + (rows.size - 1) * vSpacingPx

        layout(available, totalHeight) {
            var yOffset = 0

            rows.forEach { row ->
                var xOffset = when (horizontalAlignment) {
                    Alignment.CenterHorizontally -> (available - row.width) / 2
                    Alignment.End -> available - row.width
                    else -> 0
                }

                row.placeables.forEach { placeable ->
                    placeable.placeRelative(x = xOffset, y = yOffset)
                    xOffset += placeable.width + hSpacingPx
                }

                yOffset += row.height + vSpacingPx
            }
        }
    }
}

/**
 * A Jetpack Compose view that renders items in a CSS Grid-like area layout.
 *
 * Items are placed into named grid areas defined by the AreaGridLayout.
 * Ported from production AdaptiveCards C++ ObjectModel's AreaGridLayout concept.
 */
@Composable
fun AreaGridLayoutView(
    items: List<CardElement>,
    gridLayout: AreaGridLayout,
    hostConfig: HostConfig,
    viewModel: CardViewModel,
    actionHandler: ActionHandler = DefaultActionHandler(),
    modifier: Modifier = Modifier
) {
    val colSpacing = spacingToDp(gridLayout.columnSpacing ?: Spacing.Default, hostConfig)
    val rowSpacing = spacingToDp(gridLayout.rowSpacing ?: Spacing.Default, hostConfig)

    // When no areas are defined, fall back to vertical stack (graceful degradation)
    if (gridLayout.areas.isEmpty()) {
        Column(
            modifier = modifier.fillMaxWidth(),
            verticalArrangement = Arrangement.spacedBy(rowSpacing)
        ) {
            items.forEach { item ->
                RenderElement(
                    element = item,
                    viewModel = viewModel,
                    actionHandler = actionHandler
                )
            }
        }
        return
    }

    val maxRow = gridLayout.areas.maxOfOrNull { it.row + (it.rowSpan ?: 1) - 1 } ?: 1
    val columnCount = gridLayout.columns.size.coerceAtLeast(1)

    Column(
        modifier = modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(rowSpacing)
    ) {
        for (row in 1..maxRow) {
            val areasInRow = gridLayout.areas.filter { area ->
                row >= area.row && row < area.row + (area.rowSpan ?: 1)
            }.sortedBy { it.column }

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(colSpacing)
            ) {
                areasInRow.forEach { area ->
                    val areaIndex = gridLayout.areas.indexOf(area)
                    val weight = columnWeight(area, gridLayout.columns, columnCount)

                    Box(modifier = Modifier.weight(weight)) {
                        if (areaIndex < items.size) {
                            RenderElement(
                                element = items[areaIndex],
                                viewModel = viewModel,
                                actionHandler = actionHandler
                            )
                        }
                    }
                }
            }
        }
    }
}

/**
 * Calculate the weight for a grid area based on column definitions and span.
 * Plain numbers are treated as percentage widths (matching iOS behavior).
 * "auto" columns get the remaining percentage after fixed columns.
 */
private fun columnWeight(area: GridArea, columns: List<String>, columnCount: Int): Float {
    val span = area.columnSpan ?: 1
    var totalWeight = 0f

    // Pre-compute auto column weight: remaining percentage after plain-number columns
    val resolvedWeights = resolveColumnWeights(columns, columnCount)

    for (col in area.column until (area.column + span).coerceAtMost(columnCount + 1)) {
        totalWeight += resolvedWeights.getOrElse(col - 1) { 1f }
    }

    return totalWeight.coerceAtLeast(1f)
}

/**
 * Resolve column definitions into proportional weights.
 * Plain numbers → percentage weights (e.g., 35 → weight 35).
 * "auto" → remaining percentage split equally among auto columns.
 * "Nfr" → fractional weight N.
 */
private fun resolveColumnWeights(columns: List<String>, columnCount: Int): List<Float> {
    var usedPercentage = 0f
    var autoCount = 0

    for (i in 0 until columnCount) {
        val colDef = columns.getOrNull(i) ?: "1fr"
        val trimmed = colDef.trim()
        when {
            trimmed.endsWith("fr") -> { /* fr columns don't consume percentage */ }
            trimmed == "auto" || trimmed == "*" -> autoCount++
            else -> {
                val pct = trimmed.removeSuffix("px").toFloatOrNull()
                if (pct != null) usedPercentage += pct
            }
        }
    }

    val remainingPercentage = (100f - usedPercentage).coerceAtLeast(0f)
    val autoWeight = if (autoCount > 0) remainingPercentage / autoCount else 1f

    return (0 until columnCount).map { i ->
        val colDef = (columns.getOrNull(i) ?: "1fr").trim()
        when {
            colDef.endsWith("fr") -> colDef.removeSuffix("fr").toFloatOrNull() ?: 1f
            colDef == "auto" || colDef == "*" -> autoWeight.coerceAtLeast(1f)
            else -> (colDef.removeSuffix("px").toFloatOrNull() ?: 1f).coerceAtLeast(1f)
        }
    }
}

/**
 * Convert Spacing enum to Dp using HostConfig values.
 */
private fun spacingToDp(spacing: Spacing, hostConfig: HostConfig): Dp {
    return when (spacing) {
        Spacing.None -> 0.dp
        Spacing.ExtraSmall -> hostConfig.spacing.extraSmall.dp
        Spacing.Small -> hostConfig.spacing.small.dp
        Spacing.Default -> hostConfig.spacing.default.dp
        Spacing.Medium -> hostConfig.spacing.medium.dp
        Spacing.Large -> hostConfig.spacing.large.dp
        Spacing.ExtraLarge -> hostConfig.spacing.extraLarge.dp
        Spacing.Padding -> hostConfig.spacing.padding.dp
    }
}

/**
 * Parse a size string like "100px" into Dp.
 */
private fun parseSizeDp(value: String?): Dp? {
    if (value == null) return null
    val cleaned = value.replace("px", "")
    return cleaned.toFloatOrNull()?.dp
}
