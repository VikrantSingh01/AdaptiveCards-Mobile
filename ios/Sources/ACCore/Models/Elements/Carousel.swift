// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

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

    enum CodingKeys: String, CodingKey {
        case type, id, pages, timer, initialPage, spacing
        case separator, height, isVisible, requires
    }

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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        // pages can be a template expression string; gracefully default to empty array
        if let pagesArray = try? container.decode([CarouselPage].self, forKey: .pages) {
            self.pages = pagesArray
        } else {
            self.pages = []
        }
        self.timer = try container.decodeIfPresent(Int.self, forKey: .timer)
        self.initialPage = try container.decodeIfPresent(Int.self, forKey: .initialPage)
        self.spacing = try container.decodeIfPresent(Spacing.self, forKey: .spacing)
        self.separator = try container.decodeIfPresent(Bool.self, forKey: .separator)
        self.height = try container.decodeIfPresent(BlockElementHeight.self, forKey: .height)
        self.isVisible = try container.decodeIfPresent(Bool.self, forKey: .isVisible)
        self.requires = try container.decodeIfPresent([String: String].self, forKey: .requires)
    }
}

public struct CarouselPage: Codable, Equatable, Identifiable {
    public var jsonId: String?
    public var items: [CardElement]
    public var selectAction: CardAction?

    /// Unique ID: prefer JSON "id", fall back to deterministic content-based ID
    public var id: String {
        if let jsonId, !jsonId.isEmpty {
            return jsonId
        }
        // Fallback: deterministic ID based on content
        let itemIds = items.map { $0.elementId ?? $0.typeString }.joined(separator: "_")
        let base = itemIds.isEmpty ? "page_empty" : itemIds
        if selectAction != nil {
            return "\(base)_with_action"
        }
        return base
    }

    enum CodingKeys: String, CodingKey {
        case jsonId = "id"
        case items, selectAction, type, rtl
    }

    public init(
        jsonId: String? = nil,
        items: [CardElement],
        selectAction: CardAction? = nil
    ) {
        self.jsonId = jsonId
        self.items = items
        self.selectAction = selectAction
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.jsonId = try container.decodeIfPresent(String.self, forKey: .jsonId)
        self.items = (try? container.decode([CardElement].self, forKey: .items)) ?? []
        self.selectAction = try container.decodeIfPresent(CardAction.self, forKey: .selectAction)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(jsonId, forKey: .jsonId)
        try container.encode(items, forKey: .items)
        try container.encodeIfPresent(selectAction, forKey: .selectAction)
    }
}
