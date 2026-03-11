import Foundation

/// Pre-configured Microsoft Teams host config with Fluent UI design tokens
/// aligned to the Adaptive Card specification Figma (iOS page — Light mode).
public class TeamsHostConfig {
    /// Cached singleton — HostConfig is immutable, no need to recreate per card.
    private static let shared: HostConfig = buildLight()

    public static func create() -> HostConfig { shared }

    private static func buildLight() -> HostConfig {
        return HostConfig(
            fontFamily: ".SF UI Text",
            supportsInteractivity: true,
            imageBaseUrl: "",
            spacing: SpacingConfig(
                small: 8,
                default: 10,
                medium: 12,
                large: 16,
                extraLarge: 20,
                padding: 8
            ),
            separator: SeparatorConfig(
                lineThickness: 1,
                lineColor: "#FFDFDEDE"
            ),
            fontSizes: FontSizesConfig(
                small: 12,
                default: 15,
                medium: 15,
                large: 17,
                extraLarge: 22
            ),
            fontWeights: FontWeightsConfig(
                lighter: 300,
                default: 400,
                bolder: 600
            ),
            fontTypes: FontTypesConfig(
                default: FontTypeDefinition(fontFamily: ".SF UI Text"),
                monospace: FontTypeDefinition(fontFamily: "Menlo")
            ),
            containerStyles: ContainerStylesConfig(
                default: ContainerStyleConfig(
                    backgroundColor: "#FFFFFF",
                    foregroundColors: teamsLightDefaultForegroundColors()
                ),
                emphasis: ContainerStyleConfig(
                    backgroundColor: "#F1F1F1",
                    foregroundColors: teamsLightDefaultForegroundColors(),
                    borderColor: "#00FFFFFF"
                ),
                good: ContainerStyleConfig(
                    backgroundColor: "#E7F2DA",
                    foregroundColors: teamsLightDefaultForegroundColors()
                ),
                attention: ContainerStyleConfig(
                    backgroundColor: "#F7E9E9",
                    foregroundColors: teamsLightDefaultForegroundColors()
                ),
                warning: ContainerStyleConfig(
                    backgroundColor: "#FBF6D9",
                    foregroundColors: teamsLightDefaultForegroundColors()
                ),
                accent: ContainerStyleConfig(
                    backgroundColor: "#DCE5F7",
                    foregroundColors: teamsLightDefaultForegroundColors()
                )
            ),
            imageSizes: ImageSizesConfig(
                small: 32,
                medium: 52,
                large: 100
            ),
            actions: ActionsConfig(
                actionsOrientation: "Horizontal",
                actionAlignment: "Left",
                buttonSpacing: 8,
                maxActions: 6,
                spacing: "Default",
                showCard: ShowCardConfig(
                    actionMode: "Inline",
                    style: "Default",
                    inlineTopMargin: 10
                ),
                iconPlacement: "LeftOfTitle",
                iconSize: 16
            ),
            adaptiveCard: AdaptiveCardConfig(
                allowCustomStyle: true
            ),
            imageSet: ImageSetConfig(
                imageSize: "Medium",
                maxImageHeight: 100
            ),
            factSet: FactSetConfig(
                title: FactSetTextConfig(weight: "Bolder"),
                value: FactSetTextConfig(weight: "Default"),
                spacing: 16
            ),
            media: MediaConfig(
                defaultPoster: "",
                playButton: "",
                allowInlinePlayback: true
            ),
            inputs: InputsConfig(
                label: InputLabelGroupConfig(
                    inputSpacing: "Default",
                    requiredInputs: InputLabelConfig(
                        color: "Default",
                        isSubtle: false,
                        size: "Default",
                        suffix: " *",
                        weight: "Default"
                    ),
                    optionalInputs: InputLabelConfig(
                        color: "Default",
                        isSubtle: true,
                        size: "Default",
                        suffix: "",
                        weight: "Default"
                    )
                ),
                errorMessage: ErrorMessageConfig(
                    size: "Default",
                    spacing: "Default",
                    weight: "Default"
                )
            ),
            hostWidth: HostWidthConfig(
                veryNarrow: 216,
                narrow: 413,
                standard: 500
            ),
            textBlock: TextBlockConfig(
                headingLevel: 2
            ),
            textStyles: TextStylesConfig(
                heading: TextStyleConfig(
                    weight: "Bolder",
                    size: "Large",
                    isSubtle: false,
                    color: "Default",
                    fontType: "Default"
                ),
                columnHeader: TextStyleConfig(
                    weight: "Bolder",
                    size: "Default",
                    isSubtle: false,
                    color: "Default",
                    fontType: "Default"
                )
            ),
            image: ImageConfig(imageSize: "Auto"),
            ratingLabel: RatingElementConfig(
                filledStar: RatingStarConfig(marigoldColor: "#EAA300", neutralColor: "#212121"),
                emptyStar: RatingStarConfig(marigoldColor: "#F9E2AE", neutralColor: "#E1E1E1"),
                ratingTextColor: "#000000",
                countTextColor: "#000000"
            ),
            ratingInput: RatingElementConfig(
                filledStar: RatingStarConfig(marigoldColor: "#EAA300", neutralColor: "#212121"),
                emptyStar: RatingStarConfig(marigoldColor: "#EAA300", neutralColor: "#212121"),
                ratingTextColor: "#000000",
                countTextColor: "#000000"
            ),
            table: TableConfig(cellSpacing: 8),
            compoundButton: CompoundButtonConfig(
                badge: BadgeConfig(backgroundColor: "#5B5FC7"),
                borderColor: "#E1E1E1"
            ),
            borderWidth: [:],
            cornerRadius: [
                "columnSet": 4,
                "column": 4,
                "container": 4,
                "table": 4,
                "image": 4
            ],
            badgeStyles: BadgeStylesConfig(
                default: BadgeStyleVariants(
                    filled: BadgeStyleDef(backgroundColor: "#212121", strokeColor: "#212121", textColor: "#ffffff"),
                    tint: BadgeStyleDef(backgroundColor: "#6e6e6e", strokeColor: "#6e6e6e", textColor: "#ffffff")
                ),
                accent: BadgeStyleVariants(
                    filled: BadgeStyleDef(backgroundColor: "#5b5fc7", strokeColor: "#5b5fc7", textColor: "#ffffff"),
                    tint: BadgeStyleDef(backgroundColor: "#e8b8fa", strokeColor: "#e1e1e1", textColor: "#5b5fc7")
                ),
                attention: BadgeStyleVariants(
                    filled: BadgeStyleDef(backgroundColor: "#d92c2c", strokeColor: "#d92c2c", textColor: "#ffffff"),
                    tint: BadgeStyleDef(backgroundColor: "#f9d9d9", strokeColor: "#e1e1e1", textColor: "#d92c2c")
                ),
                good: BadgeStyleVariants(
                    filled: BadgeStyleDef(backgroundColor: "#0f7a0b", strokeColor: "#0f7a0b", textColor: "#ffffff"),
                    tint: BadgeStyleDef(backgroundColor: "#e7f2da", strokeColor: "#e1e1e1", textColor: "#0f7a0b")
                ),
                informative: BadgeStyleVariants(
                    filled: BadgeStyleDef(backgroundColor: "#ffffff", strokeColor: "#ffffff", textColor: "#212121"),
                    tint: BadgeStyleDef(backgroundColor: "#ffffff", strokeColor: "#e1e1e1", textColor: "#212121")
                ),
                subtle: BadgeStyleVariants(
                    filled: BadgeStyleDef(backgroundColor: "#f1f1f1", strokeColor: "#f1f1f1", textColor: "#6e6e6e"),
                    tint: BadgeStyleDef(backgroundColor: "#f1f1f1", strokeColor: "#e1e1e1", textColor: "#6e6e6e")
                ),
                warning: BadgeStyleVariants(
                    filled: BadgeStyleDef(backgroundColor: "#835c00", strokeColor: "#835c00", textColor: "#ffffff"),
                    tint: BadgeStyleDef(backgroundColor: "#fbf6d9", strokeColor: "#e1e1e1", textColor: "#835C00")
                )
            ),
            pageControl: PageControlConfig(selectedTintColor: "#5B5FC7")
        )
    }

    /// Foreground colors for light theme containers matching Figma spec
    private static func teamsLightDefaultForegroundColors() -> ForegroundColorsConfig {
        return ForegroundColorsConfig(
            default: ColorConfig(default: "#212121", subtle: "#6E6E6E"),
            dark: ColorConfig(default: "#000000", subtle: "#212121"),
            light: ColorConfig(default: "#FFFFFF", subtle: "#F1F1F1"),
            accent: ColorConfig(default: "#6264A7", subtle: "#8B8CC7"),
            good: ColorConfig(default: "#237B4B", subtle: "#217346"),
            warning: ColorConfig(default: "#C50F1F", subtle: "#CC4A31"),
            attention: ColorConfig(default: "#C4314B", subtle: "#B24782")
        )
    }
}
