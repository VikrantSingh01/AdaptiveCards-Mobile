package com.microsoft.adaptivecards.charts

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.DonutChart
import kotlin.math.*

@Composable
fun DonutChartView(chart: DonutChart) {
    var selectedIndex by remember { mutableStateOf<Int?>(null) }
    var animationPlayed by remember { mutableStateOf(false) }
    val animationProgress by animateFloatAsState(
        targetValue = if (animationPlayed) 1f else 0f,
        animationSpec = tween(800),
        label = "donut_animation"
    )
    
    LaunchedEffect(Unit) {
        animationPlayed = true
    }
    
    val chartSize = ChartSize.from(chart.size)
    val colors = ChartColors.colors(chart.colors)
    val total = chart.data.sumOf { it.value }
    val innerRadiusRatio = chart.innerRadiusRatio?.toFloat() ?: 0.5f
    
    val accessibilityDesc = buildAccessibilityDescription(chart, total)
    
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .semantics { contentDescription = accessibilityDesc }
    ) {
        chart.title?.let { title ->
            Text(
                text = title,
                style = MaterialTheme.typography.titleMedium,
                modifier = Modifier.padding(bottom = 12.dp)
            )
        }
        
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(chartSize.heightDp.dp),
            horizontalArrangement = Arrangement.spacedBy(20.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Donut Chart
            Box(
                modifier = Modifier
                    .weight(1f)
                    .aspectRatio(1f)
            ) {
                Canvas(
                    modifier = Modifier
                        .fillMaxSize()
                        .pointerInput(Unit) {
                            detectTapGestures { offset ->
                                val center = Offset(size.width / 2f, size.height / 2f)
                                val dx = offset.x - center.x
                                val dy = offset.y - center.y
                                val distance = sqrt(dx * dx + dy * dy)
                                val radius = size.width.coerceAtMost(size.height) / 2f
                                
                                if (distance <= radius && distance >= radius * innerRadiusRatio) {
                                    var angle = (atan2(dy, dx) + PI / 2).toFloat()
                                    if (angle < 0) angle += (2 * PI).toFloat()
                                    
                                    var startAngle = 0f
                                    for ((index, dataPoint) in chart.data.withIndex()) {
                                        val percentage = (dataPoint.value / total).toFloat()
                                        val sweepAngle = 360f * percentage
                                        val endAngle = startAngle + sweepAngle
                                        
                                        if (angle >= startAngle * PI.toFloat() / 180 && 
                                            angle < endAngle * PI.toFloat() / 180) {
                                            selectedIndex = if (selectedIndex == index) null else index
                                            break
                                        }
                                        startAngle = endAngle
                                    }
                                }
                            }
                        }
                ) {
                    val canvasSize = size.width.coerceAtMost(size.height)
                    val radius = canvasSize / 2f
                    val strokeWidth = radius * (1 - innerRadiusRatio)
                    val center = Offset(size.width / 2f, size.height / 2f)
                    
                    var startAngle = -90f
                    
                    chart.data.forEachIndexed { index, dataPoint ->
                        val percentage = (dataPoint.value / total).toFloat()
                        val sweepAngle = 360f * percentage * animationProgress
                        
                        val color = dataPoint.color?.let { 
                            ChartColors.colors(listOf(it)).firstOrNull() 
                        } ?: colors[index % colors.size]
                        
                        val adjustedColor = if (selectedIndex == index) {
                            color.copy(alpha = 0.7f)
                        } else {
                            color
                        }
                        
                        drawArc(
                            color = adjustedColor,
                            startAngle = startAngle,
                            sweepAngle = sweepAngle,
                            useCenter = false,
                            topLeft = Offset(
                                center.x - radius + strokeWidth / 2,
                                center.y - radius + strokeWidth / 2
                            ),
                            size = Size(
                                (radius - strokeWidth / 2) * 2,
                                (radius - strokeWidth / 2) * 2
                            ),
                            style = Stroke(width = strokeWidth)
                        )
                        
                        startAngle += sweepAngle
                    }
                }
            }
            
            // Legend
            if (chart.showLegend != false) {
                Column(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    chart.data.forEachIndexed { index, dataPoint ->
                        val color = dataPoint.color?.let { 
                            ChartColors.colors(listOf(it)).firstOrNull() 
                        } ?: colors[index % colors.size]
                        val percentage = (dataPoint.value / total * 100).toInt()
                        
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .alpha(if (selectedIndex == null || selectedIndex == index) 1f else 0.5f),
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(16.dp)
                                    .background(color, shape = androidx.compose.foundation.shape.RoundedCornerShape(2.dp))
                            )
                            
                            Text(
                                text = dataPoint.label,
                                style = MaterialTheme.typography.bodySmall,
                                modifier = Modifier.weight(1f)
                            )
                            
                            Text(
                                text = "$percentage%",
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                }
            }
        }
    }
}

private fun buildAccessibilityDescription(chart: DonutChart, total: Double): String {
    val builder = StringBuilder("Donut chart")
    chart.title?.let { builder.append(" titled $it") }
    builder.append(". ${chart.data.size} segments: ")
    
    val segments = chart.data.joinToString(", ") { dataPoint ->
        val percentage = (dataPoint.value / total * 100).toInt()
        "${dataPoint.label} $percentage%"
    }
    builder.append(segments)
    
    return builder.toString()
}

private fun Modifier.alpha(alpha: Float): Modifier = this.then(
    androidx.compose.ui.graphics.graphicsLayer(alpha = alpha)
)

private fun Modifier.background(color: Color, shape: androidx.compose.ui.graphics.Shape): Modifier = this.then(
    androidx.compose.foundation.background(color, shape)
)
