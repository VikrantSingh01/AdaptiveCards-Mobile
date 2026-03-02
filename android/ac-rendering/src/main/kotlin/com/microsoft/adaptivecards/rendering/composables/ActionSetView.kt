package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.*
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.*
import com.microsoft.adaptivecards.hostconfig.LocalHostConfig
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel
import com.microsoft.adaptivecards.accessibility.buttonSemantics
import com.microsoft.adaptivecards.accessibility.linkSemantics
import com.microsoft.adaptivecards.accessibility.toggleButtonSemantics
import com.microsoft.adaptivecards.accessibility.containerSemantics

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

    Column(modifier = modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(
                hostConfig.actions.buttonSpacing.dp
            )
        ) {
            visibleActions.forEach { action ->
                ActionButton(
                    action = action,
                    actionHandler = actionHandler,
                    viewModel = viewModel,
                    modifier = Modifier.weight(1f)
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

        // Render inline ShowCard content for expanded ShowCard actions
        // (upstream #100, #374)
        actions.filterIsInstance<ActionShowCard>().forEach { showCardAction ->
            val actionId = showCardAction.id ?: return@forEach
            val isExpanded = viewModel.isShowCardExpanded(actionId)
            if (isExpanded) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .containerSemantics("${showCardAction.title ?: "Card"} content")
                ) {
                    showCardAction.card.body?.forEachIndexed { index, element ->
                        RenderElement(
                            element = element,
                            isFirst = index == 0,
                            viewModel = viewModel,
                            actionHandler = actionHandler
                        )
                    }
                    showCardAction.card.actions?.let { subActions ->
                        if (subActions.isNotEmpty()) {
                            ActionSetView(
                                actions = subActions,
                                actionHandler = actionHandler,
                                viewModel = viewModel
                            )
                        }
                    }
                }
            }
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
 * ShowCard actions use [toggleButtonSemantics] to announce expanded/collapsed
 * state (upstream #100, #374). Other actions use [buttonSemantics] (with
 * mergeDescendants to avoid duplicate TalkBack focus, upstream #202) or
 * [linkSemantics] for OpenUrl actions (upstream #492).
 */
@Composable
fun ActionButton(
    action: CardAction,
    actionHandler: ActionHandler,
    viewModel: CardViewModel,
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

    // Use tooltip as content description for accessibility when available
    val tooltipText = action.tooltip
    val label = tooltipText ?: action.title ?: "Action"

    // Choose correct semantics modifier based on action type:
    // - ShowCard: toggleButtonSemantics with expanded/collapsed state
    // - OpenUrl: linkSemantics (no Role.Button to avoid "link button")
    // - All others: buttonSemantics
    val semanticsModifier = when (action) {
        is ActionShowCard -> {
            val actionId = action.id ?: ""
            val isExpanded = viewModel.isShowCardExpanded(actionId)
            modifier.toggleButtonSemantics(
                label = label,
                expanded = isExpanded,
                enabled = action.isEnabled
            )
        }
        is ActionOpenUrl -> {
            modifier.linkSemantics(
                label = tooltipText ?: action.title ?: "Link",
                enabled = action.isEnabled
            )
        }
        else -> {
            modifier.buttonSemantics(
                label = label,
                enabled = action.isEnabled
            )
        }
    }

    Button(
        onClick = {
            // For ShowCard, toggle the expanded state in the view model
            if (action is ActionShowCard) {
                val actionId = action.id ?: ""
                viewModel.toggleShowCard(actionId)
            }
            handleAction(action, actionHandler, viewModel)
        },
        enabled = action.isEnabled,
        colors = buttonColors,
        modifier = semanticsModifier
    ) {
        Text(action.title ?: "")
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
