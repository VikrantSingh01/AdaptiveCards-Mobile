package com.microsoft.adaptivecards.charts

import androidx.compose.ui.graphics.Color

object ChartColors {
    val defaultPalette = listOf(
        Color(0xFF0078D4), // Blue
        Color(0xFF00BCF2), // Cyan
        Color(0xFF8764B8), // Purple
        Color(0xFF00B7C3), // Teal
        Color(0xFFFFB900), // Yellow
        Color(0xFFD83B01), // Orange
        Color(0xFFE74856), // Red
        Color(0xFF00CC6A)  // Green
    )
    
    fun colors(from: List<String>?): List<Color> {
        return from?.mapNotNull { parseHexColor(it) } ?: defaultPalette
    }
    
    private fun parseHexColor(hex: String): Color? {
        val cleanHex = hex.removePrefix("#")
        return try {
            when (cleanHex.length) {
                6 -> Color(0xFF000000 or cleanHex.toLong(16))
                8 -> Color(cleanHex.toLong(16))
                else -> null
            }
        } catch (e: Exception) {
            null
        }
    }
}

enum class ChartSize(val heightDp: Int) {
    SMALL(150),
    MEDIUM(250),
    LARGE(350),
    AUTO(250);
    
    companion object {
        fun from(string: String?): ChartSize {
            return when (string?.lowercase()) {
                "small" -> SMALL
                "medium" -> MEDIUM
                "large" -> LARGE
                else -> AUTO
            }
        }
    }
}
