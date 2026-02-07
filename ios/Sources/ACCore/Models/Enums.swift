import Foundation

// MARK: - Alignment

public enum HorizontalAlignment: String, Codable {
    case left = "Left"
    case center = "Center"
    case right = "Right"
}

public enum VerticalAlignment: String, Codable {
    case top = "Top"
    case center = "Center"
    case bottom = "Bottom"
}

// MARK: - Spacing

public enum Spacing: String, Codable {
    case none = "None"
    case small = "Small"
    case `default` = "Default"
    case medium = "Medium"
    case large = "Large"
    case extraLarge = "ExtraLarge"
    case padding = "Padding"
}

// MARK: - Typography

public enum FontType: String, Codable {
    case `default` = "Default"
    case monospace = "Monospace"
}

public enum FontSize: String, Codable {
    case small = "Small"
    case `default` = "Default"
    case medium = "Medium"
    case large = "Large"
    case extraLarge = "ExtraLarge"
}

public enum FontWeight: String, Codable {
    case lighter = "Lighter"
    case `default` = "Default"
    case bolder = "Bolder"
}

// MARK: - Colors

public enum ForegroundColor: String, Codable {
    case `default` = "Default"
    case dark = "Dark"
    case light = "Light"
    case accent = "Accent"
    case good = "Good"
    case warning = "Warning"
    case attention = "Attention"
}

// MARK: - Image

public enum ImageSize: String, Codable {
    case auto = "Auto"
    case stretch = "Stretch"
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
}

public enum ImageStyle: String, Codable {
    case `default` = "Default"
    case person = "Person"
}

// MARK: - Container

public enum ContainerStyle: String, Codable {
    case `default` = "Default"
    case emphasis = "Emphasis"
    case good = "Good"
    case attention = "Attention"
    case warning = "Warning"
    case accent = "Accent"
}

// MARK: - Actions

public enum ActionStyle: String, Codable {
    case `default` = "Default"
    case positive = "Positive"
    case destructive = "Destructive"
}

public enum ActionMode: String, Codable {
    case primary = "Primary"
    case secondary = "Secondary"
}

// MARK: - Text

public enum TextBlockStyle: String, Codable {
    case `default` = "Default"
    case heading = "Heading"
}

// MARK: - Height

public enum BlockElementHeight: String, Codable {
    case auto = "Auto"
    case stretch = "Stretch"
}

// MARK: - Choice Input

public enum ChoiceInputStyle: String, Codable {
    case compact = "Compact"
    case expanded = "Expanded"
    case filtered = "Filtered"
}

// MARK: - Text Input

public enum TextInputStyle: String, Codable {
    case text = "Text"
    case tel = "Tel"
    case url = "Url"
    case email = "Email"
    case password = "Password"
}

// MARK: - Associated Inputs

public enum AssociatedInputs: String, Codable {
    case auto = "Auto"
    case none = "None"
}

// MARK: - Advanced Elements

public enum ExpandMode: String, Codable {
    case single = "Single"
    case multiple = "Multiple"
}

public enum RatingSize: String, Codable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
}

public enum SpinnerSize: String, Codable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
}
