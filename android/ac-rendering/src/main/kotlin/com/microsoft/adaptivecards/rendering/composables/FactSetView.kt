package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.FactSet
import com.microsoft.adaptivecards.hostconfig.LocalHostConfig
import com.microsoft.adaptivecards.accessibility.scaledTextSize

/**
 * Renders a FactSet element as key-value pairs
 */
@Composable
fun FactSetView(
    element: FactSet,
    modifier: Modifier = Modifier
) {
    val hostConfig = LocalHostConfig.current
    
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
                    fontWeight = FontWeight.Bold,
                    fontSize = scaledTextSize(hostConfig.factSet.title.size.name.toIntOrNull() ?: 14),
                    modifier = Modifier.weight(0.4f)
                )
                
                // Value
                Text(
                    text = fact.value,
                    fontSize = scaledTextSize(hostConfig.factSet.value.size.name.toIntOrNull() ?: 14),
                    modifier = Modifier.weight(0.6f)
                )
            }
        }
    }
}
