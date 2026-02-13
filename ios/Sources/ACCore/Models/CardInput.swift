import Foundation

public enum CardInput: Codable, Equatable {
    case text(TextInput)
    case number(NumberInput)
    case date(DateInput)
    case time(TimeInput)
    case toggle(ToggleInput)
    case choiceSet(ChoiceSetInput)
    case rating(RatingInput)
    case dataGrid(DataGridInput)
    
    enum CodingKeys: String, CodingKey {
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "Input.Text":
            self = .text(try TextInput(from: decoder))
        case "Input.Number":
            self = .number(try NumberInput(from: decoder))
        case "Input.Date":
            self = .date(try DateInput(from: decoder))
        case "Input.Time":
            self = .time(try TimeInput(from: decoder))
        case "Input.Toggle":
            self = .toggle(try ToggleInput(from: decoder))
        case "Input.ChoiceSet":
            self = .choiceSet(try ChoiceSetInput(from: decoder))
        case "Input.Rating":
            self = .rating(try RatingInput(from: decoder))
        case "Input.DataGrid":
            self = .dataGrid(try DataGridInput(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown input type: \(type)"
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .text(let input):
            try input.encode(to: encoder)
        case .number(let input):
            try input.encode(to: encoder)
        case .date(let input):
            try input.encode(to: encoder)
        case .time(let input):
            try input.encode(to: encoder)
        case .toggle(let input):
            try input.encode(to: encoder)
        case .choiceSet(let input):
            try input.encode(to: encoder)
        case .rating(let input):
            try input.encode(to: encoder)
        case .dataGrid(let input):
            try input.encode(to: encoder)
        }
    }
    
    public var id: String {
        switch self {
        case .text(let input): return input.id
        case .number(let input): return input.id
        case .date(let input): return input.id
        case .time(let input): return input.id
        case .toggle(let input): return input.id
        case .choiceSet(let input): return input.id
        case .rating(let input): return input.id
        case .dataGrid(let input): return input.id
        }
    }
    
    public var isRequired: Bool {
        switch self {
        case .text(let input): return input.isRequired ?? false
        case .number(let input): return input.isRequired ?? false
        case .date(let input): return input.isRequired ?? false
        case .time(let input): return input.isRequired ?? false
        case .toggle(let input): return false
        case .choiceSet(let input): return input.isRequired ?? false
        case .rating(let input): return input.isRequired ?? false
        case .dataGrid(let input): return input.isRequired ?? false
        }
    }
}

// MARK: - Input.Text

public struct TextInput: Codable, Equatable {
    public let type: String = "Input.Text"
    public var id: String
    public var isRequired: Bool?
    public var label: String?
    public var placeholder: String?
    public var value: String?
    public var maxLength: Int?
    public var isMultiline: Bool?
    public var style: TextInputStyle?
    public var regex: String?
    public var errorMessage: String?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var inlineAction: CardAction?
    public var fallback: CardElement?

    public init(
        id: String,
        isRequired: Bool? = nil,
        label: String? = nil,
        placeholder: String? = nil,
        value: String? = nil,
        maxLength: Int? = nil,
        isMultiline: Bool? = nil,
        style: TextInputStyle? = nil,
        regex: String? = nil,
        errorMessage: String? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        inlineAction: CardAction? = nil,
        fallback: CardElement? = nil
    ) {
        self.id = id
        self.isRequired = isRequired
        self.label = label
        self.placeholder = placeholder
        self.value = value
        self.maxLength = maxLength
        self.isMultiline = isMultiline
        self.style = style
        self.regex = regex
        self.errorMessage = errorMessage
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.inlineAction = inlineAction
        self.fallback = fallback
    }
}

// MARK: - Input.Number

public struct NumberInput: Codable, Equatable {
    public let type: String = "Input.Number"
    public var id: String
    public var isRequired: Bool?
    public var label: String?
    public var placeholder: String?
    public var value: Double?
    public var min: Double?
    public var max: Double?
    public var errorMessage: String?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var fallback: CardElement?

