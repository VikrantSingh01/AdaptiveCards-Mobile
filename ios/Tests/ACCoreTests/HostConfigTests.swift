import XCTest
@testable import ACCore

final class HostConfigTests: XCTestCase {

    func testDefaultHostConfig() {
        let config = HostConfig()

        XCTAssertEqual(config.spacing.default, 8)
        XCTAssertEqual(config.fontSizes.default, 12)
        XCTAssertEqual(config.separator.lineThickness, 1)
    }

    func testTeamsHostConfig() {
        let config = TeamsHostConfig.create()

        // Core spacing & typography
        XCTAssertEqual(config.spacing.default, 8)
        XCTAssertEqual(config.spacing.small, 8)
        XCTAssertEqual(config.spacing.medium, 12)
        XCTAssertEqual(config.spacing.large, 16)
        XCTAssertEqual(config.spacing.extraLarge, 20)
        XCTAssertEqual(config.spacing.padding, 10)

        XCTAssertEqual(config.fontSizes.small, 12)
        XCTAssertEqual(config.fontSizes.default, 14)
        XCTAssertEqual(config.fontSizes.medium, 14)
        XCTAssertEqual(config.fontSizes.large, 16)
        XCTAssertEqual(config.fontSizes.extraLarge, 20)

        XCTAssertEqual(config.fontWeights.lighter, 400)
        XCTAssertEqual(config.fontWeights.default, 400)
        XCTAssertEqual(config.fontWeights.bolder, 500)

        // Separator
        XCTAssertEqual(config.separator.lineColor, "#0D16233A")
        XCTAssertEqual(config.separator.lineThickness, 1)

        // Image sizes
        XCTAssertEqual(config.imageSizes.small, 32)
        XCTAssertEqual(config.imageSizes.medium, 52)
        XCTAssertEqual(config.imageSizes.large, 100)

        // Actions
        XCTAssertEqual(config.actions.maxActions, 6)
        XCTAssertEqual(config.actions.buttonSpacing, 8)
        XCTAssertEqual(config.actions.iconPlacement, "LeftOfTitle")

        // Corner radius
        XCTAssertEqual(config.cornerRadius["container"], 4)
        XCTAssertEqual(config.cornerRadius["image"], 4)
        XCTAssertEqual(config.cornerRadius["columnSet"], 4)

        // Foreground colors (light theme)
        let defaultColors = config.containerStyles.default.foregroundColors
        XCTAssertEqual(defaultColors.default.default, "#212121")
        XCTAssertEqual(defaultColors.default.subtle, "#6E6E6E")
        XCTAssertEqual(defaultColors.accent.default, "#6264A7")
        XCTAssertEqual(defaultColors.good.default, "#237B4B")
        XCTAssertEqual(defaultColors.attention.default, "#C4314B")
        XCTAssertEqual(defaultColors.warning.default, "#C50F1F")

        // Container backgrounds
        XCTAssertEqual(config.containerStyles.default.backgroundColor, "#FFFFFF")
        XCTAssertEqual(config.containerStyles.emphasis.backgroundColor, "#F1F1F1")
    }

