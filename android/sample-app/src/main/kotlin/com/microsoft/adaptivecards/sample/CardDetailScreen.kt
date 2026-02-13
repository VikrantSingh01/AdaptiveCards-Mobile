package com.microsoft.adaptivecards.sample

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
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.microsoft.adaptivecards.core.parsing.CardParser
import com.microsoft.adaptivecards.rendering.composables.AdaptiveCardView
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel
import kotlin.system.measureTimeMillis

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CardDetailScreen(cardId: String, actionLogState: ActionLogState) {
    var showJson by remember { mutableStateOf(false) }
    var parseTime by remember { mutableStateOf(0L) }
    var renderTime by remember { mutableStateOf(0L) }
    var refreshKey by remember { mutableStateOf(0) }

    val context = LocalContext.current
    val card = remember {
        TestCardLoader.loadAllCards(context).find { it.filename == cardId }
    }
    val cardViewModel: CardViewModel = viewModel(key = "detail_${cardId}_$refreshKey")

    LaunchedEffect(card, refreshKey) {
        card?.let {
            parseTime = measureTimeMillis {
                CardParser.parse(it.jsonString)
            }
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
                        refreshKey++
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
            // Preview section - render the actual card
            Text("Preview", style = MaterialTheme.typography.titleMedium)
            Card(
                modifier = Modifier.fillMaxWidth(),
                elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
            ) {
                val startTime = remember { System.currentTimeMillis() }
                AdaptiveCardView(
                    cardJson = card?.jsonString ?: "",
                    modifier = Modifier.padding(12.dp),
                    viewModel = cardViewModel
                )
                LaunchedEffect(Unit) {
                    renderTime = System.currentTimeMillis() - startTime
                }
            }

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
