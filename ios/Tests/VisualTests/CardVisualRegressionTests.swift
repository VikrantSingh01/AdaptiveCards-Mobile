#if canImport(UIKit)
import XCTest
import SwiftUI
@testable import ACCore
@testable import ACRendering

/// Comprehensive visual regression tests for all shared test cards.
///
/// These tests load each card from shared/test-cards/, render it as an AdaptiveCardView,
/// and compare the snapshot against a stored baseline. Tests run across multiple
/// device configurations to catch rendering regressions.
///
/// To record new baselines: run with environment variable RECORD_SNAPSHOTS=1
/// To run comparisons: run normally (default behavior)
final class CardVisualRegressionTests: CardSnapshotTestCase {

    // MARK: - Simple Elements

    func testSimpleTextCard_allDevices() {
        assertCardSnapshots(named: "simple-text", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testSimpleTextCard_darkMode() {
        assertCardSnapshot(named: "simple-text", configuration: .iPhone15ProDark)
    }

    func testSimpleTextCard_accessibility() {
        assertCardSnapshots(named: "simple-text", configurations: SnapshotConfiguration.allAccessibilitySizes)
    }

    func testSimpleTextCard_landscape() {
        assertCardSnapshots(named: "simple-text", configurations: SnapshotConfiguration.allOrientations)
    }

    // MARK: - Container Elements

    func testContainersCard_allDevices() {
        assertCardSnapshots(named: "containers", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testContainersCard_darkMode() {
        assertCardSnapshot(named: "containers", configuration: .iPhone15ProDark)
    }

    func testContainersCard_accessibility() {
        assertCardSnapshots(named: "containers", configurations: SnapshotConfiguration.allAccessibilitySizes)
    }

    // MARK: - Input Elements

    func testAllInputsCard_allDevices() {
        assertCardSnapshots(named: "all-inputs", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testAllInputsCard_darkMode() {
        assertCardSnapshot(named: "all-inputs", configuration: .iPhone15ProDark)
    }

    func testAllInputsCard_accessibility() {
        assertCardSnapshots(named: "all-inputs", configurations: SnapshotConfiguration.allAccessibilitySizes)
    }

    func testInputFormCard_allDevices() {
        assertCardSnapshots(named: "input-form", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testInputFormCard_darkMode() {
        assertCardSnapshot(named: "input-form", configuration: .iPhone15ProDark)
    }

    // MARK: - Action Elements

    func testAllActionsCard_allDevices() {
        assertCardSnapshots(named: "all-actions", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testAllActionsCard_darkMode() {
        assertCardSnapshot(named: "all-actions", configuration: .iPhone15ProDark)
    }

    func testSplitButtonsCard_allDevices() {
        assertCardSnapshots(named: "split-buttons", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testPopoverActionCard() {
        assertCardSnapshots(named: "popover-action", configurations: SnapshotConfiguration.core)
    }

    // MARK: - Table and Data

    func testTableCard_allDevices() {
        assertCardSnapshots(named: "table", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testTableCard_darkMode() {
        assertCardSnapshot(named: "table", configuration: .iPhone15ProDark)
    }

    func testTableCard_landscape() {
        assertCardSnapshots(named: "table", configurations: SnapshotConfiguration.allOrientations)
    }

    func testDatagridCard_allDevices() {
        assertCardSnapshots(named: "datagrid", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    // MARK: - Rich Content

    func testMarkdownCard_allDevices() {
        assertCardSnapshots(named: "markdown", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testMarkdownCard_darkMode() {
        assertCardSnapshot(named: "markdown", configuration: .iPhone15ProDark)
    }

    func testRichTextCard_allDevices() {
        assertCardSnapshots(named: "rich-text", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testRichTextCard_accessibility() {
        assertCardSnapshots(named: "rich-text", configurations: SnapshotConfiguration.allAccessibilitySizes)
    }

    func testCodeBlockCard_allDevices() {
        assertCardSnapshots(named: "code-block", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testCodeBlockCard_darkMode() {
        assertCardSnapshot(named: "code-block", configuration: .iPhone15ProDark)
    }

    // MARK: - Advanced Elements

    func testCarouselCard_allDevices() {
        assertCardSnapshots(named: "carousel", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testCarouselCard_darkMode() {
        assertCardSnapshot(named: "carousel", configuration: .iPhone15ProDark)
    }

    func testAccordionCard_allDevices() {
        assertCardSnapshots(named: "accordion", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testAccordionCard_darkMode() {
        assertCardSnapshot(named: "accordion", configuration: .iPhone15ProDark)
    }

    func testTabSetCard_allDevices() {
        assertCardSnapshots(named: "tab-set", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testTabSetCard_darkMode() {
        assertCardSnapshot(named: "tab-set", configuration: .iPhone15ProDark)
    }

    func testListCard_allDevices() {
        assertCardSnapshots(named: "list", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testListCard_darkMode() {
        assertCardSnapshot(named: "list", configuration: .iPhone15ProDark)
    }

    // MARK: - Indicators and Ratings

    func testRatingCard_allDevices() {
        assertCardSnapshots(named: "rating", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testRatingCard_darkMode() {
        assertCardSnapshot(named: "rating", configuration: .iPhone15ProDark)
    }

    func testProgressIndicatorsCard_allDevices() {
        assertCardSnapshots(named: "progress-indicators", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testProgressIndicatorsCard_darkMode() {
        assertCardSnapshot(named: "progress-indicators", configuration: .iPhone15ProDark)
    }

    // MARK: - Compound and Interactive Elements

    func testCompoundButtonsCard_allDevices() {
        assertCardSnapshots(named: "compound-buttons", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testCompoundButtonsCard_darkMode() {
        assertCardSnapshot(named: "compound-buttons", configuration: .iPhone15ProDark)
    }

    // MARK: - Media

    func testMediaCard_allDevices() {
        assertCardSnapshots(named: "media", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testMediaCard_darkMode() {
        assertCardSnapshot(named: "media", configuration: .iPhone15ProDark)
    }

    // MARK: - Charts

    func testChartsCard_allDevices() {
        assertCardSnapshots(named: "charts", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testChartsCard_darkMode() {
        assertCardSnapshot(named: "charts", configuration: .iPhone15ProDark)
    }

    // MARK: - Theming

    func testFluentThemingCard_allDevices() {
        assertCardSnapshots(named: "fluent-theming", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testFluentThemingCard_darkMode() {
        assertCardSnapshot(named: "fluent-theming", configuration: .iPhone15ProDark)
    }

    func testThemedImagesCard_lightAndDark() {
        assertCardSnapshots(named: "themed-images", configurations: SnapshotConfiguration.allAppearances)
    }

    // MARK: - Layout

    func testResponsiveLayoutCard_allDevices() {
        assertCardSnapshots(named: "responsive-layout", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testResponsiveLayoutCard_landscape() {
        assertCardSnapshots(named: "responsive-layout", configurations: SnapshotConfiguration.allOrientations)
    }

    func testResponsiveLayoutCard_iPadLandscape() {
        assertCardSnapshot(named: "responsive-layout", configuration: .iPadLandscape)
    }

    // MARK: - Templating

    func testTemplatingBasicCard() {
        assertCardSnapshots(named: "templating-basic", configurations: SnapshotConfiguration.core)
    }

    func testTemplatingConditionalCard() {
        assertCardSnapshots(named: "templating-conditional", configurations: SnapshotConfiguration.core)
    }

    func testTemplatingIterationCard() {
        assertCardSnapshots(named: "templating-iteration", configurations: SnapshotConfiguration.core)
    }

    func testTemplatingExpressionsCard() {
        assertCardSnapshots(named: "templating-expressions", configurations: SnapshotConfiguration.core)
    }

    func testTemplatingNestedCard() {
        assertCardSnapshots(named: "templating-nested", configurations: SnapshotConfiguration.core)
    }

    // MARK: - Teams and Copilot Integration

    func testTeamsConnectorCard_allDevices() {
        assertCardSnapshots(named: "teams-connector", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testTeamsTaskModuleCard_allDevices() {
        assertCardSnapshots(named: "teams-task-module", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testCopilotCitationsCard_allDevices() {
        assertCardSnapshots(named: "copilot-citations", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    func testCopilotCitationsCard_darkMode() {
        assertCardSnapshot(named: "copilot-citations", configuration: .iPhone15ProDark)
    }

    // MARK: - Streaming

    func testStreamingCard_allDevices() {
        assertCardSnapshots(named: "streaming-card", configurations: SnapshotConfiguration.allDeviceSizes)
    }

    // MARK: - Advanced Combined

    func testAdvancedCombinedCard_comprehensive() {
        assertCardSnapshots(named: "advanced-combined", configurations: SnapshotConfiguration.comprehensive)
    }
}
#endif // canImport(UIKit)
