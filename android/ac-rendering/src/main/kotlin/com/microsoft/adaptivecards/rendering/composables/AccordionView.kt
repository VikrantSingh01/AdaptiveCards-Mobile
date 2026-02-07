package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.animateContentSize
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.stateDescription
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.Accordion
import com.microsoft.adaptivecards.core.models.ExpandMode
import com.microsoft.adaptivecards.hostconfig.LocalHostConfig
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel

/**
 * Renders an Accordion element with expandable panels
 * Accessibility: Announces panel state (expanded/collapsed), supports keyboard navigation
 * Responsive: Adapts padding and text size for tablets
 */
@Composable
fun AccordionView(
    element: Accordion,
    viewModel: CardViewModel,
    actionHandler: ActionHandler,
    modifier: Modifier = Modifier
) {
    val hostConfig = LocalHostConfig.current
    val configuration = LocalConfiguration.current
    val isTablet = configuration.screenWidthDp >= 600
    
    val expandedPanels = remember {
        mutableStateMapOf<Int, Boolean>().apply {
            element.panels.forEachIndexed { index, panel ->
                this[index] = panel.isExpanded ?: false
            }
        }
    }

    Column(
        modifier = modifier
            .animateContentSize()
            .semantics {
                contentDescription = "Accordion with ${element.panels.size} panels, ${element.expandMode} mode"
            }
    ) {
        element.panels.forEachIndexed { index, panel ->
            val isExpanded = expandedPanels[index] ?: false

            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = if (isTablet) 6.dp else 4.dp),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant
                )
            ) {
                Column {
                    // Panel header
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable(
                                role = Role.Button,
                                onClickLabel = if (isExpanded) "Collapse ${panel.title}" else "Expand ${panel.title}"
                            ) {
                                if (element.expandMode == ExpandMode.SINGLE) {
                                    // Close all other panels
                                    expandedPanels.keys.forEach { key ->
                                        expandedPanels[key] = false
                                    }
                                }
                                expandedPanels[index] = !isExpanded
                            }
                            .padding(
                                horizontal = if (isTablet) 20.dp else 16.dp,
                                vertical = if (isTablet) 18.dp else 16.dp
                            )
                            .semantics {
                                stateDescription = if (isExpanded) "Expanded" else "Collapsed"
                                contentDescription = "${panel.title}, ${if (isExpanded) "expanded" else "collapsed"}"
                            },
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = panel.title,
                            style = if (isTablet) {
                                MaterialTheme.typography.titleLarge
                            } else {
                                MaterialTheme.typography.titleMedium
                            },
                            modifier = Modifier.weight(1f)
                        )

                        val rotation by animateFloatAsState(
                            targetValue = if (isExpanded) 180f else 0f,
                            label = "accordion-arrow"
                        )
                        
                        Icon(
                            imageVector = Icons.Default.KeyboardArrowDown,
                            contentDescription = if (isExpanded) "Collapse" else "Expand",
                            modifier = Modifier
                                .rotate(rotation)
                                .size(if (isTablet) 28.dp else 24.dp)
                        )
                    }

                    // Panel content
                    AnimatedVisibility(visible = isExpanded) {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(
                                    horizontal = if (isTablet) 20.dp else 16.dp,
                                    vertical = if (isTablet) 12.dp else 8.dp
                                )
                                .semantics {
                                    contentDescription = "Content for ${panel.title}"
                                }
                        ) {
                            panel.content.forEachIndexed { contentIndex, contentElement ->
                                RenderElement(
                                    element = contentElement,
                                    isFirst = contentIndex == 0,
                                    viewModel = viewModel,
                                    actionHandler = actionHandler
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}
