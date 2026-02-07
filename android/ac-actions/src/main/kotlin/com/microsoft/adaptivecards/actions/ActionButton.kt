package com.microsoft.adaptivecards.actions

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import com.microsoft.adaptivecards.core.models.ActionStyle
import com.microsoft.adaptivecards.core.models.CardAction

/**
 * Styled action button based on ActionStyle
 */
@Composable
fun ActionButton(
    action: CardAction,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val buttonColors = when (action.style) {
        ActionStyle.Positive -> ButtonDefaults.buttonColors(
            containerColor = Color(0xFF92C353)
        )
        ActionStyle.Destructive -> ButtonDefaults.buttonColors(
            containerColor = Color(0xFFC4314B)
        )
        else -> ButtonDefaults.buttonColors()
    }
    
    Button(
        onClick = onClick,
        enabled = action.isEnabled,
        colors = buttonColors,
        modifier = modifier
    ) {
        Text(action.title ?: "")
    }
}
