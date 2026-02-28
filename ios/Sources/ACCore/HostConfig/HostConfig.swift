import Foundation

public struct HostConfig: Codable {
    // MARK: - Core Properties
    public var fontFamily: String
    public var supportsInteractivity: Bool
    public var imageBaseUrl: String

    // MARK: - Existing Configs
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

    // MARK: - New Configs (ported from production)
    public var media: MediaConfig
    public var inputs: InputsConfig
    public var hostWidth: HostWidthConfig
    public var textBlock: TextBlockConfig
    public var textStyles: TextStylesConfig
    public var image: ImageConfig
    public var ratingLabel: RatingElementConfig
    public var ratingInput: RatingElementConfig
    public var table: TableConfig
    public var compoundButton: CompoundButtonConfig
    public var borderWidth: [String: Int]
    public var cornerRadius: [String: Int]

    public init(
        fontFamily: String = "",
        supportsInteractivity: Bool = true,
        imageBaseUrl: String = "",
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
        factSet: FactSetConfig = FactSetConfig(),
        media: MediaConfig = MediaConfig(),
        inputs: InputsConfig = InputsConfig(),
        hostWidth: HostWidthConfig = HostWidthConfig(),
        textBlock: TextBlockConfig = TextBlockConfig(),
        textStyles: TextStylesConfig = TextStylesConfig(),
        image: ImageConfig = ImageConfig(),
        ratingLabel: RatingElementConfig = RatingElementConfig(),
        ratingInput: RatingElementConfig = RatingElementConfig(),
        table: TableConfig = TableConfig(),
        compoundButton: CompoundButtonConfig = CompoundButtonConfig(),
        borderWidth: [String: Int] = [:],
        cornerRadius: [String: Int] = [:]
    ) {
        self.fontFamily = fontFamily
        self.supportsInteractivity = supportsInteractivity
        self.imageBaseUrl = imageBaseUrl
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
        self.media = media
        self.inputs = inputs
        self.hostWidth = hostWidth
        self.textBlock = textBlock
        self.textStyles = textStyles
        self.image = image
        self.ratingLabel = ratingLabel
        self.ratingInput = ratingInput
        self.table = table
        self.compoundButton = compoundButton
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
    }

    // Custom decoder for backward compatibility - missing keys get defaults
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        fontFamily = try c.decodeIfPresent(String.self, forKey: .fontFamily) ?? ""
        supportsInteractivity = try c.decodeIfPresent(Bool.self, forKey: .supportsInteractivity) ?? true
        imageBaseUrl = try c.decodeIfPresent(String.self, forKey: .imageBaseUrl) ?? ""
        spacing = try c.decodeIfPresent(SpacingConfig.self, forKey: .spacing) ?? SpacingConfig()
        separator = try c.decodeIfPresent(SeparatorConfig.self, forKey: .separator) ?? SeparatorConfig()
        fontSizes = try c.decodeIfPresent(FontSizesConfig.self, forKey: .fontSizes) ?? FontSizesConfig()
        fontWeights = try c.decodeIfPresent(FontWeightsConfig.self, forKey: .fontWeights) ?? FontWeightsConfig()
        fontTypes = try c.decodeIfPresent(FontTypesConfig.self, forKey: .fontTypes) ?? FontTypesConfig()
        containerStyles = try c.decodeIfPresent(ContainerStylesConfig.self, forKey: .containerStyles) ?? ContainerStylesConfig()
        imageSizes = try c.decodeIfPresent(ImageSizesConfig.self, forKey: .imageSizes) ?? ImageSizesConfig()
        actions = try c.decodeIfPresent(ActionsConfig.self, forKey: .actions) ?? ActionsConfig()
        adaptiveCard = try c.decodeIfPresent(AdaptiveCardConfig.self, forKey: .adaptiveCard) ?? AdaptiveCardConfig()
        imageSet = try c.decodeIfPresent(ImageSetConfig.self, forKey: .imageSet) ?? ImageSetConfig()
        factSet = try c.decodeIfPresent(FactSetConfig.self, forKey: .factSet) ?? FactSetConfig()
        media = try c.decodeIfPresent(MediaConfig.self, forKey: .media) ?? MediaConfig()
        inputs = try c.decodeIfPresent(InputsConfig.self, forKey: .inputs) ?? InputsConfig()
        hostWidth = try c.decodeIfPresent(HostWidthConfig.self, forKey: .hostWidth) ?? HostWidthConfig()
        textBlock = try c.decodeIfPresent(TextBlockConfig.self, forKey: .textBlock) ?? TextBlockConfig()
        textStyles = try c.decodeIfPresent(TextStylesConfig.self, forKey: .textStyles) ?? TextStylesConfig()
        image = try c.decodeIfPresent(ImageConfig.self, forKey: .image) ?? ImageConfig()
        ratingLabel = try c.decodeIfPresent(RatingElementConfig.self, forKey: .ratingLabel) ?? RatingElementConfig()
        ratingInput = try c.decodeIfPresent(RatingElementConfig.self, forKey: .ratingInput) ?? RatingElementConfig()
        table = try c.decodeIfPresent(TableConfig.self, forKey: .table) ?? TableConfig()
        compoundButton = try c.decodeIfPresent(CompoundButtonConfig.self, forKey: .compoundButton) ?? CompoundButtonConfig()
        borderWidth = try c.decodeIfPresent([String: Int].self, forKey: .borderWidth) ?? [:]
        cornerRadius = try c.decodeIfPresent([String: Int].self, forKey: .cornerRadius) ?? [:]
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
    public var `default`: FontTypeDefinition
    public var monospace: FontTypeDefinition

