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
                Text(
                    text = fact.title,
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

                // Value — wrap content, no weight
                Text(
                    text = fact.value,
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

/**
 * Resolve a font type string to a Compose FontFamily
 */
private fun resolveFontFamily(fontType: String): FontFamily {
    return when (fontType.lowercase()) {
        "monospace" -> FontFamily.Monospace
        else -> FontFamily.Default
    }
}
