package com.microsoft.adaptivecards.sample

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import kotlin.system.measureTimeMillis

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CardDetailScreen(cardId: String, actionLogState: ActionLogState) {
    var showJson by remember { mutableStateOf(false) }
    var parseTime by remember { mutableStateOf(0L) }
    var renderTime by remember { mutableStateOf(0L) }
    
    val card = remember {
        TestCardLoader.loadAllCards().find { it.filename == cardId }
    }

    LaunchedEffect(Unit) {
        parseTime = measureTimeMillis {
            // Simulate parsing
            kotlinx.coroutines.delay(2)
        }
        renderTime = measureTimeMillis {
            // Simulate rendering
            kotlinx.coroutines.delay(5)
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(card?.title ?: "Card Detail") },
                navigationIcon = {
                    IconButton(onClick = { /* Navigate back */ }) {
                        Icon(Icons.Default.ArrowBack, "Back")
                    }
                },
                actions = {
                    IconButton(onClick = {
                        parseTime = 0
                        renderTime = 0
                    }) {
                        Icon(Icons.Default.Refresh, "Reload")
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .padding(padding)
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Preview section
            Text("Preview", style = MaterialTheme.typography.titleMedium)
            CardPreviewPlaceholder(card?.jsonString ?: "")

            // Performance metrics
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                MetricCard(
                    title = "Parse",
                    value = "${parseTime}ms",
                    modifier = Modifier.weight(1f)
                )
                MetricCard(
                    title = "Render",
                    value = "${renderTime}ms",
                    modifier = Modifier.weight(1f)
                )
            }

            // JSON toggle
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text("Show JSON", style = MaterialTheme.typography.titleMedium)
                Switch(checked = showJson, onCheckedChange = { showJson = it })
            }

            if (showJson) {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surfaceVariant
                    )
                ) {
                    Text(
                        text = card?.jsonString ?: "",
                        modifier = Modifier.padding(16.dp),
                        fontFamily = FontFamily.Monospace,
                        style = MaterialTheme.typography.bodySmall
                    )
                }
            }

            // Recent actions
            Text("Recent Actions", style = MaterialTheme.typography.titleMedium)
            if (actionLogState.actions.isEmpty()) {
                Text(
                    "No actions yet",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            } else {
                actionLogState.actions.take(5).forEach { action ->
                    ActionRow(action)
                }
            }
        }
    }
}

@Composable
fun CardPreviewPlaceholder(json: String) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f)
        )
    ) {
        Column(
            modifier = Modifier.padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(
                "Adaptive Card Preview",
                style = MaterialTheme.typography.titleLarge
            )
            Text(
                "Card rendering would appear here",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            
            // Placeholder shapes
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Box(
                    modifier = Modifier
                        .width(200.dp)
                        .height(20.dp)
                        .background(
                            MaterialTheme.colorScheme.primary.copy(alpha = 0.3f),
                            MaterialTheme.shapes.small
                        )
                )
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(16.dp)
                        .background(
                            MaterialTheme.colorScheme.onSurface.copy(alpha = 0.1f),
                            MaterialTheme.shapes.small
                        )
                )
                Box(
                    modifier = Modifier
                        .fillMaxWidth(0.7f)
                        .height(16.dp)
                        .background(
                            MaterialTheme.colorScheme.onSurface.copy(alpha = 0.1f),
                            MaterialTheme.shapes.small
                        )
                )
            }
        }
    }
}

@Composable
fun MetricCard(title: String, value: String, modifier: Modifier = Modifier) {
    Card(
        modifier = modifier,
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.primaryContainer
        )
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                title,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onPrimaryContainer
            )
            Text(
                value,
                style = MaterialTheme.typography.titleLarge,
                color = MaterialTheme.colorScheme.onPrimaryContainer
            )
        }
    }
}

@Composable
fun ActionRow(action: ActionLogEntry) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant
        )
    ) {
        Column(modifier = Modifier.padding(12.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    action.actionType,
                    style = MaterialTheme.typography.titleSmall
                )
                Text(
                    formatTime(action.timestamp),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            if (action.data.isNotEmpty()) {
                Text(
                    action.data.entries.joinToString(", ") { "${it.key}: ${it.value}" },
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

private fun formatTime(timestamp: Long): String {
    val date = java.util.Date(timestamp)
    val format = java.text.SimpleDateFormat("HH:mm:ss", java.util.Locale.getDefault())
    return format.format(date)
}
