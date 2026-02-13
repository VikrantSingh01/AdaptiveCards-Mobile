import Foundation

// MARK: - TextBlock

public struct TextBlock: Codable, Equatable {
    public let type: String = "TextBlock"
    public var id: String?
    public var text: String
    public var color: ForegroundColor?
    public var fontType: FontType?
    public var size: FontSize?
    public var weight: FontWeight?
    public var isSubtle: Bool?
    public var wrap: Bool?
    public var maxLines: Int?
    public var horizontalAlignment: HorizontalAlignment?
    public var style: TextBlockStyle?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?
    public var targetWidth: String?
    public var fallback: CardElement?

    public init(
        id: String? = nil,
        text: String,
        color: ForegroundColor? = nil,
        fontType: FontType? = nil,
        size: FontSize? = nil,
        weight: FontWeight? = nil,
        isSubtle: Bool? = nil,
        wrap: Bool? = nil,
        maxLines: Int? = nil,
        horizontalAlignment: HorizontalAlignment? = nil,
        style: TextBlockStyle? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil,
        targetWidth: String? = nil,
        fallback: CardElement? = nil
    ) {
        self.id = id
        self.text = text
        self.color = color
        self.fontType = fontType
        self.size = size
        self.weight = weight
        self.isSubtle = isSubtle
        self.wrap = wrap
        self.maxLines = maxLines
        self.horizontalAlignment = horizontalAlignment
        self.style = style
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.requires = requires
        self.targetWidth = targetWidth
        self.fallback = fallback
    }
}

// MARK: - RichTextBlock

public struct RichTextBlock: Codable, Equatable {
    public let type: String = "RichTextBlock"
    public var id: String?
    public var inlines: [TextRun]
    public var horizontalAlignment: HorizontalAlignment?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?
    public var fallback: CardElement?

    public init(
        id: String? = nil,
        inlines: [TextRun],
        horizontalAlignment: HorizontalAlignment? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil,
        fallback: CardElement? = nil
    ) {
        self.id = id
        self.inlines = inlines
        self.horizontalAlignment = horizontalAlignment
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.requires = requires
        self.fallback = fallback
    }
}

// MARK: - TextRun

public struct TextRun: Codable, Equatable {
    public let type: String = "TextRun"
    public var text: String
    public var color: ForegroundColor?
    public var fontType: FontType?
    public var size: FontSize?
    public var weight: FontWeight?
    public var isSubtle: Bool?
    public var italic: Bool?
    public var strikethrough: Bool?
    public var underline: Bool?
    public var highlight: Bool?
    public var selectAction: CardAction?

    public init(
        text: String,
        color: ForegroundColor? = nil,
        fontType: FontType? = nil,
        size: FontSize? = nil,
        weight: FontWeight? = nil,
        isSubtle: Bool? = nil,
        italic: Bool? = nil,
        strikethrough: Bool? = nil,
        underline: Bool? = nil,
        highlight: Bool? = nil,
        selectAction: CardAction? = nil
    ) {
        self.text = text
        self.color = color
        self.fontType = fontType
        self.size = size
        self.weight = weight
        self.isSubtle = isSubtle
        self.italic = italic
        self.strikethrough = strikethrough
        self.underline = underline
        self.highlight = highlight
        self.selectAction = selectAction
    }
}

// MARK: - Media

public struct Media: Codable, Equatable {
    public let type: String = "Media"
    public var id: String?
    public var sources: [MediaSource]
    public var poster: String?
    public var altText: String?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?
    public var fallback: CardElement?

    public init(
        id: String? = nil,
        sources: [MediaSource],
        poster: String? = nil,
        altText: String? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil,
        fallback: CardElement? = nil
    ) {
        self.id = id
        self.sources = sources
        self.poster = poster
        self.altText = altText
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.requires = requires
        self.fallback = fallback
    }

    public struct MediaSource: Codable, Equatable {
        public var mimeType: String
        public var url: String

        public init(mimeType: String, url: String) {
            self.mimeType = mimeType
            self.url = url
        }
    }
}
