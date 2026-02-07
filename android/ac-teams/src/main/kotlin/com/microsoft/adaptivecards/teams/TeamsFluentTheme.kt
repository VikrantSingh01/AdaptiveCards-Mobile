package com.microsoft.adaptivecards.teams

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

object TeamsFluentTheme {
    @Composable
    fun getColorScheme(teamsTheme: TeamsTheme): ColorScheme {
        return when (teamsTheme) {
            TeamsTheme.LIGHT -> lightColorScheme(
                primary = Color(0xFF6264A7),
                background = Color.White,
                surface = Color(0xFFFAFAFA),
                onPrimary = Color.White,
                onBackground = Color.Black,
                onSurface = Color.Black
            )
            TeamsTheme.DARK -> darkColorScheme(
                primary = Color(0xFF8587D3),
                background = Color(0xFF1F1F1F),
                surface = Color(0xFF2D2D2D),
                onPrimary = Color.White,
                onBackground = Color.White,
                onSurface = Color.White
            )
            TeamsTheme.HIGH_CONTRAST -> darkColorScheme(
                primary = Color.Yellow,
                background = Color.Black,
                surface = Color(0xFF0D0D0D),
                onPrimary = Color.Black,
                onBackground = Color.White,
                onSurface = Color.White
            )
        }
    }
}
