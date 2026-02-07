package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.TabSet
import com.microsoft.adaptivecards.hostconfig.LocalHostConfig
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel

/**
 * Renders a TabSet element with scrollable tabs
 */
@Composable
fun TabSetView(
    element: TabSet,
    viewModel: CardViewModel,
    actionHandler: ActionHandler,
    modifier: Modifier = Modifier
) {
    val hostConfig = LocalHostConfig.current
    
    // Find initial selected tab index
    val initialTabIndex = element.selectedTabId?.let { selectedId ->
        element.tabs.indexOfFirst { it.id == selectedId }.takeIf { it >= 0 }
    } ?: 0
    
    var selectedTabIndex by remember { mutableStateOf(initialTabIndex) }

    Column(modifier = modifier.fillMaxWidth()) {
        // Tab Row
        if (element.tabs.size > 1) {
            ScrollableTabRow(
                selectedTabIndex = selectedTabIndex,
                containerColor = MaterialTheme.colorScheme.surface,
                contentColor = MaterialTheme.colorScheme.primary,
                edgePadding = 0.dp
            ) {
                element.tabs.forEachIndexed { index, tab ->
                    Tab(
                        selected = selectedTabIndex == index,
                        onClick = { selectedTabIndex = index },
                        text = {
                            Row(
                                horizontalArrangement = Arrangement.Center
                            ) {
                                // Icon (emoji)
                                tab.icon?.let { icon ->
                                    Text(text = icon)
                                    Spacer(modifier = Modifier.width(4.dp))
                                }
                                
                                // Title
                                Text(text = tab.title)
                            }
                        }
                    )
                }
            }
        }

        Divider()

        // Tab Content
        val selectedTab = element.tabs.getOrNull(selectedTabIndex)
        selectedTab?.let { tab ->
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp)
            ) {
                tab.items.forEachIndexed { index, item ->
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
}
