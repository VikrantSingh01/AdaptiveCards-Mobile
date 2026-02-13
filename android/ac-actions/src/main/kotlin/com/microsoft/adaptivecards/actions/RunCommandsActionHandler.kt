package com.microsoft.adaptivecards.actions

import com.microsoft.adaptivecards.core.models.ActionRunCommands

object RunCommandsActionHandler {
    fun handle(action: ActionRunCommands, delegate: ActionDelegate?) {
        // RunCommands actions execute commands via delegate
        delegate?.onExecute("runCommands", mapOf("commands" to action.commands.map { it.id }))
    }
}
