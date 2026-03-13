// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.core.caching

import android.content.ComponentCallbacks2
import android.content.res.Configuration
import android.graphics.Bitmap
import android.util.LruCache
import com.microsoft.adaptivecards.core.ParseWarning
import com.microsoft.adaptivecards.core.models.AdaptiveCard
import java.util.concurrent.atomic.AtomicInteger

/**
 * Unified cache for all Adaptive Cards data: parsed cards, template expansions, and images.
 *
 * ```kotlin
 * // Use global shared cache (default)
 * val stats = CardCache.shared.stats
 *
 * // Custom cache for a specific configuration
 * val cache = CardCache(CacheConfiguration.Aggressive)
 * ```
 */
class CardCache(
    private val configuration: CacheConfiguration = CacheConfiguration.Default
) {
    companion object {
        val shared = CardCache()
    }

    // Parse cache
    private data class ParseCacheEntry(
        val card: AdaptiveCard,
        val warnings: List<ParseWarning>
    )

    private val parseCache = LruCache<Int, ParseCacheEntry>(configuration.parseCapacity)
    private val parseHits = AtomicInteger(0)
    private val parseMisses = AtomicInteger(0)

    // Template expansion cache
    private val templateCache = LruCache<String, String>(configuration.templateCapacity)
    private val templateHits = AtomicInteger(0)
    private val templateMisses = AtomicInteger(0)

    // Image cache (memory tier) — sized by bytes
    private val imageCache = object : LruCache<String, Bitmap>(configuration.imageMemoryLimit) {
        override fun sizeOf(key: String, value: Bitmap): Int {
            return value.byteCount
        }
    }
    private val imageHits = AtomicInteger(0)
    private val imageMisses = AtomicInteger(0)

    // Memory pressure callback
    val memoryPressureCallback: ComponentCallbacks2 = object : ComponentCallbacks2 {
        override fun onTrimMemory(level: Int) {
            when {
                level >= ComponentCallbacks2.TRIM_MEMORY_COMPLETE -> clearAll()
                level >= ComponentCallbacks2.TRIM_MEMORY_MODERATE -> clearImages()
                level >= ComponentCallbacks2.TRIM_MEMORY_BACKGROUND -> trimToMemoryLimit()
            }
        }
        override fun onConfigurationChanged(newConfig: Configuration) {}
        override fun onLowMemory() { trimToMemoryLimit() }
    }

    // MARK: - Parse Cache

    /** Look up a cached parsed card */
    fun cachedCard(json: String): Pair<AdaptiveCard, List<ParseWarning>>? {
        val key = json.hashCode()
        val entry = synchronized(parseCache) { parseCache.get(key) }
        if (entry != null) {
            parseHits.incrementAndGet()
            return Pair(entry.card, entry.warnings)
        }
        parseMisses.incrementAndGet()
        return null
    }

    /** Cache a parsed card */
    fun cacheCard(card: AdaptiveCard, warnings: List<ParseWarning> = emptyList(), json: String) {
        val key = json.hashCode()
        synchronized(parseCache) {
            parseCache.put(key, ParseCacheEntry(card, warnings))
        }
    }

    // MARK: - Template Cache

    /** Look up a cached template expansion */
    fun cachedExpansion(template: String, dataHash: Int): String? {
        val key = "${template.hashCode()}_$dataHash"
        val result = synchronized(templateCache) { templateCache.get(key) }
        if (result != null) {
            templateHits.incrementAndGet()
        } else {
            templateMisses.incrementAndGet()
        }
        return result
    }

    /** Cache a template expansion result */
    fun cacheExpansion(result: String, template: String, dataHash: Int) {
        val key = "${template.hashCode()}_$dataHash"
        synchronized(templateCache) {
            templateCache.put(key, result)
        }
    }

    // MARK: - Image Cache

    /** Look up a cached image */
    fun cachedImage(url: String): Bitmap? {
        val image = synchronized(imageCache) { imageCache.get(url) }
        if (image != null) {
            imageHits.incrementAndGet()
        } else {
            imageMisses.incrementAndGet()
        }
        return image
    }

    /** Cache an image */
    fun cacheImage(image: Bitmap, url: String) {
        synchronized(imageCache) {
            imageCache.put(url, image)
        }
    }

    // MARK: - Bulk Operations

    /** Clear all caches */
    fun clearAll() {
        synchronized(parseCache) { parseCache.evictAll() }
        synchronized(templateCache) { templateCache.evictAll() }
        synchronized(imageCache) { imageCache.evictAll() }
    }

    /** Clear only the image cache */
    fun clearImages() {
        synchronized(imageCache) { imageCache.evictAll() }
    }

    /** Clear only the parse cache */
    fun clearParseCache() {
        synchronized(parseCache) { parseCache.evictAll() }
    }

    /** Trim caches to reduce memory usage (images first, then templates) */
    fun trimToMemoryLimit() {
        synchronized(imageCache) { imageCache.evictAll() }
        synchronized(templateCache) { templateCache.evictAll() }
    }

    // MARK: - Diagnostics

    /** Current cache statistics */
    val stats: CacheStats
        get() = CacheStats(
            parseHits = parseHits.get(),
            parseMisses = parseMisses.get(),
            templateHits = templateHits.get(),
            templateMisses = templateMisses.get(),
            imageMemoryUsage = synchronized(imageCache) { imageCache.size() },
            imageDiskUsage = 0, // Disk cache not yet implemented
            imageHits = imageHits.get(),
            imageMisses = imageMisses.get()
        )
}
