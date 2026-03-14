// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.*
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
import com.microsoft.adaptivecards.rendering.theme.LocalHostConfig
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
    val BadgeFontSize = 10.sp
}

/**
 * Renders a CompoundButton element with icon, title, description, and badge
 */
@OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class)
@Composable
fun CompoundButtonView(
    element: CompoundButton,
    actionHandler: ActionHandler,
    modifier: Modifier = Modifier
) {
    val hostConfig = LocalHostConfig.current

    // Use hostConfig containerStyles to match iOS styling (subtle fills, not solid blocks)
    val containerColor = when (element.style) {
        "emphasis" -> parseHostColor(hostConfig.containerStyles.accent.backgroundColor)
            ?: MaterialTheme.colorScheme.primaryContainer
        "positive" -> parseHostColor(hostConfig.containerStyles.good.backgroundColor)
            ?: Color(0xFFD5F0DD)
        "destructive" -> parseHostColor(hostConfig.containerStyles.attention.backgroundColor)
            ?: Color(0xFFF7E9E9)
        else -> parseHostColor(hostConfig.containerStyles.default.backgroundColor)
            ?: MaterialTheme.colorScheme.surface
    }

    val contentColor = when (element.style) {
        "emphasis" -> parseHostColor(hostConfig.containerStyles.accent.foregroundColors.default.default)
            ?: MaterialTheme.colorScheme.onPrimaryContainer
        "positive" -> parseHostColor(hostConfig.containerStyles.good.foregroundColors.default.default)
            ?: MaterialTheme.colorScheme.onSurface
        "destructive" -> parseHostColor(hostConfig.containerStyles.attention.foregroundColors.default.default)
            ?: MaterialTheme.colorScheme.onSurface
        else -> MaterialTheme.colorScheme.onSurface
    }

    val isEnabled = element.selectAction != null

    val contentDesc = buildString {
        append(element.title)
        element.description?.let { append(". $it") }
    }

    Card(
        onClick = {
            element.selectAction?.let { action ->
                when (action) {
                    is com.microsoft.adaptivecards.core.models.ActionOpenUrl -> actionHandler.onOpenUrl(action.url, action.id)
                    is com.microsoft.adaptivecards.core.models.ActionSubmit -> actionHandler.onSubmit(emptyMap(), action.id)
                    is com.microsoft.adaptivecards.core.models.ActionExecute -> actionHandler.onExecute(action.verb ?: "", emptyMap(), action.id)
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
                IconView(element.iconName, contentColor)
            }

            // Title, badge, and description
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(CompoundButtonLayout.TitleSubtitleSpacing)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = element.title,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = contentColor,
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.weight(1f, fill = false)
                    )

                    element.badge?.let { badge ->
                        val badgeColor = parseHostColor(
                            hostConfig.containerStyles.default.foregroundColors.accent.default
                        ) ?: MaterialTheme.colorScheme.primary
                        Text(
                            text = badge,
                            fontSize = CompoundButtonLayout.BadgeFontSize,
                            fontWeight = FontWeight.SemiBold,
                            color = Color.White,
                            maxLines = 1,
                            modifier = Modifier
                                .background(
                                    badgeColor,
                                    RoundedCornerShape(4.dp)
                                )
                                .padding(horizontal = 6.dp, vertical = 2.dp)
                        )
                    }
                }

                element.description?.let { description ->
                    Text(
                        text = description,
                        fontSize = 14.sp,
                        color = contentColor.copy(alpha = 0.7f),
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }

            // Trailing icon
            if (element.iconPosition == "trailing") {
                IconView(element.iconName, contentColor)
            }

            // Chevron indicator (matching iOS chevron.right style)
            Icon(
                imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                contentDescription = null,
                modifier = Modifier.size(20.dp),
                tint = contentColor.copy(alpha = 0.6f)
            )
        }
    }
}

@Composable
private fun IconView(iconString: String?, tintColor: Color) {
    if (iconString == null) return

    if (iconString.startsWith("http://") || iconString.startsWith("https://")) {
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
        // Resolve Fluent icon name to Material filled icon (matching iOS SF Symbol style)
        val resolved = resolveCompoundButtonIcon(iconString)
        Icon(
            imageVector = resolved,
            contentDescription = null,
            modifier = Modifier.size(CompoundButtonLayout.IconSize),
            tint = tintColor
        )
    }
}

private fun resolveCompoundButtonIcon(name: String): androidx.compose.ui.graphics.vector.ImageVector {
    val lookup = name.split(",").firstOrNull()?.lowercase() ?: name.lowercase()
    return when (lookup) {
        "calendar" -> Icons.Filled.DateRange
        "send" -> Icons.Filled.Send
        "edit" -> Icons.Filled.Edit
        "delete" -> Icons.Filled.Delete
        "add" -> Icons.Filled.Add
        "search" -> Icons.Filled.Search
        "share" -> Icons.Filled.Share
        "star" -> Icons.Filled.Star
        "heart" -> Icons.Filled.Favorite
        "bookmark" -> Icons.Filled.Bookmark
        "info" -> Icons.Filled.Info
        "warning" -> Icons.Filled.Warning
        "settings" -> Icons.Filled.Settings
        "mail", "email" -> Icons.Filled.Email
        "phone", "call" -> Icons.Filled.Call
        "location" -> Icons.Filled.LocationOn
        "person", "peopleteam" -> Icons.Filled.Person
        "home" -> Icons.Filled.Home
        "notification", "bell", "alert" -> Icons.Filled.Notifications
        "check", "checkmark" -> Icons.Filled.Check
        "close", "dismiss" -> Icons.Filled.Close
        else -> Icons.Filled.Info
    }
}

private fun parseHostColor(hex: String?): Color? {
    if (hex == null) return null
    return try {
        Color(android.graphics.Color.parseColor(hex))
    } catch (_: Exception) {
        null
    }
}
