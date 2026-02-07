package com.microsoft.adaptivecards.charts

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.horizontalScroll
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.LineChart
import kotlin.math.roundToInt

@Composable
fun LineChartView(chart: LineChart) {
    var selectedIndex by remember { mutableStateOf<Int?>(null) }
    var animationPlayed by remember { mutableStateOf(false) }
    val animationProgress by animateFloatAsState(
        targetValue = if (animationPlayed) 1f else 0f,
        animationSpec = tween(800),
        label = "line_animation"
    )
    
    LaunchedEffect(Unit) {
        animationPlayed = true
    }
    
    val chartSize = ChartSize.from(chart.size)
    val colors = ChartColors.colors(chart.colors)
    val maxValue = chart.data.maxOfOrNull { it.value } ?: 1.0
    val minValue = chart.data.minOfOrNull { it.value } ?: 0.0
    
    val accessibilityDesc = buildAccessibilityDescription(chart)
    
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .height(chartSize.heightDp.dp)
            .semantics { contentDescription = accessibilityDesc }
    ) {
        chart.title?.let { title ->
            Text(
                text = title,
                style = MaterialTheme.typography.titleMedium,
                modifier = Modifier.padding(bottom = 12.dp)
            )
        }
        
        Canvas(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f)
                .pointerInput(Unit) {
                    detectDragGestures(
                        onDragStart = { offset ->
                            selectedIndex = findNearestPoint(offset.x, size.width.toFloat(), chart.data.size)
                        },
                        onDrag = { change, _ ->
                            selectedIndex = findNearestPoint(change.position.x, size.width.toFloat(), chart.data.size)
                        },
                        onDragEnd = { selectedIndex = null }
                    )
                }
        ) {
            val padding = 40f
            val availableWidth = size.width - padding * 2
            val availableHeight = size.height - padding * 2
            val valueRange = (maxValue - minValue).coerceAtLeast(0.001)
            
            // Draw grid lines
            val gridColor = Color.Gray.copy(alpha = 0.2f)
            for (i in 0..4) {
                val y = padding + (availableHeight * i / 4)
                drawLine(
                    color = gridColor,
                    start = Offset(padding, y),
                    end = Offset(size.width - padding, y),
                    strokeWidth = 1f
                )
            }
            
            if (chart.data.size < 2) return@Canvas
            
            // Calculate points
            val points = chart.data.mapIndexed { index, dataPoint ->
                val x = padding + (availableWidth * index / (chart.data.size - 1))
                val normalizedValue = ((dataPoint.value - minValue) / valueRange).toFloat()
                val y = size.height - padding - (availableHeight * normalizedValue)
                Offset(x, y)
            }
            
            // Draw line path
            val path = Path()
            val visiblePointsCount = (points.size * animationProgress).roundToInt().coerceAtLeast(1)
            val visiblePoints = points.take(visiblePointsCount)
            
            if (visiblePoints.isNotEmpty()) {
                path.moveTo(visiblePoints.first().x, visiblePoints.first().y)
                
                if (chart.smooth == true) {
                    // Smooth curve
                    for (i in 0 until visiblePoints.size - 1) {
                        val current = visiblePoints[i]
                        val next = visiblePoints[i + 1]
                        val controlPoint1 = Offset(
                            current.x + (next.x - current.x) * 0.4f,
                            current.y
                        )
                        val controlPoint2 = Offset(
                            current.x + (next.x - current.x) * 0.6f,
                            next.y
                        )
                        path.cubicTo(
                            controlPoint1.x, controlPoint1.y,
                            controlPoint2.x, controlPoint2.y,
                            next.x, next.y
                        )
                    }
                } else {
                    // Straight lines
                    for (point in visiblePoints.drop(1)) {
                        path.lineTo(point.x, point.y)
                    }
                }
            }
            
            val lineColor = colors.firstOrNull() ?: Color.Blue
            drawPath(
                path = path,
                color = lineColor,
                style = Stroke(width = 4f, cap = StrokeCap.Round)
            )
            
            // Draw data points if enabled
            if (chart.showDataPoints != false) {
                visiblePoints.forEachIndexed { index, point ->
                    val dotColor = if (selectedIndex == index) lineColor.copy(alpha = 0.5f) else lineColor
                    drawCircle(
                        color = dotColor,
                        radius = 8f,
                        center = point
                    )
                }
            }
        }
        
        if (chart.showLegend == true) {
            Spacer(modifier = Modifier.height(8.dp))
            Legend(chart = chart, selectedIndex = selectedIndex)
        }
    }
}

@Composable
private fun Legend(
    chart: LineChart,
    selectedIndex: Int?
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .horizontalScroll(rememberScrollState())
            .padding(horizontal = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        chart.data.forEachIndexed { index, dataPoint ->
            Column(
                modifier = Modifier.alpha(if (selectedIndex == null || selectedIndex == index) 1f else 0.5f),
                horizontalAlignment = Alignment.Start
            ) {
                Text(
                    text = dataPoint.label,
                    style = MaterialTheme.typography.bodySmall
                )
                Text(
                    text = String.format("%.1f", dataPoint.value),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

private fun findNearestPoint(x: Float, width: Float, pointCount: Int): Int? {
    if (pointCount < 2) return null
    val padding = 40f
    val availableWidth = width - padding * 2
    val relativeX = x - padding
    val segmentWidth = availableWidth / (pointCount - 1)
    val index = (relativeX / segmentWidth).roundToInt()
    return index.coerceIn(0, pointCount - 1)
}

private fun buildAccessibilityDescription(chart: LineChart): String {
    val builder = StringBuilder("Line chart")
    chart.title?.let { builder.append(" titled $it") }
    builder.append(". ${chart.data.size} data points: ")
    
    val points = chart.data.joinToString(", ") { dataPoint ->
        "${dataPoint.label} ${String.format("%.1f", dataPoint.value)}"
    }
    builder.append(points)
    
    return builder.toString()
}

private fun Modifier.alpha(alpha: Float): Modifier = this.then(
    androidx.compose.ui.graphics.graphicsLayer(alpha = alpha)
)