    func testHostConfigParser() throws {
        let json = """
        {
            "spacing": {
                "small": 4,
                "default": 8,
                "medium": 12,
                "large": 16,
                "extraLarge": 24,
                "padding": 16
            },
            "separator": {
                "lineThickness": 1,
                "lineColor": "#E0E0E0"
            },
            "fontSizes": {
                "small": 12,
                "default": 14,
                "medium": 17,
                "large": 21,
                "extraLarge": 26
            },
            "fontWeights": {
                "lighter": 300,
                "default": 400,
                "bolder": 600
            },
            "fontTypes": {
                "default": {
                    "fontFamily": "System"
                },
                "monospace": {
                    "fontFamily": "Courier"
                }
            },
            "containerStyles": {
                "default": {
                    "backgroundColor": "#FFFFFF",
                    "foregroundColors": {
                        "default": {
                            "default": "#000000",
                            "subtle": "#666666"
                        },
                        "dark": {
                            "default": "#000000",
                            "subtle": "#666666"
                        },
                        "light": {
                            "default": "#FFFFFF",
                            "subtle": "#CCCCCC"
                        },
                        "accent": {
                            "default": "#0078D4",
                            "subtle": "#0063B1"
                        },
                        "good": {
                            "default": "#4CAF50",
                            "subtle": "#388E3C"
                        },
                        "warning": {
                            "default": "#FF9800",
                            "subtle": "#F57C00"
                        },
                        "attention": {
                            "default": "#F44336",
                            "subtle": "#D32F2F"
                        }
                    }
                },
                "emphasis": {
                    "backgroundColor": "#F5F5F5",
                    "foregroundColors": {
                        "default": {
                            "default": "#000000",
                            "subtle": "#666666"
                        },
                        "dark": {
                            "default": "#000000",
                            "subtle": "#666666"
                        },
                        "light": {
                            "default": "#FFFFFF",
                            "subtle": "#CCCCCC"
                        },
                        "accent": {
                            "default": "#0078D4",
                            "subtle": "#0063B1"
                        },
                        "good": {
                            "default": "#4CAF50",
                            "subtle": "#388E3C"
                        },
                        "warning": {
                            "default": "#FF9800",
                            "subtle": "#F57C00"
                        },
                        "attention": {
                            "default": "#F44336",
                            "subtle": "#D32F2F"
                        }
                    }
                },
                "good": {
                    "backgroundColor": "#E8F5E9",
                    "foregroundColors": {
                        "default": {
                            "default": "#000000",
                            "subtle": "#666666"
                        },
                        "dark": {
                            "default": "#000000",
                            "subtle": "#666666"
                        },
                        "light": {
                            "default": "#FFFFFF",
                            "subtle": "#CCCCCC"
                        },
                        "accent": {
                            "default": "#0078D4",
                            "subtle": "#0063B1"
                        },
                        "good": {
                            "default": "#4CAF50",
                            "subtle": "#388E3C"
                        },
                        "warning": {
                            "default": "#FF9800",
                            "subtle": "#F57C00"
                        },
                        "attention": {
                            "default": "#F44336",
                            "subtle": "#D32F2F"
                        }
                    }
                },
                "attention": {
                    "backgroundColor": "#FFF3E0",
                    "foregroundColors": {
                        "default": {
                            "default": "#000000",
                            "subtle": "#666666"
                        },
                        "dark": {
                            "default": "#000000",
                            "subtle": "#666666"
                        },
                        "light": {
                            "default": "#FFFFFF",
                            "subtle": "#CCCCCC"
                        },
                        "accent": {
                            "default": "#0078D4",
                            "subtle": "#0063B1"
                        },
                        "good": {
                            "default": "#4CAF50",
                            "subtle": "#388E3C"
                        },
                        "warning": {
                            "default": "#FF9800",
                            "subtle": "#F57C00"
                        },
                        "attention": {
                            "default": "#F44336",
                            "subtle": "#D32F2F"
                        }
                    }
                },
                "warning": {
                    "backgroundColor": "#FFEBEE",
                    "foregroundColors": {
                        "default": {
                            "default": "#000000",
                            "subtle": "#666666"
                        },
                        "dark": {
                            "default": "#000000",
                            "subtle": "#666666"
                        },
                        "light": {
                            "default": "#FFFFFF",
                            "subtle": "#CCCCCC"
                        },
                        "accent": {
                            "default": "#0078D4",
                            "subtle": "#0063B1"
                        },
                        "good": {
                            "default": "#4CAF50",
                            "subtle": "#388E3C"
                        },
                        "warning": {
                            "default": "#FF9800",
                            "subtle": "#F57C00"
                        },
                        "attention": {
                            "default": "#F44336",
                            "subtle": "#D32F2F"
                        }
                    }
                },
                "accent": {
                    "backgroundColor": "#E3F2FD",
                    "foregroundColors": {
                        "default": {
                            "default": "#000000",
                            "subtle": "#666666"
                        },
                        "dark": {
                            "default": "#000000",
                            "subtle": "#666666"
                        },
                        "light": {
                            "default": "#FFFFFF",
                            "subtle": "#CCCCCC"
                        },
                        "accent": {
                            "default": "#0078D4",
                            "subtle": "#0063B1"
                        },
                        "good": {
                            "default": "#4CAF50",
                            "subtle": "#388E3C"
                        },
                        "warning": {
                            "default": "#FF9800",
                            "subtle": "#F57C00"
                        },
                        "attention": {
                            "default": "#F44336",
                            "subtle": "#D32F2F"
                        }
                    }
                }
            },
            "imageSizes": {
                "small": 60,
                "medium": 120,
                "large": 180
            },
            "actions": {
                "actionsOrientation": "Horizontal",
                "actionAlignment": "Left",
                "buttonSpacing": 8,
                "maxActions": 5,
                "spacing": "Default",
                "showCard": {
                    "actionMode": "Inline",
                    "style": "Emphasis"
                }
            },
            "adaptiveCard": {
                "allowCustomStyle": true
            },
            "imageSet": {
                "imageSize": "Medium",
                "maxImageHeight": 100
            },
            "factSet": {
                "title": {
                    "weight": "Bolder"
                },
                "value": {
                    "weight": "Default"
                },
                "spacing": 8
            }
        }
        """

        let parser = HostConfigParser()
        let config = try parser.parse(json)

        XCTAssertEqual(config.spacing.small, 4)
        XCTAssertEqual(config.fontSizes.default, 14)
        XCTAssertEqual(config.separator.lineColor, "#E0E0E0")
    }
}
