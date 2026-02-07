package com.microsoft.adaptivecards.accessibility

import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * Scales a Dp value based on system font scale
 */
@Composable
fun Dp.scaledWithFontSize(): Dp {
    val fontScale = LocalDensity.current.fontScale
    return this * fontScale
}

/**
 * Gets a scaled text size based on system preferences
 */
@Composable
fun scaledTextSize(baseSize: TextUnit): TextUnit {
    val fontScale = LocalDensity.current.fontScale
    return baseSize * fontScale
}

/**
 * Gets a scaled text size from integer sp value
 */
@Composable
fun scaledTextSize(baseSizeSp: Int): TextUnit {
    val fontScale = LocalDensity.current.fontScale
    return (baseSizeSp * fontScale).sp
}

/**
 * Minimum touch target size for accessibility (48dp)
 */
val MinTouchTargetSize = 48.dp

/**
 * Ensures minimum touch target size for better accessibility
 */
@Composable
fun ensureMinTouchTarget(requestedSize: Dp): Dp {
    return maxOf(requestedSize, MinTouchTargetSize)
}
