package com.microsoft.adaptivecards.core.hostconfig

import com.microsoft.adaptivecards.core.models.*
import kotlinx.serialization.Serializable

@Serializable
data class HostConfig(
    val fontFamily: String = "",
    val supportsInteractivity: Boolean = true,
    val imageBaseUrl: String = "",
    val spacing: SpacingConfig = SpacingConfig(),
    val separator: SeparatorConfig = SeparatorConfig(),
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
    val inputs: InputsConfig = InputsConfig(),
    val hostWidth: HostWidthConfig = HostWidthConfig(),
    val textBlock: TextBlockConfig = TextBlockConfig(),
    val textStyles: TextStylesConfig = TextStylesConfig(),
    val image: ImageConfig = ImageConfig(),
    val ratingLabel: RatingElementConfig = RatingElementConfig(),
    val ratingInput: RatingElementConfig = RatingElementConfig(),
    val table: TableConfig = TableConfig(),
    val compoundButton: CompoundButtonConfig = CompoundButtonConfig(),
    val lineHeights: LineHeightsConfig = LineHeightsConfig(),
    val borderWidth: Map<String, Int> = emptyMap(),
    val cornerRadius: CornerRadiusConfig = CornerRadiusConfig(),
    val badgeStyles: BadgeStylesConfig = BadgeStylesConfig(),
    val pageControl: PageControlConfig = PageControlConfig()
)

@Serializable
data class SpacingConfig(
    val extraSmall: Int = 4,
    val small: Int = 8,
    val default: Int = 12,
    val medium: Int = 16,
    val large: Int = 20,
    val extraLarge: Int = 24,
    val padding: Int = 12
)

@Serializable
data class SeparatorConfig(
    val lineThickness: Int = 1,
    val lineColor: String = "#EEEEEE"
)

@Serializable
data class FontTypesConfig(
    val default: FontTypeConfig = FontTypeConfig(),
    val monospace: FontTypeConfig = FontTypeConfig(fontFamily = "Courier New, Courier, monospace")
)

@Serializable
data class FontTypeConfig(
    val fontFamily: String = "Roboto, system-ui, sans-serif",
    val fontSizes: FontSizesConfig? = null,
    val fontWeights: FontWeightsConfig? = null
)

@Serializable
data class FontSizesConfig(
    val small: Int = 12,
    val default: Int = 14,
    val medium: Int = 14,
    val large: Int = 16,
    val extraLarge: Int = 20
)

/** Line height configuration matching the Figma type ramp */
@Serializable
data class LineHeightsConfig(
    val small: Int = 16,
    val default: Int = 18,
    val medium: Int = 18,
    val large: Int = 24,
    val extraLarge: Int = 24
)

@Serializable
data class FontWeightsConfig(
    val lighter: Int = 400,
    val default: Int = 400,
    val bolder: Int = 500
)

@Serializable
data class ContainerStylesConfig(
    val default: ContainerStyleConfig = ContainerStyleConfig(),
    val emphasis: ContainerStyleConfig = ContainerStyleConfig(backgroundColor = "#F1F1F1"),
    val good: ContainerStyleConfig = ContainerStyleConfig(backgroundColor = "#DFF6DD"),
    val attention: ContainerStyleConfig = ContainerStyleConfig(backgroundColor = "#FED9CC"),
    val warning: ContainerStyleConfig = ContainerStyleConfig(backgroundColor = "#FFF4CE"),
    val accent: ContainerStyleConfig = ContainerStyleConfig(backgroundColor = "#E8E8F7")
)

@Serializable
data class ContainerStyleConfig(
    val backgroundColor: String = "#FFFFFF",
    val borderColor: String = "#E0E0E0",
    val foregroundColors: ForegroundColorsConfig = ForegroundColorsConfig()
)

@Serializable
data class ForegroundColorsConfig(
    val default: ColorConfig = ColorConfig(default = "#212121", subtle = "#6E6E6E"),
    val dark: ColorConfig = ColorConfig(default = "#000000", subtle = "#212121"),
    val light: ColorConfig = ColorConfig(default = "#FFFFFF", subtle = "#F1F1F1"),
    val accent: ColorConfig = ColorConfig(default = "#6264A7", subtle = "#8B8CC7"),
    val good: ColorConfig = ColorConfig(default = "#237B4B", subtle = "#217346"),
    val warning: ColorConfig = ColorConfig(default = "#C50F1F", subtle = "#CC4A31"),
    val attention: ColorConfig = ColorConfig(default = "#C4314B", subtle = "#B24782")
)

@Serializable
data class ColorConfig(
    val default: String,
    val subtle: String,
    val highlightColors: HighlightColorConfig = HighlightColorConfig()
)

/** Highlight/selection colors for text within a color slot */
@Serializable
data class HighlightColorConfig(
    val default: String = "#FFFFFF00",
    val subtle: String = "#FFFFFFE0"
)

@Serializable
data class ImageSizesConfig(
    val small: Int = 32,
    val medium: Int = 52,
    val large: Int = 100
)

