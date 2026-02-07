package com.microsoft.adaptivecards.teams

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts

class TaskModulePresenter(private val activity: ComponentActivity) {
    private var launcher: ActivityResultLauncher<Intent>? = null
    
    init {
        launcher = activity.registerForActivityResult(
            ActivityResultContracts.StartActivityForResult()
        ) { result ->
            // Handle result
        }
    }
    
    fun present(url: String, title: String?) {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
        launcher?.launch(intent)
    }
    
    fun dismiss() {
        activity.finish()
    }
}
