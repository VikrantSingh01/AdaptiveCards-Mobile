// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.rendering.composables

import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import android.util.Base64
import coil.compose.AsyncImage
import coil.request.CachePolicy
import coil.decode.SvgDecoder
import coil.request.ImageRequest
import java.nio.ByteBuffer
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
 * Sizes resolved from HostConfig.imageSizes (small=80, medium=120, large=180 — matching iOS).
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

    // Determine image size — detect SVG from URL, themedUrls, and content type hints
    val isSvg = element.url.endsWith(".svg", ignoreCase = true) ||
        element.url.startsWith("data:image/svg+xml") ||
        element.url.contains("/svg", ignoreCase = true) ||
        element.themedUrls?.values?.any { it.endsWith(".svg", ignoreCase = true) || it.contains("svg", ignoreCase = true) } == true
    val imageModifier = when (element.size ?: ImageSize.Auto) {
        ImageSize.Small -> modifier.size(hostConfig.imageSizes.small.dp)
        ImageSize.Medium -> {
            // SVGs with named sizes should preserve aspect ratio, not force square
            if (isSvg) modifier.width(hostConfig.imageSizes.medium.dp)
            else modifier.size(hostConfig.imageSizes.medium.dp)
        }
        ImageSize.Large -> {
            if (isSvg) modifier.width(hostConfig.imageSizes.large.dp)
            else modifier.size(hostConfig.imageSizes.large.dp)
        }
        ImageSize.Stretch -> modifier.fillMaxWidth()
        ImageSize.Auto -> {
            // Parse explicit width/height if provided (supports "20px" or plain "20")
            val widthPx = element.width?.removeSuffix("px")?.toIntOrNull()
            val heightPx = element.pixelHeight?.removeSuffix("px")?.toIntOrNull()
            // Check if height is "auto" (not a pixel value)
            val hasAutoHeight = element.height != null && element.pixelHeight == null
            when {
                widthPx != null && heightPx != null -> modifier.size(widthPx.dp, heightPx.dp)
                widthPx != null -> modifier.width(widthPx.dp)
                heightPx != null -> modifier.height(heightPx.dp)
                // When height="auto" with no width, use medium default size to avoid
                // collapsing to tiny or expanding to full width in auto-width columns
                hasAutoHeight -> modifier.size(hostConfig.imageSizes.medium.dp)
                // Auto per AC spec: fill container width to match iOS parity.
                // Images without explicit size should expand to fill available width.
                // Use a small minimum height to prevent zero-height collapse before
                // image loads, but keep it modest to avoid oversizing in narrow columns
                // (e.g., forecast icons in carousel ColumnSets with 4-5 columns).
                else -> modifier.fillMaxWidth().heightIn(min = 40.dp)
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
    // For data:image/svg+xml;base64,... URIs, decode the base64 payload into a ByteBuffer
    // so Coil can process it with SvgDecoder (Coil doesn't natively handle data URIs).
    val imageData: Any = if (element.url.startsWith("data:image/svg+xml;base64,")) {
        val base64Part = element.url.substringAfter("data:image/svg+xml;base64,")
        val bytes = Base64.decode(base64Part, Base64.DEFAULT)
        ByteBuffer.wrap(bytes)
    } else {
        element.url
    }

    val model = ImageRequest.Builder(context)
        .data(imageData)
        .apply {
            // Always add SvgDecoder — it checks content type/magic bytes internally,
            // so it's safe as a fallback and handles SVGs served from URLs without
            // .svg extension (e.g., CDN-hosted brand logos like Disney).
            decoderFactory(SvgDecoder.Factory())
            if (element.forceLoad == true) {
                memoryCachePolicy(CachePolicy.DISABLED)
                diskCachePolicy(CachePolicy.DISABLED)
            }
        }
        .crossfade(true)
        .build()

    // Resolve content scale — fitMode takes priority over size-based heuristics
    val contentScale = when (element.fitMode?.lowercase()) {
        "cover" -> ContentScale.Crop
        "fill" -> ContentScale.FillBounds
        "contain" -> ContentScale.Fit
        else -> when {
            element.size == ImageSize.Stretch -> ContentScale.Crop
            element.size == null || element.size == ImageSize.Auto -> {
                val hasExplicitSize = element.width != null || element.pixelHeight != null
                val hasAutoHeight = element.height != null && element.pixelHeight == null
                if (hasExplicitSize || hasAutoHeight) ContentScale.Fit else ContentScale.FillWidth
            }
            else -> ContentScale.Fit
        }
    }

    AsyncImage(
        model = model,
        contentDescription = element.altText,
        contentScale = contentScale,
        modifier = finalModifier
            .imageSemantics(element.altText)
            .selectAction(element.selectAction, actionHandler)
    )
}
