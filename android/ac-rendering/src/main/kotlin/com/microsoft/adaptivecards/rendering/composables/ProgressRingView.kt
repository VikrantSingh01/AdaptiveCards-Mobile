// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.*
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.HorizontalAlignment
import com.microsoft.adaptivecards.core.models.ProgressRing
import com.microsoft.adaptivecards.rendering.theme.LocalHostConfig

@Composable
fun ProgressRingView(
    element: ProgressRing,
    modifier: Modifier = Modifier
) {
    val hostConfig = LocalHostConfig.current

    val ringSize = when (element.size?.lowercase()) {
        "tiny" -> 16.dp
        "small" -> 24.dp
        "large" -> 48.dp
        else -> 32.dp
    }

    val lineWidth = when (element.size?.lowercase()) {
        "tiny" -> 2.dp
        "small" -> 3.dp
        "large" -> 5.dp
        else -> 4.dp
    }

    val ringColor = resolveProgressRingColor(element.color, hostConfig)
    val labelPosition = element.labelPosition?.lowercase() ?: "above"

    val alignment = when (element.horizontalAlignment) {
        HorizontalAlignment.Center -> Alignment.CenterHorizontally
        HorizontalAlignment.Right -> Alignment.End
        else -> Alignment.Start
    }

    val infiniteTransition = rememberInfiniteTransition(label = "ring")
    val rotation by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 1000, easing = LinearEasing)
        ),
        label = "rotation"
    )

    val ring: @Composable () -> Unit = {
        Canvas(modifier = Modifier.size(ringSize)) {
            drawArc(
                color = ringColor,
                startAngle = rotation - 90f,
                sweepAngle = 270f,
                useCenter = false,
                style = Stroke(width = lineWidth.toPx(), cap = StrokeCap.Round)
            )
        }
    }

    val label: @Composable () -> Unit = {
        element.label?.let { text ->
            Text(
                text = text,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
            )
        }
    }

    Column(
        horizontalAlignment = alignment,
        modifier = modifier
            .fillMaxWidth()
            .semantics {
                contentDescription = element.label ?: "Loading"
            }
    ) {
        when (labelPosition) {
            "below" -> {
                ring()
                Spacer(modifier = Modifier.height(4.dp))
                label()
            }
            "before" -> {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    label()
                    Spacer(modifier = Modifier.width(8.dp))
                    ring()
                }
            }
            "after" -> {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    ring()
                    Spacer(modifier = Modifier.width(8.dp))
                    label()
                }
            }
            else -> { // "above"
                label()
                Spacer(modifier = Modifier.height(4.dp))
                ring()
            }
        }
    }
}

private fun resolveProgressRingColor(
    color: String?,
    hostConfig: com.microsoft.adaptivecards.core.hostconfig.HostConfig
): Color {
    if (color == null) {
        return try {
            Color(android.graphics.Color.parseColor(hostConfig.containerStyles.default.foregroundColors.accent.default))
        } catch (_: Exception) { Color(0xFF0078D4) }
    }
    val fg = hostConfig.containerStyles.default.foregroundColors
    val hex = when (color.lowercase()) {
        "default" -> fg.default.default
        "dark" -> fg.dark.default
        "light" -> fg.light.default
        "accent" -> fg.accent.default
        "good", "green" -> fg.good.default
        "warning", "yellow" -> fg.warning.default
        "attention", "red" -> fg.attention.default
        else -> color
    }
    return try {
        Color(android.graphics.Color.parseColor(hex))
    } catch (_: Exception) { Color(0xFF0078D4) }
}
