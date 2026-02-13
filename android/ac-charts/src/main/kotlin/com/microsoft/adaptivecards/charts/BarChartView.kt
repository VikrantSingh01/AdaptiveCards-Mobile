package com.microsoft.adaptivecards.charts

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.horizontalScroll
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.BarChart

@Composable
fun BarChartView(chart: BarChart) {
    var selectedIndex by remember { mutableStateOf<Int?>(null) }
    var animationPlayed by remember { mutableStateOf(false) }
    val animationProgress by animateFloatAsState(
        targetValue = if (animationPlayed) 1f else 0f,
        animationSpec = tween(600),
        label = "bar_animation"
    )
    
    LaunchedEffect(Unit) {
        animationPlayed = true
    }
    
    val chartSize = ChartSize.from(chart.size)
    val colors = ChartColors.colors(chart.colors)
    val maxValue = chart.data.maxOfOrNull { it.value } ?: 1.0
    val isHorizontal = chart.orientation?.lowercase() == "horizontal"
    
    val accessibilityDesc = buildAccessibilityDescription(chart, isHorizontal)
    
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
        
        if (isHorizontal) {
            HorizontalBars(
                chart = chart,
                colors = colors,
                maxValue = maxValue,
                animationProgress = animationProgress,
                selectedIndex = selectedIndex,
                onBarTap = { index -> selectedIndex = if (selectedIndex == index) null else index }
            )
        } else {
            VerticalBars(
                chart = chart,
                colors = colors,
                maxValue = maxValue,
                animationProgress = animationProgress,
                selectedIndex = selectedIndex,
                onBarTap = { index -> selectedIndex = if (selectedIndex == index) null else index }
            )
        }
        
        if (chart.showLegend == true) {
            Spacer(modifier = Modifier.height(8.dp))
            Legend(chart = chart, colors = colors, selectedIndex = selectedIndex)
        }
    }
}

@Composable
private fun VerticalBars(
    chart: BarChart,
    colors: List<Color>,
    maxValue: Double,
    animationProgress: Float,
    selectedIndex: Int?,
    onBarTap: (Int) -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.Bottom
    ) {
        chart.data.forEachIndexed { index, dataPoint ->
            Column(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxHeight(),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Bottom
            ) {
                if (chart.showValues == true) {
                    Text(
                        text = dataPoint.value.toInt().toString(),
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                }
                
                val color = dataPoint.color?.let { 
                    ChartColors.colors(listOf(it)).firstOrNull() 
                } ?: colors[index % colors.size]
                
                val barHeight = ((dataPoint.value / maxValue).toFloat() * 0.8f * animationProgress)
                
                Canvas(
                    modifier = Modifier
                        .fillMaxWidth()
                        .fillMaxHeight(barHeight)
                        .pointerInput(Unit) {
                            detectTapGestures { onBarTap(index) }
                        }
                ) {
                    drawRoundRect(
                        color = if (selectedIndex == index) color.copy(alpha = 0.7f) else color,
                        size = size,
                        cornerRadius = CornerRadius(8f, 8f)
                    )
                }
                
                Spacer(modifier = Modifier.height(4.dp))
                
                Text(
                    text = dataPoint.label,
                    style = MaterialTheme.typography.bodySmall,
                    maxLines = 1
                )
            }
        }
    }
}

@Composable
private fun HorizontalBars(
    chart: BarChart,
    colors: List<Color>,
    maxValue: Double,
    animationProgress: Float,
    selectedIndex: Int?,
    onBarTap: (Int) -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 8.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        chart.data.forEachIndexed { index, dataPoint ->
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(32.dp)
                    .pointerInput(Unit) {
                        detectTapGestures { onBarTap(index) }
                    },
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = dataPoint.label,
                    style = MaterialTheme.typography.bodySmall,
                    modifier = Modifier.width(80.dp)
                )
                
                val color = dataPoint.color?.let { 
                    ChartColors.colors(listOf(it)).firstOrNull() 
                } ?: colors[index % colors.size]
                
                val barWidth = ((dataPoint.value / maxValue).toFloat() * animationProgress)
                
                Box(modifier = Modifier.weight(1f)) {
                    Canvas(
                        modifier = Modifier
                            .fillMaxWidth(barWidth)
                            .height(24.dp)
                    ) {
                        drawRoundRect(
                            color = if (selectedIndex == index) color.copy(alpha = 0.7f) else color,
                            size = size,
                            cornerRadius = CornerRadius(8f, 8f)
                        )
                    }
                }
                
                if (chart.showValues == true) {
                    Text(
                        text = dataPoint.value.toInt().toString(),
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.width(50.dp)
                    )
                }
            }
        }
    }
}

@Composable
private fun Legend(
    chart: BarChart,
    colors: List<Color>,
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
            val color = dataPoint.color?.let { 
                ChartColors.colors(listOf(it)).firstOrNull() 
            } ?: colors[index % colors.size]
            
            Row(
                modifier = Modifier.alpha(if (selectedIndex == null || selectedIndex == index) 1f else 0.5f),
                horizontalArrangement = Arrangement.spacedBy(4.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(12.dp)
                        .background(color, androidx.compose.foundation.shape.RoundedCornerShape(2.dp))
                )
                
                Text(
                    text = dataPoint.label,
                    style = MaterialTheme.typography.bodySmall
                )
            }
        }
    }
}

private fun buildAccessibilityDescription(chart: BarChart, isHorizontal: Boolean): String {
    val builder = StringBuilder()
    builder.append(if (isHorizontal) "Horizontal" else "Vertical")
    builder.append(" bar chart")
    chart.title?.let { builder.append(" titled $it") }
    builder.append(". ${chart.data.size} bars: ")
    
    val bars = chart.data.joinToString(", ") { dataPoint ->
        "${dataPoint.label} ${dataPoint.value.toInt()}"
    }
    builder.append(bars)
    
    return builder.toString()
}

