import Foundation
// MARK: - CompoundButton

/// Icon descriptor that can be decoded from either a plain string or an object
/// like `{"name": "Calendar", "size": "Small"}`.
public struct IconDescriptor: Codable, Equatable {
    public var name: String
    public var size: String?

    public init(name: String, size: String? = nil) {
        self.name = name
        self.size = size
    }

    public init(from decoder: Decoder) throws {
        // Try as a plain string first
        if let container = try? decoder.singleValueContainer(),
           let stringValue = try? container.decode(String.self) {
            self.name = stringValue
            self.size = nil
            return
        }
        // Otherwise decode as object with name/size
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.size = try container.decodeIfPresent(String.self, forKey: .size)
    }
}

public struct CompoundButton: Codable, Equatable {
    public let type: String = "CompoundButton"
    public var id: String?
    public var title: String
    public var description: String?
    public var icon: IconDescriptor?
    public var iconPosition: String?
    public var selectAction: CardAction?
    public var badge: String?
    public var style: String?
    public var isVisible: Bool?
    public var separator: Bool?
    public var spacing: Spacing?
    public var height: BlockElementHeight?
    public var requires: [String: String]?

    /// Convenience accessor: the icon name as a string regardless of how it was encoded
    public var iconName: String? {
        return icon?.name
    }

    public init(
        id: String? = nil,
        title: String,
        description: String? = nil,
        icon: IconDescriptor? = nil,
        iconPosition: String? = nil,
        selectAction: CardAction? = nil,
        badge: String? = nil,
        style: String? = nil,
        isVisible: Bool? = nil,
        separator: Bool? = nil,
        spacing: Spacing? = nil,
        height: BlockElementHeight? = nil,
        requires: [String: String]? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.iconPosition = iconPosition
        self.selectAction = selectAction
        self.badge = badge
        self.style = style
        self.isVisible = isVisible
        self.separator = separator
        self.spacing = spacing
        self.height = height
        self.requires = requires
    }
}
