// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import Foundation

/// Decodes labelWidth which can be either a String (e.g. "60px") or a number (percentage).
/// Per AC v1.6 spec, labelWidth accepts both types.
private func decodeLabelWidth<K: CodingKey>(from container: KeyedDecodingContainer<K>, forKey key: K) throws -> String? {
    if let stringValue = try? container.decodeIfPresent(String.self, forKey: key) {
        return stringValue
    }
    if let intValue = try? container.decodeIfPresent(Int.self, forKey: key) {
        return String(intValue)
    }
    if let doubleValue = try? container.decodeIfPresent(Double.self, forKey: key) {
        return String(Int(doubleValue))
    }
    return nil
}

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
    public var labelPosition: String?
    public var labelWidth: String?
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

    enum CodingKeys: String, CodingKey {
        case type, id, isRequired, label, labelPosition, labelWidth, placeholder, value, maxLength
        case isMultiline, style, regex, errorMessage, spacing, separator
        case height, isVisible, inlineAction, fallback
    }

    public init(
        id: String,
        isRequired: Bool? = nil,
        label: String? = nil,
        labelPosition: String? = nil,
        labelWidth: String? = nil,
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
        self.labelPosition = labelPosition
        self.labelWidth = labelWidth
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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.isRequired = try container.decodeBoolFromStringIfPresent(forKey: .isRequired)
        self.label = try container.decodeIfPresent(String.self, forKey: .label)
        self.labelPosition = try container.decodeIfPresent(String.self, forKey: .labelPosition)
        self.labelWidth = try decodeLabelWidth(from: container, forKey: .labelWidth)
        self.placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
        self.maxLength = try container.decodeIfPresent(Int.self, forKey: .maxLength)
        self.isMultiline = try container.decodeIfPresent(Bool.self, forKey: .isMultiline)
        self.style = try container.decodeIfPresent(TextInputStyle.self, forKey: .style)
        self.regex = try container.decodeIfPresent(String.self, forKey: .regex)
        self.errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
        self.spacing = try container.decodeIfPresent(Spacing.self, forKey: .spacing)
        self.separator = try container.decodeIfPresent(Bool.self, forKey: .separator)
        self.height = try container.decodeIfPresent(BlockElementHeight.self, forKey: .height)
        self.isVisible = try container.decodeIfPresent(Bool.self, forKey: .isVisible)
        self.inlineAction = try container.decodeIfPresent(CardAction.self, forKey: .inlineAction)
        self.fallback = try container.decodeIfPresent(CardElement.self, forKey: .fallback)
    }
}

// MARK: - Input.Number

public struct NumberInput: Codable, Equatable {
    public let type: String = "Input.Number"
    public var id: String
    public var isRequired: Bool?
    public var label: String?
    public var labelPosition: String?
    public var labelWidth: String?
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

    enum CodingKeys: String, CodingKey {
        case type, id, isRequired, label, labelPosition, labelWidth, placeholder, value, min, max
        case errorMessage, spacing, separator, height, isVisible, fallback
    }

    public init(
        id: String,
        isRequired: Bool? = nil,
        label: String? = nil,
        labelPosition: String? = nil,
        labelWidth: String? = nil,
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
        self.labelPosition = labelPosition
        self.labelWidth = labelWidth
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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.isRequired = try container.decodeBoolFromStringIfPresent(forKey: .isRequired)
        self.label = try container.decodeIfPresent(String.self, forKey: .label)
        self.labelPosition = try container.decodeIfPresent(String.self, forKey: .labelPosition)
        self.labelWidth = try decodeLabelWidth(from: container, forKey: .labelWidth)
        self.placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        self.value = try container.decodeIfPresent(Double.self, forKey: .value)
        self.min = try container.decodeIfPresent(Double.self, forKey: .min)
        self.max = try container.decodeIfPresent(Double.self, forKey: .max)
        self.errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
        self.spacing = try container.decodeIfPresent(Spacing.self, forKey: .spacing)
        self.separator = try container.decodeIfPresent(Bool.self, forKey: .separator)
        self.height = try container.decodeIfPresent(BlockElementHeight.self, forKey: .height)
        self.isVisible = try container.decodeIfPresent(Bool.self, forKey: .isVisible)
        self.fallback = try container.decodeIfPresent(CardElement.self, forKey: .fallback)
    }
}

