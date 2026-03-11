package com.microsoft.adaptivecards.core.hostconfig

import com.microsoft.adaptivecards.core.models.*

/**
 * Pre-configured HostConfig for Microsoft Teams with Fluent UI design tokens.
 *
 * Light theme aligned to the Adaptive Cards Figma specification (March 2026).
 * Typography uses the Roboto type ramp; colors use Fluent Teams tokens.
 */
object TeamsHostConfig {

    /** Creates the standard Teams light-theme HostConfig. */
    fun create(): HostConfig = createLight()

    /** Teams light theme — white card surface. */
    fun createLight(): HostConfig = HostConfig(
        fontFamily = "Roboto",
        supportsInteractivity = true,
        imageBaseUrl = "",
        spacing = SpacingConfig(
            extraSmall = 4,
            small = 8,
            default = 8,
            medium = 12,
            large = 16,
            extraLarge = 20,
            padding = 10
        ),
        separator = SeparatorConfig(
            lineThickness = 1,
            lineColor = "#0D16233A"  // ~5 % opacity dark stroke
        ),
        fontTypes = FontTypesConfig(
            default = FontTypeConfig(
                fontFamily = "Roboto, system-ui, sans-serif"
            ),
            monospace = FontTypeConfig(
                fontFamily = "Roboto Mono, Courier New, monospace"
            )
        ),
        fontSizes = FontSizesConfig(
            small = 12,
            default = 14,
            medium = 14,
            large = 16,
            extraLarge = 20
        ),
        fontWeights = FontWeightsConfig(
            lighter = 400,
            default = 400,
            bolder = 500
        ),
        lineHeights = LineHeightsConfig(
            small = 16,
            default = 18,
            medium = 18,
            large = 24,
            extraLarge = 24
        ),
        containerStyles = ContainerStylesConfig(
            default = ContainerStyleConfig(
                backgroundColor = "#FFFFFF",
                borderColor = "#E1E1E1",
                foregroundColors = teamsLightForegroundColors()
            ),
            emphasis = ContainerStyleConfig(
                backgroundColor = "#F1F1F1",
                borderColor = "#E1E1E1",
                foregroundColors = teamsLightForegroundColors()
            ),
            good = ContainerStyleConfig(
                backgroundColor = "#DFF6DD",
                borderColor = "#9FD89F",
                foregroundColors = teamsLightForegroundColors()
            ),
            attention = ContainerStyleConfig(
                backgroundColor = "#FED9CC",
                borderColor = "#E97548",
                foregroundColors = teamsLightForegroundColors()
            ),
            warning = ContainerStyleConfig(
                backgroundColor = "#FFF4CE",
                borderColor = "#F8D22A",
                foregroundColors = teamsLightForegroundColors()
            ),
            accent = ContainerStyleConfig(
                backgroundColor = "#E8E8F7",
                borderColor = "#6264A7",
                foregroundColors = teamsLightForegroundColors()
            )
        ),
        imageSizes = ImageSizesConfig(
            small = 32,
            medium = 52,
            large = 100
        ),
        actions = ActionsConfig(
            maxActions = 6,
            spacing = Spacing.Medium,
            buttonSpacing = 8,
            showCard = ShowCardConfig(
                actionMode = "inline",
                style = ContainerStyle.Default,
                inlineTopMargin = 8
            ),
            actionsOrientation = "horizontal",
            actionAlignment = "left",
            iconPlacement = "leftOfTitle",
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
            spacing = 32
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
            veryNarrow = 216,
            narrow = 413,
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
            emptyStar = RatingStarConfig(marigoldColor = "#F9E2AE", neutralColor = "#E1E1E1"),
            ratingTextColor = "#000000",
            countTextColor = "#000000"
        ),
        ratingInput = RatingElementConfig(
            filledStar = RatingStarConfig(marigoldColor = "#EAA300", neutralColor = "#212121"),
            emptyStar = RatingStarConfig(marigoldColor = "#EAA300", neutralColor = "#212121"),
            ratingTextColor = "#000000",
            countTextColor = "#000000"
        ),
        table = TableConfig(cellSpacing = 8),
        compoundButton = CompoundButtonConfig(
            badge = BadgeConfig(backgroundColor = "#5B5FC7"),
            borderColor = "#E1E1E1"
        ),
        cornerRadius = CornerRadiusConfig(
            columnSet = 4,
            column = 4,
            container = 4,
            table = 4,
            image = 4
        ),
        borderWidth = emptyMap(),
        badgeStyles = BadgeStylesConfig(
            default = BadgeStyleVariants(
                filled = BadgeStyleDef(backgroundColor = "#212121", strokeColor = "#212121", textColor = "#FFFFFF"),
                tint = BadgeStyleDef(backgroundColor = "#F1F1F1", strokeColor = "#E1E1E1", textColor = "#212121")
            ),
            accent = BadgeStyleVariants(
                filled = BadgeStyleDef(backgroundColor = "#5B5FC7", strokeColor = "#5B5FC7", textColor = "#FFFFFF"),
                tint = BadgeStyleDef(backgroundColor = "#E8EBFA", strokeColor = "#E1E1E1", textColor = "#5B5FC7")
            ),
            attention = BadgeStyleVariants(
                filled = BadgeStyleDef(backgroundColor = "#D92C2C", strokeColor = "#D92C2C", textColor = "#FFFFFF"),
                tint = BadgeStyleDef(backgroundColor = "#FEF7F7", strokeColor = "#E1E1E1", textColor = "#D92C2C")
            ),
            good = BadgeStyleVariants(
                filled = BadgeStyleDef(backgroundColor = "#0F7A0B", strokeColor = "#0F7A0B", textColor = "#FFFFFF"),
                tint = BadgeStyleDef(backgroundColor = "#E7F2DA", strokeColor = "#E1E1E1", textColor = "#0F7A0B")
            ),
            informative = BadgeStyleVariants(
                filled = BadgeStyleDef(backgroundColor = "#FFFFFF", strokeColor = "#FFFFFF", textColor = "#212121"),
                tint = BadgeStyleDef(backgroundColor = "#FFFFFF", strokeColor = "#E1E1E1", textColor = "#6E6E6E")
            ),
            subtle = BadgeStyleVariants(
                filled = BadgeStyleDef(backgroundColor = "#F8F8F8", strokeColor = "#F8F8F8", textColor = "#6E6E6E"),
                tint = BadgeStyleDef(backgroundColor = "#F8F8F8", strokeColor = "#E1E1E1", textColor = "#6E6E6E")
            ),
            warning = BadgeStyleVariants(
                filled = BadgeStyleDef(backgroundColor = "#835C00", strokeColor = "#835C00", textColor = "#FFFFFF"),
                tint = BadgeStyleDef(backgroundColor = "#FBF6D9", strokeColor = "#E1E1E1", textColor = "#835C00")
            )
        ),
        pageControl = PageControlConfig(selectedTintColor = "#5B5FC7")
    )

