#if canImport(UIKit)
import XCTest
import SwiftUI
@testable import ACCore
@testable import ACRendering

/// Visual regression tests focused on appearance variations.
///
/// Validates rendering consistency across:
/// - Light mode vs dark mode
/// - Different font/accessibility scales
/// - Custom host configurations
///
/// These tests are critical for ensuring theme support works correctly
/// and that accessibility settings do not break layouts.
final class AppearanceVisualTests: CardSnapshotTestCase {

    // MARK: - Light vs Dark Mode Comparisons

    /// Tests every card in both light and dark mode to flag theme rendering issues
    func testAllCards_lightVsDark() {
        let cardNames = Self.allTestCardNames
        let configs: [SnapshotConfiguration] = [.iPhone15Pro, .iPhone15ProDark]

        for cardName in cardNames {
            assertCardSnapshots(named: cardName, configurations: configs)
        }
    }

    // MARK: - Accessibility Size Scale Tests

    /// Tests a representative card at each accessibility size
    func testSimpleText_allAccessibilitySizes() {
        assertCardSnapshots(
            named: "simple-text",
            configurations: SnapshotConfiguration.allAccessibilitySizes
        )
    }

    func testContainers_allAccessibilitySizes() {
        assertCardSnapshots(
            named: "containers",
            configurations: SnapshotConfiguration.allAccessibilitySizes
        )
    }

    func testAllInputs_allAccessibilitySizes() {
        assertCardSnapshots(
            named: "all-inputs",
            configurations: SnapshotConfiguration.allAccessibilitySizes
        )
    }

    func testTable_allAccessibilitySizes() {
        assertCardSnapshots(
            named: "table",
            configurations: SnapshotConfiguration.allAccessibilitySizes
        )
    }

    func testAccordion_allAccessibilitySizes() {
        assertCardSnapshots(
            named: "accordion",
            configurations: SnapshotConfiguration.allAccessibilitySizes
        )
    }

    func testRating_allAccessibilitySizes() {
        assertCardSnapshots(
            named: "rating",
            configurations: SnapshotConfiguration.allAccessibilitySizes
        )
    }

    func testMarkdown_allAccessibilitySizes() {
        assertCardSnapshots(
            named: "markdown",
            configurations: SnapshotConfiguration.allAccessibilitySizes
        )
    }

    // MARK: - Extreme Accessibility Size with Dark Mode

    func testSimpleText_darkMode_accessibilityXXXL() {
        let config = SnapshotConfiguration(
            name: "iPhone_15_Pro_Dark_A11y_XXXL",
            size: CGSize(width: 393, height: 852),
            interfaceStyle: .dark,
            contentSizeCategory: .accessibilityExtraExtraExtraLarge,
            horizontalSizeClass: .compact,
            verticalSizeClass: .regular
        )
        assertCardSnapshot(named: "simple-text", configuration: config)
    }

    func testAllInputs_darkMode_accessibilityXXXL() {
        let config = SnapshotConfiguration(
            name: "iPhone_15_Pro_Dark_A11y_XXXL",
            size: CGSize(width: 393, height: 852),
            interfaceStyle: .dark,
            contentSizeCategory: .accessibilityExtraExtraExtraLarge,
            horizontalSizeClass: .compact,
            verticalSizeClass: .regular
        )
        assertCardSnapshot(named: "all-inputs", configuration: config)
    }

    // MARK: - Custom Host Config Tests

    func testSimpleText_customHostConfig() {
        let customConfig = HostConfig(
            spacing: SpacingConfig(small: 2, default: 4, medium: 8, large: 12, extraLarge: 16, padding: 8),
            fontSizes: FontSizesConfig(small: 10, default: 12, medium: 15, large: 18, extraLarge: 22)
        )
        assertCardSnapshot(
            named: "simple-text",
            configuration: .iPhone15Pro,
            hostConfig: customConfig
        )
    }

    func testContainers_compactHostConfig() {
        let compactConfig = HostConfig(
            spacing: SpacingConfig(small: 1, default: 2, medium: 4, large: 8, extraLarge: 12, padding: 4)
        )
        assertCardSnapshot(
            named: "containers",
            configuration: .iPhone15Pro,
            hostConfig: compactConfig
        )
    }

    func testAllInputs_spaciousHostConfig() {
        let spaciousConfig = HostConfig(
            spacing: SpacingConfig(small: 8, default: 16, medium: 24, large: 32, extraLarge: 48, padding: 24)
        )
        assertCardSnapshot(
            named: "all-inputs",
            configuration: .iPhone15Pro,
            hostConfig: spaciousConfig
        )
    }

    // MARK: - iPad-Specific Tests

    func testAllCards_iPad() {
        let cardNames = Self.allTestCardNames
        let configs: [SnapshotConfiguration] = [.iPadPortrait, .iPadLandscape]

        for cardName in cardNames {
            assertCardSnapshots(named: cardName, configurations: configs)
        }
    }
}
#endif // canImport(UIKit)