@Serializable
data class ActionsConfig(
    val maxActions: Int = 6,
    val spacing: Spacing = Spacing.Medium,
    val buttonSpacing: Int = 8,
    val showCard: ShowCardConfig = ShowCardConfig(),
    val actionsOrientation: String = "horizontal",
    val actionAlignment: String = "left",
    val iconPlacement: String = "leftOfTitle",
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
    val playButton: String? = null,
    val allowInlinePlayback: Boolean = true
)

@Serializable
data class FactSetConfig(
    val title: FactSetTextConfig = FactSetTextConfig(weight = FontWeight.Bolder),
    val value: FactSetTextConfig = FactSetTextConfig(),
    val spacing: Int = 32
)

@Serializable
data class FactSetTextConfig(
    val size: FontSize = FontSize.Default,
    val color: Color = Color.Default,
    val isSubtle: Boolean = false,
    val weight: FontWeight = FontWeight.Default,
    val fontType: String = "Default",
    val wrap: Boolean = true,
    val maxWidth: Int = 0
)

@Serializable
data class InputsConfig(
    val label: InputLabelGroupConfig = InputLabelGroupConfig(),
    val errorMessage: InputErrorMessageConfig = InputErrorMessageConfig()
)

/** Label configuration for input groups (required vs optional) */
@Serializable
data class InputLabelGroupConfig(
    val inputSpacing: Spacing = Spacing.Default,
    val requiredInputs: InputLabelConfig = InputLabelConfig(),
    val optionalInputs: InputLabelConfig = InputLabelConfig()
)

@Serializable
data class InputLabelConfig(
    val color: Color = Color.Default,
    val isSubtle: Boolean = false,
    val size: FontSize = FontSize.Default,
    val suffix: String = "",
    val weight: FontWeight = FontWeight.Default
)

@Serializable
data class InputErrorMessageConfig(
    val color: Color = Color.Attention,
    val size: FontSize = FontSize.Small,
    val weight: FontWeight = FontWeight.Default
)

// MARK: - New configs ported from production

/** Responsive breakpoints for host width */
@Serializable
data class HostWidthConfig(
    val veryNarrow: Int = 216,
    val narrow: Int = 413,
    val standard: Int = 500
)

/** TextBlock-specific configuration */
@Serializable
data class TextBlockConfig(
    val headingLevel: Int = 2
)

/** Semantic text styles (heading, columnHeader, etc.) */
@Serializable
data class TextStylesConfig(
    val heading: TextStyleConfig = TextStyleConfig(),
    val columnHeader: TextStyleConfig = TextStyleConfig(weight = FontWeight.Bolder)
)

@Serializable
data class TextStyleConfig(
    val weight: FontWeight = FontWeight.Default,
    val size: FontSize = FontSize.Default,
    val isSubtle: Boolean = false,
    val color: Color = Color.Default,
    val fontType: String = "Default"
)

/** Default image configuration */
@Serializable
data class ImageConfig(
    val imageSize: ImageSize = ImageSize.Auto
)

/** Rating element (stars) configuration */
@Serializable
data class RatingElementConfig(
    val filledStar: RatingStarConfig = RatingStarConfig(),
    val emptyStar: RatingStarConfig = RatingStarConfig(),
    val ratingTextColor: String = "#000000",
    val countTextColor: String = "#000000"
)

@Serializable
data class RatingStarConfig(
    val marigoldColor: String = "#EAA300",
    val neutralColor: String = "#212121"
)

/** Table configuration */
@Serializable
data class TableConfig(
    val cellSpacing: Int = 8
)

/** Compound button configuration */
@Serializable
data class CompoundButtonConfig(
    val badge: BadgeConfig = BadgeConfig(),
    val borderColor: String = "#E1E1E1"
)

@Serializable
data class BadgeConfig(
    val backgroundColor: String = "#5B5FC7"
)

/** Corner radius configuration for containers and elements */
@Serializable
data class CornerRadiusConfig(
    val columnSet: Int = 4,
    val column: Int = 4,
    val container: Int = 4,
    val table: Int = 4,
    val image: Int = 4
)

/** Badge styles configuration from Figma spec */
@Serializable
data class BadgeStylesConfig(
    val default: BadgeStyleVariants = BadgeStyleVariants(),
    val accent: BadgeStyleVariants = BadgeStyleVariants(),
    val attention: BadgeStyleVariants = BadgeStyleVariants(),
    val good: BadgeStyleVariants = BadgeStyleVariants(),
    val informative: BadgeStyleVariants = BadgeStyleVariants(),
    val subtle: BadgeStyleVariants = BadgeStyleVariants(),
    val warning: BadgeStyleVariants = BadgeStyleVariants()
)

@Serializable
data class BadgeStyleVariants(
    val filled: BadgeStyleDef = BadgeStyleDef(),
    val tint: BadgeStyleDef = BadgeStyleDef()
)

@Serializable
data class BadgeStyleDef(
    val backgroundColor: String = "#212121",
    val strokeColor: String = "#212121",
    val textColor: String = "#FFFFFF"
)

/** Page control configuration */
@Serializable
data class PageControlConfig(
    val selectedTintColor: String = "#5B5FC7"
)
