// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.Icon as MaterialIcon
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.Icon
import com.microsoft.adaptivecards.rendering.theme.LocalHostConfig
import com.microsoft.adaptivecards.rendering.modifiers.selectAction
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler

/**
 * Renders an Icon element using Material Icons as a Fluent icon approximation.
 */
@Composable
fun IconView(
    element: Icon,
    modifier: Modifier = Modifier,
    actionHandler: ActionHandler
) {
    val hostConfig = LocalHostConfig.current
    val sizeDp = when (element.size?.lowercase()) {
        "xxsmall" -> 12.dp
        "xsmall" -> 16.dp
        "small" -> 20.dp
        "medium", "default", null -> 24.dp
        "large" -> 32.dp
        "xlarge" -> 40.dp
        "xxlarge" -> 48.dp
        else -> 24.dp
    }

    val tintColor = getTextColor(
        element.color ?: com.microsoft.adaptivecards.core.models.Color.Default,
        isSubtle = false,
        hostConfig = hostConfig
    )

    val imageVector = resolveIconName(element.name, element.style)

    val iconModifier = modifier
        .size(sizeDp)
        .selectAction(element.selectAction, actionHandler)

    MaterialIcon(
        imageVector = imageVector,
        contentDescription = element.name,
        modifier = iconModifier,
        tint = tintColor
    )
}

/**
 * Maps Fluent icon names to Material Icons equivalents.
 * Covers the most commonly used Adaptive Card icon names.
 */
