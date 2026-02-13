import Foundation

// MARK: - Carousel

public struct Carousel: Codable, Equatable {
    public let type: String = "Carousel"
    public var id: String?
    public var pages: [CarouselPage]
    public var timer: Int?
    public var initialPage: Int?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?

    public init(
        id: String? = nil,
        pages: [CarouselPage],
        timer: Int? = nil,
        initialPage: Int? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil
    ) {
        self.id = id
        self.pages = pages
        self.timer = timer
        self.initialPage = initialPage
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.requires = requires
    }
}

public struct CarouselPage: Codable, Equatable, Identifiable {
    public var items: [CardElement]
    public var selectAction: CardAction?

    // Generate stable ID from items and selectAction
    public var id: String {
        // Use item IDs if available, otherwise generate from content
        let itemIds = items.map { $0.elementId ?? $0.typeString }.joined(separator: "_")
        if itemIds.isEmpty {
            return "page_empty"
        }

        if selectAction != nil {
            // Include a marker that action is present without accessing private properties
            return "\(itemIds)_with_action"
        }

        return itemIds
    }

    public init(
        items: [CardElement],
        selectAction: CardAction? = nil
    ) {
        self.items = items
        self.selectAction = selectAction
    }
}
