import Foundation

public enum CardAction: Codable, Equatable {
    case submit(SubmitAction)
    case openUrl(OpenUrlAction)
    case showCard(ShowCardAction)
    case execute(ExecuteAction)
    case toggleVisibility(ToggleVisibilityAction)
    
    enum CodingKeys: String, CodingKey {
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "Action.Submit":
            self = .submit(try SubmitAction(from: decoder))
        case "Action.OpenUrl":
            self = .openUrl(try OpenUrlAction(from: decoder))
        case "Action.ShowCard":
            self = .showCard(try ShowCardAction(from: decoder))
        case "Action.Execute":
            self = .execute(try ExecuteAction(from: decoder))
        case "Action.ToggleVisibility":
            self = .toggleVisibility(try ToggleVisibilityAction(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown action type: \(type)"
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .submit(let action):
            try action.encode(to: encoder)
        case .openUrl(let action):
            try action.encode(to: encoder)
        case .showCard(let action):
            try action.encode(to: encoder)
        case .execute(let action):
            try action.encode(to: encoder)
        case .toggleVisibility(let action):
            try action.encode(to: encoder)
        }
    }
}

// MARK: - Base Action Properties

public protocol BaseAction: Codable, Equatable {
    var id: String? { get }
    var title: String? { get }
    var iconUrl: String? { get }
    var style: ActionStyle? { get }
    var tooltip: String? { get }
    var isEnabled: Bool? { get }
    var mode: ActionMode? { get }
}

// MARK: - Action.Submit

public struct SubmitAction: BaseAction {
    public let type: String = "Action.Submit"
    public var id: String?
    public var title: String?
    public var iconUrl: String?
    public var style: ActionStyle?
    public var tooltip: String?
    public var isEnabled: Bool?
    public var mode: ActionMode?
    public var data: [String: AnyCodable]?
    public var associatedInputs: AssociatedInputs?
    
    public init(
        id: String? = nil,
        title: String? = nil,
        iconUrl: String? = nil,
        style: ActionStyle? = nil,
        tooltip: String? = nil,
        isEnabled: Bool? = nil,
        mode: ActionMode? = nil,
        data: [String: AnyCodable]? = nil,
        associatedInputs: AssociatedInputs? = nil
    ) {
        self.id = id
        self.title = title
        self.iconUrl = iconUrl
        self.style = style
        self.tooltip = tooltip
        self.isEnabled = isEnabled
        self.mode = mode
        self.data = data
        self.associatedInputs = associatedInputs
    }
}

// MARK: - Action.OpenUrl

public struct OpenUrlAction: BaseAction {
    public let type: String = "Action.OpenUrl"
    public var id: String?
    public var title: String?
    public var iconUrl: String?
    public var style: ActionStyle?
    public var tooltip: String?
    public var isEnabled: Bool?
    public var mode: ActionMode?
    public var url: String
    
    public init(
        id: String? = nil,
        title: String? = nil,
        iconUrl: String? = nil,
        style: ActionStyle? = nil,
        tooltip: String? = nil,
        isEnabled: Bool? = nil,
        mode: ActionMode? = nil,
        url: String
    ) {
        self.id = id
        self.title = title
        self.iconUrl = iconUrl
        self.style = style
        self.tooltip = tooltip
        self.isEnabled = isEnabled
        self.mode = mode
        self.url = url
    }
}

// MARK: - Action.ShowCard

public struct ShowCardAction: BaseAction {
    public let type: String = "Action.ShowCard"
    public var id: String?
    public var title: String?
    public var iconUrl: String?
    public var style: ActionStyle?
    public var tooltip: String?
    public var isEnabled: Bool?
    public var mode: ActionMode?
    public var card: AdaptiveCard
    
    public init(
        id: String? = nil,
        title: String? = nil,
        iconUrl: String? = nil,
        style: ActionStyle? = nil,
        tooltip: String? = nil,
        isEnabled: Bool? = nil,
        mode: ActionMode? = nil,
        card: AdaptiveCard
    ) {
        self.id = id
        self.title = title
        self.iconUrl = iconUrl
        self.style = style
        self.tooltip = tooltip
        self.isEnabled = isEnabled
        self.mode = mode
        self.card = card
    }
}

// MARK: - Action.Execute

public struct ExecuteAction: BaseAction {
    public let type: String = "Action.Execute"
    public var id: String?
    public var title: String?
    public var iconUrl: String?
    public var style: ActionStyle?
    public var tooltip: String?
    public var isEnabled: Bool?
    public var mode: ActionMode?
    public var verb: String?
    public var data: [String: AnyCodable]?
    public var associatedInputs: AssociatedInputs?
    
    public init(
        id: String? = nil,
        title: String? = nil,
        iconUrl: String? = nil,
        style: ActionStyle? = nil,
        tooltip: String? = nil,
        isEnabled: Bool? = nil,
        mode: ActionMode? = nil,
        verb: String? = nil,
        data: [String: AnyCodable]? = nil,
        associatedInputs: AssociatedInputs? = nil
    ) {
        self.id = id
        self.title = title
        self.iconUrl = iconUrl
        self.style = style
        self.tooltip = tooltip
        self.isEnabled = isEnabled
        self.mode = mode
        self.verb = verb
        self.data = data
        self.associatedInputs = associatedInputs
    }
}

// MARK: - Action.ToggleVisibility

public struct ToggleVisibilityAction: BaseAction {
    public let type: String = "Action.ToggleVisibility"
    public var id: String?
    public var title: String?
    public var iconUrl: String?
    public var style: ActionStyle?
    public var tooltip: String?
    public var isEnabled: Bool?
    public var mode: ActionMode?
    public var targetElements: [TargetElement]
    
    public init(
        id: String? = nil,
        title: String? = nil,
        iconUrl: String? = nil,
        style: ActionStyle? = nil,
        tooltip: String? = nil,
        isEnabled: Bool? = nil,
        mode: ActionMode? = nil,
        targetElements: [TargetElement]
    ) {
        self.id = id
        self.title = title
        self.iconUrl = iconUrl
        self.style = style
        self.tooltip = tooltip
        self.isEnabled = isEnabled
        self.mode = mode
        self.targetElements = targetElements
    }
    
    public struct TargetElement: Codable, Equatable {
        public var elementId: String
        public var isVisible: Bool?
        
        public init(elementId: String, isVisible: Bool? = nil) {
            self.elementId = elementId
            self.isVisible = isVisible
        }
    }
}

// MARK: - AnyCodable for dynamic data

public struct AnyCodable: Codable, Equatable {
    public let value: Any
    
    public init(_ value: Any) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            try container.encodeNil()
        }
    }
    
    public static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        switch (lhs.value, rhs.value) {
        case (let l as Bool, let r as Bool): return l == r
        case (let l as Int, let r as Int): return l == r
        case (let l as Double, let r as Double): return l == r
        case (let l as String, let r as String): return l == r
        default: return false
        }
    }
}
