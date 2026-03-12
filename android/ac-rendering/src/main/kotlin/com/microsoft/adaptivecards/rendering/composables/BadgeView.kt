package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.Icon as MaterialIcon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.microsoft.adaptivecards.core.models.Badge
import com.microsoft.adaptivecards.core.models.HorizontalAlignment

/**
 * Renders a Badge element — a styled label with optional icon, used for status indicators.
 *
 * Supports styles: Good (green), Attention (red), Warning (amber), Accent (blue), Default (gray).
 * Supports appearances: Tint (colored bg), Filled (solid bg).
 */
@Composable
fun BadgeView(
    element: Badge,
    modifier: Modifier = Modifier
) {
    val (bgColor, fgColor) = resolveBadgeColors(element.style, element.appearance)
    val fontSize = when (element.size?.lowercase()) {
        "small" -> 11.sp
        "large" -> 14.sp
        "extralarge" -> 16.sp
        else -> 12.sp
    }
    val paddingH = when (element.size?.lowercase()) {
        "large", "extralarge" -> 12.dp
        else -> 8.dp
    }
    val paddingV = when (element.size?.lowercase()) {
        "large", "extralarge" -> 6.dp
        else -> 4.dp
    }
    val shape = when (element.shape?.lowercase()) {
        "square" -> RoundedCornerShape(4.dp)
        "circular" -> RoundedCornerShape(50)
        else -> RoundedCornerShape(12.dp)
    }

    val alignment = when (element.horizontalAlignment) {
        HorizontalAlignment.Center -> Alignment.CenterHorizontally
        HorizontalAlignment.Right -> Alignment.End
        else -> Alignment.Start
    }

    Column(
        modifier = modifier,
        horizontalAlignment = alignment
    ) {
        Row(
            modifier = Modifier
                .clip(shape)
                .background(bgColor)
                .padding(horizontal = paddingH, vertical = paddingV),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            element.icon?.let { iconName ->
                val iconVector = resolveIconNameForBadge(iconName)
                MaterialIcon(
                    imageVector = iconVector,
                    contentDescription = null,
                    modifier = Modifier.size(14.dp),
                    tint = fgColor
                )
            }

            Text(
                text = element.text,
                color = fgColor,
                fontSize = fontSize,
                fontWeight = FontWeight.Medium
            )
        }
    }
}

private fun resolveBadgeColors(style: String?, appearance: String?): Pair<Color, Color> {
    val isTint = appearance?.lowercase() == "tint"

    return when (style?.lowercase()) {
        "good" -> if (isTint) {
            Pair(Color(0xFFDFF6DD), Color(0xFF107C10))
        } else {
            Pair(Color(0xFF107C10), Color.White)
        }
        "attention" -> if (isTint) {
            Pair(Color(0xFFFDE7E9), Color(0xFFC50F1F))
        } else {
            Pair(Color(0xFFC50F1F), Color.White)
        }
        "warning" -> if (isTint) {
            Pair(Color(0xFFFFF4CE), Color(0xFF835C00))
        } else {
            Pair(Color(0xFF835C00), Color.White)
        }
        "accent" -> if (isTint) {
            Pair(Color(0xFFEBF3FC), Color(0xFF0078D4))
        } else {
            Pair(Color(0xFF0078D4), Color.White)
        }
        else -> if (isTint) {
            Pair(Color(0xFFF0F0F0), Color(0xFF424242))
        } else {
            Pair(Color(0xFF424242), Color.White)
        }
    }
}

private fun resolveIconNameForBadge(name: String): ImageVector {
    return when (name.lowercase()) {
        "checkmarkcircle" -> Icons.Filled.CheckCircle
        "dismisscircle" -> Icons.Filled.Cancel
        "errorcircle" -> Icons.Filled.Error
        "warning" -> Icons.Filled.Warning
        "info" -> Icons.Filled.Info
        "star" -> Icons.Filled.Star
        "heart" -> Icons.Filled.Favorite
        "flag" -> Icons.Filled.Flag
        "clock" -> Icons.Outlined.Schedule
        else -> Icons.Outlined.Label
    }
}
