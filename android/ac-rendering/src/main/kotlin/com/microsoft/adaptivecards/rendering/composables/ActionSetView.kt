package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.microsoft.adaptivecards.core.models.*
import com.microsoft.adaptivecards.hostconfig.LocalHostConfig
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel
import com.microsoft.adaptivecards.accessibility.buttonSemantics

/**
 * Renders an ActionSet as a row or column of action buttons.
 *
 * Separates actions into primary (visible buttons) and secondary (overflow menu)
 * based on the action `mode` property. Primary actions exceeding `maxActions` from
 * HostConfig are also moved into the overflow menu, matching the web renderer behavior.
 */
@Composable
fun ActionSetView(
    actions: List<CardAction>,
    actionHandler: ActionHandler,
    viewModel: CardViewModel,
    modifier: Modifier = Modifier
) {
    val hostConfig = LocalHostConfig.current
    val maxActions = hostConfig.actions.maxActions

    // Separate actions by mode: Primary (default) vs Secondary (overflow)
    val primaryActions = actions.filter { it.mode != ActionMode.Secondary }
    val secondaryActions = actions.filter { it.mode == ActionMode.Secondary }.toMutableList()

    // If primary actions exceed maxActions, move the excess into the overflow menu
    val visibleActions: List<CardAction>
    if (primaryActions.size > maxActions) {
        visibleActions = primaryActions.take(maxActions)
        secondaryActions.addAll(0, primaryActions.drop(maxActions))
    } else {
        visibleActions = primaryActions
    }

    val isLeftAligned = hostConfig.actions.actionAlignment == "left"

    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(
            hostConfig.actions.buttonSpacing.dp
        )
    ) {
        visibleActions.forEach { action ->
            ActionButton(
                action = action,
                actionHandler = actionHandler,
                viewModel = viewModel,
                modifier = if (isLeftAligned) Modifier else Modifier.weight(1f)
            )
        }

        // Overflow menu for secondary actions
        if (secondaryActions.isNotEmpty()) {
            OverflowMenuButton(
                actions = secondaryActions,
                actionHandler = actionHandler,
                viewModel = viewModel
            )
        }
    }
}

/**
 * Overflow "..." button that opens a dropdown menu with secondary actions.
 */
@Composable
private fun OverflowMenuButton(
    actions: List<CardAction>,
    actionHandler: ActionHandler,
    viewModel: CardViewModel
) {
    var expanded by remember { mutableStateOf(false) }

    Box {
        OutlinedButton(
            onClick = { expanded = true },
            modifier = Modifier.semantics {
                contentDescription = "More actions"
            }
        ) {
            Text("\u2026") // Ellipsis character
        }

        DropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false }
        ) {
            actions.forEach { action ->
                DropdownMenuItem(
                    text = { Text(action.title ?: "") },
                    onClick = {
                        expanded = false
                        handleAction(action, actionHandler, viewModel)
                    },
                    enabled = action.isEnabled
                )
            }
        }
    }
}

/**
 * Renders a single action as a button.
 *
 * Default style: outlined with accent border (matching Figma).
 * Positive/Destructive: filled with semantic color.
 * Icons placed to the left of title per HostConfig.actions.iconPlacement.
 */
