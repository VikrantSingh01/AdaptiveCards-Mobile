import Foundation
// MARK: - CompoundButton

public struct CompoundButton: Codable, Equatable {
    public let type: String = "CompoundButton"
    public var id: String?
    public var title: String
    public var subtitle: String?
    public var icon: String?
    public var iconPosition: String?
    public var action: CardAction?
    public var style: String?
    public var isVisible: Bool?
    public var separator: Bool?
    public var spacing: Spacing?
    public var height: BlockElementHeight?
    public var requires: [String: String]?

    public init(
        id: String? = nil,
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        iconPosition: String? = nil,
        action: CardAction? = nil,
        style: String? = nil,
        isVisible: Bool? = nil,
        separator: Bool? = nil,
        spacing: Spacing? = nil,
        height: BlockElementHeight? = nil,
        requires: [String: String]? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconPosition = iconPosition
        self.action = action
        self.style = style
        self.isVisible = isVisible
        self.separator = separator
        self.spacing = spacing
        self.height = height
        self.requires = requires
    }
}
