import Foundation

// MARK: - Case-Insensitive Codable Helper

/// Protocol for enums that should decode case-insensitively
protocol CaseInsensitiveCodable: RawRepresentable, Codable, CaseIterable where RawValue == String {}

extension CaseInsensitiveCodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        // Try exact match first
        if let value = Self(rawValue: rawValue) {
            self = value
            return
        }

        // Try case-insensitive match
        let lowered = rawValue.lowercased()
        for c in Self.allCases where c.rawValue.lowercased() == lowered {
            self = c
            return
        }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Cannot initialize \(Self.self) from invalid String value \(rawValue)"
        )
    }
}

// Helper: make all our enums CaseIterable so the case-insensitive lookup works
// We keep the raw values capitalized (matching Adaptive Cards spec canonical form)
// but accept any casing on decode.

// MARK: - Alignment

public enum HorizontalAlignment: String, Codable, CaseIterable, CaseInsensitiveCodable {
    case left = "Left"
    case center = "Center"
    case right = "Right"
}

public enum VerticalAlignment: String, Codable, CaseIterable, CaseInsensitiveCodable {
    case top = "Top"
    case center = "Center"
    case bottom = "Bottom"
}

// MARK: - Spacing

public enum Spacing: String, Codable, CaseIterable, CaseInsensitiveCodable {
    case none = "None"
    case small = "Small"
    case `default` = "Default"
    case medium = "Medium"
    case large = "Large"
    case extraLarge = "ExtraLarge"
    case padding = "Padding"
}

// MARK: - Typography

public enum FontType: String, Codable, CaseIterable, CaseInsensitiveCodable {
    case `default` = "Default"
    case monospace = "Monospace"
}

public enum FontSize: String, Codable, CaseIterable, CaseInsensitiveCodable {
    case small = "Small"
    case `default` = "Default"
    case medium = "Medium"
    case large = "Large"
    case extraLarge = "ExtraLarge"
}

public enum FontWeight: String, Codable, CaseIterable, CaseInsensitiveCodable {
    case lighter = "Lighter"
    case `default` = "Default"
    case bolder = "Bolder"
}

// MARK: - Colors

public enum ForegroundColor: String, Codable, CaseIterable, CaseInsensitiveCodable {
    case `default` = "Default"
    case dark = "Dark"
    case light = "Light"
    case accent = "Accent"
    case good = "Good"
    case warning = "Warning"
    case attention = "Attention"
}

// MARK: - Image

public enum ImageSize: String, Codable, CaseIterable, CaseInsensitiveCodable {
    case auto = "Auto"
    case stretch = "Stretch"
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
}

public enum ImageStyle: String, Codable, CaseIterable, CaseInsensitiveCodable {
    case `default` = "Default"
    case person = "Person"
}

// MARK: - Container

public enum ContainerStyle: String, Codable, CaseIterable, CaseInsensitiveCodable {
    case `default` = "Default"
    case emphasis = "Emphasis"
    case good = "Good"
    case attention = "Attention"
    case warning = "Warning"
    case accent = "Accent"
}

// MARK: - Actions

public enum ActionStyle: String, Codable, CaseIterable, CaseInsensitiveCodable {
    case `default` = "Default"
    case positive = "Positive"
    case destructive = "Destructive"
}

public enum ActionMode: String, Codable, CaseIterable, CaseInsensitiveCodable {
    case primary = "Primary"
    case secondary = "Secondary"
}

public enum ActionSetMode: String, Codable, CaseIterable, CaseInsensitiveCodable {
    case `default` = "Default"
    case overflow = "Overflow"
}

// MARK: - Text

public enum TextBlockStyle: String, Codable, CaseIterable, CaseInsensitiveCodable {
    case `default` = "Default"
    case heading = "Heading"
}

// MARK: - Height

public enum BlockElementHeight: String, Codable, CaseIterable, CaseInsensitiveCodable {
    case auto = "Auto"
    case stretch = "Stretch"
}

// MARK: - Choice Input

public enum ChoiceInputStyle: String, Codable, CaseIterable, CaseInsensitiveCodable {
    case compact = "Compact"
    case expanded = "Expanded"
    case filtered = "Filtered"
}

// MARK: - Text Input

public enum TextInputStyle: String, Codable, CaseIterable, CaseInsensitiveCodable {
    case text = "Text"
    case tel = "Tel"
    case url = "Url"
    case email = "Email"
    case password = "Password"
}

// MARK: - Associated Inputs

public enum AssociatedInputs: String, Codable, CaseIterable, CaseInsensitiveCodable {
    case auto = "Auto"
    case none = "None"
}

// MARK: - Advanced Elements

public enum ExpandMode: String, Codable, CaseIterable, CaseInsensitiveCodable {
    case single = "Single"
    case multiple = "Multiple"
}

public enum RatingSize: String, Codable, CaseIterable, CaseInsensitiveCodable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
}

public enum SpinnerSize: String, Codable, CaseIterable, CaseInsensitiveCodable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
}
