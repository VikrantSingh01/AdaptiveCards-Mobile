#if canImport(UIKit)
import XCTest
import SwiftUI
@testable import ACCore
@testable import ACRendering

/// Comprehensive snapshot test that exercises every test card across
/// all major configurations. This is the "full matrix" test suite.
///
/// Use this for complete regression validation (e.g., before releases).
/// For faster CI iterations, use the individual test files instead.
final class ComprehensiveSnapshotTests: CardSnapshotTestCase {

    private let reporter = SnapshotTestReporter()

    // MARK: - Full Matrix Test

    /// Runs every card through the core configuration set (light, dark, iPad, accessibility).
    /// This is the primary CI gate for visual regressions.
    func testAllCards_coreConfigurations() {
        let cardNames = Self.allTestCardNames
        let configurations = SnapshotConfiguration.core

        for cardName in cardNames {
            let startTime = CFAbsoluteTimeGetCurrent()
            let results = assertCardSnapshots(
                named: cardName,
                configurations: configurations
            )
            let duration = CFAbsoluteTimeGetCurrent() - startTime

            for (index, result) in results.enumerated() {
                reporter.record(
                    cardName: cardName,
                    configuration: configurations[index].name,
                    result: result,
                    duration: duration / Double(configurations.count)
                )
            }
        }

        reporter.printSummary()
    }

    /// Full comprehensive run across ALL configurations.
    /// This takes longer but covers every device/appearance/accessibility combination.
    func testAllCards_comprehensiveConfigurations() {
        let cardNames = Self.allTestCardNames
        let configurations = SnapshotConfiguration.comprehensive

        for cardName in cardNames {
            let startTime = CFAbsoluteTimeGetCurrent()
            let results = assertCardSnapshots(
                named: cardName,
                configurations: configurations
            )
            let duration = CFAbsoluteTimeGetCurrent() - startTime

            for (index, result) in results.enumerated() {
                reporter.record(
                    cardName: cardName,
                    configuration: configurations[index].name,
                    result: result,
                    duration: duration / Double(configurations.count)
                )
            }
        }

        // Generate reports
        let reportsDir = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Snapshots/Reports")
            .path

        reporter.generateJSONReport(to: "\(reportsDir)/visual-regression-report.json")
        reporter.generateHTMLReport(to: "\(reportsDir)/visual-regression-report.html")
        reporter.printSummary()
    }

    // MARK: - Category-Specific Full Tests

    /// Tests all cards that contain input elements across device sizes
    func testInputCards_allDevices() {
        let inputCards = [
            "all-inputs", "input-form", "edge-mixed-inputs"
        ]

        for cardName in inputCards {
            assertCardSnapshots(
                named: cardName,
                configurations: SnapshotConfiguration.allDeviceSizes + [.iPhone15ProDark]
            )
        }
    }

    /// Tests all cards with complex layouts across device sizes
    func testLayoutCards_allDevices() {
        let layoutCards = [
            "containers", "table", "datagrid", "responsive-layout",
            "carousel", "accordion", "tab-set", "list"
        ]

        for cardName in layoutCards {
            assertCardSnapshots(
                named: cardName,
                configurations: SnapshotConfiguration.allDeviceSizes + SnapshotConfiguration.allOrientations
            )
        }
    }

    /// Tests all edge case cards in all configurations
    func testEdgeCaseCards_allConfigurations() {
        let edgeCaseCards = Self.allTestCardNames.filter { $0.hasPrefix("edge-") }

        for cardName in edgeCaseCards {
            assertCardSnapshots(
                named: cardName,
                configurations: SnapshotConfiguration.core
            )
        }
    }

    /// Tests all templating cards in core configurations
    func testTemplatingCards_coreConfigurations() {
        let templatingCards = Self.allTestCardNames.filter { $0.hasPrefix("templating-") }

        for cardName in templatingCards {
            assertCardSnapshots(
                named: cardName,
                configurations: SnapshotConfiguration.core
            )
        }
    }
}
#endif // canImport(UIKit)
