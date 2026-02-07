package com.microsoft.adaptivecards.actions

import android.content.Context
import android.net.Uri
import androidx.browser.customtabs.CustomTabsIntent
import com.microsoft.adaptivecards.core.models.ActionOpenUrlDialog

object OpenUrlDialogActionHandler {
    fun handle(action: ActionOpenUrlDialog, context: Context, delegate: ActionDelegate?) {
        delegate?.onActionTriggered(action)
    }
}
