import Foundation
// MARK: - TabSet

public struct TabSet: Codable, Equatable {
    public let type: String = "TabSet"
    public var id: String?
    public var tabs: [Tab]
    public var selectedTabId: String?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?

    public init(
        id: String? = nil,
        tabs: [Tab],
        selectedTabId: String? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil
    ) {
        self.id = id
        self.tabs = tabs
        self.selectedTabId = selectedTabId
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.requires = requires
    }
}

public struct Tab: Codable, Equatable {
    public var id: String
    public var title: String
    public var icon: String?
    public var items: [CardElement]

    public init(
        id: String,
        title: String,
        icon: String? = nil,
        items: [CardElement]
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.items = items
    }
}
