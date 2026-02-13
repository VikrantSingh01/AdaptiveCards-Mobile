import Foundation

public struct HostConfig: Codable {
    public var spacing: SpacingConfig
    public var separator: SeparatorConfig
    public var fontSizes: FontSizesConfig
    public var fontWeights: FontWeightsConfig
    public var fontTypes: FontTypesConfig
    public var containerStyles: ContainerStylesConfig
    public var imageSizes: ImageSizesConfig
    public var actions: ActionsConfig
    public var adaptiveCard: AdaptiveCardConfig
    public var imageSet: ImageSetConfig
    public var factSet: FactSetConfig

    public init(
        spacing: SpacingConfig = SpacingConfig(),
        separator: SeparatorConfig = SeparatorConfig(),
        fontSizes: FontSizesConfig = FontSizesConfig(),
        fontWeights: FontWeightsConfig = FontWeightsConfig(),
        fontTypes: FontTypesConfig = FontTypesConfig(),
        containerStyles: ContainerStylesConfig = ContainerStylesConfig(),
        imageSizes: ImageSizesConfig = ImageSizesConfig(),
        actions: ActionsConfig = ActionsConfig(),
        adaptiveCard: AdaptiveCardConfig = AdaptiveCardConfig(),
        imageSet: ImageSetConfig = ImageSetConfig(),
        factSet: FactSetConfig = FactSetConfig()
    ) {
        self.spacing = spacing
        self.separator = separator
        self.fontSizes = fontSizes
        self.fontWeights = fontWeights
        self.fontTypes = fontTypes
        self.containerStyles = containerStyles
        self.imageSizes = imageSizes
        self.actions = actions
        self.adaptiveCard = adaptiveCard
        self.imageSet = imageSet
        self.factSet = factSet
    }
}

// MARK: - Spacing Configuration

public struct SpacingConfig: Codable {
    public var small: Int
    public var `default`: Int
    public var medium: Int
    public var large: Int
    public var extraLarge: Int
    public var padding: Int

    public init(
        small: Int = 4,
        default: Int = 8,
        medium: Int = 12,
        large: Int = 16,
        extraLarge: Int = 24,
        padding: Int = 16
    ) {
        self.small = small
        self.default = `default`
        self.medium = medium
        self.large = large
        self.extraLarge = extraLarge
        self.padding = padding
    }
}

// MARK: - Separator Configuration

public struct SeparatorConfig: Codable {
    public var lineThickness: Int
    public var lineColor: String

    public init(lineThickness: Int = 1, lineColor: String = "#E0E0E0") {
        self.lineThickness = lineThickness
        self.lineColor = lineColor
    }
}

// MARK: - Font Sizes Configuration

public struct FontSizesConfig: Codable {
    public var small: Int
    public var `default`: Int
    public var medium: Int
    public var large: Int
    public var extraLarge: Int

    public init(
        small: Int = 12,
        default: Int = 14,
        medium: Int = 17,
        large: Int = 21,
        extraLarge: Int = 26
    ) {
        self.small = small
        self.default = `default`
        self.medium = medium
        self.large = large
        self.extraLarge = extraLarge
    }
}

// MARK: - Font Weights Configuration

public struct FontWeightsConfig: Codable {
    public var lighter: Int
    public var `default`: Int
    public var bolder: Int

    public init(lighter: Int = 300, default: Int = 400, bolder: Int = 600) {
        self.lighter = lighter
        self.default = `default`
        self.bolder = bolder
    }
}

// MARK: - Font Types Configuration

public struct FontTypesConfig: Codable {
    public var `default`: FontFamilyConfig
    public var monospace: FontFamilyConfig

    public init(
        default: FontFamilyConfig = FontFamilyConfig(fontFamily: "System"),
        monospace: FontFamilyConfig = FontFamilyConfig(fontFamily: "Courier")
    ) {
        self.default = `default`
        self.monospace = monospace
    }

    public struct FontFamilyConfig: Codable {
        public var fontFamily: String

        public init(fontFamily: String) {
            self.fontFamily = fontFamily
        }
    }
}

// MARK: - Container Styles Configuration

public struct ContainerStylesConfig: Codable {
    public var `default`: ContainerStyleConfig
    public var emphasis: ContainerStyleConfig
    public var good: ContainerStyleConfig
    public var attention: ContainerStyleConfig
    public var warning: ContainerStyleConfig
    public var accent: ContainerStyleConfig

