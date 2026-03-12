package com.microsoft.adaptivecards.sample

import com.microsoft.adaptivecards.core.models.CardAction
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler

/**
 * ActionHandler that logs every action callback to ActionLogState
 * for visibility in the Action Log screen.
 */
class LoggingActionHandler(
    private val actionLogState: ActionLogState
) : ActionHandler {

    override fun onSubmit(data: Map<String, Any>, actionId: String?) {
        actionLogState.log("Action.Submit", data)
    }

    override fun onOpenUrl(url: String, actionId: String?) {
        actionLogState.log("Action.OpenUrl", mapOf("url" to url, "actionId" to (actionId ?: "")))
    }

    override fun onExecute(verb: String, data: Map<String, Any>, actionId: String?) {
        val logData = data.toMutableMap()
        logData["verb"] = verb
        actionLogState.log("Action.Execute", logData)
    }

    override fun onShowCard(cardAction: CardAction) {
        actionLogState.log("Action.ShowCard", mapOf("type" to cardAction.type))
    }

    override fun onToggleVisibility(targetElementIds: List<String>) {
        actionLogState.log("Action.ToggleVisibility", mapOf("targets" to targetElementIds.joinToString(",")))
    }
}