    public init(
        id: String,
        isRequired: Bool? = nil,
        label: String? = nil,
        placeholder: String? = nil,
        value: Double? = nil,
        min: Double? = nil,
        max: Double? = nil,
        errorMessage: String? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        fallback: CardElement? = nil
    ) {
        self.id = id
        self.isRequired = isRequired
        self.label = label
        self.placeholder = placeholder
        self.value = value
        self.min = min
        self.max = max
        self.errorMessage = errorMessage
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.fallback = fallback
    }
}

// MARK: - Input.Date

public struct DateInput: Codable, Equatable {
    public let type: String = "Input.Date"
    public var id: String
    public var isRequired: Bool?
    public var label: String?
    public var placeholder: String?
    public var value: String?
    public var min: String?
    public var max: String?
    public var errorMessage: String?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var fallback: CardElement?

    public init(
        id: String,
        isRequired: Bool? = nil,
        label: String? = nil,
        placeholder: String? = nil,
        value: String? = nil,
        min: String? = nil,
        max: String? = nil,
        errorMessage: String? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        fallback: CardElement? = nil
    ) {
        self.id = id
        self.isRequired = isRequired
        self.label = label
        self.placeholder = placeholder
        self.value = value
        self.min = min
        self.max = max
        self.errorMessage = errorMessage
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.fallback = fallback
    }
}

// MARK: - Input.Time

public struct TimeInput: Codable, Equatable {
    public let type: String = "Input.Time"
    public var id: String
    public var isRequired: Bool?
    public var label: String?
    public var placeholder: String?
    public var value: String?
    public var min: String?
    public var max: String?
    public var errorMessage: String?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var fallback: CardElement?

    public init(
        id: String,
        isRequired: Bool? = nil,
        label: String? = nil,
        placeholder: String? = nil,
        value: String? = nil,
        min: String? = nil,
        max: String? = nil,
        errorMessage: String? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        fallback: CardElement? = nil
    ) {
        self.id = id
        self.isRequired = isRequired
        self.label = label
        self.placeholder = placeholder
        self.value = value
        self.min = min
        self.max = max
        self.errorMessage = errorMessage
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.fallback = fallback
    }
}

// MARK: - Input.Toggle

public struct ToggleInput: Codable, Equatable {
    public let type: String = "Input.Toggle"
    public var id: String
    public var title: String
    public var value: String?
    public var valueOn: String?
    public var valueOff: String?
    public var wrap: Bool?
    public var label: String?
    public var errorMessage: String?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var fallback: CardElement?

    public init(
        id: String,
        title: String,
        value: String? = nil,
        valueOn: String? = nil,
        valueOff: String? = nil,
        wrap: Bool? = nil,
        label: String? = nil,
        errorMessage: String? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        fallback: CardElement? = nil
    ) {
        self.id = id
        self.title = title
        self.value = value
        self.valueOn = valueOn
        self.valueOff = valueOff
        self.wrap = wrap
        self.label = label
        self.errorMessage = errorMessage
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.fallback = fallback
    }
}

// MARK: - Input.ChoiceSet

public struct ChoiceSetInput: Codable, Equatable {
    public let type: String = "Input.ChoiceSet"
    public var id: String
    public var isRequired: Bool?
    public var label: String?
    public var choices: [Choice]
    public var value: String?
    public var style: ChoiceInputStyle?
    public var isMultiSelect: Bool?
    public var placeholder: String?
    public var wrap: Bool?
    public var errorMessage: String?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var fallback: CardElement?

    public init(
        id: String,
        isRequired: Bool? = nil,
        label: String? = nil,
        choices: [Choice],
        value: String? = nil,
        style: ChoiceInputStyle? = nil,
        isMultiSelect: Bool? = nil,
        placeholder: String? = nil,
        wrap: Bool? = nil,
        errorMessage: String? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        fallback: CardElement? = nil
    ) {
        self.id = id
        self.isRequired = isRequired
        self.label = label
        self.choices = choices
        self.value = value
        self.style = style
        self.isMultiSelect = isMultiSelect
        self.placeholder = placeholder
        self.wrap = wrap
        self.errorMessage = errorMessage
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.fallback = fallback
    }
    
    public struct Choice: Codable, Equatable {
        public var title: String
        public var value: String
        
        public init(title: String, value: String) {
            self.title = title
            self.value = value
        }
    }
}
