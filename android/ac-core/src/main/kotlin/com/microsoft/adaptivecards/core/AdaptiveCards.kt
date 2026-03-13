// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.core

import android.util.Log
import com.microsoft.adaptivecards.core.caching.CardCache
import com.microsoft.adaptivecards.core.models.AdaptiveCard
import com.microsoft.adaptivecards.core.models.CardElement
import com.microsoft.adaptivecards.core.models.CardInput
import com.microsoft.adaptivecards.core.models.Container
import com.microsoft.adaptivecards.core.models.ColumnSet
import com.microsoft.adaptivecards.core.models.Carousel
import com.microsoft.adaptivecards.core.models.TabSet
import com.microsoft.adaptivecards.core.models.UnknownElement
import com.microsoft.adaptivecards.core.parsing.CardParser

/**
 * Primary entry point for the Adaptive Cards SDK.
 * Provides standalone parsing APIs that can be used without a view.
 *
 * ```kotlin
 * // Simple parse
 * val result = AdaptiveCards.parse(jsonString)
 * if (result.isValid) {
 *     val card = result.card!!
 * }
 *
 * // Pre-parse for caching (e.g., in a RecyclerView prefetch)
 * val results = jsonStrings.map { AdaptiveCards.parse(it) }
 * ```
 */
object AdaptiveCards {

    private const val TAG = "AdaptiveCards"

    /**
     * Parse an Adaptive Card JSON string into a card model.
     *
     * Results are cached via [CardCache.shared]. Calling `parse` with the same JSON
     * string returns a cached result with `parseTimeMs == 0`.
     *
     * @param json A JSON string representing an Adaptive Card
     * @return A [ParseResult] containing the card, warnings, and timing info
     */
    fun parse(json: String): ParseResult = parse(json, CardCache.shared)

    /**
     * Parse with a specific cache instance (or null to disable caching).
     */
    fun parse(json: String, cache: CardCache?): ParseResult {
        if (json.isEmpty()) {
            return ParseResult(error = ParseError.Empty())
        }

        // Check cache
        if (cache != null) {
            val cached = cache.cachedCard(json)
            if (cached != null) {
                return ParseResult(
                    card = cached.first,
                    warnings = cached.second,
                    parseTimeMs = 0.0,
                    cacheHit = true
                )
            }
        }

        // Parse
        val startNs = System.nanoTime()
        return try {
            val card = CardParser.parse(json)
            val parseTimeMs = (System.nanoTime() - startNs) / 1_000_000.0
            val warnings = collectWarnings(card)

            // Cache the result
            cache?.cacheCard(card, warnings, json)

            ParseResult(
                card = card,
                warnings = warnings,
                parseTimeMs = parseTimeMs,
                cacheHit = false
            )
        } catch (e: Exception) {
            val parseTimeMs = (System.nanoTime() - startNs) / 1_000_000.0
            Log.e(TAG, "Failed to parse card", e)
            ParseResult(
                error = ParseError.DecodingFailed(e.message ?: "Unknown error"),
                parseTimeMs = parseTimeMs
            )
        }
    }

    /**
     * Clears the shared cache. Call on low-memory events.
     */
    fun clearCache() {
        CardCache.shared.clearAll()
    }

    // MARK: - Prefetch

    /**
     * Pre-parse cards that are about to scroll into view.
     * Call from RecyclerView.Adapter.onBindViewHolder or LazyColumn prefetch.
     */
    fun prefetch(jsons: List<String>, configuration: CardConfiguration = CardConfiguration.Default) {
        Thread {
            for (json in jsons) {
                parse(json, configuration.cache)
            }
        }.start()
    }

    /**
     * Pre-warm image caches for pre-parsed cards.
     */
    @JvmName("prefetchCards")
    fun prefetch(cards: List<AdaptiveCard>, configuration: CardConfiguration = CardConfiguration.Default) {
        // Future: extract image URLs and pre-warm image cache
    }

    /**
     * Cancel prefetch for cards that scrolled out of range.
     */
    fun cancelPrefetch(jsons: List<String>) {
        // Future: cancel in-flight image prefetch tasks
    }

    /**
     * Walk the parsed card tree and collect warnings for unknown types, etc.
     */
    private fun collectWarnings(card: AdaptiveCard): List<ParseWarning> {
        val warnings = mutableListOf<ParseWarning>()

        fun walk(elements: List<CardElement>?) {
            elements ?: return
            for (element in elements) {
                when (element) {
                    is UnknownElement -> {
                        val typeName = element.unknownType ?: "Unknown"
                        warnings.add(
                            ParseWarning(
                                code = ParseWarning.Code.UNKNOWN_ELEMENT_TYPE,
                                message = "Unknown element type: $typeName"
                            )
                        )
                    }
                    is CardInput -> {
                        if (element.id.isNullOrBlank()) {
                            warnings.add(
                                ParseWarning(
                                    code = ParseWarning.Code.MISSING_INPUT_ID,
                                    message = "Input element of type '${element.type}' is missing required 'id' property"
                                )
                            )
                        }
                    }
                    else -> {}
                }

                // Recurse into containers
                when (element) {
                    is Container -> walk(element.items)
                    is ColumnSet -> element.columns?.forEach { walk(it.items) }
                    is Carousel -> element.pages.forEach { walk(it.items) }
                    is TabSet -> element.tabs.forEach { walk(it.items) }
                    else -> {}
                }
            }
        }

        walk(card.body)
        return warnings
    }
}
