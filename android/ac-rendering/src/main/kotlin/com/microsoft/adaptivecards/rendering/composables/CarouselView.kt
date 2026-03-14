// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Card
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import com.microsoft.adaptivecards.core.models.BlockElementHeight
import com.microsoft.adaptivecards.core.models.CardElement
import com.microsoft.adaptivecards.core.models.Carousel
import com.microsoft.adaptivecards.core.models.CarouselPage
import com.microsoft.adaptivecards.core.models.ColumnSet
import com.microsoft.adaptivecards.core.models.Container
import com.microsoft.adaptivecards.core.models.FactSet
import com.microsoft.adaptivecards.core.models.FontSize
import com.microsoft.adaptivecards.core.models.Image
import com.microsoft.adaptivecards.core.models.ImageSize
import com.microsoft.adaptivecards.core.models.TextBlock
import com.microsoft.adaptivecards.rendering.theme.LocalHostConfig
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

/**
 * Renders a Carousel element with horizontal paging and page indicators
 * Accessibility: Announces current page and total pages, supports swipe gestures
 * Responsive: Adapts padding and card size for tablets
 */
@Composable
fun CarouselView(
    element: Carousel,
    viewModel: CardViewModel,
    actionHandler: ActionHandler,
    modifier: Modifier = Modifier
) {
    val hostConfig = LocalHostConfig.current
    val configuration = LocalConfiguration.current
    val isTablet = configuration.screenWidthDp >= 600
    
    val visiblePages = remember(element.pages) {
        element.pages.filter { it.items.isNotEmpty() }
    }

    val pagerState = rememberPagerState(
        initialPage = (element.initialPage ?: 0).coerceAtMost((visiblePages.size - 1).coerceAtLeast(0)),
        pageCount = { visiblePages.size }
    )
    val scope = rememberCoroutineScope()

    // Auto-advance timer
    LaunchedEffect(pagerState.currentPage, element.timer) {
        element.timer?.let { timerMs ->
            if (timerMs > 0 && visiblePages.isNotEmpty()) {
                scope.launch {
                    delay(timerMs.toLong())
                    val nextPage = (pagerState.currentPage + 1) % visiblePages.size
                    pagerState.animateScrollToPage(nextPage)
                }
            }
        }
    }

    // Estimate pager height based on page content (matching iOS parity)
    val pagerHeight = remember(element, visiblePages, configuration) {
        val screenWidthDp = configuration.screenWidthDp.toFloat()
        val screenHeightDp = configuration.screenHeightDp.toFloat()
        val hPad = if (isTablet) 80f else 48f
        val contentWidth = screenWidthDp - hPad
        val pagePadding = if (isTablet) 48f else 32f

        // If heightInPixels is set, use it directly (matching iOS)
        val explicitHeight = element.heightInPixels
            ?.replace("px", "", ignoreCase = true)
            ?.trim()
            ?.toFloatOrNull()
        if (explicitHeight != null) {
            return@remember explicitHeight
        }

        // If height is stretch, use 65% of screen height (matching iOS)
        if (element.height == BlockElementHeight.Stretch) {
            screenHeightDp * 0.65f
        } else {
            val maxPageHeight = visiblePages.maxOfOrNull { page ->
                estimatePageHeight(page, contentWidth)
            } ?: 0f

            val estimated = maxPageHeight + pagePadding
            // Use generous minimum to ensure nested content (e.g., weather forecast
            // grids with multiple ColumnSets) is fully visible
            val minimum = if (isTablet) 240f else 220f
            val maxHeight = screenHeightDp * 0.65f
            maxOf(estimated, minimum).coerceAtMost(maxHeight)
        }
    }

    Column(
        modifier = modifier.semantics {
            contentDescription = "Carousel with ${visiblePages.size} pages, currently on page ${pagerState.currentPage + 1}"
        }
    ) {
        // Horizontal pager for carousel pages
        HorizontalPager(
            state = pagerState,
            modifier = Modifier
                .fillMaxWidth()
                .height(pagerHeight.dp)
                .semantics {
                    contentDescription = "Page ${pagerState.currentPage + 1} of ${visiblePages.size}"
                }
        ) { page ->
            val carouselPage = visiblePages.getOrNull(page) ?: return@HorizontalPager

            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .fillMaxHeight()
                    .padding(
                        horizontal = if (isTablet) 16.dp else 8.dp,
                        vertical = 8.dp
                    )
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(
                            all = if (isTablet) 24.dp else 16.dp
                        )
                ) {
                    // Render page items
                    carouselPage.items.forEachIndexed { index, item ->
                        RenderElement(
                            element = item,
                            isFirst = index == 0,
                            viewModel = viewModel,
                            actionHandler = actionHandler
                        )
                    }
                }
            }
        }

        // Page indicators
        if (visiblePages.size > 1) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = if (isTablet) 12.dp else 8.dp)
                    .semantics {
                        contentDescription = "Page indicator: ${pagerState.currentPage + 1} of ${visiblePages.size}"
                    },
                horizontalArrangement = Arrangement.Center
            ) {
                repeat(visiblePages.size) { index ->
                    val color = if (pagerState.currentPage == index) {
                        try { Color(android.graphics.Color.parseColor(hostConfig.containerStyles.default.foregroundColors.accent.default)) } catch (e: Exception) { Color(0xFF0078D4) }
                    } else {
                        Color.Gray.copy(alpha = 0.5f)
                    }
                    
                    Box(
                        modifier = Modifier
                            .padding(horizontal = 4.dp)
                            .size(if (isTablet) 10.dp else 8.dp)
                            .clip(CircleShape)
                            .background(color)
                            .semantics {
                                contentDescription = if (pagerState.currentPage == index) {
                                    "Current page ${index + 1}"
                                } else {
                                    "Page ${index + 1}"
                                }
                            }
                    )
                }
            }
        }
    }
}

