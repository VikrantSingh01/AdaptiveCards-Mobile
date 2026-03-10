package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.FactSet
import com.microsoft.adaptivecards.hostconfig.LocalHostConfig
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
    val titleWeight = resolveFontWeight(hostConfig.factSet.title.weight, hostConfig)
    val valueWeight = resolveFontWeight(hostConfig.factSet.value.weight, hostConfig)
    val titleColor = getTextColor(hostConfig.factSet.title.color, hostConfig.factSet.title.isSubtle, hostConfig)
    val valueColor = getTextColor(hostConfig.factSet.value.color, hostConfig.factSet.value.isSubtle, hostConfig)
    val titleMaxWidth = hostConfig.factSet.title.maxWidth

    Column(
        modifier = modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(hostConfig.factSet.spacing.dp)
    ) {
        element.facts.forEach { fact ->
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                // Title (key)
                Text(
                    text = fact.title,
                    fontWeight = titleWeight,
                    fontSize = scaledTextSize(titleSize),
                    color = titleColor,
                    modifier = if (titleMaxWidth > 0) {
                        Modifier.widthIn(max = titleMaxWidth.dp)
                    } else {
                        Modifier.weight(0.4f)
                    }
                )

                // Value
                Text(
                    text = fact.value,
                    fontWeight = valueWeight,
                    fontSize = scaledTextSize(valueSize),
                    color = valueColor,
                    modifier = Modifier.weight(1f)
                )
            }
        }
    }
}
