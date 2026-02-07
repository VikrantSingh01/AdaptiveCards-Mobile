package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.microsoft.adaptivecards.core.models.Image
import com.microsoft.adaptivecards.core.models.ImageSize
import com.microsoft.adaptivecards.core.models.ImageStyle
import com.microsoft.adaptivecards.hostconfig.LocalHostConfig
import com.microsoft.adaptivecards.rendering.modifiers.selectAction
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler
import com.microsoft.adaptivecards.accessibility.imageSemantics

/**
 * Renders an Image element using Coil for async loading
 */
@Composable
fun ImageView(
    element: Image,
    modifier: Modifier = Modifier,
    actionHandler: ActionHandler
) {
    val hostConfig = LocalHostConfig.current
    
    // Determine image size
    val imageModifier = when (element.size ?: ImageSize.Auto) {
        ImageSize.Small -> modifier.size(hostConfig.imageSizes.small.dp)
        ImageSize.Medium -> modifier.size(hostConfig.imageSizes.medium.dp)
        ImageSize.Large -> modifier.size(hostConfig.imageSizes.large.dp)
        ImageSize.Stretch -> modifier.fillMaxWidth()
        ImageSize.Auto -> {
            // Parse explicit width if provided
            val width = element.width?.toIntOrNull()
            if (width != null) {
                modifier.width(width.dp)
            } else {
                modifier
            }
        }
    }
    
    // Apply person style (circular crop)
    val finalModifier = if (element.style == ImageStyle.Person) {
        imageModifier.clip(CircleShape)
    } else {
        imageModifier
    }
    
    AsyncImage(
        model = element.url,
        contentDescription = element.altText,
        contentScale = if (element.size == ImageSize.Stretch) ContentScale.Crop else ContentScale.Fit,
        modifier = finalModifier
            .imageSemantics(element.altText)
            .selectAction(element.selectAction, actionHandler)
    )
}
