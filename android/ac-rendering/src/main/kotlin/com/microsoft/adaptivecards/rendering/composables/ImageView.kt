package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import coil.decode.SvgDecoder
import coil.request.ImageRequest
import com.microsoft.adaptivecards.core.models.Image
import com.microsoft.adaptivecards.core.models.ImageSize
import com.microsoft.adaptivecards.core.models.ImageStyle
import com.microsoft.adaptivecards.rendering.theme.LocalHostConfig
import com.microsoft.adaptivecards.rendering.modifiers.selectAction
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler
import com.microsoft.adaptivecards.accessibility.imageSemantics

/**
 * Renders an Image element using Coil for async loading.
 *
 * Sizes resolved from HostConfig.imageSizes (Figma: small=32, medium=52, large=100).
 * Corner radius applied from HostConfig.cornerRadius.image (4dp) except for Person style.
 * SVG images supported via Coil's SvgDecoder (both URL and data:image/svg+xml URIs).
 */
@Composable
fun ImageView(
    element: Image,
    modifier: Modifier = Modifier,
    actionHandler: ActionHandler
) {
    val hostConfig = LocalHostConfig.current
    val cornerRadius = hostConfig.cornerRadius.image
    val context = LocalContext.current

    // Skip symbol: URLs (platform-specific, not renderable)
    if (element.url.startsWith("symbol:")) return

    // Determine image size
    val imageModifier = when (element.size ?: ImageSize.Auto) {
        ImageSize.Small -> modifier.size(hostConfig.imageSizes.small.dp)
        ImageSize.Medium -> modifier.size(hostConfig.imageSizes.medium.dp)
        ImageSize.Large -> modifier.size(hostConfig.imageSizes.large.dp)
        ImageSize.Stretch -> modifier.fillMaxWidth()
        ImageSize.Auto -> {
            // Parse explicit width/height if provided (supports "20px" or plain "20")
            val widthPx = element.width?.removeSuffix("px")?.toIntOrNull()
            val heightPx = element.pixelHeight?.removeSuffix("px")?.toIntOrNull()
            when {
                widthPx != null && heightPx != null -> modifier.size(widthPx.dp, heightPx.dp)
                widthPx != null -> modifier.width(widthPx.dp)
                heightPx != null -> modifier.height(heightPx.dp)
                // Auto per AC spec: display at natural size constrained to container width.
                else -> modifier.fillMaxWidth()
            }
        }
    }

    // Apply shape: Person → circle, RoundedCorners → explicit radius, otherwise HostConfig radius
    val finalModifier = when (element.style) {
        ImageStyle.Person -> imageModifier.clip(CircleShape)
        ImageStyle.RoundedCorners -> imageModifier.clip(RoundedCornerShape(8.dp))
        else -> if (cornerRadius > 0) imageModifier.clip(RoundedCornerShape(cornerRadius.dp)) else imageModifier
    }

    // Build image request — add SVG decoder for SVG content
    val isSvg = element.url.endsWith(".svg", ignoreCase = true) ||
        element.url.startsWith("data:image/svg+xml")

    val model = ImageRequest.Builder(context)
        .data(element.url)
        .apply {
            if (isSvg) {
                decoderFactory(SvgDecoder.Factory())
            }
        }
        .crossfade(true)
        .build()

    AsyncImage(
        model = model,
        contentDescription = element.altText,
        contentScale = when {
            element.size == ImageSize.Stretch -> ContentScale.Crop
            element.size == null || element.size == ImageSize.Auto -> {
                val hasExplicitSize = element.width != null || element.pixelHeight != null
                if (hasExplicitSize) ContentScale.Fit else ContentScale.FillWidth
            }
            else -> ContentScale.Fit
        },
        modifier = finalModifier
            .imageSemantics(element.altText)
            .selectAction(element.selectAction, actionHandler)
    )
}
