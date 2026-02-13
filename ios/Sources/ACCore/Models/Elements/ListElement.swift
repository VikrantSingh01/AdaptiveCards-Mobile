import Foundation
// MARK: - List

public struct ListElement: Codable, Equatable {
    public let type: String = "List"
    public var id: String?
    public var items: [CardElement]
    public var maxHeight: String?
    public var style: String?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?
    
    public init(
        id: String? = nil,
        items: [CardElement],
        maxHeight: String? = nil,
        style: String? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil
    ) {
        self.id = id
        self.items = items
        self.maxHeight = maxHeight
        self.style = style
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.requires = requires
    }
}
