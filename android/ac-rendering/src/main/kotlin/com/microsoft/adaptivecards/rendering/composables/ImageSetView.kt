package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import com.microsoft.adaptivecards.core.models.ImageSet
import com.microsoft.adaptivecards.core.models.ImageSetStyle
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler

/**
 * Renders an ImageSet element as either a flow row grid or a stacked (overlapping) layout
 */
@OptIn(ExperimentalLayoutApi::class)
@Composable
fun ImageSetView(
    element: ImageSet,
    modifier: Modifier = Modifier,
    actionHandler: ActionHandler
) {
    if (element.style == ImageSetStyle.Stacked) {
        StackedImageSetView(element = element, modifier = modifier, actionHandler = actionHandler)
    } else {
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
}

@Composable
private fun StackedImageSetView(
    element: ImageSet,
    modifier: Modifier = Modifier,
    actionHandler: ActionHandler
) {
    val overlapOffset = element.offset ?: -20

    Row(modifier = modifier) {
        element.images.forEachIndexed { index, image ->
            val horizontalOffset = if (index == 0) 0 else overlapOffset * index

            Box(
                modifier = Modifier
                    .offset(x = horizontalOffset.dp)
                    .zIndex((element.images.size - index).toFloat())
            ) {
                ImageView(
                    element = image.copy(
                        size = element.imageSize ?: image.size,
                        style = com.microsoft.adaptivecards.core.models.ImageStyle.Person
                    ),
                    modifier = Modifier
                        .clip(CircleShape)
                        .border(2.dp, Color.White, CircleShape),
                    actionHandler = actionHandler
                )
            }
        }
    }
}
