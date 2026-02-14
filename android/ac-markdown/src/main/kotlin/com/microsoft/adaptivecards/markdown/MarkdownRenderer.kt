package com.microsoft.adaptivecards.markdown

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.sp

/**
 * Renders markdown tokens to AnnotatedString for Compose Text views
 */
class MarkdownRenderer {

    companion object {
        /**
         * URL schemes considered safe for user navigation.
         *
         * Only these schemes are rendered as clickable links. All other schemes
         * (e.g. `javascript:`, `data:`, `file:`, `vbscript:`, custom app schemes)
         * are blocked to prevent XSS, phishing, and open-redirect attacks.
         *
         * - `http` / `https` — standard web URLs
         * - `mailto` — email composition
         * - `tel` — phone dialer
         *
         * See: GHSA-r5qq-54gp-7gcx
         */
        private val ALLOWED_SCHEMES = setOf("http", "https", "mailto", "tel")

        /**
         * Returns true if the URI string uses a safe, allowed scheme.
         *
         * URLs without a scheme or with a disallowed scheme return false.
         */
        fun isSafeUrl(url: String): Boolean {
            val colonIndex = url.indexOf(':')
            if (colonIndex <= 0) return false
            val scheme = url.substring(0, colonIndex).lowercase()
            return scheme in ALLOWED_SCHEMES
        }
        /**
         * Convert markdown tokens to AnnotatedString
         * @param tokens The parsed markdown tokens
         * @param fontSize Base font size to use
         * @param color Base text color
         * @return AnnotatedString with markdown styling applied
         */
        fun render(
            tokens: List<MarkdownToken>,
            fontSize: TextUnit = 14.sp,
            color: Color = Color.Black
        ): AnnotatedString {
            return buildAnnotatedString {
                for (token in tokens) {
                    renderToken(token, fontSize, color)
                }
            }
        }
        
        private fun AnnotatedString.Builder.renderToken(
            token: MarkdownToken,
            fontSize: TextUnit,
            color: Color
        ) {
            when (token) {
                is MarkdownToken.Text -> {
                    pushStyle(SpanStyle(color = color, fontSize = fontSize))
                    append(token.text)
                    pop()
                }
                
                is MarkdownToken.Bold -> {
                    pushStyle(SpanStyle(
                        color = color,
                        fontSize = fontSize,
                        fontWeight = FontWeight.Bold
                    ))
                    append(token.text)
                    pop()
                }
                
                is MarkdownToken.Italic -> {
                    pushStyle(SpanStyle(
                        color = color,
                        fontSize = fontSize,
                        fontStyle = FontStyle.Italic
                    ))
                    append(token.text)
                    pop()
                }
                
                is MarkdownToken.Code -> {
                    pushStyle(SpanStyle(
                        color = color,
                        fontSize = fontSize,
                        fontFamily = FontFamily.Monospace,
                        background = Color.Gray.copy(alpha = 0.2f)
                    ))
                    append(token.text)
                    pop()
                }
                
                is MarkdownToken.Link -> {
                    if (isSafeUrl(token.url)) {
                        pushStyle(SpanStyle(
                            color = Color.Blue,
                            fontSize = fontSize,
                            textDecoration = TextDecoration.Underline
                        ))
                        pushStringAnnotation(
                            tag = "URL",
                            annotation = token.url
                        )
                        append(token.text)
                        pop()
                        pop()
                    } else {
                        pushStyle(SpanStyle(color = color, fontSize = fontSize))
                        append(token.text)
                        pop()
                    }
                }
                
                is MarkdownToken.Header -> {
                    val headerSize = when (token.level) {
                        1 -> fontSize * 2.0f
                        2 -> fontSize * 1.5f
                        3 -> fontSize * 1.25f
                        else -> fontSize
                    }
                    pushStyle(SpanStyle(
                        color = color,
                        fontSize = headerSize,
                        fontWeight = FontWeight.Bold
                    ))
                    append(token.text)
                    pop()
                }
                
                is MarkdownToken.BulletItem -> {
                    pushStyle(SpanStyle(color = color, fontSize = fontSize))
                    append("• ${token.text}")
                    pop()
                }
                
                is MarkdownToken.NumberedItem -> {
                    pushStyle(SpanStyle(color = color, fontSize = fontSize))
                    append("${token.number}. ${token.text}")
                    pop()
                }
                
                is MarkdownToken.LineBreak -> {
                    append("\n")
                }
            }
        }
    }
}
