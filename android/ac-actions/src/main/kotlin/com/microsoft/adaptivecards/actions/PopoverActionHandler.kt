package com.microsoft.adaptivecards.actions

import com.microsoft.adaptivecards.core.models.ActionPopover

object PopoverActionHandler {
    fun handle(action: ActionPopover, delegate: ActionDelegate?) {
        delegate?.onActionTriggered(action)
    }
}
