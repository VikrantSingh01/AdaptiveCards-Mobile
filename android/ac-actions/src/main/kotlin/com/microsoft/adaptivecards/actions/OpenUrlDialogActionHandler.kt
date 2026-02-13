package com.microsoft.adaptivecards.actions

import android.content.Context
import android.content.Intent
import android.net.Uri
import com.microsoft.adaptivecards.core.models.ActionOpenUrlDialog

object OpenUrlDialogActionHandler {
    fun handle(action: ActionOpenUrlDialog, context: Context, delegate: ActionDelegate?) {
        try {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(action.url))
            context.startActivity(intent)
        } catch (e: Exception) {
            // Handle error gracefully
        }
        delegate?.onOpenUrl(action.url)
    }
}
