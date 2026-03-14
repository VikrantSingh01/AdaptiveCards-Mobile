// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.text.ClickableText
import androidx.compose.material3.LocalTextStyle
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.BaselineShift
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.sp
import com.microsoft.adaptivecards.core.models.CitationRun
import com.microsoft.adaptivecards.core.models.HorizontalAlignment
import com.microsoft.adaptivecards.core.models.RichTextBlock
import com.microsoft.adaptivecards.core.models.TextRun
import com.microsoft.adaptivecards.rendering.theme.LocalHostConfig
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler
import com.microsoft.adaptivecards.accessibility.scaledTextSize

/**
 * Renders a RichTextBlock with styled inline text runs.
 * Supports: bold, italic, strikethrough, underline, highlight, color,
 * font size/weight from HostConfig, clickable links via selectAction,
 * and CitationRun inline citation badges.
 */
@Composable
fun RichTextBlockView(
    element: RichTextBlock,
    modifier: Modifier = Modifier,
    actionHandler: ActionHandler
) {
    val hostConfig = LocalHostConfig.current
    val uriHandler = LocalUriHandler.current

    val annotatedText = buildAnnotatedString {
        element.inlines.forEach { inline ->
            when (inline) {
                is TextRun -> {
                    val textRun = inline
                    val start = length
                    append(DateTimeMacroExpander.expand(textRun.text))
                    val end = length

                    // Resolve font size from HostConfig
                    val fontSize = resolveFontSize(
                        textRun.size ?: com.microsoft.adaptivecards.core.models.FontSize.Default,
                        hostConfig
                    )

                    // Resolve font weight from HostConfig
                    val fontWeight = resolveFontWeight(
                        textRun.weight ?: com.microsoft.adaptivecards.core.models.FontWeight.Default,
                        hostConfig
                    )

                    // Resolve color from HostConfig
                    val textColor = getTextColor(
                        textRun.color ?: com.microsoft.adaptivecards.core.models.Color.Default,
                        textRun.isSubtle ?: false,
                        hostConfig
                    )

                    // Build text decoration (supports combining strikethrough + underline)
                    val decorations = mutableListOf<TextDecoration>()
                    if (textRun.strikethrough == true) decorations.add(TextDecoration.LineThrough)
                    if (textRun.underline == true) decorations.add(TextDecoration.Underline)

                    // Link styling: underline + accent color
                    val isLink = textRun.selectAction != null
                    if (isLink) decorations.add(TextDecoration.Underline)

                    val finalColor = if (isLink) {
                        getTextColor(
                            com.microsoft.adaptivecards.core.models.Color.Accent,
                            false,
                            hostConfig
                        )
                    } else {
                        textColor
                    }

                    val spanStyle = SpanStyle(
                        fontSize = scaledTextSize(fontSize),
                        fontWeight = fontWeight,
                        fontStyle = if (textRun.italic == true) FontStyle.Italic else FontStyle.Normal,
                        color = finalColor,
                        textDecoration = if (decorations.isNotEmpty()) {
                            TextDecoration.combine(decorations)
                        } else {
                            TextDecoration.None
                        },
                        background = if (textRun.highlight == true) {
                            getHighlightColor(
                                textRun.color ?: com.microsoft.adaptivecards.core.models.Color.Default,
                                textRun.isSubtle ?: false,
                                hostConfig
                            )
                        } else {
                            Color.Transparent
                        }
                    )
                    addStyle(spanStyle, start, end)

                    // Add URL annotation for clickable links
                    if (isLink) {
                        val action = textRun.selectAction
                        if (action is com.microsoft.adaptivecards.core.models.ActionOpenUrl) {
                            addStringAnnotation("URL", action.url, start, end)
                        }
                    }
                }

                is CitationRun -> {
                    val badgeText = "[${inline.referenceIndex}]"
                    val start = length
                    append(badgeText)
                    val end = length

                    val accentColor = getTextColor(
                        com.microsoft.adaptivecards.core.models.Color.Accent,
                        false,
                        hostConfig
                    )

                    val smallFontSize = resolveFontSize(
                        com.microsoft.adaptivecards.core.models.FontSize.Small,
                        hostConfig
                    )

                    val spanStyle = SpanStyle(
                        fontSize = scaledTextSize(smallFontSize),
                        fontWeight = FontWeight.SemiBold,
                        color = accentColor,
                        baselineShift = BaselineShift.Superscript
                    )
                    addStyle(spanStyle, start, end)
                }
            }
        }
    }

    val textAlign = when (element.horizontalAlignment) {
        HorizontalAlignment.Center -> TextAlign.Center
        HorizontalAlignment.Right -> TextAlign.Right
        else -> TextAlign.Start
    }

    ClickableText(
        text = annotatedText,
        modifier = modifier,
        style = LocalTextStyle.current.copy(textAlign = textAlign),
        onClick = { offset ->
            annotatedText.getStringAnnotations("URL", offset, offset)
                .firstOrNull()?.let { annotation ->
                    try {
                        uriHandler.openUri(annotation.item)
                    } catch (_: Exception) {
                        // Silently handle invalid URLs
                    }
                }
        }
    )
}
