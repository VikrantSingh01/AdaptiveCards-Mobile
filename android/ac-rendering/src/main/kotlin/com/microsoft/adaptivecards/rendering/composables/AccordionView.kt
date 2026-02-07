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
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.Accordion
import com.microsoft.adaptivecards.core.models.ExpandMode
import com.microsoft.adaptivecards.hostconfig.LocalHostConfig
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel

/**
 * Renders an Accordion element with expandable panels
 */
@Composable
fun AccordionView(
    element: Accordion,
    viewModel: CardViewModel,
    actionHandler: ActionHandler,
    modifier: Modifier = Modifier
) {
    val hostConfig = LocalHostConfig.current
    val expandedPanels = remember {
        mutableStateMapOf<Int, Boolean>().apply {
            element.panels.forEachIndexed { index, panel ->
                this[index] = panel.isExpanded ?: false
            }
        }
    }

    Column(modifier = modifier.animateContentSize()) {
        element.panels.forEachIndexed { index, panel ->
            val isExpanded = expandedPanels[index] ?: false

            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 4.dp),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant
                )
            ) {
                Column {
                    // Panel header
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable {
                                if (element.expandMode == ExpandMode.SINGLE) {
                                    // Close all other panels
                                    expandedPanels.keys.forEach { key ->
                                        expandedPanels[key] = false
                                    }
                                }
                                expandedPanels[index] = !isExpanded
                            }
                            .padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = panel.title,
                            style = MaterialTheme.typography.titleMedium,
                            modifier = Modifier.weight(1f)
                        )

                        val rotation by animateFloatAsState(
                            targetValue = if (isExpanded) 180f else 0f,
                            label = "accordion-arrow"
                        )
                        
                        Icon(
                            imageVector = Icons.Default.KeyboardArrowDown,
                            contentDescription = if (isExpanded) "Collapse" else "Expand",
                            modifier = Modifier.rotate(rotation)
                        )
                    }

                    // Panel content
                    AnimatedVisibility(visible = isExpanded) {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 16.dp, vertical = 8.dp)
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
