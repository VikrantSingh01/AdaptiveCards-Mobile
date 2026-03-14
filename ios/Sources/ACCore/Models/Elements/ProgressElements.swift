// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import Foundation
// MARK: - ProgressBar

public struct ProgressBar: Codable, Equatable {
    public let type: String = "ProgressBar"
    public var id: String?
    public var value: Double?
    public var max: Double?
    public var label: String?
    public var color: String?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?

    /// Normalized progress fraction (0.0–1.0).
    /// - When `max` is explicitly set: `value / max`
    /// - When `max` is nil and `value` <= 1: treat value as already a 0–1 fraction
    /// - When `max` is nil and `value` > 1: treat as 0–100 scale
    public var normalizedValue: Double {
        let v = value ?? 0
        if let m = max {
            guard m > 0 else { return 0 }
            return Swift.min(Swift.max(v / m, 0), 1)
        }
        // No explicit max: auto-detect scale
        if v >= 0 && v <= 1 {
            return Swift.max(v, 0)
        }
        return Swift.min(Swift.max(v / 100, 0), 1)
    }

    public init(
        id: String? = nil,
        value: Double? = nil,
        max: Double? = nil,
        label: String? = nil,
        color: String? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil
    ) {
        self.id = id
        self.value = value
        self.max = max
        self.label = label
        self.color = color
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.requires = requires
    }
}

// MARK: - ProgressRing

public struct ProgressRing: Codable, Equatable {
    public let type: String = "ProgressRing"
    public var id: String?
    public var label: String?
    public var labelPosition: String?
    public var size: String?
    public var color: String?
    public var horizontalAlignment: HorizontalAlignment?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?

    public init(
        id: String? = nil,
        label: String? = nil,
        labelPosition: String? = nil,
        size: String? = nil,
        color: String? = nil,
        horizontalAlignment: HorizontalAlignment? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil
    ) {
        self.id = id
        self.label = label
        self.labelPosition = labelPosition
        self.size = size
        self.color = color
        self.horizontalAlignment = horizontalAlignment
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.requires = requires
    }
}

// MARK: - Spinner

public struct Spinner: Codable, Equatable {
    public let type: String = "Spinner"
    public var id: String?
    public var size: SpinnerSize?
    public var label: String?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?

    public init(
        id: String? = nil,
        size: SpinnerSize? = nil,
        label: String? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil
    ) {
        self.id = id
        self.size = size
        self.label = label
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.requires = requires
    }
}
