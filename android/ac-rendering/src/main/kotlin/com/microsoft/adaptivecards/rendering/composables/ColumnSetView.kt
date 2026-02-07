package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.microsoft.adaptivecards.core.models.ColumnSet
import com.microsoft.adaptivecards.core.models.Column
import com.microsoft.adaptivecards.rendering.modifiers.containerStyle
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel

/**
 * Renders a ColumnSet element
 */
@Composable
fun ColumnSetView(
    element: ColumnSet,
    modifier: Modifier = Modifier,
    viewModel: CardViewModel,
    actionHandler: ActionHandler
) {
    val columns = element.columns ?: emptyList()
    
    Row(
        modifier = modifier
            .containerStyle(element.style)
            .fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        columns.forEach { column ->
            ColumnView(
                column = column,
                modifier = Modifier.weight(getColumnWeight(column.width)),
                viewModel = viewModel,
                actionHandler = actionHandler
            )
        }
    }
}

/**
 * Renders a single Column
 */
@Composable
fun ColumnView(
    column: Column,
    modifier: Modifier = Modifier,
    viewModel: CardViewModel,
    actionHandler: ActionHandler
) {
    val items = column.items ?: emptyList()
    
    Column(
        modifier = modifier.containerStyle(column.style)
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
 * Calculate column weight from width string
 */
private fun getColumnWeight(width: String?): Float {
    return when (width) {
        "auto" -> 0f
        "stretch" -> 1f
        null -> 1f
        else -> {
            // Try to parse as number
            width.toFloatOrNull() ?: 1f
        }
    }
}
