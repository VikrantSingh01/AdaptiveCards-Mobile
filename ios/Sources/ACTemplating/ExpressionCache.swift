import Foundation

/// Thread-safe cache for parsed expression ASTs
/// Ported from production Teams-AdaptiveCards-Mobile SDK's FunctionCallCache pattern
///
/// Caches parsed `Expression` ASTs to avoid re-parsing the same expression string.
/// Uses LRU eviction and optional TTL for entries.
public final class ExpressionCache: @unchecked Sendable {
    /// Cache entry wrapping a parsed expression with metadata
    private struct CacheEntry {
        let expression: Expression
        let createdAt: Date
        var lastAccessedAt: Date
        var accessCount: Int
    }

    private var cache: [String: CacheEntry] = [:]
    private let lock = NSLock()
    private let maxEntries: Int
    private let ttl: TimeInterval?

    /// Cache statistics
    public private(set) var hits: Int = 0
    public private(set) var misses: Int = 0

    /// Hit rate as a percentage (0.0 - 1.0)
    public var hitRate: Double {
        let total = hits + misses
        return total > 0 ? Double(hits) / Double(total) : 0
    }

    /// Number of entries currently in the cache
    public var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return cache.count
    }

    /// Create a new expression cache
    /// - Parameters:
    ///   - maxEntries: Maximum number of cached expressions (default: 256)
    ///   - ttl: Time-to-live for cache entries in seconds (nil = no expiration)
    public init(maxEntries: Int = 256, ttl: TimeInterval? = nil) {
        self.maxEntries = maxEntries
        self.ttl = ttl
    }

    /// Get a cached expression, or parse and cache it
    /// - Parameters:
    ///   - expression: The expression string
    ///   - parser: The parser to use if the expression is not cached
    /// - Returns: The parsed expression
    public func getOrParse(_ expressionString: String, using parser: ExpressionParser) throws -> Expression {
        lock.lock()

        // Check cache
        if var entry = cache[expressionString] {
            // Check TTL
            if let ttl = ttl, Date().timeIntervalSince(entry.createdAt) > ttl {
                cache.removeValue(forKey: expressionString)
                lock.unlock()
                // Fall through to parse
            } else {
                entry.lastAccessedAt = Date()
                entry.accessCount += 1
                cache[expressionString] = entry
                hits += 1
                lock.unlock()
                return entry.expression
            }
        } else {
            lock.unlock()
        }

        // Parse
        let parsed = try parser.parse(expressionString)

        // Store in cache
        lock.lock()
        defer { lock.unlock() }

        // Evict if at capacity
        if cache.count >= maxEntries {
            evictLRU()
        }

        misses += 1
        cache[expressionString] = CacheEntry(
            expression: parsed,
            createdAt: Date(),
            lastAccessedAt: Date(),
            accessCount: 1
        )

        return parsed
    }

    /// Clear all cached expressions
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        cache.removeAll()
        hits = 0
        misses = 0
    }

    /// Remove expired entries (only relevant when TTL is set)
    public func purgeExpired() {
        guard let ttl = ttl else { return }

        lock.lock()
        defer { lock.unlock() }

        let now = Date()
        cache = cache.filter { _, entry in
            now.timeIntervalSince(entry.createdAt) <= ttl
        }
    }

    // MARK: - Private

    /// Evict the least recently used entry
    private func evictLRU() {
        guard let lruKey = cache.min(by: { $0.value.lastAccessedAt < $1.value.lastAccessedAt })?.key else {
            return
        }
        cache.removeValue(forKey: lruKey)
    }
}
