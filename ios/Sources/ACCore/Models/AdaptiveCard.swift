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
}
