// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.microsoft.adaptivecards.core.models.AdaptiveCard
import com.microsoft.adaptivecards.core.models.CardElement
import com.microsoft.adaptivecards.core.models.Container
import com.microsoft.adaptivecards.core.models.ColumnSet
import com.microsoft.adaptivecards.core.models.Table

/**
 * Floating diagnostics overlay for debugging Adaptive Card rendering.
 * Shows element count, parse time, and an expandable detail panel.
 */
@Composable
fun DiagnosticsOverlay(
    card: AdaptiveCard,
    parseTimeMs: Double,
    modifier: Modifier = Modifier
) {
    var isExpanded by remember { mutableStateOf(false) }
    val elementCount = remember(card) { countElements(card.body ?: emptyList()) }
    val actionCount = (card.actions ?: emptyList()).size

    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.End
    ) {
        // Floating badge
        Row(
            modifier = Modifier
                .clip(RoundedCornerShape(4.dp))
                .background(Color.Black.copy(alpha = 0.75f))
                .clickable { isExpanded = !isExpanded }
                .padding(horizontal = 8.dp, vertical = 4.dp),
            horizontalArrangement = Arrangement.spacedBy(4.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "ℹ",
                fontSize = 10.sp,
                color = Color.White
            )
            Text(
                text = "$elementCount elements",
                fontSize = 9.sp,
                fontFamily = FontFamily.Monospace,
                fontWeight = FontWeight.Medium,
                color = Color.White
            )
            if (parseTimeMs > 0) {
                Text(
                    text = "• ${"%.1f".format(parseTimeMs)}ms",
                    fontSize = 9.sp,
                    fontFamily = FontFamily.Monospace,
                    fontWeight = FontWeight.Medium,
                    color = Color.White
                )
            }
        }

        // Expandable detail panel
        AnimatedVisibility(
            visible = isExpanded,
            enter = fadeIn() + scaleIn(initialScale = 0.9f),
            exit = fadeOut() + scaleOut(targetScale = 0.9f)
        ) {
            Column(
                modifier = Modifier
                    .widthIn(max = 200.dp)
                    .padding(top = 4.dp)
                    .clip(RoundedCornerShape(6.dp))
                    .background(Color.Black.copy(alpha = 0.85f))
                    .padding(8.dp),
                verticalArrangement = Arrangement.spacedBy(2.dp)
            ) {
                DetailRow("Elements", "$elementCount")
                DetailRow("Actions", "$actionCount")
                DetailRow("Parse", "${"%.2f".format(parseTimeMs)}ms")
                DetailRow("Version", card.version ?: "–")
                card.lang?.let { DetailRow("Lang", it) }
                if (card.rtl == true) DetailRow("RTL", "true")
                if (card.refresh != null) DetailRow("Refresh", "configured")
            }
        }
    }
}

@Composable
private fun DetailRow(label: String, value: String) {
    Row {
        Text(
            text = label,
            fontSize = 9.sp,
            fontFamily = FontFamily.Monospace,
            fontWeight = FontWeight.Bold,
            color = Color.White,
            modifier = Modifier.width(60.dp)
        )
        Text(
            text = value,
            fontSize = 9.sp,
            fontFamily = FontFamily.Monospace,
            color = Color.White
        )
    }
}

private fun countElements(elements: List<CardElement>): Int {
    var count = 0
    for (element in elements) {
        count++
        when (element) {
            is Container -> count += countElements(element.items ?: emptyList())
            is ColumnSet -> {
                for (col in element.columns ?: emptyList()) {
                    count += countElements(col.items ?: emptyList())
                }
            }
            is Table -> {
                for (row in element.rows ?: emptyList()) {
                    for (cell in row.cells) {
                        count += countElements(cell.items ?: emptyList())
                    }
                }
            }
            else -> {}
        }
    }
    return count
}