// MARK: - Input.Date

public struct DateInput: Codable, Equatable {
    public let type: String = "Input.Date"
    public var id: String
    public var isRequired: Bool?
    public var label: String?
    public var labelPosition: String?
    public var labelWidth: String?
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

    enum CodingKeys: String, CodingKey {
        case type, id, isRequired, label, labelPosition, labelWidth, placeholder, value, min, max
        case errorMessage, spacing, separator, height, isVisible, fallback
    }

    public init(
        id: String,
        isRequired: Bool? = nil,
        label: String? = nil,
        labelPosition: String? = nil,
        labelWidth: String? = nil,
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
        self.labelPosition = labelPosition
        self.labelWidth = labelWidth
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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.isRequired = try container.decodeBoolFromStringIfPresent(forKey: .isRequired)
        self.label = try container.decodeIfPresent(String.self, forKey: .label)
        self.labelPosition = try container.decodeIfPresent(String.self, forKey: .labelPosition)
        self.labelWidth = try decodeLabelWidth(from: container, forKey: .labelWidth)
        self.placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
        self.min = try container.decodeIfPresent(String.self, forKey: .min)
        self.max = try container.decodeIfPresent(String.self, forKey: .max)
        self.errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
        self.spacing = try container.decodeIfPresent(Spacing.self, forKey: .spacing)
        self.separator = try container.decodeIfPresent(Bool.self, forKey: .separator)
        self.height = try container.decodeIfPresent(BlockElementHeight.self, forKey: .height)
        self.isVisible = try container.decodeIfPresent(Bool.self, forKey: .isVisible)
        self.fallback = try container.decodeIfPresent(CardElement.self, forKey: .fallback)
    }
}

// MARK: - Input.Time

public struct TimeInput: Codable, Equatable {
    public let type: String = "Input.Time"
    public var id: String
    public var isRequired: Bool?
    public var label: String?
    public var labelPosition: String?
    public var labelWidth: String?
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

    enum CodingKeys: String, CodingKey {
        case type, id, isRequired, label, labelPosition, labelWidth, placeholder, value, min, max
        case errorMessage, spacing, separator, height, isVisible, fallback
    }

    public init(
        id: String,
        isRequired: Bool? = nil,
        label: String? = nil,
        labelPosition: String? = nil,
        labelWidth: String? = nil,
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
        self.labelPosition = labelPosition
        self.labelWidth = labelWidth
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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.isRequired = try container.decodeBoolFromStringIfPresent(forKey: .isRequired)
        self.label = try container.decodeIfPresent(String.self, forKey: .label)
        self.labelPosition = try container.decodeIfPresent(String.self, forKey: .labelPosition)
        self.labelWidth = try decodeLabelWidth(from: container, forKey: .labelWidth)
        self.placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
        self.min = try container.decodeIfPresent(String.self, forKey: .min)
        self.max = try container.decodeIfPresent(String.self, forKey: .max)
        self.errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
        self.spacing = try container.decodeIfPresent(Spacing.self, forKey: .spacing)
        self.separator = try container.decodeIfPresent(Bool.self, forKey: .separator)
        self.height = try container.decodeIfPresent(BlockElementHeight.self, forKey: .height)
        self.isVisible = try container.decodeIfPresent(Bool.self, forKey: .isVisible)
        self.fallback = try container.decodeIfPresent(CardElement.self, forKey: .fallback)
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
    public var labelPosition: String?
    public var labelWidth: String?
    public var errorMessage: String?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var fallback: CardElement?

    enum CodingKeys: String, CodingKey {
        case type, id, title, value, valueOn, valueOff, wrap, label, labelPosition, labelWidth
        case errorMessage, spacing, separator, height, isVisible, fallback
    }

    public init(
        id: String,
        title: String,
        value: String? = nil,
        valueOn: String? = nil,
        valueOff: String? = nil,
        wrap: Bool? = nil,
        label: String? = nil,
        labelPosition: String? = nil,
        labelWidth: String? = nil,
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
        self.labelPosition = labelPosition
        self.labelWidth = labelWidth
        self.errorMessage = errorMessage
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.fallback = fallback
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
        self.valueOn = try container.decodeIfPresent(String.self, forKey: .valueOn)
        self.valueOff = try container.decodeIfPresent(String.self, forKey: .valueOff)
        self.wrap = try container.decodeIfPresent(Bool.self, forKey: .wrap)
        self.label = try container.decodeIfPresent(String.self, forKey: .label)
        self.labelPosition = try container.decodeIfPresent(String.self, forKey: .labelPosition)
        self.labelWidth = try decodeLabelWidth(from: container, forKey: .labelWidth)
        self.errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
        self.spacing = try container.decodeIfPresent(Spacing.self, forKey: .spacing)
        self.separator = try container.decodeIfPresent(Bool.self, forKey: .separator)
        self.height = try container.decodeIfPresent(BlockElementHeight.self, forKey: .height)
        self.isVisible = try container.decodeIfPresent(Bool.self, forKey: .isVisible)
        self.fallback = try container.decodeIfPresent(CardElement.self, forKey: .fallback)
    }
}

// MARK: - Input.ChoiceSet

public struct ChoiceSetInput: Codable, Equatable {
    public let type: String = "Input.ChoiceSet"
    public var id: String
    public var isRequired: Bool?
    public var label: String?
    public var labelPosition: String?
    public var labelWidth: String?
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
    /// Dynamic typeahead data source (v1.6). When present, choices are fetched
    /// from the host via `DataQueryProvider` instead of the static `choices` array.
    public var choicesData: DataQuery?

