#if canImport(UIKit)
import XCTest
import SwiftUI
@testable import ACCore
@testable import ACRendering

/// Element-level snapshot tests for core card elements.
///
/// Uses the custom SnapshotTestCase framework (no external dependencies).
/// Renders individual AdaptiveCardView instances from inline JSON and compares
/// against stored baselines.
///
/// Record baselines: `RECORD_SNAPSHOTS=1 swift test --filter SnapshotTests`
/// Verify:           `swift test --filter SnapshotTests`
final class CardElementSnapshotTests: CardSnapshotTestCase {

    // MARK: - TextBlock Snapshots

    func testTextBlockBasic() {
        let json = """
        {
            "type": "AdaptiveCard",
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.5",
            "body": [
                { "type": "TextBlock", "text": "Hello World", "size": "large", "weight": "bolder" }
            ]
        }
        """
        let view = createCardView(json: json)
        assertSnapshot(of: view, named: "textblock_basic", configuration: .iPhone15Pro)
    }

    func testTextBlockAllSizes() {
        let sizes = ["small", "default", "medium", "large", "extraLarge"]
        for size in sizes {
            let json = """
            {
                "type": "AdaptiveCard",
                "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                "version": "1.5",
                "body": [
                    { "type": "TextBlock", "text": "Sample Text — \(size)", "size": "\(size)" }
                ]
            }
            """
            let view = createCardView(json: json)
            assertSnapshot(of: view, named: "textblock_size_\(size)", configuration: .iPhone15Pro)
        }
    }

    func testTextBlockWrapping() {
        let json = """
        {
            "type": "AdaptiveCard",
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.5",
            "body": [
                { "type": "TextBlock", "text": "This is a very long text that should wrap across multiple lines when rendered in a narrow container to verify wrapping behavior.", "wrap": true }
            ]
        }
        """
        let view = createCardView(json: json)
        assertSnapshots(of: view, named: "textblock_wrapping", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    // MARK: - Image Snapshots

    func testImagePlaceholder() {
        let json = """
        {
            "type": "AdaptiveCard",
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.5",
            "body": [
                { "type": "Image", "url": "https://adaptivecards.io/content/cats/1.png", "size": "medium", "altText": "Cat" }
            ]
        }
        """
        let view = createCardView(json: json)
        assertSnapshot(of: view, named: "image_medium", configuration: .iPhone15Pro)
    }

    // MARK: - Container Snapshots

    func testContainerBasic() {
        let json = """
        {
            "type": "AdaptiveCard",
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.5",
            "body": [
                {
                    "type": "Container",
                    "items": [
                        { "type": "TextBlock", "text": "Title", "size": "large", "weight": "bolder" },
                        { "type": "TextBlock", "text": "Subtitle", "color": "accent", "isSubtle": true }
                    ]
                }
            ]
        }
        """
        let view = createCardView(json: json)
        assertSnapshot(of: view, named: "container_basic", configuration: .iPhone15Pro)
    }

    func testContainerWithStyle() {
        let json = """
        {
            "type": "AdaptiveCard",
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.5",
            "body": [
                {
                    "type": "Container",
                    "style": "emphasis",
                    "items": [
                        { "type": "TextBlock", "text": "Emphasis Container", "weight": "bolder" },
                        { "type": "TextBlock", "text": "With styled background" }
                    ]
                },
                {
                    "type": "Container",
                    "style": "accent",
                    "items": [
                        { "type": "TextBlock", "text": "Accent Container", "weight": "bolder" },
                        { "type": "TextBlock", "text": "With accent background" }
                    ]
                }
            ]
        }
        """
        let view = createCardView(json: json)
        assertSnapshots(of: view, named: "container_styles", configurations: SnapshotConfiguration.allAppearances)
    }

    // MARK: - ColumnSet Snapshots

    func testColumnSetBasic() {
        let json = """
        {
            "type": "AdaptiveCard",
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.5",
            "body": [
                {
                    "type": "ColumnSet",
                    "columns": [
                        { "type": "Column", "width": "1", "items": [{ "type": "TextBlock", "text": "Column 1" }] },
                        { "type": "Column", "width": "1", "items": [{ "type": "TextBlock", "text": "Column 2" }] },
                        { "type": "Column", "width": "1", "items": [{ "type": "TextBlock", "text": "Column 3" }] }
                    ]
                }
            ]
        }
        """
        let view = createCardView(json: json)
        assertSnapshots(of: view, named: "columnset_basic", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    // MARK: - Dark Mode Tests

    func testDarkModeRendering() {
        let json = """
        {
            "type": "AdaptiveCard",
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.5",
            "body": [
                { "type": "TextBlock", "text": "Dark Mode Text", "size": "large", "weight": "bolder" },
                { "type": "TextBlock", "text": "Subtitle in dark mode", "isSubtle": true },
                {
                    "type": "Container",
                    "style": "emphasis",
                    "items": [{ "type": "TextBlock", "text": "Emphasis in dark" }]
                }
            ]
        }
        """
        let view = createCardView(json: json)
        assertSnapshots(of: view, named: "dark_mode_elements", configurations: SnapshotConfiguration.allAppearances)
    }

    // MARK: - Responsive Layout Tests

    func testResponsiveLayout() {
        let json = """
        {
            "type": "AdaptiveCard",
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.5",
            "body": [
                { "type": "TextBlock", "text": "Responsive Card", "size": "large" },
                {
                    "type": "ColumnSet",
                    "columns": [
                        { "type": "Column", "width": "auto", "items": [{ "type": "TextBlock", "text": "Auto" }] },
                        { "type": "Column", "width": "stretch", "items": [{ "type": "TextBlock", "text": "Stretch" }] }
                    ]
                }
            ]
        }
        """
        let view = createCardView(json: json)
        assertSnapshots(of: view, named: "responsive_layout", configurations: [
            .iPhoneSE, .iPhone15Pro, .iPadPortrait, .iPadLandscape
        ])
    }

    // MARK: - Accessibility Size Tests

    func testAccessibilitySizes() {
        let json = """
        {
            "type": "AdaptiveCard",
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.5",
            "body": [
                { "type": "TextBlock", "text": "Accessibility Test", "size": "medium", "weight": "bolder" },
                { "type": "TextBlock", "text": "This text should scale with dynamic type settings.", "wrap": true }
            ]
        }
        """
        let view = createCardView(json: json)
        assertSnapshots(of: view, named: "accessibility_sizes", configurations: SnapshotConfiguration.allAccessibilitySizes)
    }
}
#endif // canImport(UIKit)
