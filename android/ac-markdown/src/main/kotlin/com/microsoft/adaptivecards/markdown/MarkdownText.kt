package com.microsoft.adaptivecards.markdown

import androidx.compose.foundation.text.ClickableText
import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.sp

/**
 * A Composable that renders markdown text with proper styling
 * 
 * @param text The markdown text to render
 * @param modifier Modifier to be applied to the text
 * @param fontSize Base font size to use (default: 14.sp)
 * @param color Base text color (default: Color.Black)
 */
@Composable
fun MarkdownText(
    text: String,
    modifier: Modifier = Modifier,
    fontSize: TextUnit = 14.sp,
    color: Color = Color.Black
) {
    val tokens = MarkdownParser.parse(text)
    val annotatedString = MarkdownRenderer.render(tokens, fontSize, color)
    val uriHandler = LocalUriHandler.current
    
    ClickableText(
        text = annotatedString,
        modifier = modifier,
        style = LocalTextStyle.current.copy(fontSize = fontSize, color = color),
        onClick = { offset ->
            // Handle link clicks — only open URLs with safe schemes
            annotatedString.getStringAnnotations(tag = "URL", start = offset, end = offset)
                .firstOrNull()?.let { annotation ->
                    if (MarkdownRenderer.isSafeUrl(annotation.item)) {
                        try {
                            uriHandler.openUri(annotation.item)
                        } catch (e: Exception) {
                            // Handle URI opening error gracefully
                        }
                    }
                }
        }
    )
}
