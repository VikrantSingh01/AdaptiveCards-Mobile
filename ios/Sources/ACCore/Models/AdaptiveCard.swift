import Foundation

public struct AdaptiveCard: Codable, Equatable {
    public let type: String = "AdaptiveCard"
    public var version: String
    public var schema: String?
    public var body: [CardElement]?
    public var actions: [CardAction]?
    public var selectAction: CardAction?
    public var fallbackText: String?
    public var backgroundImage: BackgroundImage?
    public var minHeight: String?
    public var speak: String?
    public var lang: String?
    public var verticalContentAlignment: VerticalAlignment?
    public var refresh: Refresh?
    public var authentication: Authentication?
    public var metadata: [String: AnyCodable]?
    public var rtl: Bool?
    public var references: [DocumentReference]?

    enum CodingKeys: String, CodingKey {
        case type
        case version
        case schema = "$schema"
        case body
        case actions
        case selectAction
        case fallbackText
        case backgroundImage
        case minHeight
        case speak
        case lang
        case verticalContentAlignment
        case refresh
        case authentication
        case metadata
        case rtl
        case references
    }

    public init(
        version: String = "1.6",
        schema: String? = nil,
        body: [CardElement]? = nil,
        actions: [CardAction]? = nil,
        selectAction: CardAction? = nil,
        fallbackText: String? = nil,
        backgroundImage: BackgroundImage? = nil,
        minHeight: String? = nil,
        speak: String? = nil,
        lang: String? = nil,
        verticalContentAlignment: VerticalAlignment? = nil,
        refresh: Refresh? = nil,
        authentication: Authentication? = nil,
        metadata: [String: AnyCodable]? = nil,
        rtl: Bool? = nil,
        references: [DocumentReference]? = nil
    ) {
        self.version = version
        self.schema = schema
        self.body = body
        self.actions = actions
        self.selectAction = selectAction
        self.fallbackText = fallbackText
        self.backgroundImage = backgroundImage
        self.minHeight = minHeight
        self.speak = speak
        self.lang = lang
        self.verticalContentAlignment = verticalContentAlignment
        self.refresh = refresh
        self.authentication = authentication
        self.metadata = metadata
        self.rtl = rtl
        self.references = references
    }

    // Custom decoder to allow missing version in sub-cards (Action.ShowCard)
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // version is optional in sub-cards, defaults to "1.6"
        self.version = try container.decodeIfPresent(String.self, forKey: .version) ?? "1.6"
        self.schema = try container.decodeIfPresent(String.self, forKey: .schema)
        // body can be an array of CardElement, but template files may have
        // "body" as a string expression. Gracefully skip non-array values.
        if let bodyArray = try? container.decodeIfPresent([CardElement].self, forKey: .body) {
            self.body = bodyArray
        } else {
            self.body = nil
        }
        // actions can be an array of CardAction objects, but hostConfig samples may
        // have "actions" as a dictionary (config object). Gracefully skip non-array values.
        if let actionsArray = try? container.decodeIfPresent([CardAction].self, forKey: .actions) {
            self.actions = actionsArray
        } else {
            self.actions = nil
        }
        self.selectAction = try container.decodeIfPresent(CardAction.self, forKey: .selectAction)
        self.fallbackText = try container.decodeIfPresent(String.self, forKey: .fallbackText)
        self.backgroundImage = try container.decodeIfPresent(BackgroundImage.self, forKey: .backgroundImage)
        self.minHeight = try container.decodeIfPresent(String.self, forKey: .minHeight)
        self.speak = try container.decodeIfPresent(String.self, forKey: .speak)
        self.lang = try container.decodeIfPresent(String.self, forKey: .lang)
        self.verticalContentAlignment = try container.decodeIfPresent(VerticalAlignment.self, forKey: .verticalContentAlignment)
        self.refresh = try container.decodeIfPresent(Refresh.self, forKey: .refresh)
        self.authentication = try container.decodeIfPresent(Authentication.self, forKey: .authentication)
        self.metadata = try container.decodeIfPresent([String: AnyCodable].self, forKey: .metadata)
        self.rtl = try container.decodeIfPresent(Bool.self, forKey: .rtl)
        self.references = try container.decodeIfPresent([DocumentReference].self, forKey: .references)
    }
}

// MARK: - DocumentReference

/// A reference entry for CitationRun inlines.
/// Parsed from the top-level `references` array in an AdaptiveCard.
public struct DocumentReference: Codable, Equatable {
    public var type: String?
    public var title: String?
    public var icon: String?
    public var url: String?
    public var abstract: String?

    public init(
        type: String? = nil,
        title: String? = nil,
        icon: String? = nil,
        url: String? = nil,
        abstract: String? = nil
    ) {
        self.type = type
        self.title = title
        self.icon = icon
        self.url = url
        self.abstract = abstract
    }
}
