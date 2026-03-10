package com.microsoft.adaptivecards.rendering.modifiers

import androidx.compose.foundation.background
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.ContainerStyle
import com.microsoft.adaptivecards.hostconfig.LocalHostConfig

/**
 * Applies background color and corner radius based on container style and host config.
 */
@Composable
fun Modifier.containerStyle(
    style: ContainerStyle?,
    cornerRadiusDp: Int? = null
): Modifier {
    if (style == null && cornerRadiusDp == null) {
        return this
    }

    val hostConfig = LocalHostConfig.current
    var result = this

    // Apply corner radius
    val radius = cornerRadiusDp ?: hostConfig.cornerRadius.container
    if (radius > 0) {
        result = result.clip(RoundedCornerShape(radius.dp))
    }

    // Apply background color from container style
    if (style != null) {
        val styleConfig = when (style) {
            ContainerStyle.Default -> hostConfig.containerStyles.default
            ContainerStyle.Emphasis -> hostConfig.containerStyles.emphasis
            ContainerStyle.Good -> hostConfig.containerStyles.good
            ContainerStyle.Attention -> hostConfig.containerStyles.attention
            ContainerStyle.Warning -> hostConfig.containerStyles.warning
            ContainerStyle.Accent -> hostConfig.containerStyles.accent
        }
        val backgroundColor = parseColor(styleConfig.backgroundColor)
        result = result.background(backgroundColor)
    }

    return result
}

/**
 * Parse color string to Compose Color, supporting #AARRGGBB and #RRGGBB formats.
 */
internal fun parseColor(colorString: String): Color {
    return try {
        Color(android.graphics.Color.parseColor(colorString))
    } catch (e: Exception) {
        Color.White
    }
}
