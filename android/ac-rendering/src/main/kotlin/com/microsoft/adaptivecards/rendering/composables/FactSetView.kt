// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.microsoft.adaptivecards.core.models.FactSet
import com.microsoft.adaptivecards.rendering.theme.LocalHostConfig
import com.microsoft.adaptivecards.accessibility.scaledTextSize
import com.microsoft.adaptivecards.markdown.MarkdownParser
import com.microsoft.adaptivecards.markdown.MarkdownRenderer
import com.microsoft.adaptivecards.markdown.containsMarkdown
// DateTimeMacroExpander is in the same package

/**
 * Renders a FactSet element as key-value pairs.
 * Resolves font size, weight, and color from HostConfig factSet configuration.
 */
@Composable
fun FactSetView(
    element: FactSet,
    modifier: Modifier = Modifier
) {
    val hostConfig = LocalHostConfig.current
    val titleSize = resolveFontSize(hostConfig.factSet.title.size, hostConfig)
    val valueSize = resolveFontSize(hostConfig.factSet.value.size, hostConfig)
    val titleLineHeight = resolveLineHeight(hostConfig.factSet.title.size, hostConfig).sp
    val valueLineHeight = resolveLineHeight(hostConfig.factSet.value.size, hostConfig).sp
    val titleWeight = resolveFontWeight(hostConfig.factSet.title.weight, hostConfig)
    val valueWeight = resolveFontWeight(hostConfig.factSet.value.weight, hostConfig)
    val titleColor = getTextColor(hostConfig.factSet.title.color, hostConfig.factSet.title.isSubtle, hostConfig)
    val valueColor = getTextColor(hostConfig.factSet.value.color, hostConfig.factSet.value.isSubtle, hostConfig)
    val titleMaxWidth = hostConfig.factSet.title.maxWidth

    Column(
        modifier = modifier,
        verticalArrangement = Arrangement.spacedBy(hostConfig.factSet.spacing.dp)
    ) {
        element.facts.forEach { fact ->
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                // Title (key) — use fixed max width, wrap content
                val titleText = DateTimeMacroExpander.expand(fact.title)
                if (titleText.containsMarkdown()) {
                    val tokens = MarkdownParser.parse(titleText)
                    val annotated = MarkdownRenderer.render(tokens, titleSize.sp, titleColor)
                    Text(
                        text = annotated,
                        fontWeight = titleWeight,
                        fontSize = scaledTextSize(titleSize),
                        lineHeight = titleLineHeight,
                        fontFamily = resolveFontFamily(hostConfig.factSet.title.fontType),
                        maxLines = if (hostConfig.factSet.title.wrap) Int.MAX_VALUE else 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.widthIn(
                            max = if (titleMaxWidth > 0) titleMaxWidth.dp else 150.dp
                        )
                    )
                } else {
                    Text(
                        text = titleText,
                        fontWeight = titleWeight,
                        fontSize = scaledTextSize(titleSize),
                        lineHeight = titleLineHeight,
                        color = titleColor,
                        fontFamily = resolveFontFamily(hostConfig.factSet.title.fontType),
                        maxLines = if (hostConfig.factSet.title.wrap) Int.MAX_VALUE else 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.widthIn(
                            max = if (titleMaxWidth > 0) titleMaxWidth.dp else 150.dp
                        )
                    )
                }

                // Value — wrap content, with markdown support
                val valueText = DateTimeMacroExpander.expand(fact.value)
                if (valueText.containsMarkdown()) {
                    val tokens = MarkdownParser.parse(valueText)
                    val annotated = MarkdownRenderer.render(tokens, valueSize.sp, valueColor)
                    Text(
                        text = annotated,
                        fontWeight = valueWeight,
                        fontSize = scaledTextSize(valueSize),
                        lineHeight = valueLineHeight,
                        fontFamily = resolveFontFamily(hostConfig.factSet.value.fontType),
                        maxLines = if (hostConfig.factSet.value.wrap) Int.MAX_VALUE else 1,
                        overflow = TextOverflow.Ellipsis
                    )
                } else {
                    Text(
                        text = valueText,
                        fontWeight = valueWeight,
                        fontSize = scaledTextSize(valueSize),
                        lineHeight = valueLineHeight,
                        color = valueColor,
                        fontFamily = resolveFontFamily(hostConfig.factSet.value.fontType),
                        maxLines = if (hostConfig.factSet.value.wrap) Int.MAX_VALUE else 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }
        }
    }
}

/**
 * Resolve a font type string to a Compose FontFamily
 */
private fun resolveFontFamily(fontType: String): FontFamily {
    return when (fontType.lowercase()) {
        "monospace" -> FontFamily.Monospace
        else -> FontFamily.Default
    }
}
