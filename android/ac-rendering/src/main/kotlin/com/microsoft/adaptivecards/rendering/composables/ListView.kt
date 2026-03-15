// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
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

// Layout constants for consistency
private object ListLayout {
    val BulletWidth = 20.dp
    val NumberWidth = 24.dp
    val ItemSpacing = 8.dp
    val MinTouchTarget = 44.dp
    val ItemVerticalPadding = 4.dp
    val ItemSpacingVertical = 4.dp
}

/**
 * Renders a List element with support for different styles and scrolling.
 * Uses LazyColumn only when maxHeight is set (self-scrolling list);
 * otherwise uses Column to avoid nested-scrolling crashes when the card
 * itself is inside a scrollable parent.
 */
@Composable
fun ListView(
    element: ListElement,
    viewModel: CardViewModel,
    actionHandler: ActionHandler,
    modifier: Modifier = Modifier
) {
    val maxHeightDp = parseMaxHeight(element.maxHeight)
    val listStyle = element.style ?: "default"

    if (maxHeightDp != null) {
        // Bounded list: use LazyColumn for efficient scrolling within maxHeight
        val listState = rememberLazyListState()
        LazyColumn(
            state = listState,
            modifier = modifier
                .heightIn(max = maxHeightDp)
                .fillMaxWidth()
                .semantics {
                    collectionInfo = CollectionInfo(
                        rowCount = element.items.size,
                        columnCount = 1
                    )
                },
            verticalArrangement = Arrangement.spacedBy(ListLayout.ItemSpacingVertical)
        ) {
            itemsIndexed(element.items) { index, item ->
                ListItemRow(index, item, listStyle, viewModel, actionHandler)
            }
        }
    } else {
        // Unbounded list: use Column to participate in parent scroll container
        Column(
            modifier = modifier
                .fillMaxWidth()
                .semantics {
                    collectionInfo = CollectionInfo(
                        rowCount = element.items.size,
                        columnCount = 1
                    )
                },
            verticalArrangement = Arrangement.spacedBy(ListLayout.ItemSpacingVertical)
        ) {
            element.items.forEachIndexed { index, item ->
                ListItemRow(index, item, listStyle, viewModel, actionHandler)
            }
        }
    }
}

@Composable
private fun ListItemRow(
    index: Int,
    item: com.microsoft.adaptivecards.core.models.CardElement,
    listStyle: String,
    viewModel: CardViewModel,
    actionHandler: ActionHandler
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .defaultMinSize(minHeight = ListLayout.MinTouchTarget),
        horizontalArrangement = Arrangement.Start,
        verticalAlignment = Alignment.Top
    ) {
        when (listStyle) {
            "bulleted" -> {
                Text(
                    text = "•",
                    fontSize = 18.sp,
                    color = MaterialTheme.colorScheme.onSurface,
                    modifier = Modifier
                        .width(ListLayout.BulletWidth)
                        .padding(end = ListLayout.ItemSpacing)
                )
            }
            "numbered" -> {
                Text(
                    text = "${index + 1}.",
                    fontSize = 14.sp,
                    color = MaterialTheme.colorScheme.onSurface,
                    modifier = Modifier
                        .width(ListLayout.NumberWidth)
                        .padding(end = ListLayout.ItemSpacing)
                )
            }
        }

        Box(
            modifier = Modifier
                .weight(1f)
                .padding(vertical = ListLayout.ItemVerticalPadding)
        ) {
            RenderElement(
                element = item,
                isFirst = true, // suppress adaptive spacing — ListView handles spacing via Arrangement.spacedBy
                viewModel = viewModel,
                actionHandler = actionHandler
            )
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