    enum CodingKeys: String, CodingKey {
        case type, id, isRequired, label, labelPosition, labelWidth, choices, value, style
        case isMultiSelect, placeholder, wrap, errorMessage
        case spacing, separator, height, isVisible, fallback
        case choicesData = "choices.data"
    }

    public init(
        id: String,
        isRequired: Bool? = nil,
        label: String? = nil,
        labelPosition: String? = nil,
        labelWidth: String? = nil,
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
        fallback: CardElement? = nil,
        choicesData: DataQuery? = nil
    ) {
        self.id = id
        self.isRequired = isRequired
        self.label = label
        self.labelPosition = labelPosition
        self.labelWidth = labelWidth
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
        self.choicesData = choicesData
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.isRequired = try container.decodeBoolFromStringIfPresent(forKey: .isRequired)
        self.label = try container.decodeIfPresent(String.self, forKey: .label)
        self.labelPosition = try container.decodeIfPresent(String.self, forKey: .labelPosition)
        self.labelWidth = try decodeLabelWidth(from: container, forKey: .labelWidth)
        self.choices = try container.decodeIfPresent([Choice].self, forKey: .choices) ?? []
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
        self.style = try container.decodeIfPresent(ChoiceInputStyle.self, forKey: .style)
        self.isMultiSelect = try container.decodeIfPresent(Bool.self, forKey: .isMultiSelect)
        self.placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        self.wrap = try container.decodeIfPresent(Bool.self, forKey: .wrap)
        self.errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
        self.spacing = try container.decodeIfPresent(Spacing.self, forKey: .spacing)
        self.separator = try container.decodeIfPresent(Bool.self, forKey: .separator)
        self.height = try container.decodeIfPresent(BlockElementHeight.self, forKey: .height)
        self.isVisible = try container.decodeIfPresent(Bool.self, forKey: .isVisible)
        self.fallback = try container.decodeIfPresent(CardElement.self, forKey: .fallback)
        self.choicesData = try container.decodeIfPresent(DataQuery.self, forKey: .choicesData)
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

// MARK: - Data.Query

/// Model for dynamic typeahead in ChoiceSet (v1.6 spec).
/// When present on a ChoiceSet, choices are fetched dynamically from the host
/// via a `DataQueryProvider` instead of using the static `choices` array.
public struct DataQuery: Codable, Equatable {
    /// The dataset identifier for the host to query
    public var dataset: String
    /// Maximum number of results to return
    public var count: Int?
    /// Initial value to pre-populate the search
    public var value: String?

    public init(dataset: String, count: Int? = nil, value: String? = nil) {
        self.dataset = dataset
        self.count = count
        self.value = value
    }
}
