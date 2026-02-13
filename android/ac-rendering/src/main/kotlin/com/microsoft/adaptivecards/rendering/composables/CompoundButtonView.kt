package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import coil.request.ImageRequest
import com.microsoft.adaptivecards.core.models.CompoundButton
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler

// Layout constants for consistency
private object CompoundButtonLayout {
    val IconSize = 24.dp
    val IconTextSpacing = 12.dp
    val TitleSubtitleSpacing = 4.dp
    val HorizontalPadding = 16.dp
    val VerticalPadding = 12.dp
    val CornerRadius = 8.dp
    val MinHeight = 48.dp
    val Elevation = 2.dp
}

/**
 * Renders a CompoundButton element with icon, title, and subtitle
 */
@OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class)
@Composable
fun CompoundButtonView(
    element: CompoundButton,
    actionHandler: ActionHandler,
    modifier: Modifier = Modifier
) {
    val containerColor = when (element.style) {
        "emphasis" -> MaterialTheme.colorScheme.primary
        "positive" -> Color(0xFF4CAF50) // Green
        "destructive" -> Color(0xFFF44336) // Red
        else -> MaterialTheme.colorScheme.surface
    }
    
    val contentColor = when (element.style) {
        "emphasis", "positive", "destructive" -> Color.White
        else -> MaterialTheme.colorScheme.onSurface
    }
    
    val isEnabled = element.action != null
    
    val contentDesc = buildString {
        append(element.title)
        element.subtitle?.let { append(". $it") }
    }
    
    Card(
        onClick = {
            element.action?.let { action ->
                when (action) {
                    is com.microsoft.adaptivecards.core.models.ActionOpenUrl -> actionHandler.onOpenUrl(action.url)
                    is com.microsoft.adaptivecards.core.models.ActionSubmit -> actionHandler.onSubmit(emptyMap())
                    is com.microsoft.adaptivecards.core.models.ActionExecute -> actionHandler.onExecute(action.verb ?: "", emptyMap())
                    else -> { /* Other action types */ }
                }
            }
        },
        modifier = modifier
            .fillMaxWidth()
            .defaultMinSize(minHeight = CompoundButtonLayout.MinHeight)
            .semantics { contentDescription = contentDesc },
        colors = CardDefaults.cardColors(
            containerColor = containerColor,
            contentColor = contentColor
        ),
        elevation = CardDefaults.cardElevation(
            defaultElevation = if (element.style == "default") CompoundButtonLayout.Elevation else 0.dp
        ),
        shape = MaterialTheme.shapes.medium,
        enabled = isEnabled
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(
                    horizontal = CompoundButtonLayout.HorizontalPadding,
                    vertical = CompoundButtonLayout.VerticalPadding
                ),
            horizontalArrangement = Arrangement.spacedBy(CompoundButtonLayout.IconTextSpacing),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Leading icon
            if (element.iconPosition != "trailing") {
                IconView(element.icon, contentColor)
            }
            
            // Title and subtitle
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(CompoundButtonLayout.TitleSubtitleSpacing)
            ) {
                Text(
                    text = element.title,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = contentColor,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
                
                element.subtitle?.let { subtitle ->
                    Text(
                        text = subtitle,
                        fontSize = 14.sp,
                        color = contentColor.copy(alpha = 0.7f),
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }
            
            // Trailing icon
            if (element.iconPosition == "trailing") {
                IconView(element.icon, contentColor)
            }
            
            // Chevron indicator
            Icon(
                painter = painterResource(android.R.drawable.ic_menu_more),
                contentDescription = null,
                modifier = Modifier.size(14.dp),
                tint = contentColor.copy(alpha = 0.5f)
            )
        }
    }
}

@Composable
private fun IconView(iconString: String?, tintColor: Color) {
    if (iconString == null) return
    
    if (iconString.startsWith("http://") || iconString.startsWith("https://")) {
        // Load from URL
        AsyncImage(
            model = ImageRequest.Builder(LocalContext.current)
                .data(iconString)
                .crossfade(true)
                .build(),
            contentDescription = null,
            modifier = Modifier.size(CompoundButtonLayout.IconSize),
            contentScale = ContentScale.Fit,
            error = painterResource(android.R.drawable.ic_menu_gallery),
            placeholder = painterResource(android.R.drawable.ic_menu_gallery)
        )
    } else {
        // Material Icon - for now show a placeholder
        // In a real app, you'd map icon names to Material Icons
        Icon(
            painter = painterResource(android.R.drawable.ic_menu_info_details),
            contentDescription = null,
            modifier = Modifier.size(CompoundButtonLayout.IconSize),
            tint = tintColor
        )
    }
}
