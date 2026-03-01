package com.microsoft.adaptivecards.copilot

import androidx.compose.animation.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage

/**
 * Jetpack Compose view for rendering Chain of Thought UX.
 *
 * Ported from production Teams-AdaptiveCards-Mobile SDK.
 * Shows the reasoning steps Copilot goes through while processing a request.
 */
@Composable
fun ChainOfThoughtView(
    data: ChainOfThoughtData,
    modifier: Modifier = Modifier,
    onHeightChange: (() -> Unit)? = null
) {
    var expandedSteps by remember { mutableStateOf(setOf(0)) }

    Column(
        modifier = modifier
            .fillMaxWidth()
            .shadow(4.dp, RoundedCornerShape(12.dp))
            .clip(RoundedCornerShape(12.dp))
            .background(MaterialTheme.colorScheme.surface)
            .padding(16.dp)
    ) {
        // Header
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(
                    MaterialTheme.colorScheme.surfaceVariant,
                    RoundedCornerShape(8.dp)
                )
                .padding(horizontal = 16.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = androidx.compose.material.icons.Icons.Default.Settings,
                contentDescription = "Thinking",
                tint = MaterialTheme.colorScheme.primary,
                modifier = Modifier.size(16.dp)
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = data.state,
                style = MaterialTheme.typography.titleSmall,
                fontWeight = FontWeight.Medium
            )
        }

        Spacer(modifier = Modifier.height(8.dp))

        // Entries
        data.entries.forEachIndexed { index, entry ->
            ChainOfThoughtEntryView(
                entry = entry,
                isCompleted = data.isDone || index < data.entries.size - 1,
                isLast = index == data.entries.size - 1,
                isExpanded = expandedSteps.contains(index),
                onToggleExpanded = {
                    onHeightChange?.invoke()
                    expandedSteps = if (expandedSteps.contains(index)) {
                        expandedSteps - index
                    } else {
                        expandedSteps + index
                    }
                }
            )
        }
    }
}

@Composable
private fun ChainOfThoughtEntryView(
    entry: ChainOfThoughtEntry,
    isCompleted: Boolean,
    isLast: Boolean,
    isExpanded: Boolean,
    onToggleExpanded: () -> Unit
) {
    Column(modifier = Modifier.fillMaxWidth()) {
        // Header row
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clickable { onToggleExpanded() }
                .padding(vertical = 8.dp),
            verticalAlignment = Alignment.Top
        ) {
            // Status indicator
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.width(12.dp)
            ) {
                Box(
                    modifier = Modifier
                        .size(12.dp)
                        .clip(CircleShape)
                        .background(if (isCompleted) Color(0xFF4CAF50) else Color(0xFFFF9800)),
                    contentAlignment = Alignment.Center
                ) {
                    if (isCompleted) {
                        Text("✓", fontSize = 8.sp, color = Color.White, fontWeight = FontWeight.Bold)
                    }
                }

                if (!isLast) {
                    Spacer(modifier = Modifier.height(4.dp))
                    Box(
                        modifier = Modifier
                            .width(2.dp)
                            .height(24.dp)
                            .background(Color.Gray.copy(alpha = 0.3f))
                    )
                }
            }

            Spacer(modifier = Modifier.width(12.dp))

            // Content
            Column(modifier = Modifier.weight(1f)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = entry.header,
                        style = MaterialTheme.typography.bodyMedium,
                        fontWeight = FontWeight.SemiBold,
                        modifier = Modifier.weight(1f)
                    )

                    // App info
                    entry.appInfo?.let { appInfo ->
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier.padding(start = 8.dp)
                        ) {
                            AsyncImage(
                                model = appInfo.icon,
                                contentDescription = appInfo.name,
                                modifier = Modifier.size(16.dp),
                                contentScale = ContentScale.Fit
                            )
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(
                                text = appInfo.name,
                                style = MaterialTheme.typography.labelSmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }

                    // Chevron
                    Text(
                        text = if (isExpanded) "▲" else "▼",
                        fontSize = 12.sp,
                        color = Color.Gray,
                        modifier = Modifier.padding(start = 8.dp)
                    )
                }
            }
        }

        // Expanded content
        AnimatedVisibility(visible = isExpanded) {
            Row(modifier = Modifier.padding(start = 24.dp, bottom = 8.dp)) {
                Text(
                    text = entry.content,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}
