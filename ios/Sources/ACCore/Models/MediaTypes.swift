import Foundation

// MARK: - TextBlock

public struct TextBlock: Codable, Equatable {
    public let type: String = "TextBlock"
    public var id: String?
    public var text: String?
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
        text: String? = nil,
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

    enum CodingKeys: String, CodingKey {
        case type, id, text, color, fontType, size, weight, isSubtle, wrap
        case maxLines, horizontalAlignment, style, spacing, separator
        case height, isVisible, requires, targetWidth, fallback
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        self.color = try container.decodeIfPresent(ForegroundColor.self, forKey: .color)
        self.fontType = try container.decodeIfPresent(FontType.self, forKey: .fontType)
        self.size = try container.decodeIfPresent(FontSize.self, forKey: .size)
        self.weight = try container.decodeIfPresent(FontWeight.self, forKey: .weight)
        self.isSubtle = try container.decodeIfPresent(Bool.self, forKey: .isSubtle)
        self.wrap = try container.decodeIfPresent(Bool.self, forKey: .wrap)
        self.maxLines = try container.decodeIfPresent(Int.self, forKey: .maxLines)
        self.horizontalAlignment = try container.decodeIfPresent(HorizontalAlignment.self, forKey: .horizontalAlignment)
        self.style = try container.decodeIfPresent(TextBlockStyle.self, forKey: .style)
        self.spacing = try container.decodeIfPresent(Spacing.self, forKey: .spacing)
        self.separator = try container.decodeIfPresent(Bool.self, forKey: .separator)
        self.height = try container.decodeIfPresent(BlockElementHeight.self, forKey: .height)
        self.isVisible = try container.decodeIfPresent(Bool.self, forKey: .isVisible)
        self.requires = try container.decodeIfPresent([String: String].self, forKey: .requires)
        self.targetWidth = try container.decodeIfPresent(String.self, forKey: .targetWidth)
        self.fallback = try container.decodeIfPresent(CardElement.self, forKey: .fallback)
    }
}

// MARK: - RichTextBlock

public struct RichTextBlock: Codable, Equatable {
    public let type: String = "RichTextBlock"
    public var id: String?
    public var inlines: [InlineElement]
    public var horizontalAlignment: HorizontalAlignment?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?
    public var fallback: CardElement?

    public init(
        id: String? = nil,
        inlines: [InlineElement],
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

// MARK: - InlineElement

/// Polymorphic inline element within a RichTextBlock.
/// Supports TextRun (styled text) and CitationRun (citation badge).
public enum InlineElement: Codable, Equatable {
    case textRun(TextRun)
    case citationRun(CitationRun)

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        // Try plain string shorthand first — maps to TextRun
        if let container = try? decoder.singleValueContainer(),
           let stringValue = try? container.decode(String.self) {
            self = .textRun(TextRun(text: stringValue))
            return
        }

        // Peek at "type" to determine which inline to decode
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decodeIfPresent(String.self, forKey: .type)

        switch type {
        case "CitationRun":
            self = .citationRun(try CitationRun(from: decoder))
        default:
            // Default to TextRun for "TextRun" type or missing type
            self = .textRun(try TextRun(from: decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .textRun(let textRun):
            try textRun.encode(to: encoder)
        case .citationRun(let citationRun):
            try citationRun.encode(to: encoder)
        }
    }

    /// Convenience: the display text for this inline element
    public var text: String {
        switch self {
        case .textRun(let run): return run.text
        case .citationRun(let run): return run.text
        }
    }
}

// MARK: - CitationRun

/// An inline citation badge that renders as a superscript `[N]` reference.
public struct CitationRun: Codable, Equatable {
    public let type: String = "CitationRun"
    public var text: String
    public var referenceIndex: Int

    public init(text: String, referenceIndex: Int) {
        self.text = text
        self.referenceIndex = referenceIndex
    }

    enum CodingKeys: String, CodingKey {
        case type, text, referenceIndex
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

    /// Custom decoder: accept both a plain string (shorthand) and a full TextRun object.
    /// Per Adaptive Cards spec, inlines can contain plain strings as shorthand for
    /// `{"type": "TextRun", "text": "<string>"}`.
    public init(from decoder: Decoder) throws {
        // Try as a plain string first (shorthand form)
        if let container = try? decoder.singleValueContainer(),
           let stringValue = try? container.decode(String.self) {
            self.text = stringValue
            self.color = nil
            self.fontType = nil
            self.size = nil
            self.weight = nil
            self.isSubtle = nil
            self.italic = nil
            self.strikethrough = nil
            self.underline = nil
            self.highlight = nil
            self.selectAction = nil
            return
        }
        // Otherwise decode as object
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: .text)
        self.color = try container.decodeIfPresent(ForegroundColor.self, forKey: .color)
        self.fontType = try container.decodeIfPresent(FontType.self, forKey: .fontType)
        self.size = try container.decodeIfPresent(FontSize.self, forKey: .size)
        self.weight = try container.decodeIfPresent(FontWeight.self, forKey: .weight)
        self.isSubtle = try container.decodeIfPresent(Bool.self, forKey: .isSubtle)
        self.italic = try container.decodeIfPresent(Bool.self, forKey: .italic)
        self.strikethrough = try container.decodeIfPresent(Bool.self, forKey: .strikethrough)
        self.underline = try container.decodeIfPresent(Bool.self, forKey: .underline)
        self.highlight = try container.decodeIfPresent(Bool.self, forKey: .highlight)
        self.selectAction = try container.decodeIfPresent(CardAction.self, forKey: .selectAction)
    }

    enum CodingKeys: String, CodingKey {
        case type, text, color, fontType, size, weight, isSubtle
        case italic, strikethrough, underline, highlight, selectAction
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