    /** Teams dark theme — dark card surface. */
    fun createDark(): HostConfig = HostConfig(
        fontFamily = "Roboto",
        supportsInteractivity = true,
        imageBaseUrl = "",
        spacing = SpacingConfig(
            extraSmall = 4,
            small = 8,
            default = 8,
            medium = 12,
            large = 16,
            extraLarge = 20,
            padding = 10
        ),
        separator = SeparatorConfig(
            lineThickness = 1,
            lineColor = "#EEEEEE"
        ),
        fontTypes = FontTypesConfig(
            default = FontTypeConfig(
                fontFamily = "Roboto, system-ui, sans-serif"
            ),
            monospace = FontTypeConfig(
                fontFamily = "Roboto Mono, Courier New, monospace"
            )
        ),
        fontSizes = FontSizesConfig(
            small = 12,
            default = 14,
            medium = 14,
            large = 16,
            extraLarge = 20
        ),
        fontWeights = FontWeightsConfig(
            lighter = 400,
            default = 400,
            bolder = 500
        ),
        lineHeights = LineHeightsConfig(
            small = 16,
            default = 18,
            medium = 18,
            large = 24,
            extraLarge = 24
        ),
        containerStyles = ContainerStylesConfig(
            default = ContainerStyleConfig(
                backgroundColor = "#141414",
                borderColor = "#292929",
                foregroundColors = teamsDarkForegroundColors()
            ),
            emphasis = ContainerStyleConfig(
                backgroundColor = "#141414",
                borderColor = "#292929",
                foregroundColors = teamsDarkForegroundColors()
            ),
            good = ContainerStyleConfig(
                backgroundColor = "#052505",
                borderColor = "#217346",
                foregroundColors = teamsDarkForegroundColors()
            ),
            attention = ContainerStyleConfig(
                backgroundColor = "#3B0509",
                borderColor = "#D74654",
                foregroundColors = teamsDarkForegroundColors()
            ),
            warning = ContainerStyleConfig(
                backgroundColor = "#4A3F04",
                borderColor = "#C4AB00",
                foregroundColors = teamsDarkForegroundColors()
            ),
            accent = ContainerStyleConfig(
                backgroundColor = "#1A1A3E",
                borderColor = "#7D84C4",
                foregroundColors = teamsDarkForegroundColors()
            )
        ),
        imageSizes = ImageSizesConfig(
            small = 32,
            medium = 52,
            large = 100
        ),
        actions = ActionsConfig(
            maxActions = 6,
            spacing = Spacing.Medium,
            buttonSpacing = 8,
            showCard = ShowCardConfig(
                actionMode = "inline",
                style = ContainerStyle.Default,
                inlineTopMargin = 8
            ),
            actionsOrientation = "horizontal",
            actionAlignment = "left",
            iconPlacement = "leftOfTitle",
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
            spacing = 32
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
            veryNarrow = 216,
            narrow = 413,
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
            filledStar = RatingStarConfig(marigoldColor = "#EAA300", neutralColor = "#E1E1E1"),
            emptyStar = RatingStarConfig(marigoldColor = "#835B00", neutralColor = "#404040"),
            ratingTextColor = "#E1E1E1",
            countTextColor = "#E1E1E1"
        ),
        ratingInput = RatingElementConfig(
            filledStar = RatingStarConfig(marigoldColor = "#F2C661", neutralColor = "#E1E1E1"),
            emptyStar = RatingStarConfig(marigoldColor = "#F2C661", neutralColor = "#E1E1E1"),
            ratingTextColor = "#000000",
            countTextColor = "#000000"
        ),
        table = TableConfig(cellSpacing = 8),
        compoundButton = CompoundButtonConfig(
            badge = BadgeConfig(backgroundColor = "#7F85F5"),
            borderColor = "#000000"
        ),
        cornerRadius = CornerRadiusConfig(
            columnSet = 4,
            column = 4,
            container = 4,
            table = 4,
            image = 4
        ),
        borderWidth = emptyMap(),
        badgeStyles = BadgeStylesConfig(
            default = BadgeStyleVariants(
                filled = BadgeStyleDef(backgroundColor = "#e1e1e1", strokeColor = "#e1e1e1", textColor = "#000000"),
                tint = BadgeStyleDef(backgroundColor = "#919191", strokeColor = "#919191", textColor = "#000000")
            ),
            accent = BadgeStyleVariants(
                filled = BadgeStyleDef(backgroundColor = "#7f85f5", strokeColor = "#7f85f5", textColor = "#000000"),
                tint = BadgeStyleDef(backgroundColor = "#2f2f4a", strokeColor = "#292929", textColor = "#7f85f5")
            ),
            attention = BadgeStyleVariants(
                filled = BadgeStyleDef(backgroundColor = "#e83a3a", strokeColor = "#e83a3a", textColor = "#000000"),
                tint = BadgeStyleDef(backgroundColor = "#250909", strokeColor = "#292929", textColor = "#e83a3a")
            ),
            good = BadgeStyleVariants(
                filled = BadgeStyleDef(backgroundColor = "#0eb244", strokeColor = "#0eb244", textColor = "#000000"),
                tint = BadgeStyleDef(backgroundColor = "#0d2e0d", strokeColor = "#292929", textColor = "#0eb244")
            ),
            informative = BadgeStyleVariants(
                filled = BadgeStyleDef(backgroundColor = "#292929", strokeColor = "#292929", textColor = "#919191"),
                tint = BadgeStyleDef(backgroundColor = "#212121", strokeColor = "#292929", textColor = "#919191")
            ),
            subtle = BadgeStyleVariants(
                filled = BadgeStyleDef(backgroundColor = "#000000", strokeColor = "#000000", textColor = "#e1e1e1"),
                tint = BadgeStyleDef(backgroundColor = "#000000", strokeColor = "#292929", textColor = "#e1e1e1")
            ),
            warning = BadgeStyleVariants(
                filled = BadgeStyleDef(backgroundColor = "#ffb900", strokeColor = "#ffb900", textColor = "#000000"),
                tint = BadgeStyleDef(backgroundColor = "#4d3a0c", strokeColor = "#292929", textColor = "#ffb900")
            )
        ),
        pageControl = PageControlConfig(selectedTintColor = "#7F85F5")
    )

