package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.sp
import com.microsoft.adaptivecards.core.models.*
import com.microsoft.adaptivecards.hostconfig.LocalHostConfig
import com.microsoft.adaptivecards.accessibility.scaledTextSize

/**
 * Renders a TextBlock element
 */
@Composable
fun TextBlockView(
    element: TextBlock,
    modifier: Modifier = Modifier
) {
    val hostConfig = LocalHostConfig.current
    
    // Determine text size
    val textSize = when (element.size ?: FontSize.Default) {
        FontSize.Small -> scaledTextSize(hostConfig.fontSizes.small)
        FontSize.Default -> scaledTextSize(hostConfig.fontSizes.default)
        FontSize.Medium -> scaledTextSize(hostConfig.fontSizes.medium)
        FontSize.Large -> scaledTextSize(hostConfig.fontSizes.large)
        FontSize.ExtraLarge -> scaledTextSize(hostConfig.fontSizes.extraLarge)
    }
    
    // Determine font weight
    val fontWeight = when (element.weight ?: FontWeight.Default) {
        com.microsoft.adaptivecards.core.models.FontWeight.Lighter -> FontWeight.Light
        com.microsoft.adaptivecards.core.models.FontWeight.Default -> FontWeight.Normal
        com.microsoft.adaptivecards.core.models.FontWeight.Bolder -> FontWeight.Bold
    }
    
    // Determine font family
    val fontFamily = when (element.fontType ?: FontType.Default) {
        FontType.Default -> FontFamily.Default
        FontType.Monospace -> FontFamily.Monospace
    }
    
    // Determine text color
    val textColor = getTextColor(
        color = element.color ?: com.microsoft.adaptivecards.core.models.Color.Default,
        isSubtle = element.isSubtle ?: false,
        hostConfig = hostConfig
    )
    
    // Determine text alignment
    val textAlign = when (element.horizontalAlignment) {
        HorizontalAlignment.Left -> TextAlign.Start
        HorizontalAlignment.Center -> TextAlign.Center
        HorizontalAlignment.Right -> TextAlign.End
        null -> TextAlign.Start
    }
    
    Text(
        text = element.text,
        fontSize = textSize,
        fontWeight = fontWeight,
        fontFamily = fontFamily,
        color = textColor,
        textAlign = textAlign,
        maxLines = element.maxLines ?: if (element.wrap == true) Int.MAX_VALUE else 1,
        overflow = if (element.wrap == true) TextOverflow.Visible else TextOverflow.Ellipsis,
        modifier = modifier
    )
}

/**
 * Get text color from host config based on color and subtle properties
 */
private fun getTextColor(
    color: com.microsoft.adaptivecards.core.models.Color,
    isSubtle: Boolean,
    hostConfig: com.microsoft.adaptivecards.core.hostconfig.HostConfig
): Color {
    val containerStyle = hostConfig.containerStyles.default
    val foregroundColors = containerStyle.foregroundColors
    
    val colorConfig = when (color) {
        com.microsoft.adaptivecards.core.models.Color.Default -> foregroundColors.default
        com.microsoft.adaptivecards.core.models.Color.Dark -> foregroundColors.dark
        com.microsoft.adaptivecards.core.models.Color.Light -> foregroundColors.light
        com.microsoft.adaptivecards.core.models.Color.Accent -> foregroundColors.accent
        com.microsoft.adaptivecards.core.models.Color.Good -> foregroundColors.good
        com.microsoft.adaptivecards.core.models.Color.Warning -> foregroundColors.warning
        com.microsoft.adaptivecards.core.models.Color.Attention -> foregroundColors.attention
    }
    
    val colorString = if (isSubtle) colorConfig.subtle else colorConfig.default
    
    return try {
        Color(android.graphics.Color.parseColor(colorString))
    } catch (e: Exception) {
        Color.Black
    }
}
