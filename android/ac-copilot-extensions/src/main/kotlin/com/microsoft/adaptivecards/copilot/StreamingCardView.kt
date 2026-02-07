package com.microsoft.adaptivecards.copilot

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.CardElement

@Composable
fun StreamingCardView(
    streamingState: StreamingState,
    partialContent: List<CardElement>
) {
    Column(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        partialContent.forEach { element ->
            Text(
                text = "Element: ${element.type}",
                style = MaterialTheme.typography.bodyMedium
            )
        }
        
        when (streamingState) {
            is StreamingState.Idle -> {}
            is StreamingState.Streaming -> {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(16.dp)
                    )
                    Text(
                        text = "Loading...",
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
            is StreamingState.Complete -> {}
            is StreamingState.Error -> {
                Text(
                    text = "Error: ${streamingState.error.message}",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.error
                )
            }
        }
    }
}
