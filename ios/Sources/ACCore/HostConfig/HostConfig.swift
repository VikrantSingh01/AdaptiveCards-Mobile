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
        small: Int = 3,
        default: Int = 8,
        medium: Int = 20,
        large: Int = 30,
        extraLarge: Int = 40,
        padding: Int = 20
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

    public init(lineThickness: Int = 1, lineColor: String = "#B2000000") {
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
        small: Int = 10,
        default: Int = 12,
        medium: Int = 14,
        large: Int = 17,
        extraLarge: Int = 20
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

    public init(lighter: Int = 200, default: Int = 400, bolder: Int = 800) {
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
            backgroundColor: "#FFFFFFFF",
            foregroundColors: ForegroundColorsConfig()
        ),
        emphasis: ContainerStyleConfig = ContainerStyleConfig(
            backgroundColor: "#08000000",
            foregroundColors: ForegroundColorsConfig()
        ),
        good: ContainerStyleConfig = ContainerStyleConfig(
            backgroundColor: "#FFD5F0DD",
            foregroundColors: ForegroundColorsConfig()
        ),
        attention: ContainerStyleConfig = ContainerStyleConfig(
            backgroundColor: "#F7E9E9",
            foregroundColors: ForegroundColorsConfig()
        ),
        warning: ContainerStyleConfig = ContainerStyleConfig(
            backgroundColor: "#F7F7DF",
            foregroundColors: ForegroundColorsConfig()
        ),
        accent: ContainerStyleConfig = ContainerStyleConfig(
            backgroundColor: "#DCE5F7",
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
        default: ColorConfig = ColorConfig(default: "#FF000000", subtle: "#B2000000"),
        dark: ColorConfig = ColorConfig(default: "#FF101010", subtle: "#B2101010"),
        light: ColorConfig = ColorConfig(default: "#FFFFFFFF", subtle: "#B2FFFFFF"),
        accent: ColorConfig = ColorConfig(default: "#FF0000FF", subtle: "#B20000FF"),
        good: ColorConfig = ColorConfig(default: "#FF008000", subtle: "#B2008000"),
        warning: ColorConfig = ColorConfig(default: "#FFFFD700", subtle: "#B2FFD700"),
        attention: ColorConfig = ColorConfig(default: "#FF8B0000", subtle: "#B28B0000")
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

    public init(small: Int = 80, medium: Int = 120, large: Int = 180) {
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
        actionAlignment: String = "Stretch",
        buttonSpacing: Int = 10,
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
        title: FactSetTextConfig = FactSetTextConfig(weight: "Bolder", maxWidth: 150),
        value: FactSetTextConfig = FactSetTextConfig(weight: "Default", maxWidth: 0),
        spacing: Int = 0
    ) {
        self.title = title
        self.value = value
        self.spacing = spacing
    }
}

public struct FactSetTextConfig: Codable {
    public var weight: String
    public var maxWidth: Int
    public var size: Int

    public init(weight: String, maxWidth: Int = 0, size: Int = 12) {
        self.weight = weight
        self.maxWidth = maxWidth
        self.size = size
    }
}
