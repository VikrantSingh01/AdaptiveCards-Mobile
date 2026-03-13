// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

package com.microsoft.adaptivecards.core

/**
 * Performance telemetry for a single card render.
 * Delivered via [CardLifecycleEvent.PerformanceReport] after the card is fully loaded.
 */
data class CardPerformanceMetrics(
    // Timing
    val parseTimeMs: Double = 0.0,
    val templateExpansionTimeMs: Double = 0.0,
    val firstRenderTimeMs: Double = 0.0,
    val fullyLoadedTimeMs: Double = 0.0,
    val totalImageLoadTimeMs: Double = 0.0,

    // Counts
    val elementCount: Int = 0,
    val inputCount: Int = 0,
    val imageCount: Int = 0,
    val actionCount: Int = 0,

    // Cache effectiveness
    val parseCacheHit: Boolean = false,
    val imagesCachedCount: Int = 0,
    val imagesLoadedCount: Int = 0,
    val templateCacheHit: Boolean = false,

    // Errors
    val unknownElementTypes: List<String> = emptyList(),
    val failedImageUrls: List<String> = emptyList(),
    val validationErrorCount: Int = 0
)
