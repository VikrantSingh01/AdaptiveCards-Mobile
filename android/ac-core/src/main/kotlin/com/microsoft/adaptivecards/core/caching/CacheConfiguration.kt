// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.core.caching

/**
 * Configuration for the unified card cache.
 */
data class CacheConfiguration(
    /** Maximum number of parsed cards to cache */
    val parseCapacity: Int = 64,

    /** Maximum number of template expansion results to cache */
    val templateCapacity: Int = 128,

    /** Maximum memory (in bytes) for in-memory image cache */
    val imageMemoryLimit: Int = 50_000_000,   // 50 MB

    /** Maximum disk space (in bytes) for disk image cache */
    val imageDiskLimit: Int = 200_000_000,    // 200 MB

    /** Whether the cache automatically responds to system memory pressure */
    val respondsToMemoryPressure: Boolean = true
) {
    companion object {
        /** Default configuration: balanced for typical usage */
        val Default = CacheConfiguration()

        /** Aggressive caching for high-throughput scenarios (e.g., chat lists) */
        val Aggressive = CacheConfiguration(
            parseCapacity = 128,
            templateCapacity = 256,
            imageMemoryLimit = 100_000_000,
            imageDiskLimit = 500_000_000
        )

        /** Minimal caching for memory-constrained environments */
        val Minimal = CacheConfiguration(
            parseCapacity = 16,
            templateCapacity = 32,
            imageMemoryLimit = 10_000_000,
            imageDiskLimit = 50_000_000
        )
    }
}

/**
 * Diagnostics for cache utilization
 */
data class CacheStats(
    val parseHits: Int = 0,
    val parseMisses: Int = 0,
    val templateHits: Int = 0,
    val templateMisses: Int = 0,
    val imageMemoryUsage: Int = 0,
    val imageDiskUsage: Int = 0,
    val imageHits: Int = 0,
    val imageMisses: Int = 0
) {
    val parseHitRate: Double
        get() {
            val total = parseHits + parseMisses
            return if (total > 0) parseHits.toDouble() / total else 0.0
        }
}
