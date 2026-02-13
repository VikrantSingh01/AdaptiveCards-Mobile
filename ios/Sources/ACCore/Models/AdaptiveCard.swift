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
        rtl: Bool? = nil
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
    }

    // Custom decoder to allow missing version in sub-cards (Action.ShowCard)
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // version is optional in sub-cards, defaults to "1.6"
        self.version = try container.decodeIfPresent(String.self, forKey: .version) ?? "1.6"
        self.schema = try container.decodeIfPresent(String.self, forKey: .schema)
        self.body = try container.decodeIfPresent([CardElement].self, forKey: .body)
        self.actions = try container.decodeIfPresent([CardAction].self, forKey: .actions)
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
    }
}
