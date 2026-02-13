import Foundation

/// Pre-configured Microsoft Teams host config with Fluent UI design tokens
public class TeamsHostConfig {
    public static func create() -> HostConfig {
        return HostConfig(
            spacing: SpacingConfig(
                small: 4,
                default: 8,
                medium: 12,
                large: 16,
                extraLarge: 24,
                padding: 16
            ),
            separator: SeparatorConfig(
                lineThickness: 1,
                lineColor: "#E1DFDD"
            ),
            fontSizes: FontSizesConfig(
                small: 12,
                default: 14,
                medium: 16,
                large: 20,
                extraLarge: 26
            ),
            fontWeights: FontWeightsConfig(
                lighter: 300,
                default: 400,
                bolder: 600
            ),
            fontTypes: FontTypesConfig(
                default: FontTypesConfig.FontFamilyConfig(fontFamily: "Segoe UI"),
                monospace: FontTypesConfig.FontFamilyConfig(fontFamily: "Courier New")
            ),
            containerStyles: ContainerStylesConfig(
                default: ContainerStyleConfig(
                    backgroundColor: "#FFFFFF",
                    foregroundColors: teamsDefaultForegroundColors()
                ),
                emphasis: ContainerStyleConfig(
                    backgroundColor: "#F5F5F5",
                    foregroundColors: teamsDefaultForegroundColors()
                ),
                good: ContainerStyleConfig(
                    backgroundColor: "#DFF6DD",
                    foregroundColors: teamsDefaultForegroundColors()
                ),
                attention: ContainerStyleConfig(
                    backgroundColor: "#FFF4CE",
                    foregroundColors: teamsDefaultForegroundColors()
                ),
                warning: ContainerStyleConfig(
                    backgroundColor: "#FED9CC",
                    foregroundColors: teamsDefaultForegroundColors()
                ),
                accent: ContainerStyleConfig(
                    backgroundColor: "#E8F2FD",
                    foregroundColors: teamsDefaultForegroundColors()
                )
            ),
            imageSizes: ImageSizesConfig(
                small: 40,
                medium: 80,
                large: 160
            ),
            actions: ActionsConfig(
                actionsOrientation: "Horizontal",
                actionAlignment: "Left",
                buttonSpacing: 8,
                maxActions: 5,
                spacing: "Default",
                showCard: ShowCardConfig(
                    actionMode: "Inline",
                    style: "Emphasis"
                )
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
                spacing: 8
            )
        )
    }

    private static func teamsDefaultForegroundColors() -> ForegroundColorsConfig {
        return ForegroundColorsConfig(
            default: ColorConfig(default: "#242424", subtle: "#616161"),
            dark: ColorConfig(default: "#000000", subtle: "#666666"),
            light: ColorConfig(default: "#FFFFFF", subtle: "#CCCCCC"),
            accent: ColorConfig(default: "#6264A7", subtle: "#464775"),
            good: ColorConfig(default: "#92C353", subtle: "#6EA02C"),
            warning: ColorConfig(default: "#F8D22A", subtle: "#C5A300"),
            attention: ColorConfig(default: "#C4314B", subtle: "#A72037")
        )
    }
}
