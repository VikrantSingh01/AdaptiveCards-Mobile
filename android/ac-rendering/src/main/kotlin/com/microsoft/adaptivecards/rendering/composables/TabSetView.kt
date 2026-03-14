// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.TabSet
import com.microsoft.adaptivecards.rendering.theme.LocalHostConfig
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel

/**
 * Renders a TabSet element with scrollable tabs
 * Accessibility: Announces selected tab and total tabs, keyboard navigable
 * Responsive: Adapts padding and text size for tablets
 */
@Composable
fun TabSetView(
    element: TabSet,
    viewModel: CardViewModel,
    actionHandler: ActionHandler,
    modifier: Modifier = Modifier
) {
    val hostConfig = LocalHostConfig.current
    val configuration = LocalConfiguration.current
    val isTablet = configuration.screenWidthDp >= 600
    
    // Find initial selected tab index
    val initialTabIndex = element.selectedTabId?.let { selectedId ->
        element.tabs.indexOfFirst { it.id == selectedId }.takeIf { it >= 0 }
    } ?: 0
    
    var selectedTabIndex by remember { mutableStateOf(initialTabIndex) }

    Column(
        modifier = modifier
            .fillMaxWidth()
            .semantics {
                contentDescription = "Tab set with ${element.tabs.size} tabs, ${element.tabs.getOrNull(selectedTabIndex)?.title} selected"
            }
    ) {
        // Tab Row
        if (element.tabs.size > 1) {
            ScrollableTabRow(
                selectedTabIndex = selectedTabIndex,
                containerColor = MaterialTheme.colorScheme.surface,
                contentColor = MaterialTheme.colorScheme.primary,
                edgePadding = if (isTablet) 8.dp else 0.dp,
                modifier = Modifier.semantics {
                    contentDescription = "Tab navigation with ${element.tabs.size} tabs"
                }
            ) {
                element.tabs.forEachIndexed { index, tab ->
                    Tab(
                        selected = selectedTabIndex == index,
                        onClick = { selectedTabIndex = index },
                        text = {
                            Text(
                                text = tab.title,
                                style = if (isTablet) {
                                    MaterialTheme.typography.titleMedium
                                } else {
                                    MaterialTheme.typography.titleSmall
                                }
                            )
                        },
                        icon = tab.icon?.let { iconName ->
                            {
                                Icon(
                                    imageVector = resolveIconName(iconName),
                                    contentDescription = iconName,
                                    modifier = Modifier.size(if (isTablet) 22.dp else 18.dp)
                                )
                            }
                        },
                        modifier = Modifier.semantics {
                            contentDescription = if (selectedTabIndex == index) {
                                "${tab.title} tab, selected"
                            } else {
                                "${tab.title} tab"
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
                    .padding(
                        all = if (isTablet) 24.dp else 16.dp
                    )
                    .semantics {
                        contentDescription = "Content for ${tab.title} tab"
                    }
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
