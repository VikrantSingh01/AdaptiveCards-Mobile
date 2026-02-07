package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import com.microsoft.adaptivecards.core.models.RichTextBlock
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler

/**
 * Renders a RichTextBlock with styled inline text runs
 */
@Composable
fun RichTextBlockView(
    element: RichTextBlock,
    modifier: Modifier = Modifier,
    actionHandler: ActionHandler
) {
    val annotatedText = buildAnnotatedString {
        element.inlines.forEach { textRun ->
            val start = length
            append(textRun.text)
            val end = length
            
            // Apply styles
            val spanStyle = SpanStyle(
                fontWeight = if (textRun.weight == com.microsoft.adaptivecards.core.models.FontWeight.Bolder) 
                    FontWeight.Bold else FontWeight.Normal,
                textDecoration = when {
                    textRun.strikethrough == true -> TextDecoration.LineThrough
                    textRun.underline == true -> TextDecoration.Underline
                    else -> null
                }
            )
            addStyle(spanStyle, start, end)
        }
    }
    
    Text(
        text = annotatedText,
        modifier = modifier
    )
}

/**
 * Renders a Media element (stub - requires media player integration)
 */
@Composable
fun MediaView(
    element: com.microsoft.adaptivecards.core.models.Media,
    modifier: Modifier = Modifier
) {
    // Stub implementation - would require ExoPlayer or similar
    Column(modifier = modifier) {
        Text("Media: ${element.sources.firstOrNull()?.url ?: "No source"}")
    }
}

/**
 * Renders a Table element (stub - basic implementation)
 */
@Composable
fun TableView(
    element: com.microsoft.adaptivecards.core.models.Table,
    modifier: Modifier = Modifier,
    viewModel: com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel,
    actionHandler: ActionHandler
) {
    // Basic table implementation
    Column(modifier = modifier) {
        element.rows.forEach { row ->
            Row(modifier = Modifier.fillMaxWidth()) {
                row.cells.forEach { cell ->
                    Column(modifier = Modifier.weight(1f)) {
                        cell.items?.forEachIndexed { index, item ->
                            RenderElement(
                                element = item,
                                isFirst = index == 0,
                                viewModel = viewModel,
                                actionHandler = actionHandler
                            )
                        }
                    }
                }
            }
        }
    }
}
