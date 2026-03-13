// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.Column
import com.microsoft.adaptivecards.core.models.ColumnSet
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
    val spacing = hostConfig.spacing.default.dp

    val cornerRadius = hostConfig.cornerRadius.columnSet

    Row(
        modifier = modifier
            .then(if (cornerRadius > 0) Modifier.clip(RoundedCornerShape(cornerRadius.dp)) else Modifier)
            .containerStyle(element.style, cornerRadius)
            .fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(spacing)
    ) {
        columns.forEachIndexed { index, column ->
            if (index > 0 && column.separator) {
                VerticalSeparatorLine()
            }
            val columnModifier = resolveColumnWidth(column.width)
            ColumnView(
                column = column,
                modifier = columnModifier,
                viewModel = viewModel,
                actionHandler = actionHandler
            )
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
 * Resolve column width string to a Modifier.
 * Supports: "auto", "stretch", numeric weights (e.g. "2"), pixel widths (e.g. "100px").
 */
@Composable
private fun RowScope.resolveColumnWidth(width: String?): Modifier {
    return when {
        width == null || width == "stretch" -> Modifier.weight(1f)
        width == "auto" -> Modifier
        width.endsWith("px") -> {
            val pixels = width.removeSuffix("px").toIntOrNull()
            if (pixels != null) Modifier.width(pixels.dp) else Modifier.weight(1f)
        }
        else -> {
            val weight = width.toFloatOrNull()
            if (weight != null && weight > 0f) Modifier.weight(weight) else Modifier.weight(1f)
        }
    }
}
