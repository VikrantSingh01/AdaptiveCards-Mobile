package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.Layout
import androidx.compose.ui.layout.Measurable
import androidx.compose.ui.layout.Placeable
import androidx.compose.ui.unit.Constraints
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.hostconfig.HostConfig
import com.microsoft.adaptivecards.core.models.*

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
    modifier: Modifier = Modifier
) {
    val colSpacing = spacingToDp(flowLayout.columnSpacing ?: Spacing.DEFAULT, hostConfig)
    val rowSpacing = spacingToDp(flowLayout.rowSpacing ?: Spacing.DEFAULT, hostConfig)

    FlowRow(
        horizontalSpacing = colSpacing,
        verticalSpacing = rowSpacing,
        horizontalAlignment = when (flowLayout.horizontalAlignment) {
            HorizontalAlignment.CENTER -> Alignment.CenterHorizontally
            HorizontalAlignment.RIGHT -> Alignment.End
            else -> Alignment.Start
        },
        modifier = modifier
    ) {
        items.forEachIndexed { _, item ->
            val itemWidthDp = parseSizeDp(flowLayout.itemWidth)
            val minWidthDp = parseSizeDp(flowLayout.minItemWidth)
            val maxWidthDp = parseSizeDp(flowLayout.maxItemWidth)

            val itemModifier = Modifier
                .then(if (itemWidthDp != null) Modifier.width(itemWidthDp) else Modifier)
                .then(if (minWidthDp != null) Modifier.widthIn(min = minWidthDp) else Modifier)
                .then(if (maxWidthDp != null) Modifier.widthIn(max = maxWidthDp) else Modifier)
                .then(if (flowLayout.itemFit == ItemFit.FILL) Modifier.weight(1f) else Modifier)

            Box(modifier = itemModifier) {
                ElementRenderer(element = item, hostConfig = hostConfig)
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

        data class RowInfo(
            val placeables: MutableList<Placeable> = mutableListOf(),
            var width: Int = 0,
            var height: Int = 0
        )

        val rows = mutableListOf(RowInfo())
        var currentRow = rows.first()

        measurables.forEach { measurable ->
            val placeable = measurable.measure(
                constraints.copy(minWidth = 0, minHeight = 0)
            )

            val neededWidth = if (currentRow.placeables.isEmpty()) {
                placeable.width
            } else {
                currentRow.width + hSpacingPx + placeable.width
            }

            if (neededWidth > constraints.maxWidth && currentRow.placeables.isNotEmpty()) {
                // Wrap to next row
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
        val maxWidth = constraints.maxWidth

        layout(maxWidth, totalHeight) {
            var yOffset = 0

            rows.forEach { row ->
                var xOffset = when (horizontalAlignment) {
                    Alignment.CenterHorizontally -> (maxWidth - row.width) / 2
                    Alignment.End -> maxWidth - row.width
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
    modifier: Modifier = Modifier
) {
    val colSpacing = spacingToDp(gridLayout.columnSpacing ?: Spacing.DEFAULT, hostConfig)
    val rowSpacing = spacingToDp(gridLayout.rowSpacing ?: Spacing.DEFAULT, hostConfig)
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
                areasInRow.forEachIndexed { _, area ->
                    val areaIndex = gridLayout.areas.indexOf(area)
                    val weight = columnWeight(area, gridLayout.columns, columnCount)

                    Box(modifier = Modifier.weight(weight)) {
                        if (areaIndex < items.size) {
                            ElementRenderer(element = items[areaIndex], hostConfig = hostConfig)
                        }
                    }
                }
            }
        }
    }
}

/**
 * Calculate the weight for a grid area based on column definitions and span.
 */
private fun columnWeight(area: GridArea, columns: List<String>, columnCount: Int): Float {
    val span = area.columnSpan ?: 1
    var totalWeight = 0f

    for (col in area.column until (area.column + span).coerceAtMost(columnCount + 1)) {
        val colDef = columns.getOrNull(col - 1) ?: "1fr"
        totalWeight += parseFractionWeight(colDef)
    }

    return totalWeight.coerceAtLeast(1f)
}

/**
 * Parse a column definition like "1fr", "2fr", "auto" into a weight value.
 */
private fun parseFractionWeight(colDef: String): Float {
    if (colDef.endsWith("fr")) {
        return colDef.removeSuffix("fr").toFloatOrNull() ?: 1f
    }
    return 1f // Default weight for "auto", pixel values, etc.
}

/**
 * Convert Spacing enum to Dp using HostConfig values.
 */
private fun spacingToDp(spacing: Spacing, hostConfig: HostConfig): Dp {
    return when (spacing) {
        Spacing.NONE -> 0.dp
        Spacing.SMALL -> hostConfig.spacing.small.dp
        Spacing.DEFAULT -> hostConfig.spacing.defaultSpacing.dp
        Spacing.MEDIUM -> hostConfig.spacing.medium.dp
        Spacing.LARGE -> hostConfig.spacing.large.dp
        Spacing.EXTRA_LARGE -> hostConfig.spacing.extraLarge.dp
        Spacing.PADDING -> hostConfig.spacing.padding.dp
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