    public init(
        default: FontTypeDefinition = FontTypeDefinition(fontFamily: "System"),
        monospace: FontTypeDefinition = FontTypeDefinition(fontFamily: "Courier")
    ) {
        self.default = `default`
        self.monospace = monospace
    }
}

/// Full font type definition with optional per-type size/weight overrides
public struct FontTypeDefinition: Codable {
    public var fontFamily: String
    public var fontSizes: FontSizesConfig?
    public var fontWeights: FontWeightsConfig?

    public init(
        fontFamily: String,
        fontSizes: FontSizesConfig? = nil,
        fontWeights: FontWeightsConfig? = nil
    ) {
        self.fontFamily = fontFamily
        self.fontSizes = fontSizes
        self.fontWeights = fontWeights
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
    public var borderColor: String
    public var foregroundColors: ForegroundColorsConfig

    public init(
        backgroundColor: String,
        foregroundColors: ForegroundColorsConfig,
        borderColor: String = "#E0E0E0"
    ) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.foregroundColors = foregroundColors
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        backgroundColor = try c.decode(String.self, forKey: .backgroundColor)
        borderColor = try c.decodeIfPresent(String.self, forKey: .borderColor) ?? "#E0E0E0"
        foregroundColors = try c.decodeIfPresent(ForegroundColorsConfig.self, forKey: .foregroundColors) ?? ForegroundColorsConfig()
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
    public var highlightColors: HighlightColorConfig

    public init(default: String, subtle: String, highlightColors: HighlightColorConfig = HighlightColorConfig()) {
        self.default = `default`
        self.subtle = subtle
        self.highlightColors = highlightColors
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.default = try c.decode(String.self, forKey: .default)
        subtle = try c.decode(String.self, forKey: .subtle)
        highlightColors = try c.decodeIfPresent(HighlightColorConfig.self, forKey: .highlightColors) ?? HighlightColorConfig()
    }
}

/// Highlight/selection colors for text within a color slot
public struct HighlightColorConfig: Codable {
    public var `default`: String
    public var subtle: String

