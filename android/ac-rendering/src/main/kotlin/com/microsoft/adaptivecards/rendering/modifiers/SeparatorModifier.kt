package com.microsoft.adaptivecards.rendering.modifiers

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.hostconfig.LocalHostConfig

/**
 * Draws a separator line based on host config
 */
@Composable
fun SeparatorLine() {
    val hostConfig = LocalHostConfig.current
    val lineColor = parseColor(hostConfig.separator.lineColor)
    val lineThickness = hostConfig.separator.lineThickness.dp
    
    Canvas(
        modifier = Modifier
            .fillMaxWidth()
            .height(lineThickness)
    ) {
        drawLine(
            color = lineColor,
            start = Offset(0f, 0f),
            end = Offset(size.width, 0f),
            strokeWidth = lineThickness.toPx()
        )
    }
}

/**
 * Applies separator if needed
 */
@Composable
fun Modifier.adaptiveSeparator(
    showSeparator: Boolean
): Modifier {
    return this
    // Separator is rendered as a separate composable
}

/**
 * Parse color string to Compose Color
 */
private fun parseColor(colorString: String): Color {
    return try {
        Color(android.graphics.Color.parseColor(colorString))
    } catch (e: Exception) {
        Color.Gray
    }
}
