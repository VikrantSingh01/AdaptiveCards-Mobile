package com.microsoft.adaptivecards.rendering.modifiers

import androidx.compose.foundation.clickable
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.microsoft.adaptivecards.core.models.CardAction
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler

/**
 * Makes an element clickable with a select action
 */
@Composable
fun Modifier.selectAction(
    action: CardAction?,
    actionHandler: ActionHandler
): Modifier {
    if (action == null) {
        return this
    }
    
    return this.clickable {
        // Handle the action based on type
        when (action) {
            is com.microsoft.adaptivecards.core.models.ActionOpenUrl -> {
                actionHandler.onOpenUrl(action.url)
            }
            is com.microsoft.adaptivecards.core.models.ActionSubmit -> {
                // For selectAction, submit with empty data
                actionHandler.onSubmit(emptyMap())
            }
            is com.microsoft.adaptivecards.core.models.ActionExecute -> {
                actionHandler.onExecute(action.verb ?: "", emptyMap())
            }
            else -> {
                // Other action types
            }
        }
    }
}
