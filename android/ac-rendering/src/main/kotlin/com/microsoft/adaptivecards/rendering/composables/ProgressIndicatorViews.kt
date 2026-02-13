package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.ProgressBar
import com.microsoft.adaptivecards.core.models.Spinner
import com.microsoft.adaptivecards.core.models.SpinnerSize
import com.microsoft.adaptivecards.hostconfig.LocalHostConfig

/**
 * Renders a ProgressBar element
 * Accessibility: Announces progress percentage and label
 * Responsive: Adapts height and text size for tablets
 */
@Composable
fun ProgressBarView(
    element: ProgressBar,
    modifier: Modifier = Modifier
) {
    val hostConfig = LocalHostConfig.current
    val configuration = LocalConfiguration.current
    val isTablet = configuration.screenWidthDp >= 600
    
    val progressColor = element.color?.let { 
        try {
            Color(android.graphics.Color.parseColor(it))
        } catch (e: Exception) {
            try { Color(android.graphics.Color.parseColor(hostConfig.containerStyles.default.foregroundColors.accent.default)) } catch (e: Exception) { Color(0xFF0078D4) }
        }
    } ?: try { Color(android.graphics.Color.parseColor(hostConfig.containerStyles.default.foregroundColors.accent.default)) } catch (e: Exception) { Color(0xFF0078D4) }
    
    val percentage = (element.value * 100).toInt()
    
    Column(
        modifier = modifier
            .fillMaxWidth()
            .semantics {
                contentDescription = buildString {
                    element.label?.let { append("$it, ") }
                    append("Progress: $percentage percent")
                }
            }
    ) {
        // Label
        element.label?.let { label ->
            Text(
                text = label,
                style = if (isTablet) {
                    MaterialTheme.typography.bodyLarge
                } else {
                    MaterialTheme.typography.bodyMedium
                },
                modifier = Modifier.padding(bottom = if (isTablet) 6.dp else 4.dp)
            )
        }

        // Progress bar
        LinearProgressIndicator(
            progress = element.value.toFloat().coerceIn(0f, 1f),
            modifier = Modifier
                .fillMaxWidth()
                .height(if (isTablet) 10.dp else 8.dp),
            color = progressColor,
            trackColor = progressColor.copy(alpha = 0.2f)
        )

        // Percentage text
        Text(
            text = "$percentage%",
            style = if (isTablet) {
                MaterialTheme.typography.bodyMedium
            } else {
                MaterialTheme.typography.bodySmall
            },
            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f),
            modifier = Modifier.padding(top = if (isTablet) 6.dp else 4.dp)
        )
    }
}

/**
 * Renders a Spinner element (circular progress indicator)
 * Accessibility: Announces loading state with label
 * Responsive: Adapts spinner size and spacing for tablets
 */
@Composable
fun SpinnerView(
    element: Spinner,
    modifier: Modifier = Modifier
) {
    val hostConfig = LocalHostConfig.current
    val configuration = LocalConfiguration.current
    val isTablet = configuration.screenWidthDp >= 600
    
    val baseSize = when (element.size ?: SpinnerSize.MEDIUM) {
        SpinnerSize.SMALL -> 24.dp
        SpinnerSize.MEDIUM -> 40.dp
        SpinnerSize.LARGE -> 56.dp
    }
    val size = if (isTablet) baseSize + 8.dp else baseSize
    
    val strokeWidth = when (element.size ?: SpinnerSize.MEDIUM) {
        SpinnerSize.SMALL -> if (isTablet) 3.dp else 2.dp
        SpinnerSize.MEDIUM -> if (isTablet) 4.dp else 3.dp
        SpinnerSize.LARGE -> if (isTablet) 5.dp else 4.dp
    }

    Column(
        modifier = modifier.semantics {
            contentDescription = buildString {
                append("Loading")
                element.label?.let { append(": $it") }
            }
        },
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        CircularProgressIndicator(
            modifier = Modifier.size(size),
            color = try { Color(android.graphics.Color.parseColor(hostConfig.containerStyles.default.foregroundColors.accent.default)) } catch (e: Exception) { Color(0xFF0078D4) },
            strokeWidth = strokeWidth
        )

        // Label
        element.label?.let { label ->
            Spacer(modifier = Modifier.height(if (isTablet) 12.dp else 8.dp))
            Text(
                text = label,
                style = if (isTablet) {
                    MaterialTheme.typography.bodyMedium
                } else {
                    MaterialTheme.typography.bodySmall
                },
                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
            )
        }
    }
}