    /** Foreground colors for the Teams light theme. */
    private fun teamsLightForegroundColors(): ForegroundColorsConfig = ForegroundColorsConfig(
        default = ColorConfig(default = "#212121", subtle = "#6E6E6E"),
        dark = ColorConfig(default = "#000000", subtle = "#212121"),
        light = ColorConfig(default = "#FFFFFF", subtle = "#F1F1F1"),
        accent = ColorConfig(default = "#6264A7", subtle = "#8B8CC7"),
        good = ColorConfig(default = "#237B4B", subtle = "#217346"),
        warning = ColorConfig(default = "#C50F1F", subtle = "#CC4A31"),
        attention = ColorConfig(default = "#C4314B", subtle = "#B24782")
    )

    /** Foreground colors for the Teams dark theme. */
    private fun teamsDarkForegroundColors(): ForegroundColorsConfig = ForegroundColorsConfig(
        default = ColorConfig(default = "#FFFFFF", subtle = "#919191"),
        dark = ColorConfig(default = "#000000", subtle = "#141414"),
        light = ColorConfig(default = "#FFFFFF", subtle = "#E1E1E1"),
        accent = ColorConfig(default = "#7D84C4", subtle = "#8B8CC7"),
        good = ColorConfig(default = "#92C353", subtle = "#217346"),
        warning = ColorConfig(default = "#D74654", subtle = "#4F232B"),
        attention = ColorConfig(default = "#D74654", subtle = "#CF6098")
    )
}
