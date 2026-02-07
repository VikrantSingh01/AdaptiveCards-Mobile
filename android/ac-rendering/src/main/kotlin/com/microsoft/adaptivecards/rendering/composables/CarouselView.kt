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
import com.google.accompanist.pager.HorizontalPager
import com.google.accompanist.pager.rememberPagerState
import com.microsoft.adaptivecards.core.models.Carousel
import com.microsoft.adaptivecards.hostconfig.LocalHostConfig
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
    
    val pagerState = rememberPagerState(
        initialPage = element.initialPage ?: 0
    )
    val scope = rememberCoroutineScope()

    // Auto-advance timer
    LaunchedEffect(pagerState.currentPage, element.timer) {
        element.timer?.let { timerMs ->
            if (timerMs > 0 && element.pages.isNotEmpty()) {
                scope.launch {
                    delay(timerMs.toLong())
                    val nextPage = (pagerState.currentPage + 1) % element.pages.size
                    pagerState.animateScrollToPage(nextPage)
                }
            }
        }
    }

    Column(
        modifier = modifier.semantics {
            contentDescription = "Carousel with ${element.pages.size} pages, currently on page ${pagerState.currentPage + 1}"
        }
    ) {
        // Horizontal pager for carousel pages
        HorizontalPager(
            count = element.pages.size,
            state = pagerState,
            modifier = Modifier
                .fillMaxWidth()
                .semantics {
                    contentDescription = "Page ${pagerState.currentPage + 1} of ${element.pages.size}"
                }
        ) { page ->
            val carouselPage = element.pages[page]
            
            Card(
                modifier = Modifier
                    .fillMaxWidth()
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
        if (element.pages.size > 1) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = if (isTablet) 12.dp else 8.dp)
                    .semantics {
                        contentDescription = "Page indicator: ${pagerState.currentPage + 1} of ${element.pages.size}"
                    },
                horizontalArrangement = Arrangement.Center
            ) {
                repeat(element.pages.size) { index ->
                    val color = if (pagerState.currentPage == index) {
                        Color(hostConfig.colors.accent.default)
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
