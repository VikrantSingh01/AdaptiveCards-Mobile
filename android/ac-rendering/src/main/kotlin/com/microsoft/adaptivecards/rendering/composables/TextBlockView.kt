package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.text.ClickableText
import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.LineHeightStyle
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.sp
import com.microsoft.adaptivecards.core.models.*
import com.microsoft.adaptivecards.rendering.theme.LocalHostConfig
import com.microsoft.adaptivecards.accessibility.scaledTextSize
import com.microsoft.adaptivecards.markdown.MarkdownParser
import com.microsoft.adaptivecards.markdown.MarkdownRenderer
import com.microsoft.adaptivecards.markdown.containsMarkdown

/**
 * Renders a TextBlock element with Figma-aligned typography:
 * - Font sizes and line heights from HostConfig
 * - Font weights mapped through HostConfig (lighter=400, default=400, bolder=500)
 * - Roboto font family on Android
 */
@Composable
fun TextBlockView(
    element: TextBlock,
    modifier: Modifier = Modifier
) {
    val hostConfig = LocalHostConfig.current

    val sizeEnum = element.size ?: FontSize.Default

    // Determine text size
    val textSize = when (sizeEnum) {
        FontSize.Small -> scaledTextSize(hostConfig.fontSizes.small)
        FontSize.Default -> scaledTextSize(hostConfig.fontSizes.default)
        FontSize.Medium -> scaledTextSize(hostConfig.fontSizes.medium)
        FontSize.Large -> scaledTextSize(hostConfig.fontSizes.large)
        FontSize.ExtraLarge -> scaledTextSize(hostConfig.fontSizes.extraLarge)
    }

    // Determine line height from HostConfig
    val lineHeight = when (sizeEnum) {
        FontSize.Small -> hostConfig.lineHeights.small.sp
        FontSize.Default -> hostConfig.lineHeights.default.sp
        FontSize.Medium -> hostConfig.lineHeights.medium.sp
        FontSize.Large -> hostConfig.lineHeights.large.sp
        FontSize.ExtraLarge -> hostConfig.lineHeights.extraLarge.sp
    }

    // Determine font weight via HostConfig weight mapping
    val fontWeight = resolveFontWeight(
        element.weight ?: com.microsoft.adaptivecards.core.models.FontWeight.Default,
        hostConfig
    )

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

    val maxLines = (element.maxLines ?: if (element.wrap == true) Int.MAX_VALUE else 1).coerceAtLeast(1)
    val overflow = if (element.wrap == true) TextOverflow.Visible else TextOverflow.Ellipsis

    // fillMaxWidth is required for textAlign (center/right) to have visible effect
    val alignedModifier = if (element.horizontalAlignment != null && element.horizontalAlignment != HorizontalAlignment.Left) {
        modifier.fillMaxWidth()
    } else {
        modifier
    }

    // Check if text contains markdown
    if (element.text.containsMarkdown()) {
        // Render with markdown support
        val tokens = MarkdownParser.parse(element.text)
        val annotatedString = MarkdownRenderer.render(tokens, textSize, textColor)
        val uriHandler = LocalUriHandler.current

        ClickableText(
            text = annotatedString,
            modifier = alignedModifier,
            style = LocalTextStyle.current.copy(
                fontSize = textSize,
                fontWeight = fontWeight,
                fontFamily = fontFamily,
                color = textColor,
                textAlign = textAlign,
                lineHeight = lineHeight
            ),
            maxLines = maxLines,
            overflow = overflow,
            onClick = { offset ->
                // Handle link clicks — only open URLs with safe schemes
                annotatedString.getStringAnnotations(tag = "URL", start = offset, end = offset)
                    .firstOrNull()?.let { annotation ->
                        if (MarkdownRenderer.isSafeUrl(annotation.item)) {
                            try {
                                uriHandler.openUri(annotation.item)
                            } catch (e: Exception) {
                                // Handle URI opening error gracefully
                            }
                        }
                    }
            }
        )
    } else {
        // Render plain text
        Text(
            text = element.text,
            fontSize = textSize,
            fontWeight = fontWeight,
            fontFamily = fontFamily,
            color = textColor,
            textAlign = textAlign,
            lineHeight = lineHeight,
            maxLines = maxLines,
            overflow = overflow,
            modifier = alignedModifier
        )
    }
}

/**
 * Resolve a FontSize enum to the actual pixel value from HostConfig
 */
internal fun resolveFontSize(
    size: com.microsoft.adaptivecards.core.models.FontSize,
    hostConfig: com.microsoft.adaptivecards.core.hostconfig.HostConfig
): Int = when (size) {
    com.microsoft.adaptivecards.core.models.FontSize.Small -> hostConfig.fontSizes.small
    com.microsoft.adaptivecards.core.models.FontSize.Default -> hostConfig.fontSizes.default
    com.microsoft.adaptivecards.core.models.FontSize.Medium -> hostConfig.fontSizes.medium
    com.microsoft.adaptivecards.core.models.FontSize.Large -> hostConfig.fontSizes.large
    com.microsoft.adaptivecards.core.models.FontSize.ExtraLarge -> hostConfig.fontSizes.extraLarge
}

/**
 * Resolve a FontSize enum to the line height from HostConfig
 */
internal fun resolveLineHeight(
    size: com.microsoft.adaptivecards.core.models.FontSize,
    hostConfig: com.microsoft.adaptivecards.core.hostconfig.HostConfig
): Int = when (size) {
    com.microsoft.adaptivecards.core.models.FontSize.Small -> hostConfig.lineHeights.small
    com.microsoft.adaptivecards.core.models.FontSize.Default -> hostConfig.lineHeights.default
    com.microsoft.adaptivecards.core.models.FontSize.Medium -> hostConfig.lineHeights.medium
    com.microsoft.adaptivecards.core.models.FontSize.Large -> hostConfig.lineHeights.large
    com.microsoft.adaptivecards.core.models.FontSize.ExtraLarge -> hostConfig.lineHeights.extraLarge
}

/**
 * Resolve a FontWeight enum to Compose FontWeight from HostConfig
 */
internal fun resolveFontWeight(
    weight: com.microsoft.adaptivecards.core.models.FontWeight,
    hostConfig: com.microsoft.adaptivecards.core.hostconfig.HostConfig
): FontWeight {
    val value = when (weight) {
        com.microsoft.adaptivecards.core.models.FontWeight.Lighter -> hostConfig.fontWeights.lighter
        com.microsoft.adaptivecards.core.models.FontWeight.Default -> hostConfig.fontWeights.default
        com.microsoft.adaptivecards.core.models.FontWeight.Bolder -> hostConfig.fontWeights.bolder
    }
    return when (value) {
        in 100..199 -> FontWeight.Thin
        in 200..299 -> FontWeight.Light
        in 300..399 -> FontWeight.Normal
        in 400..499 -> FontWeight.Normal
        in 500..599 -> FontWeight.Medium
        in 600..699 -> FontWeight.SemiBold
        in 700..799 -> FontWeight.Bold
        else -> FontWeight.ExtraBold
    }
}

/**
 * Get text color from host config based on color and subtle properties
 */
internal fun getTextColor(
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

/**
 * Get highlight background color from host config based on color slot and subtle properties.
 */
internal fun getHighlightColor(
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

    val colorString = if (isSubtle) colorConfig.highlightColors.subtle else colorConfig.highlightColors.default

    return try {
        Color(android.graphics.Color.parseColor(colorString))
    } catch (e: Exception) {
        Color(0x4DFFFF00) // Fallback: yellow at 30% opacity
    }
}
