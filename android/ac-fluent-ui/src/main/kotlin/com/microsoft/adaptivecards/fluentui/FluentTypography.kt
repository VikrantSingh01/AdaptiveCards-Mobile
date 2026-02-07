package com.microsoft.adaptivecards.fluentui

import androidx.compose.runtime.Immutable
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.sp

@Immutable
data class FluentTypography(
    // Caption sizes
    val caption2: FluentFont = FluentFont(size = 10.sp, weight = FontWeight.Normal, lineHeight = 12.sp),
    val caption1: FluentFont = FluentFont(size = 12.sp, weight = FontWeight.Normal, lineHeight = 16.sp),
    
    // Body sizes
    val body1: FluentFont = FluentFont(size = 14.sp, weight = FontWeight.Normal, lineHeight = 20.sp),
    val body2: FluentFont = FluentFont(size = 14.sp, weight = FontWeight.SemiBold, lineHeight = 20.sp),
    
    // Subtitle sizes
    val subtitle2: FluentFont = FluentFont(size = 16.sp, weight = FontWeight.Normal, lineHeight = 22.sp),
    val subtitle1: FluentFont = FluentFont(size = 16.sp, weight = FontWeight.SemiBold, lineHeight = 22.sp),
    
    // Title sizes
    val title3: FluentFont = FluentFont(size = 20.sp, weight = FontWeight.SemiBold, lineHeight = 26.sp),
    val title2: FluentFont = FluentFont(size = 24.sp, weight = FontWeight.SemiBold, lineHeight = 32.sp),
    val title1: FluentFont = FluentFont(size = 28.sp, weight = FontWeight.SemiBold, lineHeight = 36.sp),
    
    // Display sizes
    val largeTitle: FluentFont = FluentFont(size = 32.sp, weight = FontWeight.SemiBold, lineHeight = 40.sp),
    val display: FluentFont = FluentFont(size = 40.sp, weight = FontWeight.SemiBold, lineHeight = 52.sp)
)

@Immutable
data class FluentFont(
    val size: TextUnit,
    val weight: FontWeight,
    val lineHeight: TextUnit
)
