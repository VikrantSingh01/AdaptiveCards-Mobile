package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Divider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.microsoft.adaptivecards.core.models.*
import com.microsoft.adaptivecards.hostconfig.LocalHostConfig
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel

/**
 * Renders a Media element with poster image and play overlay.
 * Full media playback requires platform media player integration (ExoPlayer).
 */
@Composable
fun MediaView(
    element: Media,
    modifier: Modifier = Modifier
) {
    val posterUrl = element.poster
    if (posterUrl != null) {
        // Show poster image with play button overlay
        Box(
            modifier = modifier
                .fillMaxWidth()
                .heightIn(min = 150.dp)
                .clip(MaterialTheme.shapes.medium),
            contentAlignment = Alignment.Center
        ) {
            AsyncImage(
                model = posterUrl,
                contentDescription = element.altText ?: "Media poster",
                contentScale = ContentScale.Crop,
                modifier = Modifier.fillMaxWidth()
            )
            // Play button overlay
            Box(
                modifier = Modifier
                    .size(56.dp)
                    .background(
                        color = Color.Black.copy(alpha = 0.6f),
                        shape = MaterialTheme.shapes.extraLarge
                    ),
                contentAlignment = Alignment.Center
            ) {
                Text("▶", color = Color.White, style = MaterialTheme.typography.headlineMedium)
            }
        }
    } else {
        Box(
            modifier = modifier
                .fillMaxWidth()
                .height(100.dp)
                .background(Color(0xFFF5F5F5)),
            contentAlignment = Alignment.Center
        ) {
            Text(
                "Media: ${element.sources.firstOrNull()?.url ?: "No source"}",
                color = Color.Gray
            )
        }
    }
}

/**
 * Renders a Table element with proper grid lines, header row styling,
 * cell alignment, and container style backgrounds.
 */
@Composable
fun TableView(
    element: Table,
    modifier: Modifier = Modifier,
    viewModel: CardViewModel,
    actionHandler: ActionHandler
) {
    val hostConfig = LocalHostConfig.current
    val showGridLines = element.showGridLines != false // default true
    val firstRowAsHeaders = element.firstRowAsHeaders ?: false

    // Resolve grid style background
    val gridStyleConfig = resolveContainerStyle(element.gridStyle, hostConfig)
    val gridBackground = parseColorSafe(gridStyleConfig?.backgroundColor)
    val gridLineColor = Color(0xFFE0E0E0)

    val tableCornerRadius = hostConfig.cornerRadius.table

    Column(
        modifier = modifier
            .fillMaxWidth()
            .then(
                if (tableCornerRadius > 0) Modifier.clip(RoundedCornerShape(tableCornerRadius.dp)) else Modifier
            )
            .then(
                if (gridBackground != null) Modifier.background(gridBackground) else Modifier
            )
    ) {
        element.rows.forEachIndexed { rowIndex, row ->
            val isHeader = firstRowAsHeaders && rowIndex == 0
            val rowStyleConfig = resolveContainerStyle(row.style, hostConfig)
            val rowBackground = parseColorSafe(rowStyleConfig?.backgroundColor)

            // Header separator
            if (showGridLines && rowIndex > 0) {
                @Suppress("DEPRECATION") Divider(
                    thickness = if (isHeader || (firstRowAsHeaders && rowIndex == 1)) 2.dp else 1.dp,
                    color = gridLineColor
                )
            }

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .then(
                        if (rowBackground != null) Modifier.background(rowBackground) else Modifier
                    )
                    .padding(vertical = 4.dp)
            ) {
                val columnDefs = element.columns ?: emptyList()

                row.cells.forEachIndexed { cellIndex, cell ->
                    // Resolve cell weight from column definition
                    val colDef = columnDefs.getOrNull(cellIndex)
                    val weight = parseColumnWeight(colDef?.width) ?: 1f

                    // Resolve vertical alignment (cell > row > table)
                    val verticalAlign = cell.verticalContentAlignment
                        ?: row.verticalCellContentAlignment
                        ?: element.verticalCellContentAlignment
                        ?: VerticalContentAlignment.Top

                    // Resolve horizontal alignment (colDef > row > table)
                    val horizontalAlign = colDef?.horizontalCellContentAlignment
                        ?: row.horizontalCellContentAlignment
                        ?: element.horizontalCellContentAlignment

                    val cellStyleConfig = resolveContainerStyle(cell.style, hostConfig)
                    val cellBackground = parseColorSafe(cellStyleConfig?.backgroundColor)

                    Column(
                        modifier = Modifier
                            .weight(weight)
                            .then(
                                if (cellBackground != null) Modifier.background(cellBackground) else Modifier
                            )
                            .padding(horizontal = 8.dp, vertical = 4.dp),
                        verticalArrangement = when (verticalAlign) {
                            VerticalContentAlignment.Center -> Arrangement.Center
                            VerticalContentAlignment.Bottom -> Arrangement.Bottom
                            else -> Arrangement.Top
                        },
                        horizontalAlignment = when (horizontalAlign) {
                            HorizontalAlignment.Center -> Alignment.CenterHorizontally
                            HorizontalAlignment.Right -> Alignment.End
                            else -> Alignment.Start
                        }
                    ) {
                        cell.items?.forEachIndexed { index, item ->
                            // Apply bold for header cells
                            if (isHeader && item is TextBlock) {
                                Text(
                                    text = item.text,
                                    fontWeight = FontWeight.Bold,
                                    style = MaterialTheme.typography.bodyMedium
                                )
                            } else {
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
}

/**
 * Resolve a ContainerStyle to its config from HostConfig
 */
private fun resolveContainerStyle(
    style: ContainerStyle?,
    hostConfig: com.microsoft.adaptivecards.core.hostconfig.HostConfig
): com.microsoft.adaptivecards.core.hostconfig.ContainerStyleConfig? {
    return when (style) {
        ContainerStyle.Default -> hostConfig.containerStyles.default
        ContainerStyle.Emphasis -> hostConfig.containerStyles.emphasis
        ContainerStyle.Good -> hostConfig.containerStyles.good
        ContainerStyle.Attention -> hostConfig.containerStyles.attention
        ContainerStyle.Warning -> hostConfig.containerStyles.warning
        ContainerStyle.Accent -> hostConfig.containerStyles.accent
        else -> null
    }
}

/**
 * Parse column width string to a weight value
 */
private fun parseColumnWeight(width: String?): Float? {
    if (width == null) return null
    // Try numeric weight
    width.toFloatOrNull()?.let { return it.coerceAtLeast(1f) }
    // "auto" or "stretch" use equal weight
    return null
}

/**
 * Safely parse a hex color string to Compose Color
 */
private fun parseColorSafe(hex: String?): Color? {
    if (hex == null) return null
    return try {
        Color(android.graphics.Color.parseColor(hex))
    } catch (_: Exception) {
        null
    }
}
