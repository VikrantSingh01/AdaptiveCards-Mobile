package com.microsoft.adaptivecards.actions

import com.microsoft.adaptivecards.core.models.ActionPopover

object PopoverActionHandler {
    fun handle(action: ActionPopover, delegate: ActionDelegate?) {
        // Popover actions are UI-driven; delegate notification only
        delegate?.onShowCard(action.id ?: "", true)
    }
}
