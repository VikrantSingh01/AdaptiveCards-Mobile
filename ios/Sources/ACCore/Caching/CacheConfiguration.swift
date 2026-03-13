// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import Foundation

/// Configuration for the unified card cache.
public struct CacheConfiguration: Sendable {
    /// Maximum number of parsed cards to cache
    public var parseCapacity: Int

    /// Maximum number of template expansion results to cache
    public var templateCapacity: Int

    /// Maximum memory (in bytes) for in-memory image cache
    public var imageMemoryLimit: Int

    /// Maximum disk space (in bytes) for disk image cache
    public var imageDiskLimit: Int

    /// Whether the cache automatically responds to system memory pressure
    public var respondsToMemoryPressure: Bool

    /// Default configuration: balanced for typical usage
    public static let `default` = CacheConfiguration(
        parseCapacity: 64,
        templateCapacity: 128,
        imageMemoryLimit: 50_000_000,    // 50 MB
        imageDiskLimit: 200_000_000,     // 200 MB
        respondsToMemoryPressure: true
    )

    /// Aggressive caching for high-throughput scenarios (e.g., chat lists)
    public static let aggressive = CacheConfiguration(
        parseCapacity: 128,
        templateCapacity: 256,
        imageMemoryLimit: 100_000_000,   // 100 MB
        imageDiskLimit: 500_000_000,     // 500 MB
        respondsToMemoryPressure: true
    )

    /// Minimal caching for memory-constrained environments
    public static let minimal = CacheConfiguration(
        parseCapacity: 16,
        templateCapacity: 32,
        imageMemoryLimit: 10_000_000,    // 10 MB
        imageDiskLimit: 50_000_000,      // 50 MB
        respondsToMemoryPressure: true
    )

    public init(
        parseCapacity: Int = 64,
        templateCapacity: Int = 128,
        imageMemoryLimit: Int = 50_000_000,
        imageDiskLimit: Int = 200_000_000,
        respondsToMemoryPressure: Bool = true
    ) {
        self.parseCapacity = parseCapacity
        self.templateCapacity = templateCapacity
        self.imageMemoryLimit = imageMemoryLimit
        self.imageDiskLimit = imageDiskLimit
        self.respondsToMemoryPressure = respondsToMemoryPressure
    }
}

/// Diagnostics for cache utilization
public struct CacheStats: Sendable {
    public let parseHits: Int
    public let parseMisses: Int
    public var parseHitRate: Double {
        let total = parseHits + parseMisses
        guard total > 0 else { return 0 }
        return Double(parseHits) / Double(total)
    }
    public let templateHits: Int
    public let templateMisses: Int
    public let imageMemoryUsage: Int    // Bytes
    public let imageDiskUsage: Int      // Bytes
    public let imageHits: Int
    public let imageMisses: Int

    public init(
        parseHits: Int = 0, parseMisses: Int = 0,
        templateHits: Int = 0, templateMisses: Int = 0,
        imageMemoryUsage: Int = 0, imageDiskUsage: Int = 0,
        imageHits: Int = 0, imageMisses: Int = 0
    ) {
        self.parseHits = parseHits
        self.parseMisses = parseMisses
        self.templateHits = templateHits
        self.templateMisses = templateMisses
        self.imageMemoryUsage = imageMemoryUsage
        self.imageDiskUsage = imageDiskUsage
        self.imageHits = imageHits
        self.imageMisses = imageMisses
    }
}