/**
 * Estimate the content height (in dp) for a carousel page based on element types.
 * Recursively estimates nested containers for accurate height calculation.
 */
private fun estimatePageHeight(page: CarouselPage, contentWidth: Float): Float {
    return estimateElementsHeight(page.items, contentWidth)
}

private fun estimateElementsHeight(items: List<CardElement>, contentWidth: Float): Float {
    val lineHeight = 20f
    val defaultSpacing = 8f
    var height = 0f

    for ((index, item) in items.withIndex()) {
        // Add inter-item spacing (matching default AC spacing)
        if (index > 0) height += defaultSpacing

        height += when (item) {
            is Container -> {
                val nested = item.items ?: emptyList()
                estimateElementsHeight(nested, contentWidth)
            }
            is ColumnSet -> {
                val columns = item.columns ?: emptyList()
                // Use sum of tallest column + extra padding for complex nested content
                val tallestColumn = columns.maxOfOrNull { col ->
                    estimateElementsHeight(col.items ?: emptyList(), contentWidth / columns.size.coerceAtLeast(1))
                } ?: (lineHeight * 3)
                // Add minimum baseline for ColumnSets with content
                tallestColumn.coerceAtLeast(lineHeight * 3)
            }
            is FactSet -> lineHeight * item.facts.size.coerceAtLeast(1)
            is TextBlock -> {
                // Estimate lines based on text length relative to available width
                // ~5dp per character at default font size (conservative to avoid undersizing)
                val charsPerLine = (contentWidth / 5f).coerceAtLeast(1f)
                val textLen = item.text.length.toFloat()
                val baseFontScale = when (item.size) {
                    FontSize.ExtraLarge -> 1.8f
                    FontSize.Large -> 1.4f
                    FontSize.Medium -> 1.2f
                    FontSize.Small -> 0.85f
                    else -> 1f
                }
                val estimatedLines = if (item.wrap == true) {
                    ((textLen / charsPerLine) * baseFontScale).coerceIn(1f, 8f)
                } else {
                    1f
                }
                (lineHeight * baseFontScale * estimatedLines).coerceAtLeast(lineHeight)
            }
            is Image -> {
                // Use named sizes instead of always assuming 1:1 aspect with content width
                val widthPx = item.width?.removeSuffix("px")?.toIntOrNull()
                val heightPx = item.pixelHeight?.removeSuffix("px")?.toIntOrNull()
                when {
                    heightPx != null -> heightPx.toFloat()
                    widthPx != null -> widthPx.toFloat() // approximate 1:1
                    else -> when (item.size) {
                        ImageSize.Small -> 32f
                        ImageSize.Medium -> 52f
                        ImageSize.Large -> 100f
                        ImageSize.Stretch -> contentWidth * 0.75f
                        ImageSize.Auto, null -> contentWidth * 0.75f
                    }
                }
            }
            else -> when (item.type) {
                "ImageSet" -> contentWidth * 0.5f
                "RichTextBlock" -> lineHeight * 3
                else -> lineHeight * 2
            }
        }
    }

    return height
}
