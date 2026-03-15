// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.copilot

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.CardElement

/**
 * Streaming card view with fade-in animation for each element.
 *
 * By default renders element type labels. Hosts should provide a custom
 * [elementRenderer] composable that delegates to the rendering module's
 * `RenderElement` for full card element rendering.
 */
@Composable
fun StreamingCardView(
    streamingState: StreamingState,
    partialContent: List<CardElement>,
    elementRenderer: (@Composable (CardElement, Boolean) -> Unit)? = null
) {
    Column(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(0.dp)
    ) {
        partialContent.forEachIndexed { index, element ->
            AnimatedVisibility(
                visible = true,
                enter = fadeIn(animationSpec = tween(durationMillis = 300))
            ) {
                if (elementRenderer != null) {
                    elementRenderer(element, index == 0)
                } else {
                    Text(
                        text = "Element: ${element.type}",
                        style = MaterialTheme.typography.bodyMedium
                    )
                }
            }
        }

        when (streamingState) {
            is StreamingState.Idle -> {}
            is StreamingState.Streaming -> {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.padding(top = 8.dp)
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
                    text = "Error: ${streamingState.message}",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.error,
                    modifier = Modifier.padding(top = 8.dp)
                )
            }
        }
    }
}
