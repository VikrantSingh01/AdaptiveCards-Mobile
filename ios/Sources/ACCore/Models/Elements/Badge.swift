// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import Foundation

/// Represents a Badge element in Adaptive Cards.
/// Displays a small status indicator with text, optional icon, and styled appearance.
/// Properties: text, style, appearance, icon, size, horizontalAlignment, spacing
public struct Badge: Codable, Equatable {
    public let type: String
    public var id: String?
    public var text: String?
    public var style: String?
    public var appearance: String?
    public var icon: String?
    public var iconPosition: String?
    public var size: String?
    public var shape: String?
    public var horizontalAlignment: String?
    public var spacing: Spacing?
    public var isVisible: Bool?
    public var targetWidth: String?
    public var tooltip: String?

    public init(
        text: String? = nil,
        id: String? = nil,
        style: String? = nil,
        appearance: String? = nil,
        icon: String? = nil,
        iconPosition: String? = nil,
        size: String? = nil,
        shape: String? = nil,
        horizontalAlignment: String? = nil,
        spacing: Spacing? = nil,
        isVisible: Bool? = nil,
        targetWidth: String? = nil,
        tooltip: String? = nil
    ) {
        self.type = "Badge"
        self.id = id
        self.text = text
        self.style = style
        self.appearance = appearance
        self.icon = icon
        self.iconPosition = iconPosition
        self.size = size
        self.shape = shape
        self.horizontalAlignment = horizontalAlignment
        self.spacing = spacing
        self.isVisible = isVisible
        self.targetWidth = targetWidth
        self.tooltip = tooltip
    }
}