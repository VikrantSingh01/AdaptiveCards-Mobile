// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.actions

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.microsoft.adaptivecards.core.models.ActionStyle
import com.microsoft.adaptivecards.core.models.CardAction

/**
 * Styled action button based on ActionStyle
 */
@Composable
fun ActionButton(
    action: CardAction,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val buttonColors = when (action.style) {
        ActionStyle.Positive -> ButtonDefaults.buttonColors(
            containerColor = Color(0xFF92C353)
        )
        ActionStyle.Destructive -> ButtonDefaults.buttonColors(
            containerColor = Color(0xFFC4314B)
        )
        else -> ButtonDefaults.buttonColors()
    }

    Button(
        onClick = onClick,
        enabled = action.isEnabled,
        colors = buttonColors,
        modifier = modifier
    ) {
        val iconUrl = action.iconUrl
        if (iconUrl != null) {
            val iconVector = resolveActionIcon(iconUrl)
            if (iconVector != null) {
                Icon(
                    imageVector = iconVector,
                    contentDescription = null,
                    modifier = Modifier.size(16.dp)
                )
            } else if (iconUrl.startsWith("http://") || iconUrl.startsWith("https://")) {
                AsyncImage(
                    model = iconUrl,
                    contentDescription = null,
                    modifier = Modifier.size(16.dp),
                    contentScale = ContentScale.Fit
                )
            }
            Spacer(modifier = Modifier.width(6.dp))
        }
        Text(action.title ?: "")
    }
}

/**
 * Resolves an iconUrl to a Material icon. Supports "icon:<FluentName>" prefix.
 */
private fun resolveActionIcon(iconUrl: String): ImageVector? {
    if (!iconUrl.startsWith("icon:")) return null
    // Strip style suffix (e.g., ",Filled", ",Regular") before lookup
    val name = iconUrl.removePrefix("icon:").split(",").firstOrNull()?.lowercase() ?: return null
    return when (name) {
        "alerturgent" -> Icons.Filled.Notifications
        "alert", "bell" -> Icons.Outlined.Notifications
        "belloff" -> Icons.Outlined.Notifications
        "calendar" -> Icons.Outlined.DateRange
        "send" -> Icons.Filled.Send
        "edit" -> Icons.Outlined.Edit
        "delete" -> Icons.Outlined.Delete
        "add" -> Icons.Filled.Add
        "search" -> Icons.Filled.Search
        "share" -> Icons.Filled.Share
        "star" -> Icons.Outlined.Star
        "starfilled" -> Icons.Filled.Star
        "heart" -> Icons.Outlined.FavoriteBorder
        "heartfilled" -> Icons.Filled.Favorite
        "bookmark" -> Icons.Outlined.BookmarkBorder
        "bookmarkfilled" -> Icons.Filled.Bookmark
        "link" -> Icons.Filled.Share
        "clock" -> Icons.Filled.DateRange
        "comment" -> Icons.Filled.Email
        "thumblike" -> Icons.Outlined.ThumbUp
        "eye" -> Icons.Filled.Visibility
        "eyeoff" -> Icons.Filled.VisibilityOff
        "checkmarkcircle" -> Icons.Outlined.CheckCircle
        "dismisscircle" -> Icons.Filled.Clear
        "info" -> Icons.Outlined.Info
        "warning" -> Icons.Outlined.Warning
        "errorcircle" -> Icons.Filled.Error
        "open" -> Icons.Filled.OpenInNew
        "copy" -> Icons.Filled.ContentCopy
        "save" -> Icons.Filled.Done
        "flag" -> Icons.Outlined.Flag
        "flagfilled" -> Icons.Filled.Flag
        "location" -> Icons.Outlined.LocationOn
        "phone", "call" -> Icons.Filled.Call
        "mail" -> Icons.Outlined.Email
        "video" -> Icons.Filled.PlayArrow
        "camera" -> Icons.Filled.CameraAlt
        "attach" -> Icons.Filled.AttachFile
        "document" -> Icons.Filled.Description
        "folder" -> Icons.Filled.Folder
        "settings" -> Icons.Outlined.Settings
        "filter" -> Icons.Filled.FilterList
        "morehorizontal" -> Icons.Filled.MoreHoriz
        "chevronright" -> Icons.Filled.ChevronRight
        "chevrondown" -> Icons.Filled.ExpandMore
        "chevronup" -> Icons.Filled.ExpandLess
        "navigation" -> Icons.Filled.Navigation
        "receipt" -> Icons.Filled.Receipt
        "cart", "cartfilled" -> Icons.Filled.ShoppingCart
        "arrowreset" -> Icons.Filled.Refresh
        "toggleleft" -> Icons.Filled.ToggleOn
        else -> null
    }
}
