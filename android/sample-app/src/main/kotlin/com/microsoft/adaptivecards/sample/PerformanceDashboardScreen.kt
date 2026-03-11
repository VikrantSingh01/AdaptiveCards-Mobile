package com.microsoft.adaptivecards.sample

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PerformanceDashboardScreen(
    navController: androidx.navigation.NavController,
    perfStore: PerformanceStore,
    actionLogState: ActionLogState
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Performance") },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, "Back")
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
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            if (perfStore.cardsParsed == 0) {
                // Empty state
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 40.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Icon(
                        Icons.Default.BarChart,
                        contentDescription = null,
                        modifier = Modifier.size(48.dp),
                        tint = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Spacer(modifier = Modifier.height(12.dp))
                    Text("No data yet", style = MaterialTheme.typography.titleMedium)
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        "Browse cards in the gallery to collect real parse and render metrics.",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            } else {
                PerfMetricsSection("Parse Performance", Icons.Default.Description, Color(0xFF1976D2)) {
                    PerfMetricRow("Average", "${String.format("%.2f", perfStore.avgParseTimeMs)}ms", Trend.STABLE)
                    PerfMetricRow("Min", "${String.format("%.2f", perfStore.minParseTimeMs)}ms", Trend.DOWN)
                    PerfMetricRow("Max", "${String.format("%.2f", perfStore.maxParseTimeMs)}ms", Trend.UP)
                    PerfMetricRow("Total Parsed", "${perfStore.cardsParsed}", Trend.STABLE)
                }

                PerfMetricsSection("Render Performance", Icons.Default.Brush, Color(0xFF7B1FA2)) {
                    PerfMetricRow("Average", "${String.format("%.2f", perfStore.avgRenderTimeMs)}ms", Trend.STABLE)
                    PerfMetricRow("Min", "${String.format("%.2f", perfStore.minRenderTimeMs)}ms", Trend.DOWN)
                    PerfMetricRow("Max", "${String.format("%.2f", perfStore.maxRenderTimeMs)}ms", Trend.UP)
                    PerfMetricRow("Total Rendered", "${perfStore.cardsRendered}", Trend.STABLE)
                }

                PerfMetricsSection("Memory Usage", Icons.Default.Memory, Color(0xFFFF9800)) {
                    PerfMetricRow("Current", "${String.format("%.1f", perfStore.currentMemoryMB)} MB", Trend.STABLE)
                    PerfMetricRow("Peak", "${String.format("%.1f", perfStore.peakMemoryMB)} MB", Trend.UP)
                }

                PerfMetricsSection("Actions", Icons.Default.FlashOn, Color(0xFF388E3C)) {
                    PerfMetricRow("Total", "${actionLogState.actions.size}", Trend.STABLE)
                }
            }

            Spacer(modifier = Modifier.height(4.dp))

            // Reset button
            OutlinedButton(
                onClick = { perfStore.reset() },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.outlinedButtonColors(
                    contentColor = MaterialTheme.colorScheme.error
                )
            ) {
                Icon(Icons.Default.Delete, null, modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(8.dp))
                Text("Reset All Metrics")
            }
        }
    }
}

@Composable
fun PerfMetricsSection(
    title: String,
    icon: ImageVector,
    color: Color,
    content: @Composable ColumnScope.() -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(14.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                modifier = Modifier.padding(bottom = 10.dp)
            ) {
                Icon(
                    icon,
                    contentDescription = null,
                    tint = color,
                    modifier = Modifier.size(20.dp)
                )
                Text(
                    title,
                    style = MaterialTheme.typography.titleSmall,
                    color = color
                )
            }
            content()
        }
    }
}

@Composable
fun PerfMetricRow(label: String, value: String, trend: Trend) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            label,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Row(
            horizontalArrangement = Arrangement.spacedBy(6.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                value,
                style = MaterialTheme.typography.bodyLarge
            )
            Icon(
                imageVector = when (trend) {
                    Trend.UP -> Icons.Default.TrendingUp
                    Trend.DOWN -> Icons.Default.TrendingDown
                    Trend.STABLE -> Icons.Default.TrendingFlat
                },
                contentDescription = null,
                tint = when (trend) {
                    Trend.UP -> Color.Red
                    Trend.DOWN -> Color(0xFF388E3C)
                    Trend.STABLE -> Color.Gray
                },
                modifier = Modifier.size(16.dp)
            )
        }
    }
}

enum class Trend {
    UP, DOWN, STABLE
}
