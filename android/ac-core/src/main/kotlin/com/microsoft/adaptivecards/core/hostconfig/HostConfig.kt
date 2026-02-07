package com.microsoft.adaptivecards.core.hostconfig

import com.microsoft.adaptivecards.core.models.*
import kotlinx.serialization.Serializable

@Serializable
data class HostConfig(
    val spacing: SpacingConfig = SpacingConfig(),
    val separator: SeparatorConfig = SeparatorConfig(),
    val supportsInteractivity: Boolean = true,
    val fontTypes: FontTypesConfig = FontTypesConfig(),
    val fontSizes: FontSizesConfig = FontSizesConfig(),
    val fontWeights: FontWeightsConfig = FontWeightsConfig(),
    val containerStyles: ContainerStylesConfig = ContainerStylesConfig(),
    val imageSizes: ImageSizesConfig = ImageSizesConfig(),
    val actions: ActionsConfig = ActionsConfig(),
    val adaptiveCard: AdaptiveCardConfig = AdaptiveCardConfig(),
    val imageSet: ImageSetConfig = ImageSetConfig(),
    val media: MediaConfig = MediaConfig(),
    val factSet: FactSetConfig = FactSetConfig(),
    val inputs: InputsConfig = InputsConfig()
)

@Serializable
data class SpacingConfig(
    val small: Int = 4,
    val default: Int = 8,
    val medium: Int = 16,
    val large: Int = 24,
    val extraLarge: Int = 32,
    val padding: Int = 16
)

@Serializable
data class SeparatorConfig(
    val lineThickness: Int = 1,
    val lineColor: String = "#B2B2B2"
)

@Serializable
data class FontTypesConfig(
    val default: FontTypeConfig = FontTypeConfig(),
    val monospace: FontTypeConfig = FontTypeConfig(fontFamily = "Courier New, Courier, monospace")
)

@Serializable
data class FontTypeConfig(
    val fontFamily: String = "system-ui, -apple-system, sans-serif",
    val fontSizes: FontSizesConfig? = null,
    val fontWeights: FontWeightsConfig? = null
)

@Serializable
data class FontSizesConfig(
    val small: Int = 12,
    val default: Int = 14,
    val medium: Int = 17,
    val large: Int = 21,
    val extraLarge: Int = 26
)

@Serializable
data class FontWeightsConfig(
    val lighter: Int = 300,
    val default: Int = 400,
    val bolder: Int = 700
)

@Serializable
data class ContainerStylesConfig(
    val default: ContainerStyleConfig = ContainerStyleConfig(),
    val emphasis: ContainerStyleConfig = ContainerStyleConfig(backgroundColor = "#F0F0F0"),
    val good: ContainerStyleConfig = ContainerStyleConfig(backgroundColor = "#E8F5E9"),
    val attention: ContainerStyleConfig = ContainerStyleConfig(backgroundColor = "#FFF3E0"),
    val warning: ContainerStyleConfig = ContainerStyleConfig(backgroundColor = "#FFF3E0"),
    val accent: ContainerStyleConfig = ContainerStyleConfig(backgroundColor = "#E3F2FD")
)

@Serializable
data class ContainerStyleConfig(
    val backgroundColor: String = "#FFFFFF",
    val foregroundColors: ForegroundColorsConfig = ForegroundColorsConfig()
)

@Serializable
data class ForegroundColorsConfig(
    val default: ColorConfig = ColorConfig(default = "#333333", subtle = "#767676"),
    val dark: ColorConfig = ColorConfig(default = "#000000", subtle = "#666666"),
    val light: ColorConfig = ColorConfig(default = "#FFFFFF", subtle = "#CCCCCC"),
    val accent: ColorConfig = ColorConfig(default = "#0078D4", subtle = "#88C6FF"),
    val good: ColorConfig = ColorConfig(default = "#54A254", subtle = "#88C288"),
    val warning: ColorConfig = ColorConfig(default = "#C4AB00", subtle = "#DDCC6C"),
    val attention: ColorConfig = ColorConfig(default = "#C42B1C", subtle = "#DD6A5C")
)

@Serializable
data class ColorConfig(
    val default: String,
    val subtle: String
)

@Serializable
data class ImageSizesConfig(
    val small: Int = 40,
    val medium: Int = 80,
    val large: Int = 160
)

@Serializable
data class ActionsConfig(
    val maxActions: Int = 5,
    val spacing: Spacing = Spacing.Default,
    val buttonSpacing: Int = 8,
    val showCard: ShowCardConfig = ShowCardConfig(),
    val actionsOrientation: String = "horizontal",
    val actionAlignment: String = "stretch",
    val iconPlacement: String = "aboveTitle",
    val iconSize: Int = 24
)

@Serializable
data class ShowCardConfig(
    val actionMode: String = "inline",
    val style: ContainerStyle = ContainerStyle.Emphasis,
    val inlineTopMargin: Int = 16
)

@Serializable
data class AdaptiveCardConfig(
    val allowCustomStyle: Boolean = true
)

@Serializable
data class ImageSetConfig(
    val imageSize: ImageSize = ImageSize.Medium,
    val maxImageHeight: Int = 100
)

@Serializable
data class MediaConfig(
    val defaultPoster: String? = null,
    val allowInlinePlayback: Boolean = true
)

@Serializable
data class FactSetConfig(
    val title: FactSetTextConfig = FactSetTextConfig(weight = FontWeight.Bolder),
    val value: FactSetTextConfig = FactSetTextConfig(),
    val spacing: Int = 10
)

@Serializable
data class FactSetTextConfig(
    val size: FontSize = FontSize.Default,
    val color: Color = Color.Default,
    val isSubtle: Boolean = false,
    val weight: FontWeight = FontWeight.Default,
    val wrap: Boolean = true
)

@Serializable
data class InputsConfig(
    val label: InputLabelConfig = InputLabelConfig(),
    val errorMessage: InputErrorMessageConfig = InputErrorMessageConfig()
)

@Serializable
data class InputLabelConfig(
    val color: Color = Color.Default,
    val isSubtle: Boolean = false,
    val size: FontSize = FontSize.Default,
    val suffix: String = " *",
    val weight: FontWeight = FontWeight.Default
)

@Serializable
data class InputErrorMessageConfig(
    val color: Color = Color.Attention,
    val size: FontSize = FontSize.Small,
    val weight: FontWeight = FontWeight.Default
)
