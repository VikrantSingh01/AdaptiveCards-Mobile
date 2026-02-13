package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.*
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.*
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel
import com.microsoft.adaptivecards.accessibility.buttonSemantics

/**
 * Renders an ActionSet as a row or column of action buttons
 */
@Composable
fun ActionSetView(
    actions: List<CardAction>,
    actionHandler: ActionHandler,
    viewModel: CardViewModel,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        actions.forEach { action ->
            ActionButton(
                action = action,
                actionHandler = actionHandler,
                viewModel = viewModel,
                modifier = Modifier.weight(1f)
            )
        }
    }
}

/**
 * Renders a single action as a button
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
    
    Button(
        onClick = {
            handleAction(action, actionHandler, viewModel)
        },
        enabled = action.isEnabled,
        colors = buttonColors,
        modifier = modifier.buttonSemantics(
            label = action.title ?: "Action",
            enabled = action.isEnabled
        )
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
            actionHandler.onSubmit(inputData)
        }
        is ActionOpenUrl -> {
            actionHandler.onOpenUrl(action.url)
        }
        is ActionExecute -> {
            val inputData = viewModel.getAllInputValues()
            actionHandler.onExecute(action.verb ?: "", inputData)
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
            actionHandler.onOpenUrl(action.url)
        }
        is ActionPopover -> {
            // Popover actions handled externally
        }
        is ActionRunCommands -> {
            // RunCommands actions handled externally
        }
    }
}
