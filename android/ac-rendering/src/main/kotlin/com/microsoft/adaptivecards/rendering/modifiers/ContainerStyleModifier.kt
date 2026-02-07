package com.microsoft.adaptivecards.rendering.modifiers

import androidx.compose.foundation.background
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import com.microsoft.adaptivecards.core.models.ContainerStyle
import com.microsoft.adaptivecards.hostconfig.LocalHostConfig

/**
 * Applies background based on container style
 */
@Composable
fun Modifier.containerStyle(
    style: ContainerStyle?
): Modifier {
    if (style == null) {
        return this
    }
    
    val hostConfig = LocalHostConfig.current
    val styleConfig = when (style) {
        ContainerStyle.Default -> hostConfig.containerStyles.default
        ContainerStyle.Emphasis -> hostConfig.containerStyles.emphasis
        ContainerStyle.Good -> hostConfig.containerStyles.good
        ContainerStyle.Attention -> hostConfig.containerStyles.attention
        ContainerStyle.Warning -> hostConfig.containerStyles.warning
        ContainerStyle.Accent -> hostConfig.containerStyles.accent
    }
    
    val backgroundColor = parseColor(styleConfig.backgroundColor)
    
    return this.background(backgroundColor)
}

/**
 * Parse color string to Compose Color
 */
private fun parseColor(colorString: String): Color {
    return try {
        Color(android.graphics.Color.parseColor(colorString))
    } catch (e: Exception) {
        Color.White
    }
}
