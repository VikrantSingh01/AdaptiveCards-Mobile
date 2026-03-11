import Foundation
// MARK: - Rating Display

public struct RatingDisplay: Codable, Equatable {
    public let type: String = "Rating"
    public var id: String?
    public var value: Double
    public var count: Int?
    public var max: Int?
    public var size: RatingSize?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?

    public init(
        id: String? = nil,
        value: Double,
        count: Int? = nil,
        max: Int? = nil,
        size: RatingSize? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil
    ) {
        self.id = id
        self.value = value
        self.count = count
        self.max = max
        self.size = size
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.requires = requires
    }
}

// MARK: - Rating Input

public struct RatingInput: Codable, Equatable {
    public let type: String = "Input.Rating"
    public var id: String
    public var max: Int?
    public var value: Double?
    public var label: String?
    public var isRequired: Bool?
    public var errorMessage: String?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?

    enum CodingKeys: String, CodingKey {
        case type, id, max, value, label, isRequired
        case errorMessage, spacing, separator, height, isVisible
    }

    public init(
        id: String,
        max: Int? = nil,
        value: Double? = nil,
        label: String? = nil,
        isRequired: Bool? = nil,
        errorMessage: String? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil
    ) {
        self.id = id
        self.max = max
        self.value = value
        self.label = label
        self.isRequired = isRequired
        self.errorMessage = errorMessage
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.max = try container.decodeIfPresent(Int.self, forKey: .max)
        self.value = try container.decodeIfPresent(Double.self, forKey: .value)
        self.label = try container.decodeIfPresent(String.self, forKey: .label)
        self.isRequired = try container.decodeBoolFromStringIfPresent(forKey: .isRequired)
        self.errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
        self.spacing = try container.decodeIfPresent(Spacing.self, forKey: .spacing)
        self.separator = try container.decodeIfPresent(Bool.self, forKey: .separator)
        self.height = try container.decodeIfPresent(BlockElementHeight.self, forKey: .height)
        self.isVisible = try container.decodeIfPresent(Bool.self, forKey: .isVisible)
    }
}
