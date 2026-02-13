#if canImport(UIKit)
import XCTest
import SwiftUI
@testable import ACCore
@testable import ACRendering

/// Visual regression tests focused on device size and orientation variations.
///
/// Validates that cards render correctly and maintain proper layouts across:
/// - iPhone SE (smallest supported iPhone)
/// - iPhone 15 Pro (current flagship)
/// - iPad (tablet form factor with regular size class)
/// - Portrait and landscape orientations
///
/// These tests are critical for ensuring responsive design works correctly
/// across the full range of iOS devices.
final class DeviceSizeVisualTests: CardSnapshotTestCase {

    // MARK: - Portrait: All Devices

    func testSimpleText_allPortraitDevices() {
        assertCardSnapshots(named: "simple-text", configurations: [
            .iPhoneSE, .iPhone15Pro, .iPadPortrait
        ])
    }

    func testContainers_allPortraitDevices() {
        assertCardSnapshots(named: "containers", configurations: [
            .iPhoneSE, .iPhone15Pro, .iPadPortrait
        ])
    }

    func testAllInputs_allPortraitDevices() {
        assertCardSnapshots(named: "all-inputs", configurations: [
            .iPhoneSE, .iPhone15Pro, .iPadPortrait
        ])
    }

    func testTable_allPortraitDevices() {
        assertCardSnapshots(named: "table", configurations: [
            .iPhoneSE, .iPhone15Pro, .iPadPortrait
        ])
    }

    func testCarousel_allPortraitDevices() {
        assertCardSnapshots(named: "carousel", configurations: [
            .iPhoneSE, .iPhone15Pro, .iPadPortrait
        ])
    }

    func testAccordion_allPortraitDevices() {
        assertCardSnapshots(named: "accordion", configurations: [
            .iPhoneSE, .iPhone15Pro, .iPadPortrait
        ])
    }

    func testTabSet_allPortraitDevices() {
        assertCardSnapshots(named: "tab-set", configurations: [
            .iPhoneSE, .iPhone15Pro, .iPadPortrait
        ])
    }

    func testCompoundButtons_allPortraitDevices() {
        assertCardSnapshots(named: "compound-buttons", configurations: [
            .iPhoneSE, .iPhone15Pro, .iPadPortrait
        ])
    }

    func testDatagrid_allPortraitDevices() {
        assertCardSnapshots(named: "datagrid", configurations: [
            .iPhoneSE, .iPhone15Pro, .iPadPortrait
        ])
    }

    // MARK: - Landscape: Key Cards

    func testSimpleText_landscape() {
        assertCardSnapshots(named: "simple-text", configurations: [
            .iPhoneSELandscape, .iPhone15ProLandscape, .iPadLandscape
        ])
    }

    func testContainers_landscape() {
        assertCardSnapshots(named: "containers", configurations: [
            .iPhoneSELandscape, .iPhone15ProLandscape, .iPadLandscape
        ])
    }

    func testTable_landscape() {
        assertCardSnapshots(named: "table", configurations: [
            .iPhoneSELandscape, .iPhone15ProLandscape, .iPadLandscape
        ])
    }

    func testResponsiveLayout_landscape() {
        assertCardSnapshots(named: "responsive-layout", configurations: [
            .iPhoneSELandscape, .iPhone15ProLandscape, .iPadLandscape
        ])
    }

    func testAllActions_landscape() {
        assertCardSnapshots(named: "all-actions", configurations: [
            .iPhoneSELandscape, .iPhone15ProLandscape, .iPadLandscape
        ])
    }

    func testDatagrid_landscape() {
        assertCardSnapshots(named: "datagrid", configurations: [
            .iPhoneSELandscape, .iPhone15ProLandscape, .iPadLandscape
        ])
    }

    // MARK: - iPhone SE Smallest Size Tests

    /// iPhone SE has the smallest screen; verify nothing overflows
    func testAllCards_iPhoneSE() {
        let criticalCards = [
            "simple-text", "containers", "all-inputs", "all-actions",
            "table", "accordion", "carousel", "tab-set", "list",
            "compound-buttons", "code-block", "markdown", "rich-text",
            "rating", "progress-indicators", "datagrid"
        ]

        for cardName in criticalCards {
            assertCardSnapshot(named: cardName, configuration: .iPhoneSE)
        }
    }

    // MARK: - iPad Split View Simulation

    /// Simulates iPad split view by using a narrower width
    func testTable_iPadSplitView() {
        let splitViewConfig = SnapshotConfiguration(
            name: "iPad_SplitView",
            size: CGSize(width: 400, height: 1080),
            horizontalSizeClass: .compact,
            verticalSizeClass: .regular
        )
        assertCardSnapshot(named: "table", configuration: splitViewConfig)
    }

    func testContainers_iPadSplitView() {
        let splitViewConfig = SnapshotConfiguration(
            name: "iPad_SplitView",
            size: CGSize(width: 400, height: 1080),
            horizontalSizeClass: .compact,
            verticalSizeClass: .regular
        )
        assertCardSnapshot(named: "containers", configuration: splitViewConfig)
    }

    func testAllInputs_iPadSplitView() {
        let splitViewConfig = SnapshotConfiguration(
            name: "iPad_SplitView",
            size: CGSize(width: 400, height: 1080),
            horizontalSizeClass: .compact,
            verticalSizeClass: .regular
        )
        assertCardSnapshot(named: "all-inputs", configuration: splitViewConfig)
    }

    // MARK: - Orientation Transition Consistency

    /// Verifies that the same card rendered at the same total area but
    /// different aspect ratios produces consistent layouts
    func testResponsiveLayout_orientationConsistency() {
        // Portrait: 393x852 = 334,836 sq pts
        // Landscape: 852x393 = 334,836 sq pts (same area)
        assertCardSnapshots(named: "responsive-layout", configurations: [
            .iPhone15Pro, .iPhone15ProLandscape
        ])
    }
}
#endif // canImport(UIKit)
