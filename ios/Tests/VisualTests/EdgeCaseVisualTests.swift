#if canImport(UIKit)
import XCTest
import SwiftUI
@testable import ACCore
@testable import ACRendering

/// Visual regression tests focused on edge cases and boundary conditions.
///
/// These tests verify that unusual or extreme card configurations render
/// correctly without crashes, layout overflow, or visual artifacts.
final class EdgeCaseVisualTests: CardSnapshotTestCase {

    // MARK: - Empty and Minimal Cards

    func testEmptyCard_allDevices() {
        assertCardSnapshots(named: "edge-empty-card", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testEmptyCard_darkMode() {
        assertCardSnapshot(named: "edge-empty-card", configuration: .iPhone15ProDark)
    }

    func testEmptyContainers_allDevices() {
        assertCardSnapshots(named: "edge-empty-containers", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    // MARK: - Deeply Nested Content

    func testDeeplyNestedCard_allDevices() {
        assertCardSnapshots(named: "edge-deeply-nested", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testDeeplyNestedCard_accessibility() {
        assertCardSnapshots(named: "edge-deeply-nested", configurations: SnapshotConfiguration.allAccessibilitySizes)
    }

    // MARK: - Content Overflow

    func testLongTextCard_allDevices() {
        assertCardSnapshots(named: "edge-long-text", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testLongTextCard_landscape() {
        assertCardSnapshots(named: "edge-long-text", configurations: SnapshotConfiguration.allOrientations)
    }

    func testLongTextCard_accessibility() {
        assertCardSnapshots(named: "edge-long-text", configurations: SnapshotConfiguration.allAccessibilitySizes)
    }

    // MARK: - Max Actions

    func testMaxActionsCard_allDevices() {
        assertCardSnapshots(named: "edge-max-actions", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testMaxActionsCard_landscape() {
        assertCardSnapshots(named: "edge-max-actions", configurations: SnapshotConfiguration.allOrientations)
    }

    // MARK: - Unknown Types (Graceful Fallback)

    func testUnknownTypesCard_allDevices() {
        assertCardSnapshots(named: "edge-all-unknown-types", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testUnknownTypesCard_darkMode() {
        assertCardSnapshot(named: "edge-all-unknown-types", configuration: .iPhone15ProDark)
    }

    // MARK: - RTL Content

    func testRTLContentCard_allDevices() {
        assertCardSnapshots(named: "edge-rtl-content", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testRTLContentCard_darkMode() {
        assertCardSnapshot(named: "edge-rtl-content", configuration: .iPhone15ProDark)
    }

    func testRTLContentCard_accessibility() {
        assertCardSnapshots(named: "edge-rtl-content", configurations: SnapshotConfiguration.allAccessibilitySizes)
    }

    // MARK: - Mixed Inputs

    func testMixedInputsCard_allDevices() {
        assertCardSnapshots(named: "edge-mixed-inputs", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testMixedInputsCard_darkMode() {
        assertCardSnapshot(named: "edge-mixed-inputs", configuration: .iPhone15ProDark)
    }

    func testMixedInputsCard_accessibility() {
        assertCardSnapshots(named: "edge-mixed-inputs", configurations: SnapshotConfiguration.allAccessibilitySizes)
    }

    // MARK: - Stress Tests

    /// Tests rendering ALL cards at once to verify no resource exhaustion
    func testAllCardsParseSuccessfully() {
        assertAllCardsParse()
    }

    /// Renders each card at a single configuration to ensure no crashes
    func testAllCardsRenderWithoutCrash() {
        let cardNames = Self.allTestCardNames

        for cardName in cardNames {
            do {
                let json = try loadTestCard(named: cardName)
                let view = AdaptiveCardView(cardJson: json)
                let image = renderView(view, configuration: .iPhone15Pro)
                XCTAssertNotNil(image, "Card '\(cardName)' failed to render")
            } catch {
                XCTFail("Card '\(cardName)' failed: \(error.localizedDescription)")
            }
        }
    }
}
#endif // canImport(UIKit)
