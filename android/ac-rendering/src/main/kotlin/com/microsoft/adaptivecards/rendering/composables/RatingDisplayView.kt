package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.StarHalf
import androidx.compose.material.icons.outlined.StarBorder
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.RatingDisplay
import com.microsoft.adaptivecards.core.models.RatingSize
import kotlin.math.ceil
import kotlin.math.floor

/**
 * Renders a RatingDisplay element (read-only star display)
 * Accessibility: Announces rating value and count
 * Responsive: Adapts star size and spacing for tablets
 */
@Composable
fun RatingDisplayView(
    element: RatingDisplay,
    modifier: Modifier = Modifier
) {
    val configuration = LocalConfiguration.current
    val isTablet = configuration.screenWidthDp >= 600
    
    val maxStars = element.max ?: 5
    val baseStarSize = when (element.size ?: RatingSize.MEDIUM) {
        RatingSize.SMALL -> 16.dp
        RatingSize.MEDIUM -> 24.dp
        RatingSize.LARGE -> 32.dp
    }
    val starSize = if (isTablet) baseStarSize + 4.dp else baseStarSize
    
    val starColor = Color(0xFFFFC107) // Amber color for stars
    
    val ratingDescription = buildString {
        append("Rating: ${String.format("%.1f", element.value)} out of $maxStars stars")
        element.count?.let { count ->
            append(", $count reviews")
        }
    }

    Column(
        modifier = modifier.semantics {
            contentDescription = ratingDescription
        }
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Render stars
            Row(
                modifier = Modifier.semantics {
                    contentDescription = "${String.format("%.1f", element.value)} stars out of $maxStars"
                }
            ) {
                for (i in 1..maxStars) {
                    val starValue = element.value - (i - 1)
                    
                    Icon(
                        imageVector = when {
                            starValue >= 1.0 -> Icons.Filled.Star
                            starValue >= 0.5 -> Icons.Filled.StarHalf
                            else -> Icons.Outlined.StarBorder
                        },
                        contentDescription = when {
                            starValue >= 1.0 -> "Filled star"
                            starValue >= 0.5 -> "Half star"
                            else -> "Empty star"
                        },
                        tint = if (starValue > 0) starColor else Color.Gray,
                        modifier = Modifier
                            .size(starSize)
                            .padding(horizontal = if (isTablet) 2.dp else 1.dp)
                    )
                }
            }

            // Display rating value
            Spacer(modifier = Modifier.width(if (isTablet) 12.dp else 8.dp))
            Text(
                text = String.format("%.1f", element.value),
                style = if (isTablet) {
                    MaterialTheme.typography.bodyLarge
                } else {
                    MaterialTheme.typography.bodyMedium
                },
                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
            )

            // Display count if available
            element.count?.let { count ->
                Spacer(modifier = Modifier.width(4.dp))
                Text(
                    text = "($count)",
                    style = if (isTablet) {
                        MaterialTheme.typography.bodyMedium
                    } else {
                        MaterialTheme.typography.bodySmall
                    },
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f),
                    modifier = Modifier.semantics {
                        contentDescription = "$count reviews"
                    }
                )
            }
        }
    }
}
