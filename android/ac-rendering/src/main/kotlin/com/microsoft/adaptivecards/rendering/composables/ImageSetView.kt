package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.ImageSet
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler

/**
 * Renders an ImageSet element as a flow row of images
 */
@OptIn(ExperimentalLayoutApi::class)
@Composable
fun ImageSetView(
    element: ImageSet,
    modifier: Modifier = Modifier,
    actionHandler: ActionHandler
) {
    FlowRow(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        element.images.forEach { image ->
            ImageView(
                element = image.copy(size = element.imageSize ?: image.size),
                actionHandler = actionHandler
            )
        }
    }
}
