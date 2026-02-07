package com.microsoft.adaptivecards.fluentui

import androidx.compose.runtime.Immutable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color

@Immutable
data class FluentTheme(
    val colors: FluentColorTokens = FluentColorTokens(),
    val typography: FluentTypography = FluentTypography(),
    val spacing: FluentSpacing = FluentSpacing(),
    val cornerRadii: FluentCornerRadii = FluentCornerRadii()
) {
    companion object {
        val Default = FluentTheme()
    }
}

val LocalFluentTheme = staticCompositionLocalOf { FluentTheme.Default }
