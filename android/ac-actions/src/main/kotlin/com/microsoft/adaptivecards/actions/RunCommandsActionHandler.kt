package com.microsoft.adaptivecards.actions

import com.microsoft.adaptivecards.core.models.ActionRunCommands

object RunCommandsActionHandler {
    fun handle(action: ActionRunCommands, delegate: ActionDelegate?) {
        delegate?.onActionTriggered(action)
    }
}
