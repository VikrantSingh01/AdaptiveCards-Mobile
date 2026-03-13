// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.core

import android.graphics.Bitmap

/**
 * Interface for custom image loading.
 * Implement this to route images through authenticated CDN, custom cache, or local resources.
 *
 * ```kotlin
 * class TeamsImageProvider(private val authService: AuthService) : ImageProvider {
 *     override suspend fun loadImage(url: String): Bitmap {
 *         val request = Request.Builder()
 *             .url(url)
 *             .header("Authorization", "Bearer ${authService.getToken()}")
 *             .build()
 *         // ... fetch and decode
 *     }
 * }
 * ```
 */
interface ImageProvider {
    /**
     * Load an image from the given URL.
     * The SDK wraps this with caching — implementations only need to handle fetching.
     */
    suspend fun loadImage(url: String): Bitmap
}

/**
 * Errors that an ImageProvider may throw
 */
sealed class ImageProviderError(override val message: String) : Exception(message) {
    class InvalidURL(url: String) : ImageProviderError("Invalid URL: $url")
    class InvalidData : ImageProviderError("Invalid image data")
    class NetworkError(cause: Throwable) : ImageProviderError("Network error: ${cause.message}")
    class Timeout : ImageProviderError("Image load timed out")
}
