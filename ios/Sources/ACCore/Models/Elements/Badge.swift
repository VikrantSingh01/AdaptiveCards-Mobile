import Foundation

/// Represents a Badge element in Adaptive Cards.
/// Displays a small status indicator with text, optional icon, and styled appearance.
/// Properties: text, style, appearance, icon, size, horizontalAlignment, spacing
public struct Badge: Codable, Equatable {
    public let type: String
    public var id: String?
    public var text: String
    public var style: String?
    public var appearance: String?
    public var icon: String?
    public var size: String?
    public var horizontalAlignment: String?
    public var spacing: Spacing?
    public var isVisible: Bool?
    public var targetWidth: String?

    public init(
        text: String,
        id: String? = nil,
        style: String? = nil,
        appearance: String? = nil,
        icon: String? = nil,
        size: String? = nil,
        horizontalAlignment: String? = nil,
        spacing: Spacing? = nil,
        isVisible: Bool? = nil,
        targetWidth: String? = nil
    ) {
        self.type = "Badge"
        self.id = id
        self.text = text
        self.style = style
        self.appearance = appearance
        self.icon = icon
        self.size = size
        self.horizontalAlignment = horizontalAlignment
        self.spacing = spacing
        self.isVisible = isVisible
        self.targetWidth = targetWidth
    }
}