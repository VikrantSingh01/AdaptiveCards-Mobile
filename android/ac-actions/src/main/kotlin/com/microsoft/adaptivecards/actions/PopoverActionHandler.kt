// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.actions

import com.microsoft.adaptivecards.core.models.ActionPopover

object PopoverActionHandler {
    fun handle(action: ActionPopover, delegate: ActionDelegate?) {
        // Popover actions are UI-driven; delegate notification only
        delegate?.onShowCard(action.id ?: "", true)
    }
}
