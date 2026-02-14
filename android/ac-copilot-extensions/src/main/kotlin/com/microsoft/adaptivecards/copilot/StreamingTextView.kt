package com.microsoft.adaptivecards.copilot

import androidx.compose.animation.core.*
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay

/**
 * Jetpack Compose view that renders streaming text with a typing animation effect.
 *
 * Ported from production Teams-AdaptiveCards-Mobile SDK.
 * Progressively reveals text character by character with a blinking cursor.
 */
@Composable
fun StreamingTextView(
    content: StreamingContent,
    modifier: Modifier = Modifier,
    textStyle: TextStyle = MaterialTheme.typography.bodyMedium,
    onStopStreaming: (() -> Unit)? = null
) {
    val charsPerSecond = content.typingSpeed ?: 40.0
    var displayedCharCount by remember { mutableIntStateOf(0) }
    val isStreaming = !content.isComplete && content.streamingPhase == StreamingPhase.STREAMING

    // Typing animation
    LaunchedEffect(content.content) {
        val targetCount = content.content.length
        while (displayedCharCount < targetCount) {
            delay((1000.0 / charsPerSecond).toLong())
            displayedCharCount = (displayedCharCount + 1).coerceAtMost(targetCount)
        }
    }

    // Cursor blink animation
    val cursorAlpha by rememberInfiniteTransition(label = "cursor").animateFloat(
        initialValue = 1f,
        targetValue = 0f,
        animationSpec = infiniteRepeatable(
            animation = tween(500, easing = LinearEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "cursorAlpha"
    )

    Column(
        modifier = modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        // Text with cursor
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.Bottom
        ) {
            val visibleText = content.content.take(displayedCharCount)
            Text(
                text = visibleText,
                style = textStyle,
                modifier = Modifier.weight(1f, fill = false)
            )

            // Blinking cursor
            if (isStreaming && displayedCharCount < content.content.length) {
                Box(
                    modifier = Modifier
                        .width(2.dp)
                        .height(16.dp)
                        .alpha(cursorAlpha)
                        .padding(start = 1.dp)
                ) {
                    Surface(
                        modifier = Modifier.fillMaxSize(),
                        color = MaterialTheme.colorScheme.onSurface
                    ) {}
                }
            }
        }

        // Controls
        if (isStreaming) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                if (content.showProgressIndicator != false) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(16.dp),
                        strokeWidth = 2.dp
                    )
                }

                if (content.showStopButton == true && onStopStreaming != null) {
                    TextButton(
                        onClick = onStopStreaming,
                        contentPadding = PaddingValues(horizontal = 8.dp, vertical = 4.dp)
                    ) {
                        Text("Stop", style = MaterialTheme.typography.labelSmall)
                    }
                }
            }
        }
    }
}
