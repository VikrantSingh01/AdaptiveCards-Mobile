// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import Foundation

public indirect enum CardAction: Codable, Equatable {
    case submit(SubmitAction)
    case openUrl(OpenUrlAction)
    case showCard(ShowCardAction)
    case execute(ExecuteAction)
    case toggleVisibility(ToggleVisibilityAction)
    case popover(PopoverAction)
    case runCommands(RunCommandsAction)
    case openUrlDialog(OpenUrlDialogAction)
    case resetInputs(ResetInputsAction)
    case unknown(type: String)

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
        case "Action.Popover":
            self = .popover(try PopoverAction(from: decoder))
        case "Action.RunCommands":
            self = .runCommands(try RunCommandsAction(from: decoder))
        case "Action.OpenUrlDialog":
            self = .openUrlDialog(try OpenUrlDialogAction(from: decoder))
        case "Action.ResetInputs":
            self = .resetInputs(try ResetInputsAction(from: decoder))
        default:
            // Gracefully handle unknown action types per Adaptive Cards spec
            self = .unknown(type: type)
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
        case .popover(let action):
            try action.encode(to: encoder)
        case .runCommands(let action):
            try action.encode(to: encoder)
        case .openUrlDialog(let action):
            try action.encode(to: encoder)
        case .resetInputs(let action):
            try action.encode(to: encoder)
        case .unknown(let type):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
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
    public var data: AnyCodable?  // Can be string or dictionary
    public var associatedInputs: AssociatedInputs?

    public init(
        id: String? = nil,
        title: String? = nil,
        iconUrl: String? = nil,
        style: ActionStyle? = nil,
        tooltip: String? = nil,
        isEnabled: Bool? = nil,
        mode: ActionMode? = nil,
        data: AnyCodable? = nil,
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
    public var data: AnyCodable?  // Can be string or dictionary
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
        data: AnyCodable? = nil,
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

        /// AC spec allows targetElements as either strings or objects:
        /// `"targetElements": ["id1", {"elementId": "id2", "isVisible": true}]`
        public init(from decoder: Decoder) throws {
            // Try as a plain string first (shorthand: just the element ID)
            if let container = try? decoder.singleValueContainer(),
               let stringValue = try? container.decode(String.self) {
                self.elementId = stringValue
                self.isVisible = nil
                return
            }
            // Otherwise decode as object
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.elementId = try container.decode(String.self, forKey: .elementId)
            self.isVisible = try container.decodeIfPresent(Bool.self, forKey: .isVisible)
        }
    }
}

// MARK: - Action.Popover

public struct PopoverAction: BaseAction {
    public let type: String = "Action.Popover"
    public var id: String?
    public var title: String?
    public var iconUrl: String?
    public var style: ActionStyle?
    public var tooltip: String?
    public var isEnabled: Bool?
    public var mode: ActionMode?
    /// The content to display in the popover (single CardElement from JSON "content" field)
    public var content: CardElement?
    public var dismissBehavior: String?

    enum CodingKeys: String, CodingKey {
        case type, id, title, iconUrl, style, tooltip, isEnabled, mode
        case content, dismissBehavior
    }

    public init(
        id: String? = nil,
        title: String? = nil,
        iconUrl: String? = nil,
        style: ActionStyle? = nil,
        tooltip: String? = nil,
        isEnabled: Bool? = nil,
        mode: ActionMode? = nil,
        content: CardElement? = nil,
        dismissBehavior: String? = nil
    ) {
        self.id = id
        self.title = title
        self.iconUrl = iconUrl
        self.style = style
        self.tooltip = tooltip
        self.isEnabled = isEnabled
        self.mode = mode
        self.content = content
        self.dismissBehavior = dismissBehavior
    }
}

// MARK: - Action.RunCommands

public struct RunCommandsAction: BaseAction {
    public let type: String = "Action.RunCommands"
    public var id: String?
    public var title: String?
    public var iconUrl: String?
    public var style: ActionStyle?
    public var tooltip: String?
    public var isEnabled: Bool?
    public var mode: ActionMode?
    public var commands: [Command]

    public init(
        id: String? = nil,
        title: String? = nil,
        iconUrl: String? = nil,
        style: ActionStyle? = nil,
        tooltip: String? = nil,
        isEnabled: Bool? = nil,
        mode: ActionMode? = nil,
        commands: [Command]
    ) {
        self.id = id
        self.title = title
        self.iconUrl = iconUrl
        self.style = style
        self.tooltip = tooltip
        self.isEnabled = isEnabled
        self.mode = mode
        self.commands = commands
    }

    public struct Command: Codable, Equatable {
        public var type: String
        public var id: String
        public var data: [String: AnyCodable]?

        public init(type: String, id: String, data: [String: AnyCodable]? = nil) {
            self.type = type
            self.id = id
            self.data = data
        }
    }
}

// MARK: - Action.OpenUrlDialog

public struct OpenUrlDialogAction: BaseAction {
    public let type: String = "Action.OpenUrlDialog"
    public var id: String?
    public var title: String?
    public var iconUrl: String?
    public var style: ActionStyle?
    public var tooltip: String?
    public var isEnabled: Bool?
    public var mode: ActionMode?
    public var url: String
    public var dialogTitle: String?

