package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.StarHalf
import androidx.compose.material.icons.outlined.StarOutline
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.microsoft.adaptivecards.core.models.RatingDisplay
import com.microsoft.adaptivecards.core.models.RatingSize
import kotlin.math.ceil
import kotlin.math.floor

/**
 * Renders a RatingDisplay element (read-only star display)
 */
@Composable
fun RatingDisplayView(
    element: RatingDisplay,
    modifier: Modifier = Modifier
) {
    val maxStars = element.max ?: 5
    val starSize = when (element.size ?: RatingSize.MEDIUM) {
        RatingSize.SMALL -> 16.dp
        RatingSize.MEDIUM -> 24.dp
        RatingSize.LARGE -> 32.dp
    }
    
    val starColor = Color(0xFFFFC107) // Amber color for stars

    Column(modifier = modifier) {
        Row(
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Render stars
            Row {
                for (i in 1..maxStars) {
                    val starValue = element.value - (i - 1)
                    
                    Icon(
                        imageVector = when {
                            starValue >= 1.0 -> Icons.Filled.Star
                            starValue >= 0.5 -> Icons.Filled.StarHalf
                            else -> Icons.Outlined.StarOutline
                        },
                        contentDescription = null,
                        tint = if (starValue > 0) starColor else Color.Gray,
                        modifier = Modifier.size(starSize)
                    )
                }
            }

            // Display rating value
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = String.format("%.1f", element.value),
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
            )

            // Display count if available
            element.count?.let { count ->
                Spacer(modifier = Modifier.width(4.dp))
                Text(
                    text = "($count)",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f)
                )
            }
        }
    }
}
