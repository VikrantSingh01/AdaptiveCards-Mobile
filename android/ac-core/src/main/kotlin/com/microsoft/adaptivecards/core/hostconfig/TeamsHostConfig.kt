package com.microsoft.adaptivecards.core.hostconfig

import com.microsoft.adaptivecards.core.models.*

/**
 * Pre-configured HostConfig for Microsoft Teams with Fluent UI design tokens
 */
object TeamsHostConfig {
    fun create(): HostConfig = HostConfig(
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
        supportsInteractivity = true,
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
                foregroundColors = ForegroundColorsConfig(
                    default = ColorConfig(default = "#242424", subtle = "#616161"),
                    dark = ColorConfig(default = "#000000", subtle = "#616161"),
                    light = ColorConfig(default = "#FFFFFF", subtle = "#E1DFDD"),
                    accent = ColorConfig(default = "#6264A7", subtle = "#8B8CC7"),
                    good = ColorConfig(default = "#92C353", subtle = "#9ED06D"),
                    warning = ColorConfig(default = "#F8D22A", subtle = "#F9DD51"),
                    attention = ColorConfig(default = "#C4314B", subtle = "#D3596D")
                )
            ),
            emphasis = ContainerStyleConfig(
                backgroundColor = "#F5F5F5",
                foregroundColors = ForegroundColorsConfig(
                    default = ColorConfig(default = "#242424", subtle = "#616161"),
                    dark = ColorConfig(default = "#000000", subtle = "#616161"),
                    light = ColorConfig(default = "#FFFFFF", subtle = "#E1DFDD"),
                    accent = ColorConfig(default = "#6264A7", subtle = "#8B8CC7"),
                    good = ColorConfig(default = "#92C353", subtle = "#9ED06D"),
                    warning = ColorConfig(default = "#F8D22A", subtle = "#F9DD51"),
                    attention = ColorConfig(default = "#C4314B", subtle = "#D3596D")
                )
            ),
            good = ContainerStyleConfig(
                backgroundColor = "#DFF6DD",
                foregroundColors = ForegroundColorsConfig(
                    default = ColorConfig(default = "#242424", subtle = "#616161"),
                    dark = ColorConfig(default = "#000000", subtle = "#616161"),
                    light = ColorConfig(default = "#FFFFFF", subtle = "#E1DFDD"),
                    accent = ColorConfig(default = "#6264A7", subtle = "#8B8CC7"),
                    good = ColorConfig(default = "#92C353", subtle = "#9ED06D"),
                    warning = ColorConfig(default = "#F8D22A", subtle = "#F9DD51"),
                    attention = ColorConfig(default = "#C4314B", subtle = "#D3596D")
                )
            ),
            attention = ContainerStyleConfig(
                backgroundColor = "#FED9CC",
                foregroundColors = ForegroundColorsConfig(
                    default = ColorConfig(default = "#242424", subtle = "#616161"),
                    dark = ColorConfig(default = "#000000", subtle = "#616161"),
                    light = ColorConfig(default = "#FFFFFF", subtle = "#E1DFDD"),
                    accent = ColorConfig(default = "#6264A7", subtle = "#8B8CC7"),
                    good = ColorConfig(default = "#92C353", subtle = "#9ED06D"),
                    warning = ColorConfig(default = "#F8D22A", subtle = "#F9DD51"),
                    attention = ColorConfig(default = "#C4314B", subtle = "#D3596D")
                )
            ),
            warning = ContainerStyleConfig(
                backgroundColor = "#FFF4CE",
                foregroundColors = ForegroundColorsConfig(
                    default = ColorConfig(default = "#242424", subtle = "#616161"),
                    dark = ColorConfig(default = "#000000", subtle = "#616161"),
                    light = ColorConfig(default = "#FFFFFF", subtle = "#E1DFDD"),
                    accent = ColorConfig(default = "#6264A7", subtle = "#8B8CC7"),
                    good = ColorConfig(default = "#92C353", subtle = "#9ED06D"),
                    warning = ColorConfig(default = "#F8D22A", subtle = "#F9DD51"),
                    attention = ColorConfig(default = "#C4314B", subtle = "#D3596D")
                )
            ),
            accent = ContainerStyleConfig(
                backgroundColor = "#E8E8F7",
                foregroundColors = ForegroundColorsConfig(
                    default = ColorConfig(default = "#242424", subtle = "#616161"),
                    dark = ColorConfig(default = "#000000", subtle = "#616161"),
                    light = ColorConfig(default = "#FFFFFF", subtle = "#E1DFDD"),
                    accent = ColorConfig(default = "#6264A7", subtle = "#8B8CC7"),
                    good = ColorConfig(default = "#92C353", subtle = "#9ED06D"),
                    warning = ColorConfig(default = "#F8D22A", subtle = "#F9DD51"),
                    attention = ColorConfig(default = "#C4314B", subtle = "#D3596D")
                )
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
            label = InputLabelConfig(
                color = Color.Default,
                isSubtle = false,
                size = FontSize.Default,
                suffix = " *",
                weight = FontWeight.Default
            ),
            errorMessage = InputErrorMessageConfig(
                color = Color.Attention,
                size = FontSize.Small,
                weight = FontWeight.Default
            )
        )
    )
}
