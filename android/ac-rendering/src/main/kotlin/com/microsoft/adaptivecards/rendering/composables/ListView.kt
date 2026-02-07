package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.CollectionInfo
import androidx.compose.ui.semantics.collectionInfo
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.microsoft.adaptivecards.core.models.ListElement
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel

/**
 * Renders a List element with support for different styles and scrolling
 */
@Composable
fun ListView(
    element: ListElement,
    viewModel: CardViewModel,
    actionHandler: ActionHandler,
    modifier: Modifier = Modifier
) {
    val listState = rememberLazyListState()
    val maxHeightDp = parseMaxHeight(element.maxHeight)
    val listStyle = element.style ?: "default"
    
    val listModifier = if (maxHeightDp != null) {
        modifier.heightIn(max = maxHeightDp)
    } else {
        modifier
    }
    
    LazyColumn(
        state = listState,
        modifier = listModifier
            .fillMaxWidth()
            .semantics {
                collectionInfo = CollectionInfo(
                    rowCount = element.items.size,
                    columnCount = 1
                )
            },
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        itemsIndexed(element.items) { index, item ->
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .defaultMinSize(minHeight = 44.dp),
                horizontalArrangement = Arrangement.Start,
                verticalAlignment = Alignment.Top
            ) {
                // Render list item prefix based on style
                when (listStyle) {
                    "bulleted" -> {
                        Text(
                            text = "•",
                            fontSize = 18.sp,
                            color = MaterialTheme.colorScheme.onSurface,
                            modifier = Modifier
                                .width(20.dp)
                                .padding(end = 8.dp)
                        )
                    }
                    "numbered" -> {
                        Text(
                            text = "${index + 1}.",
                            fontSize = 14.sp,
                            color = MaterialTheme.colorScheme.onSurface,
                            modifier = Modifier
                                .width(24.dp)
                                .padding(end = 8.dp)
                        )
                    }
                }
                
                // Render item content
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .padding(vertical = 4.dp)
                ) {
                    RenderElement(
                        element = item,
                        isFirst = false,
                        viewModel = viewModel,
                        actionHandler = actionHandler
                    )
                }
            }
        }
    }
}

/**
 * Parse maxHeight string (e.g., "200px") to Dp
 */
private fun parseMaxHeight(maxHeight: String?): androidx.compose.ui.unit.Dp? {
    if (maxHeight == null) return null
    
    // Remove "px" suffix and convert to number
    val numberString = maxHeight.replace("px", "").trim()
    
    return try {
        val value = numberString.toDouble()
        if (value > 0) value.dp else null
    } catch (e: NumberFormatException) {
        null
    }
}