internal fun resolveIconName(name: String, style: String? = null): ImageVector {
    val isFilled = style?.lowercase() == "filled"

    // Normalize SF Symbol names: strip ".fill"/".circle" suffix, replace dots with empty
    val normalized = name.lowercase()
        .removeSuffix(".fill")
        .removeSuffix(".circle")
        .replace(".", "")

    return when (normalized) {
        // Checkmarks
        "checkmarkcircle" -> if (isFilled) Icons.Filled.CheckCircle else Icons.Outlined.CheckCircle
        "checkmark" -> Icons.Filled.Check
        // Chevrons
        "chevrondown" -> Icons.Filled.KeyboardArrowDown
        "chevronup" -> Icons.Filled.KeyboardArrowUp
        "chevronright" -> Icons.Filled.ChevronRight
        "chevronleft" -> Icons.Filled.ChevronLeft
        // Navigation & actions
        "receipt" -> Icons.Outlined.Receipt
        "comment" -> Icons.Outlined.Comment
        "chat" -> Icons.Outlined.Chat
        "send" -> Icons.Filled.Send
        "share" -> Icons.Filled.Share
        "more" -> Icons.Filled.MoreVert
        "morehorizontal" -> Icons.Filled.MoreHoriz
        // People
        "person" -> Icons.Outlined.Person
        "people" -> Icons.Outlined.People
        "personadd" -> Icons.Outlined.PersonAdd
        // Status
        "info" -> Icons.Outlined.Info
        "warning" -> Icons.Outlined.Warning
        "error", "errorcircle" -> Icons.Filled.Error
        "dismiss", "dismisscircle" -> Icons.Filled.Cancel
        // Common actions
        "edit" -> Icons.Outlined.Edit
        "delete" -> Icons.Outlined.Delete
        "add", "addcircle" -> Icons.Filled.AddCircle
        "search" -> Icons.Filled.Search
        "settings" -> Icons.Outlined.Settings
        "attach", "attachment" -> Icons.Filled.AttachFile
        "link" -> Icons.Filled.Link
        "copy" -> Icons.Outlined.ContentCopy
        // Calendar & time
        "calendar" -> Icons.Outlined.DateRange
        "clock" -> Icons.Outlined.Schedule
        // Location & maps
        "location" -> Icons.Outlined.LocationOn
        "map" -> Icons.Outlined.Map
        // Communication
        "call" -> Icons.Filled.Call
        "mail", "email" -> Icons.Outlined.Email
        "video" -> Icons.Outlined.Videocam
        // Files & documents
        "document" -> Icons.Outlined.Description
        "folder" -> Icons.Outlined.Folder
        "image" -> Icons.Outlined.Image
        // Thumbs
        "thumblike" -> Icons.Outlined.ThumbUp
        "thumbdislike" -> Icons.Outlined.ThumbDown
        // Stars & bookmarks
        "star" -> if (isFilled) Icons.Filled.Star else Icons.Outlined.Star
        "bookmark" -> if (isFilled) Icons.Filled.Bookmark else Icons.Outlined.BookmarkBorder
        // Arrows
        "arrowup" -> Icons.Filled.ArrowUpward
        "arrowdown" -> Icons.Filled.ArrowDownward
        "arrowleft" -> Icons.Filled.ArrowBack
        "arrowright" -> Icons.Filled.ArrowForward
        "arrowcircleright" -> Icons.Filled.ArrowForward
        "arrowexport" -> Icons.Outlined.OpenInNew
        "arrowsync" -> Icons.Filled.Refresh
        // Home
        "home" -> Icons.Filled.Home
        // Notifications
        "alert", "bell", "notification" -> Icons.Outlined.Notifications
        "alerturgent" -> Icons.Filled.NotificationsActive
        "belloff" -> Icons.Outlined.NotificationsOff
        // Nature
        "heartpulse" -> Icons.Outlined.MonitorHeart
        "leafone" -> Icons.Outlined.Spa
        "beach" -> Icons.Outlined.BeachAccess
        // Lock
        "lock" -> Icons.Outlined.Lock
        "lockopen", "unlock" -> Icons.Outlined.LockOpen
        // Misc
        "flag" -> Icons.Outlined.Flag
        "heart" -> if (isFilled) Icons.Filled.Favorite else Icons.Outlined.FavoriteBorder
        "eye" -> Icons.Outlined.Visibility
        "eyeoff" -> Icons.Outlined.VisibilityOff
        "open", "openinnew" -> Icons.Outlined.OpenInNew
        "play" -> Icons.Filled.PlayArrow
        "pause" -> Icons.Filled.Pause
        "stop" -> Icons.Filled.Stop
        // Downloads & transfers
        "download" -> Icons.Filled.ArrowDownward
        "upload" -> Icons.Filled.ArrowUpward
        "save" -> Icons.Outlined.Save
        "refresh" -> Icons.Filled.Refresh
        // Media
        "microphone" -> Icons.Filled.Mic
        "camera" -> Icons.Filled.CameraAlt
        "speaker" -> Icons.Filled.VolumeUp
        // Connectivity
        "wifi" -> Icons.Filled.Wifi
        "bluetooth" -> Icons.Filled.Bluetooth
        "cloud" -> Icons.Filled.Cloud
        // Layout
        "list" -> Icons.Filled.List
        "grid" -> Icons.Filled.GridView
        "filter" -> Icons.Filled.FilterList
        "sort" -> Icons.Filled.Sort
        // Objects
        "gift" -> Icons.Outlined.CardGiftcard
        "airplane" -> Icons.Filled.Flight
        "cart" -> Icons.Filled.ShoppingCart
        "tag" -> Icons.Outlined.Label
        "key" -> Icons.Outlined.Key
        "shield" -> Icons.Outlined.Shield
        "lightbulb" -> Icons.Outlined.Lightbulb
        // Dev tools
        "code" -> Icons.Filled.Code
        "terminal" -> Icons.Filled.Terminal
        "bug" -> Icons.Outlined.BugReport
        "branch" -> Icons.Filled.AccountTree
        "database" -> Icons.Filled.Storage
        "server" -> Icons.Filled.Dns
        // Shapes
        "circle" -> Icons.Filled.Circle
        "circlesmall" -> Icons.Filled.Circle
        // Additional parity
        "accesstime" -> Icons.Outlined.Schedule
        "crown" -> Icons.Outlined.WorkspacePremium
        "success" -> Icons.Filled.CheckCircle
        "morevertical" -> Icons.Filled.MoreVert
        "megaphone" -> Icons.Filled.Campaign
        "peopleteam" -> Icons.Outlined.People
        "navigation" -> Icons.Filled.Navigation
        "compass" -> Icons.Outlined.Explore
        "design", "paintbrush" -> Icons.Outlined.Palette
        "battery" -> Icons.Filled.BatteryFull
        "flash" -> Icons.Filled.FlashOn
        // SF Symbol name mappings (iOS → Material)
        "house" -> Icons.Filled.Home
        "checklist" -> Icons.Filled.Checklist
        "person3" -> Icons.Outlined.People
        "chartbar" -> Icons.Filled.BarChart
        "gearshape" -> Icons.Outlined.Settings
        "magnifyingglass" -> Icons.Filled.Search
        "envelope" -> Icons.Outlined.Email
        "paperplane" -> Icons.Filled.Send
        "trash" -> Icons.Outlined.Delete
        "pencil" -> Icons.Outlined.Edit
        "plus" -> Icons.Filled.Add
        "xmark" -> Icons.Filled.Close
        "bolt" -> Icons.Filled.FlashOn
        "bell" -> Icons.Outlined.Notifications
        "mappin" -> Icons.Outlined.LocationOn
        "phone" -> Icons.Filled.Call
        "doc" -> Icons.Outlined.Description
        "photo" -> Icons.Outlined.Image
        "mic" -> Icons.Filled.Mic
        "speaker" -> Icons.Filled.VolumeUp
        "wifi" -> Icons.Filled.Wifi
        "icloud" -> Icons.Filled.Cloud
        "questionmark" -> Icons.Outlined.HelpOutline
        // Default fallback
        else -> Icons.Outlined.HelpOutline
    }
}
