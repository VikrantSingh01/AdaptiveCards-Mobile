// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import Foundation

/// Performance guardrails to protect against pathological cards that could freeze the UI.
/// Part of `CardConfiguration` — the host can tune these per-card.
public struct PerformanceGuardrails: Sendable {
    /// Maximum number of elements rendered per card (default: 200).
    /// Elements beyond this limit are silently dropped.
    public var maxElementCount: Int

    /// Maximum nesting depth for containers (default: 10).
    /// Deeper nesting is flattened or dropped.
    public var maxNestingDepth: Int

    /// Maximum number of images loaded concurrently per card (default: 6).
    public var maxConcurrentImageLoads: Int

    /// Timeout for image loading before showing placeholder (default: 10s).
    public var imageTimeoutSeconds: Double

    /// Parse timeout — abort and show fallbackText if exceeded (default: 2s).
    public var parseTimeoutSeconds: Double

    public static let `default` = PerformanceGuardrails()

    public init(
        maxElementCount: Int = 200,
        maxNestingDepth: Int = 10,
        maxConcurrentImageLoads: Int = 6,
        imageTimeoutSeconds: Double = 10.0,
        parseTimeoutSeconds: Double = 2.0
    ) {
        self.maxElementCount = maxElementCount
        self.maxNestingDepth = maxNestingDepth
        self.maxConcurrentImageLoads = maxConcurrentImageLoads
        self.imageTimeoutSeconds = imageTimeoutSeconds
        self.parseTimeoutSeconds = parseTimeoutSeconds
    }
}