    public init(
        default: ContainerStyleConfig = ContainerStyleConfig(
            backgroundColor: "#FFFFFF",
            foregroundColors: ForegroundColorsConfig()
        ),
        emphasis: ContainerStyleConfig = ContainerStyleConfig(
            backgroundColor: "#F5F5F5",
            foregroundColors: ForegroundColorsConfig()
        ),
        good: ContainerStyleConfig = ContainerStyleConfig(
            backgroundColor: "#E8F5E9",
            foregroundColors: ForegroundColorsConfig()
        ),
        attention: ContainerStyleConfig = ContainerStyleConfig(
            backgroundColor: "#FFF3E0",
            foregroundColors: ForegroundColorsConfig()
        ),
        warning: ContainerStyleConfig = ContainerStyleConfig(
            backgroundColor: "#FFEBEE",
            foregroundColors: ForegroundColorsConfig()
        ),
        accent: ContainerStyleConfig = ContainerStyleConfig(
            backgroundColor: "#E3F2FD",
            foregroundColors: ForegroundColorsConfig()
        )
    ) {
        self.default = `default`
        self.emphasis = emphasis
        self.good = good
        self.attention = attention
        self.warning = warning
        self.accent = accent
    }
}

public struct ContainerStyleConfig: Codable {
    public var backgroundColor: String
    public var foregroundColors: ForegroundColorsConfig

    public init(backgroundColor: String, foregroundColors: ForegroundColorsConfig) {
        self.backgroundColor = backgroundColor
        self.foregroundColors = foregroundColors
    }
}

public struct ForegroundColorsConfig: Codable {
    public var `default`: ColorConfig
    public var dark: ColorConfig
    public var light: ColorConfig
    public var accent: ColorConfig
    public var good: ColorConfig
    public var warning: ColorConfig
    public var attention: ColorConfig

    public init(
        default: ColorConfig = ColorConfig(default: "#000000", subtle: "#666666"),
        dark: ColorConfig = ColorConfig(default: "#000000", subtle: "#666666"),
        light: ColorConfig = ColorConfig(default: "#FFFFFF", subtle: "#CCCCCC"),
        accent: ColorConfig = ColorConfig(default: "#0078D4", subtle: "#0063B1"),
        good: ColorConfig = ColorConfig(default: "#4CAF50", subtle: "#388E3C"),
        warning: ColorConfig = ColorConfig(default: "#FF9800", subtle: "#F57C00"),
        attention: ColorConfig = ColorConfig(default: "#F44336", subtle: "#D32F2F")
    ) {
        self.default = `default`
        self.dark = dark
        self.light = light
        self.accent = accent
        self.good = good
        self.warning = warning
        self.attention = attention
    }
}

public struct ColorConfig: Codable {
    public var `default`: String
    public var subtle: String

    public init(default: String, subtle: String) {
        self.default = `default`
        self.subtle = subtle
    }
}

// MARK: - Image Sizes Configuration

public struct ImageSizesConfig: Codable {
    public var small: Int
    public var medium: Int
    public var large: Int

    public init(small: Int = 60, medium: Int = 120, large: Int = 180) {
        self.small = small
        self.medium = medium
        self.large = large
    }
}

// MARK: - Actions Configuration

public struct ActionsConfig: Codable {
    public var actionsOrientation: String
    public var actionAlignment: String
    public var buttonSpacing: Int
    public var maxActions: Int
    public var spacing: String
    public var showCard: ShowCardConfig

    public init(
        actionsOrientation: String = "Horizontal",
        actionAlignment: String = "Left",
        buttonSpacing: Int = 8,
        maxActions: Int = 5,
        spacing: String = "Default",
        showCard: ShowCardConfig = ShowCardConfig()
    ) {
        self.actionsOrientation = actionsOrientation
        self.actionAlignment = actionAlignment
        self.buttonSpacing = buttonSpacing
        self.maxActions = maxActions
        self.spacing = spacing
        self.showCard = showCard
    }
}

public struct ShowCardConfig: Codable {
    public var actionMode: String
    public var style: String

    public init(actionMode: String = "Inline", style: String = "Emphasis") {
        self.actionMode = actionMode
        self.style = style
    }
}

// MARK: - AdaptiveCard Configuration

public struct AdaptiveCardConfig: Codable {
    public var allowCustomStyle: Bool

    public init(allowCustomStyle: Bool = true) {
        self.allowCustomStyle = allowCustomStyle
    }
}

// MARK: - ImageSet Configuration

public struct ImageSetConfig: Codable {
    public var imageSize: String
    public var maxImageHeight: Int

    public init(imageSize: String = "Medium", maxImageHeight: Int = 100) {
        self.imageSize = imageSize
        self.maxImageHeight = maxImageHeight
    }
}

// MARK: - FactSet Configuration

public struct FactSetConfig: Codable {
    public var title: FactSetTextConfig
    public var value: FactSetTextConfig
    public var spacing: Int

    public init(
        title: FactSetTextConfig = FactSetTextConfig(weight: "Bolder"),
        value: FactSetTextConfig = FactSetTextConfig(weight: "Default"),
        spacing: Int = 8
    ) {
        self.title = title
        self.value = value
        self.spacing = spacing
    }
}

public struct FactSetTextConfig: Codable {
    public var weight: String

    public init(weight: String) {
        self.weight = weight
    }
}
