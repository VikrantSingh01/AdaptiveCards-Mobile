package com.microsoft.adaptivecards.rendering.modifiers

import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.Spacing
import com.microsoft.adaptivecards.hostconfig.LocalHostConfig

/**
 * Applies spacing based on Adaptive Card spacing property
 */
@Composable
fun Modifier.adaptiveSpacing(
    spacing: Spacing?,
    isFirst: Boolean = false
): Modifier {
    if (isFirst || spacing == null || spacing == Spacing.None) {
        return this
    }
    
    val hostConfig = LocalHostConfig.current
    val spacingValue = when (spacing) {
        Spacing.Small -> hostConfig.spacing.small
        Spacing.Default -> hostConfig.spacing.default
        Spacing.Medium -> hostConfig.spacing.medium
        Spacing.Large -> hostConfig.spacing.large
        Spacing.ExtraLarge -> hostConfig.spacing.extraLarge
        Spacing.Padding -> hostConfig.spacing.padding
        else -> 0
    }
    
    return this.padding(top = spacingValue.dp)
}
