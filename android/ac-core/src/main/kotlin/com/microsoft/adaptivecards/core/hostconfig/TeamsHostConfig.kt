package com.microsoft.adaptivecards.core.hostconfig

import com.microsoft.adaptivecards.core.models.*

/**
 * Pre-configured HostConfig for Microsoft Teams with Fluent UI design tokens
 */
object TeamsHostConfig {
    fun create(): HostConfig = HostConfig(
        fontFamily = "Segoe UI",
        supportsInteractivity = true,
        imageBaseUrl = "",
        spacing = SpacingConfig(
            small = 4,
            default = 8,
            medium = 12,
            large = 16,
            extraLarge = 24,
            padding = 12
        ),
        separator = SeparatorConfig(
            lineThickness = 1,
            lineColor = "#E1DFDD"
        ),
        fontTypes = FontTypesConfig(
            default = FontTypeConfig(
                fontFamily = "Segoe UI, system-ui, -apple-system, sans-serif"
            ),
            monospace = FontTypeConfig(
                fontFamily = "Consolas, Courier New, monospace"
            )
        ),
        fontSizes = FontSizesConfig(
            small = 12,
            default = 14,
            medium = 16,
            large = 20,
            extraLarge = 26
        ),
        fontWeights = FontWeightsConfig(
            lighter = 300,
            default = 400,
            bolder = 600
        ),
        containerStyles = ContainerStylesConfig(
            default = ContainerStyleConfig(
                backgroundColor = "#FFFFFF",
                borderColor = "#E1DFDD",
                foregroundColors = teamsForegroundColors()
            ),
            emphasis = ContainerStyleConfig(
                backgroundColor = "#F5F5F5",
                borderColor = "#E1DFDD",
                foregroundColors = teamsForegroundColors()
            ),
            good = ContainerStyleConfig(
                backgroundColor = "#DFF6DD",
                borderColor = "#9FD89F",
                foregroundColors = teamsForegroundColors()
            ),
            attention = ContainerStyleConfig(
                backgroundColor = "#FED9CC",
                borderColor = "#E97548",
                foregroundColors = teamsForegroundColors()
            ),
            warning = ContainerStyleConfig(
                backgroundColor = "#FFF4CE",
                borderColor = "#F8D22A",
                foregroundColors = teamsForegroundColors()
            ),
            accent = ContainerStyleConfig(
                backgroundColor = "#E8E8F7",
                borderColor = "#6264A7",
                foregroundColors = teamsForegroundColors()
            )
        ),
        imageSizes = ImageSizesConfig(
            small = 48,
            medium = 80,
            large = 160
        ),
        actions = ActionsConfig(
            maxActions = 5,
            spacing = Spacing.Default,
            buttonSpacing = 8,
            showCard = ShowCardConfig(
                actionMode = "inline",
                style = ContainerStyle.Emphasis,
                inlineTopMargin = 16
            ),
            actionsOrientation = "horizontal",
            actionAlignment = "stretch",
            iconPlacement = "aboveTitle",
            iconSize = 20
        ),
        adaptiveCard = AdaptiveCardConfig(
            allowCustomStyle = true
        ),
        imageSet = ImageSetConfig(
            imageSize = ImageSize.Medium,
            maxImageHeight = 100
        ),
        media = MediaConfig(
            defaultPoster = null,
            playButton = null,
            allowInlinePlayback = true
        ),
        factSet = FactSetConfig(
            title = FactSetTextConfig(
                weight = FontWeight.Bolder,
                size = FontSize.Default
            ),
            value = FactSetTextConfig(
                weight = FontWeight.Default,
                size = FontSize.Default
            ),
            spacing = 10
        ),
        inputs = InputsConfig(
            label = InputLabelGroupConfig(
                inputSpacing = Spacing.Default,
                requiredInputs = InputLabelConfig(
                    color = Color.Default,
                    isSubtle = false,
                    size = FontSize.Default,
                    suffix = " *",
                    weight = FontWeight.Default
                ),
                optionalInputs = InputLabelConfig(
                    color = Color.Default,
                    isSubtle = true,
                    size = FontSize.Default,
                    suffix = "",
                    weight = FontWeight.Default
                )
            ),
            errorMessage = InputErrorMessageConfig(
                color = Color.Attention,
                size = FontSize.Small,
                weight = FontWeight.Default
            )
        ),
        hostWidth = HostWidthConfig(
            veryNarrow = 250,
            narrow = 350,
            standard = 500
        ),
        textBlock = TextBlockConfig(
            headingLevel = 2
        ),
        textStyles = TextStylesConfig(
            heading = TextStyleConfig(
                weight = FontWeight.Bolder,
                size = FontSize.Large,
                isSubtle = false,
                color = Color.Default,
                fontType = "Default"
            ),
            columnHeader = TextStyleConfig(
                weight = FontWeight.Bolder,
                size = FontSize.Default,
                isSubtle = false,
                color = Color.Default,
                fontType = "Default"
            )
        ),
        image = ImageConfig(imageSize = ImageSize.Auto),
        ratingLabel = RatingElementConfig(
            filledStar = RatingStarConfig(marigoldColor = "#EAA300", neutralColor = "#242424"),
            emptyStar = RatingStarConfig(marigoldColor = "#EAA300", neutralColor = "#242424"),
            ratingTextColor = "#242424",
            countTextColor = "#616161"
        ),
        ratingInput = RatingElementConfig(
            filledStar = RatingStarConfig(marigoldColor = "#EAA300", neutralColor = "#242424"),
            emptyStar = RatingStarConfig(marigoldColor = "#EAA300", neutralColor = "#242424"),
            ratingTextColor = "#242424",
            countTextColor = "#616161"
        ),
        table = TableConfig(cellSpacing = 8),
        compoundButton = CompoundButtonConfig(
            badge = BadgeConfig(backgroundColor = "#6264A7"),
            borderColor = "#E1DFDD"
        ),
        borderWidth = emptyMap(),
        cornerRadius = emptyMap()
    )

    private fun teamsForegroundColors(): ForegroundColorsConfig = ForegroundColorsConfig(
        default = ColorConfig(default = "#242424", subtle = "#616161"),
        dark = ColorConfig(default = "#000000", subtle = "#616161"),
        light = ColorConfig(default = "#FFFFFF", subtle = "#E1DFDD"),
        accent = ColorConfig(default = "#6264A7", subtle = "#8B8CC7"),
        good = ColorConfig(default = "#92C353", subtle = "#9ED06D"),
        warning = ColorConfig(default = "#F8D22A", subtle = "#F9DD51"),
        attention = ColorConfig(default = "#C4314B", subtle = "#D3596D")
    )
}
