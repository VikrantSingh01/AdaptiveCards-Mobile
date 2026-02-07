package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.ProgressBar
import com.microsoft.adaptivecards.core.models.Spinner
import com.microsoft.adaptivecards.core.models.SpinnerSize
import com.microsoft.adaptivecards.hostconfig.LocalHostConfig

/**
 * Renders a ProgressBar element
 */
@Composable
fun ProgressBarView(
    element: ProgressBar,
    modifier: Modifier = Modifier
) {
    val hostConfig = LocalHostConfig.current
    val progressColor = element.color?.let { 
        try {
            Color(android.graphics.Color.parseColor(it))
        } catch (e: Exception) {
            Color(hostConfig.colors.accent.default)
        }
    } ?: Color(hostConfig.colors.accent.default)

    Column(modifier = modifier.fillMaxWidth()) {
        // Label
        element.label?.let { label ->
            Text(
                text = label,
                style = MaterialTheme.typography.bodyMedium,
                modifier = Modifier.padding(bottom = 4.dp)
            )
        }

        // Progress bar
        LinearProgressIndicator(
            progress = element.value.toFloat().coerceIn(0f, 1f),
            modifier = Modifier
                .fillMaxWidth()
                .height(8.dp),
            color = progressColor,
            trackColor = progressColor.copy(alpha = 0.2f)
        )

        // Percentage text
        Text(
            text = "${(element.value * 100).toInt()}%",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f),
            modifier = Modifier.padding(top = 4.dp)
        )
    }
}

/**
 * Renders a Spinner element (circular progress indicator)
 */
@Composable
fun SpinnerView(
    element: Spinner,
    modifier: Modifier = Modifier
) {
    val hostConfig = LocalHostConfig.current
    val size = when (element.size ?: SpinnerSize.MEDIUM) {
        SpinnerSize.SMALL -> 24.dp
        SpinnerSize.MEDIUM -> 40.dp
        SpinnerSize.LARGE -> 56.dp
    }

    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        CircularProgressIndicator(
            modifier = Modifier.size(size),
            color = Color(hostConfig.colors.accent.default),
            strokeWidth = when (element.size ?: SpinnerSize.MEDIUM) {
                SpinnerSize.SMALL -> 2.dp
                SpinnerSize.MEDIUM -> 3.dp
                SpinnerSize.LARGE -> 4.dp
            }
        )

        // Label
        element.label?.let { label ->
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = label,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
            )
        }
    }
}
