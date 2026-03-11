import Foundation

/// Represents a Fluent UI Icon element in Adaptive Cards.
/// Properties: name (Fluent icon name), size, color, style, horizontalAlignment, spacing, selectAction
public struct IconElement: Codable, Equatable {
    public let type: String
    public var id: String?
    public var name: String
    public var size: String?
    public var color: String?
    public var style: String?
    public var horizontalAlignment: String?
    public var spacing: Spacing?
    public var isVisible: Bool?
    public var selectAction: CardAction?

    public init(
        name: String,
        id: String? = nil,
        size: String? = nil,
        color: String? = nil,
        style: String? = nil,
        horizontalAlignment: String? = nil,
        spacing: Spacing? = nil,
        isVisible: Bool? = nil,
        selectAction: CardAction? = nil
    ) {
        self.type = "Icon"
        self.id = id
        self.name = name
        self.size = size
        self.color = color
        self.style = style
        self.horizontalAlignment = horizontalAlignment
        self.spacing = spacing
        self.isVisible = isVisible
        self.selectAction = selectAction
    }
}
