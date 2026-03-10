import Foundation

/// Pre-configured Microsoft Teams host config with Fluent UI design tokens
/// aligned to the Adaptive Card specification Figma (Teams UI + Fluent Tokens).
public class TeamsHostConfig {
    public static func create() -> HostConfig {
        return HostConfig(
            fontFamily: "Segoe UI",
            supportsInteractivity: true,
            imageBaseUrl: "",
            spacing: SpacingConfig(
                small: 8,
                default: 8,
                medium: 12,
                large: 16,
                extraLarge: 20,
                padding: 10
            ),
            separator: SeparatorConfig(
                lineThickness: 1,
                lineColor: "#0D16233A"
            ),
            fontSizes: FontSizesConfig(
                small: 12,
                default: 14,
                medium: 14,
                large: 16,
                extraLarge: 20
            ),
            fontWeights: FontWeightsConfig(
                lighter: 400,
                default: 400,
                bolder: 500
            ),
            fontTypes: FontTypesConfig(
                default: FontTypeDefinition(fontFamily: "Segoe UI"),
                monospace: FontTypeDefinition(fontFamily: "Courier New")
            ),
            containerStyles: ContainerStylesConfig(
                default: ContainerStyleConfig(
                    backgroundColor: "#FFFFFF",
                    foregroundColors: teamsLightDefaultForegroundColors(),
                    borderColor: "#E1E1E1"
                ),
                emphasis: ContainerStyleConfig(
                    backgroundColor: "#F1F1F1",
                    foregroundColors: teamsLightDefaultForegroundColors(),
                    borderColor: "#E1E1E1"
                ),
                good: ContainerStyleConfig(
                    backgroundColor: "#DFF6DD",
                    foregroundColors: teamsLightDefaultForegroundColors(),
                    borderColor: "#9FD89F"
                ),
                attention: ContainerStyleConfig(
                    backgroundColor: "#FFF4CE",
                    foregroundColors: teamsLightDefaultForegroundColors(),
                    borderColor: "#F8D22A"
                ),
                warning: ContainerStyleConfig(
                    backgroundColor: "#FED9CC",
                    foregroundColors: teamsLightDefaultForegroundColors(),
                    borderColor: "#E97548"
                ),
                accent: ContainerStyleConfig(
                    backgroundColor: "#E8F2FD",
                    foregroundColors: teamsLightDefaultForegroundColors(),
                    borderColor: "#6264A7"
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
                spacing: "Medium",
                showCard: ShowCardConfig(
                    actionMode: "Inline",
                    style: "Emphasis",
                    inlineTopMargin: 8
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
                spacing: 32
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
                filledStar: RatingStarConfig(marigoldColor: "#EAA300", neutralColor: "#242424"),
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
            ]
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
