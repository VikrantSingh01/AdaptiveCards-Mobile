// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.actions

import com.microsoft.adaptivecards.core.models.ActionRunCommands

object RunCommandsActionHandler {
    fun handle(action: ActionRunCommands, delegate: ActionDelegate?) {
        // RunCommands actions execute commands via delegate
        delegate?.onExecute("runCommands", mapOf("commands" to action.commands.map { it.id }))
    }
}