    public init(default: String = "#FFFFFF00", subtle: String = "#FFFFFFE0") {
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
    public var iconPlacement: String
    public var iconSize: Int

    public init(
        actionsOrientation: String = "Horizontal",
        actionAlignment: String = "Stretch",
        buttonSpacing: Int = 10,
        maxActions: Int = 5,
        spacing: String = "Default",
        showCard: ShowCardConfig = ShowCardConfig(),
        iconPlacement: String = "AboveTitle",
        iconSize: Int = 16
    ) {
        self.actionsOrientation = actionsOrientation
        self.actionAlignment = actionAlignment
        self.buttonSpacing = buttonSpacing
        self.maxActions = maxActions
        self.spacing = spacing
        self.showCard = showCard
        self.iconPlacement = iconPlacement
        self.iconSize = iconSize
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        actionsOrientation = try c.decodeIfPresent(String.self, forKey: .actionsOrientation) ?? "Horizontal"
        actionAlignment = try c.decodeIfPresent(String.self, forKey: .actionAlignment) ?? "Left"
        buttonSpacing = try c.decodeIfPresent(Int.self, forKey: .buttonSpacing) ?? 8
        maxActions = try c.decodeIfPresent(Int.self, forKey: .maxActions) ?? 5
        spacing = try c.decodeIfPresent(String.self, forKey: .spacing) ?? "Default"
        showCard = try c.decodeIfPresent(ShowCardConfig.self, forKey: .showCard) ?? ShowCardConfig()
        iconPlacement = try c.decodeIfPresent(String.self, forKey: .iconPlacement) ?? "AboveTitle"
        iconSize = try c.decodeIfPresent(Int.self, forKey: .iconSize) ?? 16
    }
}

public struct ShowCardConfig: Codable {
    public var actionMode: String
    public var style: String
    public var inlineTopMargin: Int

    public init(actionMode: String = "Inline", style: String = "Emphasis", inlineTopMargin: Int = 16) {
        self.actionMode = actionMode
        self.style = style
        self.inlineTopMargin = inlineTopMargin
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        actionMode = try c.decodeIfPresent(String.self, forKey: .actionMode) ?? "Inline"
        style = try c.decodeIfPresent(String.self, forKey: .style) ?? "Emphasis"
        inlineTopMargin = try c.decodeIfPresent(Int.self, forKey: .inlineTopMargin) ?? 16
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
    public var size: String
    public var color: String
    public var isSubtle: Bool
    public var fontType: String
    public var wrap: Bool
    public var maxWidth: Int

    public init(
        weight: String = "Default",
        size: String = "Default",
        color: String = "Default",
        isSubtle: Bool = false,
        fontType: String = "Default",
        wrap: Bool = true,
        maxWidth: Int = 0
    ) {
        self.weight = weight
        self.size = size
        self.color = color
        self.isSubtle = isSubtle
        self.fontType = fontType
        self.wrap = wrap
        self.maxWidth = maxWidth
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        weight = try c.decodeIfPresent(String.self, forKey: .weight) ?? "Default"
        size = try c.decodeIfPresent(String.self, forKey: .size) ?? "Default"
        color = try c.decodeIfPresent(String.self, forKey: .color) ?? "Default"
        isSubtle = try c.decodeIfPresent(Bool.self, forKey: .isSubtle) ?? false
        fontType = try c.decodeIfPresent(String.self, forKey: .fontType) ?? "Default"
        wrap = try c.decodeIfPresent(Bool.self, forKey: .wrap) ?? true
        maxWidth = try c.decodeIfPresent(Int.self, forKey: .maxWidth) ?? 0
    }
}

// MARK: - Media Configuration

public struct MediaConfig: Codable {
    public var defaultPoster: String
    public var playButton: String
    public var allowInlinePlayback: Bool

    public init(
        defaultPoster: String = "",
        playButton: String = "",
        allowInlinePlayback: Bool = true
    ) {
        self.defaultPoster = defaultPoster
        self.playButton = playButton
        self.allowInlinePlayback = allowInlinePlayback
    }
}

// MARK: - Inputs Configuration

public struct InputsConfig: Codable {
    public var label: InputLabelGroupConfig
    public var errorMessage: ErrorMessageConfig

    public init(
        label: InputLabelGroupConfig = InputLabelGroupConfig(),
        errorMessage: ErrorMessageConfig = ErrorMessageConfig()
    ) {
        self.label = label
        self.errorMessage = errorMessage
    }
}

/// Label configuration for input groups (required vs optional)
public struct InputLabelGroupConfig: Codable {
    public var inputSpacing: String
    public var requiredInputs: InputLabelConfig
    public var optionalInputs: InputLabelConfig

    public init(
        inputSpacing: String = "Default",
        requiredInputs: InputLabelConfig = InputLabelConfig(),
        optionalInputs: InputLabelConfig = InputLabelConfig()
    ) {
        self.inputSpacing = inputSpacing
        self.requiredInputs = requiredInputs
        self.optionalInputs = optionalInputs
    }
}

/// Label appearance for a single input field
public struct InputLabelConfig: Codable {
    public var color: String
    public var isSubtle: Bool
    public var size: String
    public var suffix: String
    public var weight: String

