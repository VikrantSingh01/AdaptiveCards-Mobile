package com.microsoft.adaptivecards.sample

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PerformanceDashboardScreen() {
    var isRecording by remember { mutableStateOf(false) }
    val metrics = remember { PerformanceMetrics.sample() }

    Scaffold(
        topBar = {
            TopAppBar(title = { Text("Performance Dashboard") })
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .padding(padding)
                .fillMaxSize()
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Parse Performance
            MetricsSection("Parse Performance") {
                MetricRow("Average Parse Time", "${String.format("%.2f", metrics.avgParseTime)}ms", Trend.STABLE)
                MetricRow("Min Parse Time", "${String.format("%.2f", metrics.minParseTime)}ms", Trend.DOWN)
                MetricRow("Max Parse Time", "${String.format("%.2f", metrics.maxParseTime)}ms", Trend.UP)
                MetricRow("Cards Parsed", "${metrics.cardsParsed}", Trend.STABLE)
            }

            // Render Performance
            MetricsSection("Render Performance") {
                MetricRow("Average Render Time", "${String.format("%.2f", metrics.avgRenderTime)}ms", Trend.STABLE)
                MetricRow("Min Render Time", "${String.format("%.2f", metrics.minRenderTime)}ms", Trend.DOWN)
                MetricRow("Max Render Time", "${String.format("%.2f", metrics.maxRenderTime)}ms", Trend.UP)
                MetricRow("Cards Rendered", "${metrics.cardsRendered}", Trend.STABLE)
            }

            // Memory Usage
            MetricsSection("Memory Usage") {
                MetricRow("Current Usage", "${String.format("%.1f", metrics.currentMemoryMB)} MB", Trend.STABLE)
                MetricRow("Peak Usage", "${String.format("%.1f", metrics.peakMemoryMB)} MB", Trend.UP)
                MetricRow("Average Usage", "${String.format("%.1f", metrics.avgMemoryMB)} MB", Trend.STABLE)
            }

            // Actions
            MetricsSection("Actions") {
                MetricRow("Total Actions", "${metrics.totalActions}", Trend.UP)
                MetricRow("Success Rate", "${String.format("%.1f", metrics.actionSuccessRate * 100)}%", Trend.STABLE)
            }

            Spacer(modifier = Modifier.weight(1f))

            // Controls
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Button(
                    onClick = { isRecording = !isRecording },
                    modifier = Modifier.fillMaxWidth(),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = if (isRecording) 
                            MaterialTheme.colorScheme.error 
                        else 
                            MaterialTheme.colorScheme.primary
                    )
                ) {
                    Icon(
                        if (isRecording) Icons.Default.Stop else Icons.Default.PlayArrow,
                        null
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(if (isRecording) "Stop Recording" else "Start Recording")
                }

                OutlinedButton(
                    onClick = { /* Reset metrics */ },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("Reset Metrics")
                }

                OutlinedButton(
                    onClick = { /* Export report */ },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("Export Report")
                }
            }
        }
    }
}

@Composable
fun MetricsSection(
    title: String,
    content: @Composable ColumnScope.() -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                title,
                style = MaterialTheme.typography.titleMedium,
                modifier = Modifier.padding(bottom = 8.dp)
            )
            content()
        }
    }
}

@Composable
fun MetricRow(label: String, value: String, trend: Trend) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            label,
            style = MaterialTheme.typography.bodyMedium
        )
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
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
                    Trend.DOWN -> Color.Green
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

data class PerformanceMetrics(
    val avgParseTime: Double,
    val minParseTime: Double,
    val maxParseTime: Double,
    val avgRenderTime: Double,
    val minRenderTime: Double,
    val maxRenderTime: Double,
    val cardsParsed: Int,
    val cardsRendered: Int,
    val totalActions: Int,
    val actionSuccessRate: Double,
    val currentMemoryMB: Double,
    val peakMemoryMB: Double,
    val avgMemoryMB: Double
) {
    companion object {
        fun sample() = PerformanceMetrics(
            avgParseTime = 2.3,
            minParseTime = 1.2,
            maxParseTime = 4.5,
            avgRenderTime = 8.7,
            minRenderTime = 3.4,
            maxRenderTime = 15.6,
            cardsParsed = 127,
            cardsRendered = 127,
            totalActions = 45,
            actionSuccessRate = 0.978,
            currentMemoryMB = 18.5,
            peakMemoryMB = 24.3,
            avgMemoryMB = 16.8
        )
    }
}
