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

        // If height is stretch, use 65% of screen height (matching iOS)
        if (element.height == BlockElementHeight.Stretch) {
            screenHeightDp * 0.65f
        } else {
            val maxPageHeight = visiblePages.maxOfOrNull { page ->
                estimatePageHeight(page, contentWidth)
            } ?: 0f

            val estimated = maxPageHeight + pagePadding
            // Use generous minimum to ensure content is visible (matching iOS sizing)
            val minimum = if (isTablet) 200f else 180f
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
    var height = 0f

    for (item in items) {
        height += when (item) {
            is Container -> {
                val nested = item.items ?: emptyList()
                estimateElementsHeight(nested, contentWidth)
            }
            is ColumnSet -> {
                val columns = item.columns ?: emptyList()
                columns.maxOfOrNull { col ->
                    estimateElementsHeight(col.items ?: emptyList(), contentWidth / columns.size.coerceAtLeast(1))
                } ?: (lineHeight * 3)
            }
            is FactSet -> lineHeight * item.facts.size.coerceAtLeast(1)
            else -> when (item.type) {
                // TextBlocks in carousels typically wrap — estimate 3 lines for parity with iOS
                "TextBlock" -> lineHeight * 3
                // Images default to ~1:1 aspect ratio to match iOS sizing (was 0.75x, too small)
                "Image" -> contentWidth
                "ImageSet" -> contentWidth * 0.5f
                "RichTextBlock" -> lineHeight * 3
                else -> lineHeight * 2
            }
        }
    }

    return height
}