@Composable
fun ActionButton(
    action: CardAction,
    actionHandler: ActionHandler,
    viewModel: CardViewModel,
    modifier: Modifier = Modifier
) {
    val hostConfig = LocalHostConfig.current
    val accentColor = Color(
        android.graphics.Color.parseColor(
            hostConfig.containerStyles.default.foregroundColors.accent.default
        )
    )

    // Use tooltip as content description for accessibility when available
    val tooltipText = action.tooltip
    val cornerRadius = hostConfig.cornerRadius.container.dp
    val buttonShape = RoundedCornerShape(cornerRadius)
    val buttonPadding = PaddingValues(horizontal = hostConfig.spacing.medium.dp, vertical = (hostConfig.spacing.small * 0.75f).dp)

    when (action.style) {
        ActionStyle.Positive -> {
            val goodColor = Color(android.graphics.Color.parseColor(hostConfig.containerStyles.default.foregroundColors.good.default))
            Button(
                onClick = { handleAction(action, actionHandler, viewModel) },
                enabled = action.isEnabled,
                colors = ButtonDefaults.buttonColors(containerColor = goodColor),
                shape = buttonShape,
                contentPadding = buttonPadding,
                modifier = modifier.buttonSemantics(
                    label = tooltipText ?: action.title ?: "Action",
                    enabled = action.isEnabled
                )
            ) {
                ActionButtonContent(action, hostConfig)
            }
        }
        ActionStyle.Destructive -> {
            val attentionColor = Color(android.graphics.Color.parseColor(hostConfig.containerStyles.default.foregroundColors.attention.default))
            Button(
                onClick = { handleAction(action, actionHandler, viewModel) },
                enabled = action.isEnabled,
                colors = ButtonDefaults.buttonColors(containerColor = attentionColor),
                shape = buttonShape,
                contentPadding = buttonPadding,
                modifier = modifier.buttonSemantics(
                    label = tooltipText ?: action.title ?: "Action",
                    enabled = action.isEnabled
                )
            ) {
                ActionButtonContent(action, hostConfig)
            }
        }
        else -> {
            // Default style: outlined button with accent border
            OutlinedButton(
                onClick = { handleAction(action, actionHandler, viewModel) },
                enabled = action.isEnabled,
                border = BorderStroke(hostConfig.separator.lineThickness.dp, accentColor),
                shape = buttonShape,
                contentPadding = buttonPadding,
                colors = ButtonDefaults.outlinedButtonColors(
                    contentColor = accentColor
                ),
                modifier = modifier.buttonSemantics(
                    label = tooltipText ?: action.title ?: "Action",
                    enabled = action.isEnabled
                )
            ) {
                ActionButtonContent(action, hostConfig)
            }
        }
    }
}

/** Icon + title content shared by all button styles. */
@Composable
private fun ActionButtonContent(
    action: CardAction,
    hostConfig: com.microsoft.adaptivecards.core.hostconfig.HostConfig
) {
    Row(
        horizontalArrangement = Arrangement.spacedBy(hostConfig.spacing.small.dp),
        verticalAlignment = androidx.compose.ui.Alignment.CenterVertically
    ) {
        action.iconUrl?.let { iconUrl ->
            val iconSize = hostConfig.actions.iconSize.dp
            if (iconUrl.startsWith("icon:")) {
                val iconVector = resolveFluentIcon(iconUrl.removePrefix("icon:"))
                if (iconVector != null) {
                    Icon(
                        imageVector = iconVector,
                        contentDescription = null,
                        modifier = Modifier.size(iconSize)
                    )
                }
            } else {
                AsyncImage(
                    model = iconUrl,
                    contentDescription = null,
                    modifier = Modifier.size(iconSize)
                )
            }
        }
        Text(action.title ?: "")
    }
}

/** Maps Fluent UI icon names to Material icons. */
private fun resolveFluentIcon(name: String): ImageVector? {
    return when (name.lowercase()) {
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
        else -> null
    }
}

/**
 * Handle action execution
 */
private fun handleAction(
    action: CardAction,
    actionHandler: ActionHandler,
    viewModel: CardViewModel
) {
    when (action) {
        is ActionSubmit -> {
            val inputData = viewModel.getAllInputValues()
            actionHandler.onSubmit(inputData, action.id)
        }
        is ActionOpenUrl -> {
            actionHandler.onOpenUrl(action.url, action.id)
        }
        is ActionExecute -> {
            val inputData = viewModel.getAllInputValues()
            actionHandler.onExecute(action.verb ?: "", inputData, action.id)
        }
        is ActionShowCard -> {
            actionHandler.onShowCard(action)
        }
        is ActionToggleVisibility -> {
            action.targetElements.forEach { target ->
                viewModel.toggleVisibility(target.elementId, target.isVisible)
            }
            actionHandler.onToggleVisibility(action.targetElements.map { it.elementId })
        }
        is ActionOpenUrlDialog -> {
            actionHandler.onOpenUrl(action.url, action.id)
        }
        is ActionPopover -> {
            // Popover actions handled externally
        }
        is ActionRunCommands -> {
            // RunCommands actions handled externally
        }
    }
}
