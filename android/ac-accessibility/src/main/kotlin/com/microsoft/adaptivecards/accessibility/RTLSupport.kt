package com.microsoft.adaptivecards.accessibility

import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.unit.LayoutDirection

/**
 * Provides RTL layout support based on the card's rtl property
 * 
 * Usage:
 * ```
 * RTLSupport(isRTL = card.rtl == true) {
 *     // Card content
 * }
 * ```
 */
@Composable
fun RTLSupport(
    isRTL: Boolean = false,
    content: @Composable () -> Unit
) {
    val layoutDirection = if (isRTL) LayoutDirection.Rtl else LayoutDirection.Ltr
    
    CompositionLocalProvider(
        LocalLayoutDirection provides layoutDirection
    ) {
        content()
    }
}

/**
 * Gets the current layout direction
 */
@Composable
fun isRTL(): Boolean {
    return LocalLayoutDirection.current == LayoutDirection.Rtl
}
