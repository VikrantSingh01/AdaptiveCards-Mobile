import XCTest
@testable import ACCore

final class HostConfigTests: XCTestCase {

    func testDefaultHostConfig() {
        let config = HostConfig()

        XCTAssertEqual(config.spacing.default, 8)
        XCTAssertEqual(config.fontSizes.default, 14)
        XCTAssertEqual(config.separator.lineThickness, 1)
    }

    func testTeamsHostConfig() {
        let config = TeamsHostConfig.create()

        XCTAssertEqual(config.spacing.default, 8)
        XCTAssertEqual(config.fontSizes.default, 14)
        XCTAssertEqual(config.separator.lineColor, "#E1DFDD")
        XCTAssertEqual(config.imageSizes.small, 40)
        XCTAssertEqual(config.imageSizes.medium, 80)
        XCTAssertEqual(config.imageSizes.large, 160)
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