    public init(
        color: String = "Default",
        isSubtle: Bool = false,
        size: String = "Default",
        suffix: String = "",
        weight: String = "Default"
    ) {
        self.color = color
        self.isSubtle = isSubtle
        self.size = size
        self.suffix = suffix
        self.weight = weight
        self.maxWidth = maxWidth
        self.size = size
    }
}

/// Error message styling for input validation
public struct ErrorMessageConfig: Codable {
    public var size: String
    public var spacing: String
    public var weight: String

    public init(
        size: String = "Default",
        spacing: String = "Default",
        weight: String = "Default"
    ) {
        self.size = size
        self.spacing = spacing
        self.weight = weight
    }
}

// MARK: - Host Width Configuration (Responsive Breakpoints)

public struct HostWidthConfig: Codable {
    public var veryNarrow: Int
    public var narrow: Int
    public var standard: Int

    public init(veryNarrow: Int = 0, narrow: Int = 0, standard: Int = 0) {
        self.veryNarrow = veryNarrow
        self.narrow = narrow
        self.standard = standard
    }
}

// MARK: - TextBlock Configuration

public struct TextBlockConfig: Codable {
    public var headingLevel: Int

    public init(headingLevel: Int = 2) {
        self.headingLevel = headingLevel
    }
}

// MARK: - Text Styles Configuration

public struct TextStylesConfig: Codable {
    public var heading: TextStyleConfig
    public var columnHeader: TextStyleConfig

    public init(
        heading: TextStyleConfig = TextStyleConfig(),
        columnHeader: TextStyleConfig = TextStyleConfig(weight: "Bolder")
    ) {
        self.heading = heading
        self.columnHeader = columnHeader
    }
}

/// Style definition for a semantic text role (heading, columnHeader, etc.)
public struct TextStyleConfig: Codable {
    public var weight: String
    public var size: String
    public var isSubtle: Bool
    public var color: String
    public var fontType: String

    public init(
        weight: String = "Default",
        size: String = "Default",
        isSubtle: Bool = false,
        color: String = "Default",
        fontType: String = "Default"
    ) {
        self.weight = weight
        self.size = size
        self.isSubtle = isSubtle
        self.color = color
        self.fontType = fontType
    }
}

// MARK: - Image Configuration

public struct ImageConfig: Codable {
    public var imageSize: String

    public init(imageSize: String = "Auto") {
        self.imageSize = imageSize
    }
}

// MARK: - Rating Configuration

public struct RatingElementConfig: Codable {
    public var filledStar: RatingStarConfig
    public var emptyStar: RatingStarConfig
    public var ratingTextColor: String
    public var countTextColor: String

    public init(
        filledStar: RatingStarConfig = RatingStarConfig(),
        emptyStar: RatingStarConfig = RatingStarConfig(),
        ratingTextColor: String = "#000000",
        countTextColor: String = "#000000"
    ) {
        self.filledStar = filledStar
        self.emptyStar = emptyStar
        self.ratingTextColor = ratingTextColor
        self.countTextColor = countTextColor
    }
}

public struct RatingStarConfig: Codable {
    public var marigoldColor: String
    public var neutralColor: String

    public init(
        marigoldColor: String = "#EAA300",
        neutralColor: String = "#212121"
    ) {
        self.marigoldColor = marigoldColor
        self.neutralColor = neutralColor
    }
}

// MARK: - Table Configuration

public struct TableConfig: Codable {
    public var cellSpacing: Int

    public init(cellSpacing: Int = 8) {
        self.cellSpacing = cellSpacing
    }
}

// MARK: - Compound Button Configuration

public struct CompoundButtonConfig: Codable {
    public var badge: BadgeConfig
    public var borderColor: String

    public init(
        badge: BadgeConfig = BadgeConfig(),
        borderColor: String = "#E1E1E1"
    ) {
        self.badge = badge
        self.borderColor = borderColor
    }
}

public struct BadgeConfig: Codable {
    public var backgroundColor: String

    public init(backgroundColor: String = "#5B5FC7") {
        self.backgroundColor = backgroundColor
    }
}
