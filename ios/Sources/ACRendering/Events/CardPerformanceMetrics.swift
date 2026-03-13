// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

import Foundation

/// Performance telemetry for a single card render. Delivered via
/// `CardLifecycleEvent.performanceReport` after the card is fully loaded.
public struct CardPerformanceMetrics: Sendable {
    // Timing
    public let parseTimeMs: Double
    public let templateExpansionTimeMs: Double
    public let firstRenderTimeMs: Double
    public let fullyLoadedTimeMs: Double
    public let totalImageLoadTimeMs: Double

    // Counts
    public let elementCount: Int
    public let inputCount: Int
    public let imageCount: Int
    public let actionCount: Int

    // Cache effectiveness
    public let parseCacheHit: Bool
    public let imagesCachedCount: Int
    public let imagesLoadedCount: Int
    public let templateCacheHit: Bool

    // Errors
    public let unknownElementTypes: [String]
    public let failedImageUrls: [String]
    public let validationErrorCount: Int

    public init(
        parseTimeMs: Double = 0,
        templateExpansionTimeMs: Double = 0,
        firstRenderTimeMs: Double = 0,
        fullyLoadedTimeMs: Double = 0,
        totalImageLoadTimeMs: Double = 0,
        elementCount: Int = 0,
        inputCount: Int = 0,
        imageCount: Int = 0,
        actionCount: Int = 0,
        parseCacheHit: Bool = false,
        imagesCachedCount: Int = 0,
        imagesLoadedCount: Int = 0,
        templateCacheHit: Bool = false,
        unknownElementTypes: [String] = [],
        failedImageUrls: [String] = [],
        validationErrorCount: Int = 0
    ) {
        self.parseTimeMs = parseTimeMs
        self.templateExpansionTimeMs = templateExpansionTimeMs
        self.firstRenderTimeMs = firstRenderTimeMs
        self.fullyLoadedTimeMs = fullyLoadedTimeMs
        self.totalImageLoadTimeMs = totalImageLoadTimeMs
        self.elementCount = elementCount
        self.inputCount = inputCount
        self.imageCount = imageCount
        self.actionCount = actionCount
        self.parseCacheHit = parseCacheHit
        self.imagesCachedCount = imagesCachedCount
        self.imagesLoadedCount = imagesLoadedCount
        self.templateCacheHit = templateCacheHit
        self.unknownElementTypes = unknownElementTypes
        self.failedImageUrls = failedImageUrls
        self.validationErrorCount = validationErrorCount
    }
}
