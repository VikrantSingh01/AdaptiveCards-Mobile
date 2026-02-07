package com.microsoft.adaptivecards.fluentui

import androidx.compose.runtime.Immutable
import androidx.compose.ui.graphics.Color

@Immutable
data class FluentColorTokens(
    // Brand colors
    val brand: Color = Color(0xFF6264A7),
    val brandBackground: Color = Color(0xFF464775),
    val brandForeground: Color = Color.White,
    
    // Surface colors (light mode defaults)
    val surface: Color = Color.White,
    val surfaceSecondary: Color = Color(0xFFF5F5F5),
    val surfaceTertiary: Color = Color(0xFFE8E8E8),
    
    // Text colors
    val foreground: Color = Color(0xFF242424),
    val foregroundSecondary: Color = Color(0xFF616161),
    val foregroundDisabled: Color = Color(0xFFC7C7C7),
    
    // Border colors
    val stroke: Color = Color(0xFFD1D1D1),
    val strokeSecondary: Color = Color(0xFFE0E0E0),
    
    // Semantic colors
    val success: Color = Color(0xFF13A10E),
    val warning: Color = Color(0xFFFFC83D),
    val danger: Color = Color(0xFFD13438),
    val info: Color = Color(0xFF0078D4),
    
    // Dark mode variants
    val darkModeSurface: Color = Color(0xFF292929),
    val darkModeSurfaceSecondary: Color = Color(0xFF1F1F1F),
    val darkModeForeground: Color = Color.White
)