    public init(
        id: String? = nil,
        title: String? = nil,
        iconUrl: String? = nil,
        style: ActionStyle? = nil,
        tooltip: String? = nil,
        isEnabled: Bool? = nil,
        mode: ActionMode? = nil,
        url: String,
        dialogTitle: String? = nil
    ) {
        self.id = id
        self.title = title
        self.iconUrl = iconUrl
        self.style = style
        self.tooltip = tooltip
        self.isEnabled = isEnabled
        self.mode = mode
        self.url = url
        self.dialogTitle = dialogTitle
    }
}

// MARK: - Action.ResetInputs

public struct ResetInputsAction: BaseAction {
    public let type: String = "Action.ResetInputs"
    public var id: String?
    public var title: String?
    public var iconUrl: String?
    public var style: ActionStyle?
    public var tooltip: String?
    public var isEnabled: Bool?
    public var mode: ActionMode?
    public var targetInputIds: [String]?

    public init(
        id: String? = nil,
        title: String? = nil,
        iconUrl: String? = nil,
        style: ActionStyle? = nil,
        tooltip: String? = nil,
        isEnabled: Bool? = nil,
        mode: ActionMode? = nil,
        targetInputIds: [String]? = nil
    ) {
        self.id = id
        self.title = title
        self.iconUrl = iconUrl
        self.style = style
        self.tooltip = tooltip
        self.isEnabled = isEnabled
        self.mode = mode
        self.targetInputIds = targetInputIds
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

// MARK: - CardAction Convenience Properties

extension CardAction {
    /// Returns the title of the action regardless of the specific action type
    public var title: String? {
        switch self {
        case .submit(let a): return a.title
        case .openUrl(let a): return a.title
        case .showCard(let a): return a.title
        case .execute(let a): return a.title
        case .toggleVisibility(let a): return a.title
        case .popover(let a): return a.title
        case .runCommands(let a): return a.title
        case .openUrlDialog(let a): return a.title
        case .resetInputs(let a): return a.title
        case .unknown: return nil
        }
    }

    /// Returns the icon URL of the action regardless of the specific action type
    public var iconUrl: String? {
        switch self {
        case .submit(let a): return a.iconUrl
        case .openUrl(let a): return a.iconUrl
        case .showCard(let a): return a.iconUrl
        case .execute(let a): return a.iconUrl
        case .toggleVisibility(let a): return a.iconUrl
        case .popover(let a): return a.iconUrl
        case .runCommands(let a): return a.iconUrl
        case .openUrlDialog(let a): return a.iconUrl
        case .resetInputs(let a): return a.iconUrl
        case .unknown: return nil
        }
    }

    /// Returns the mode (primary/secondary) of the action regardless of the specific action type
    public var mode: ActionMode? {
        switch self {
        case .submit(let a): return a.mode
        case .openUrl(let a): return a.mode
        case .showCard(let a): return a.mode
        case .execute(let a): return a.mode
        case .toggleVisibility(let a): return a.mode
        case .popover(let a): return a.mode
        case .runCommands(let a): return a.mode
        case .openUrlDialog(let a): return a.mode
        case .resetInputs(let a): return a.mode
        case .unknown: return nil
        }
    }
}

// MARK: - CardAction Identifiable Extension

extension CardAction: Identifiable {
    /// Stable identifier for CardAction
    /// Uses the action's id if available, otherwise uses type and title as fallback
    public var id: String {
        let actionId: String?
        let actionTitle: String?

        switch self {
        case .submit(let action):
            actionId = action.id
            actionTitle = action.title
        case .openUrl(let action):
            actionId = action.id
            actionTitle = action.title
        case .showCard(let action):
            actionId = action.id
            actionTitle = action.title
        case .execute(let action):
            actionId = action.id
            actionTitle = action.title
        case .toggleVisibility(let action):
            actionId = action.id
            actionTitle = action.title
        case .popover(let action):
            actionId = action.id
            actionTitle = action.title
        case .runCommands(let action):
            actionId = action.id
            actionTitle = action.title
        case .openUrlDialog(let action):
            actionId = action.id
            actionTitle = action.title
        case .resetInputs(let action):
            actionId = action.id
            actionTitle = action.title
        case .unknown(let type):
            actionId = nil
            actionTitle = type
        }

        if let actionId = actionId, !actionId.isEmpty {
            return actionId
        }
        // Use type and title as fallback for stable identifier
        // Note: In practice, actions should have either an ID or a title
        let title = (actionTitle?.isEmpty == false) ? (actionTitle ?? "action") : "action"
        return "\(typeString)_\(title)"
    }

    private var typeString: String {
        switch self {
        case .submit: return "submit"
        case .openUrl: return "openUrl"
        case .showCard: return "showCard"
        case .execute: return "execute"
        case .toggleVisibility: return "toggleVisibility"
        case .popover: return "popover"
        case .runCommands: return "runCommands"
        case .openUrlDialog: return "openUrlDialog"
        case .resetInputs: return "resetInputs"
        case .unknown(let type): return type
        }
    }
}
