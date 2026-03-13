// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Unified cache for all Adaptive Cards data: parsed cards, template expansions, and images.
///
/// The host can tune capacity, eviction, and memory pressure responses:
/// ```swift
/// // Use global shared cache (default)
/// let stats = CardCache.shared.stats
///
/// // Custom cache for a specific configuration
/// let cache = CardCache(configuration: .aggressive)
/// ```
public final class CardCache: @unchecked Sendable {
    public static let shared = CardCache()

    private let configuration: CacheConfiguration
    private let lock = NSLock()

    // Parse cache
    private let parseCache: NSCache<NSString, ParseCacheEntry>
    private var _parseHits: Int = 0
    private var _parseMisses: Int = 0

    // Template expansion cache
    private let templateCache: NSCache<NSString, NSString>
    private var _templateHits: Int = 0
    private var _templateMisses: Int = 0

    // Image cache (memory tier)
    #if canImport(UIKit)
    private let imageCache: NSCache<NSString, UIImage>
    private var _imageHits: Int = 0
    private var _imageMisses: Int = 0
    #endif

    // Memory pressure observer
    private var memoryPressureObserver: Any?

    private final class ParseCacheEntry: NSObject {
        let card: AdaptiveCard
        let warnings: [ParseWarning]
        init(card: AdaptiveCard, warnings: [ParseWarning]) {
            self.card = card
            self.warnings = warnings
        }
    }

    public init(configuration: CacheConfiguration = .default) {
        self.configuration = configuration

        self.parseCache = NSCache()
        parseCache.countLimit = configuration.parseCapacity

        self.templateCache = NSCache()
        templateCache.countLimit = configuration.templateCapacity

        #if canImport(UIKit)
        self.imageCache = NSCache()
        imageCache.totalCostLimit = configuration.imageMemoryLimit
        #endif

        if configuration.respondsToMemoryPressure {
            registerMemoryPressureHandler()
        }
    }

    deinit {
        if let observer = memoryPressureObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Parse Cache

    /// Look up a cached parsed card
    public func cachedCard(for json: String) -> (card: AdaptiveCard, warnings: [ParseWarning])? {
        let key = cacheKey(for: json)
        lock.lock()
        let entry = parseCache.object(forKey: key)
        if entry != nil {
            _parseHits += 1
        } else {
            _parseMisses += 1
        }
        lock.unlock()
        guard let entry = entry else { return nil }
        return (entry.card, entry.warnings)
    }

    /// Cache a parsed card
    public func cacheCard(_ card: AdaptiveCard, warnings: [ParseWarning] = [], for json: String) {
        let key = cacheKey(for: json)
        let entry = ParseCacheEntry(card: card, warnings: warnings)
        lock.lock()
        parseCache.setObject(entry, forKey: key)
        lock.unlock()
    }

    // MARK: - Template Cache

    /// Look up a cached template expansion
    public func cachedExpansion(template: String, dataHash: Int) -> String? {
        let key = NSString(string: "\(template.hashValue)_\(dataHash)")
        lock.lock()
        let result = templateCache.object(forKey: key) as String?
        if result != nil {
            _templateHits += 1
        } else {
            _templateMisses += 1
        }
        lock.unlock()
        return result
    }

    /// Cache a template expansion result
    public func cacheExpansion(_ result: String, template: String, dataHash: Int) {
        let key = NSString(string: "\(template.hashValue)_\(dataHash)")
        lock.lock()
        templateCache.setObject(NSString(string: result), forKey: key)
        lock.unlock()
    }

    // MARK: - Image Cache

    #if canImport(UIKit)
    /// Look up a cached image
    public func cachedImage(for url: URL) -> UIImage? {
        let key = NSString(string: url.absoluteString)
        lock.lock()
        let image = imageCache.object(forKey: key)
        if image != nil {
            _imageHits += 1
        } else {
            _imageMisses += 1
        }
        lock.unlock()
        return image
    }

    /// Cache an image
    public func cacheImage(_ image: UIImage, for url: URL) {
        let key = NSString(string: url.absoluteString)
        let cost = Int(image.size.width * image.size.height * image.scale * image.scale * 4) // ~RGBA bytes
        lock.lock()
        imageCache.setObject(image, forKey: key, cost: cost)
        lock.unlock()
    }
    #endif

    // MARK: - Bulk Operations

    /// Clear all caches
    public func clearAll() {
        lock.lock()
        parseCache.removeAllObjects()
        templateCache.removeAllObjects()
        #if canImport(UIKit)
        imageCache.removeAllObjects()
        #endif
        lock.unlock()
    }

    /// Clear only the image cache
    public func clearImages() {
        lock.lock()
        #if canImport(UIKit)
        imageCache.removeAllObjects()
        #endif
        lock.unlock()
    }

    /// Clear only the parse cache
    public func clearParseCache() {
        lock.lock()
        parseCache.removeAllObjects()
        lock.unlock()
    }

    /// Trim caches to reduce memory usage (images first, then templates, then parsed cards)
    public func trimToMemoryLimit() {
        lock.lock()
        #if canImport(UIKit)
        imageCache.removeAllObjects() // Most memory-intensive, evict first
        #endif
        templateCache.removeAllObjects()
        lock.unlock()
    }

    // MARK: - Diagnostics

    /// Current cache statistics
    public var stats: CacheStats {
        lock.lock()
        let s = CacheStats(
            parseHits: _parseHits,
            parseMisses: _parseMisses,
            templateHits: _templateHits,
            templateMisses: _templateMisses,
            imageMemoryUsage: 0, // NSCache doesn't expose current usage
            imageDiskUsage: 0,
            imageHits: {
                #if canImport(UIKit)
                return _imageHits
                #else
                return 0
                #endif
            }(),
            imageMisses: {
                #if canImport(UIKit)
                return _imageMisses
                #else
                return 0
                #endif
            }()
        )
        lock.unlock()
        return s
    }

    // MARK: - Private

    private func cacheKey(for json: String) -> NSString {
        NSString(string: String(json.hashValue))
    }

    private func registerMemoryPressureHandler() {
        #if canImport(UIKit)
        memoryPressureObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.trimToMemoryLimit()
        }
        #endif
    }
}
