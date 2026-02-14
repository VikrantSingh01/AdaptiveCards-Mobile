package com.microsoft.adaptivecards.templating

import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicInteger

/**
 * Thread-safe cache for parsed expression ASTs.
 * Ported from production Teams-AdaptiveCards-Mobile SDK's FunctionCallCache pattern.
 *
 * Caches parsed [Expression] ASTs to avoid re-parsing the same expression string.
 * Uses LRU eviction and optional TTL for entries.
 *
 * @param maxEntries Maximum number of cached expressions (default: 256)
 * @param ttlMillis Time-to-live for cache entries in milliseconds (null = no expiration)
 */
class ExpressionCache(
    private val maxEntries: Int = 256,
    private val ttlMillis: Long? = null
) {
    private data class CacheEntry(
        val expression: Expression,
        val createdAt: Long = System.currentTimeMillis(),
        var lastAccessedAt: Long = System.currentTimeMillis(),
        var accessCount: Int = 1
    )

    private val cache = ConcurrentHashMap<String, CacheEntry>()
    private val _hits = AtomicInteger(0)
    private val _misses = AtomicInteger(0)

    /** Number of cache hits */
    val hits: Int get() = _hits.get()

    /** Number of cache misses */
    val misses: Int get() = _misses.get()

    /** Hit rate as a ratio (0.0 - 1.0) */
    val hitRate: Double
        get() {
            val total = hits + misses
            return if (total > 0) hits.toDouble() / total else 0.0
        }

    /** Number of entries currently in the cache */
    val count: Int get() = cache.size

    /**
     * Get a cached expression, or parse and cache it.
     *
     * @param expressionString The expression string
     * @param parser The parser to use if the expression is not cached
     * @return The parsed expression
     */
    fun getOrParse(expressionString: String, parser: ExpressionParser): Expression {
        // Check cache
        cache[expressionString]?.let { entry ->
            // Check TTL
            if (ttlMillis != null && System.currentTimeMillis() - entry.createdAt > ttlMillis) {
                cache.remove(expressionString)
            } else {
                entry.lastAccessedAt = System.currentTimeMillis()
                entry.accessCount++
                _hits.incrementAndGet()
                return entry.expression
            }
        }

        // Parse
        val parsed = parser.parse(expressionString)

        // Evict if at capacity
        if (cache.size >= maxEntries) {
            evictLRU()
        }

        _misses.incrementAndGet()
        cache[expressionString] = CacheEntry(expression = parsed)

        return parsed
    }

    /** Clear all cached expressions */
    fun clear() {
        cache.clear()
        _hits.set(0)
        _misses.set(0)
    }

    /** Remove expired entries (only relevant when TTL is set) */
    fun purgeExpired() {
        val ttl = ttlMillis ?: return
        val now = System.currentTimeMillis()
        cache.entries.removeIf { now - it.value.createdAt > ttl }
    }

    private fun evictLRU() {
        cache.entries
            .minByOrNull { it.value.lastAccessedAt }
            ?.let { cache.remove(it.key) }
    }
}
