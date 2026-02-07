package com.microsoft.adaptivecards.hostconfig

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import com.microsoft.adaptivecards.core.hostconfig.TeamsHostConfig

/**
 * Material3 theme based on Teams design tokens
 */
private val TeamsLightColorScheme = lightColorScheme(
    primary = Color(0xFF6264A7),
    onPrimary = Color(0xFFFFFFFF),
    primaryContainer = Color(0xFFE8E8F7),
    onPrimaryContainer = Color(0xFF242424),
    secondary = Color(0xFF8B8CC7),
    onSecondary = Color(0xFFFFFFFF),
    background = Color(0xFFFFFFFF),
    onBackground = Color(0xFF242424),
    surface = Color(0xFFF5F5F5),
    onSurface = Color(0xFF242424),
    error = Color(0xFFC4314B),
    onError = Color(0xFFFFFFFF)
)

private val TeamsDarkColorScheme = darkColorScheme(
    primary = Color(0xFF8B8CC7),
    onPrimary = Color(0xFF242424),
    primaryContainer = Color(0xFF6264A7),
    onPrimaryContainer = Color(0xFFFFFFFF),
    secondary = Color(0xFF6264A7),
    onSecondary = Color(0xFFFFFFFF),
    background = Color(0xFF1F1F1F),
    onBackground = Color(0xFFE1DFDD),
    surface = Color(0xFF2D2C2C),
    onSurface = Color(0xFFE1DFDD),
    error = Color(0xFFD3596D),
    onError = Color(0xFF000000)
)

/**
 * Teams theme that applies Material3 styling based on Teams HostConfig
 * 
 * Usage:
 * ```
 * TeamsTheme {
 *     AdaptiveCardView(cardJson)
 * }
 * ```
 */
@Composable
fun TeamsTheme(
    darkTheme: Boolean = false,
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) TeamsDarkColorScheme else TeamsLightColorScheme
    val hostConfig = TeamsHostConfig.create()
    
    MaterialTheme(
        colorScheme = colorScheme
    ) {
        HostConfigProvider(hostConfig = hostConfig) {
            content()
        }
    }
}
