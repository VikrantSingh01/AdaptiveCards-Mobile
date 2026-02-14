#if canImport(UIKit)
import XCTest
import SwiftUI
@testable import ACCore
@testable import ACRendering
@testable import ACTemplating

/// Performance tests for Adaptive Card parsing and rendering.
///
/// Measures:
/// - Parse time: How long it takes to decode JSON into AdaptiveCard models
/// - Render time: How long it takes to create a SwiftUI view hierarchy and render to image
/// - Memory usage: Peak memory delta during card processing
///
/// Performance thresholds are configurable via PerformanceThresholds.
/// Cards that exceed thresholds are flagged as failures.
final class CardPerformanceTests: CardSnapshotTestCase {

    private let performanceRunner = CardPerformanceRunner(thresholds: .default)
    private let reportGenerator = PerformanceReportGenerator()

    // MARK: - Individual Card Performance

    func testPerformance_simpleText() throws {
        let json = try loadTestCard(named: "simple-text")
        let metrics = performanceRunner.measure(cardName: "simple-text", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
        XCTAssertLessThan(metrics.parseTime, 0.05, "Simple card should parse in under 50ms")
    }

    func testPerformance_containers() throws {
        let json = try loadTestCard(named: "containers")
        let metrics = performanceRunner.measure(cardName: "containers", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    func testPerformance_allInputs() throws {
        let json = try loadTestCard(named: "all-inputs")
        let metrics = performanceRunner.measure(cardName: "all-inputs", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    func testPerformance_allActions() throws {
        let json = try loadTestCard(named: "all-actions")
        let metrics = performanceRunner.measure(cardName: "all-actions", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    func testPerformance_table() throws {
        let json = try loadTestCard(named: "table")
        let metrics = performanceRunner.measure(cardName: "table", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    func testPerformance_carousel() throws {
        let json = try loadTestCard(named: "carousel")
        let metrics = performanceRunner.measure(cardName: "carousel", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    func testPerformance_accordion() throws {
        let json = try loadTestCard(named: "accordion")
        let metrics = performanceRunner.measure(cardName: "accordion", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    func testPerformance_tabSet() throws {
        let json = try loadTestCard(named: "tab-set")
        let metrics = performanceRunner.measure(cardName: "tab-set", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    func testPerformance_codeBlock() throws {
        let json = try loadTestCard(named: "code-block")
        let metrics = performanceRunner.measure(cardName: "code-block", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    func testPerformance_markdown() throws {
        let json = try loadTestCard(named: "markdown")
        let metrics = performanceRunner.measure(cardName: "markdown", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    func testPerformance_richText() throws {
        let json = try loadTestCard(named: "rich-text")
        let metrics = performanceRunner.measure(cardName: "rich-text", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    func testPerformance_rating() throws {
        let json = try loadTestCard(named: "rating")
        let metrics = performanceRunner.measure(cardName: "rating", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    func testPerformance_progressIndicators() throws {
        let json = try loadTestCard(named: "progress-indicators")
        let metrics = performanceRunner.measure(cardName: "progress-indicators", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    func testPerformance_compoundButtons() throws {
        let json = try loadTestCard(named: "compound-buttons")
        let metrics = performanceRunner.measure(cardName: "compound-buttons", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    func testPerformance_datagrid() throws {
        let json = try loadTestCard(named: "datagrid")
        let metrics = performanceRunner.measure(cardName: "datagrid", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    func testPerformance_list() throws {
        let json = try loadTestCard(named: "list")
        let metrics = performanceRunner.measure(cardName: "list", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    func testPerformance_charts() throws {
        let json = try loadTestCard(named: "charts")
        let metrics = performanceRunner.measure(cardName: "charts", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    func testPerformance_fluentTheming() throws {
        let json = try loadTestCard(named: "fluent-theming")
        let metrics = performanceRunner.measure(cardName: "fluent-theming", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    func testPerformance_responsiveLayout() throws {
        let json = try loadTestCard(named: "responsive-layout")
        let metrics = performanceRunner.measure(cardName: "responsive-layout", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    // MARK: - Edge Case Performance

    func testPerformance_deeplyNested() throws {
        let runner = CardPerformanceRunner(thresholds: .complex)
        let json = try loadTestCard(named: "edge-deeply-nested")
        let metrics = runner.measure(cardName: "edge-deeply-nested", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    func testPerformance_longText() throws {
        let runner = CardPerformanceRunner(thresholds: .complex)
        let json = try loadTestCard(named: "edge-long-text")
        let metrics = runner.measure(cardName: "edge-long-text", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    func testPerformance_maxActions() throws {
        let runner = CardPerformanceRunner(thresholds: .complex)
        let json = try loadTestCard(named: "edge-max-actions")
        let metrics = runner.measure(cardName: "edge-max-actions", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    func testPerformance_mixedInputs() throws {
        let json = try loadTestCard(named: "edge-mixed-inputs")
        let metrics = performanceRunner.measure(cardName: "edge-mixed-inputs", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    // MARK: - Advanced Combined Performance

    func testPerformance_advancedCombined() throws {
        let runner = CardPerformanceRunner(thresholds: .complex)
        let json = try loadTestCard(named: "advanced-combined")
        let metrics = runner.measure(cardName: "advanced-combined", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    // MARK: - Teams and Copilot

    func testPerformance_teamsConnector() throws {
        let json = try loadTestCard(named: "teams-connector")
        let metrics = performanceRunner.measure(cardName: "teams-connector", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    func testPerformance_teamsTaskModule() throws {
        let json = try loadTestCard(named: "teams-task-module")
        let metrics = performanceRunner.measure(cardName: "teams-task-module", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    func testPerformance_copilotCitations() throws {
        let json = try loadTestCard(named: "copilot-citations")
        let metrics = performanceRunner.measure(cardName: "copilot-citations", json: json)
        reportGenerator.add(metrics)

        XCTAssertTrue(metrics.passed, metrics.failureReason ?? "")
    }

    // MARK: - Comprehensive Performance Run

    /// Measures performance for ALL test cards and generates a full report.
    /// This is the primary performance gate for CI.
    func testPerformance_allCards() throws {
        let cardNames = Self.allTestCardNames
        var allMetrics: [CardPerformanceMetrics] = []
        var failures: [String] = []

        for cardName in cardNames {
            do {
                let json = try loadTestCard(named: cardName)

                // Use relaxed thresholds for known complex cards
                let isComplex = cardName.hasPrefix("edge-") ||
                    cardName == "advanced-combined" ||
                    cardName == "datagrid"
                let runner = CardPerformanceRunner(
                    thresholds: isComplex ? .complex : .default
                )

                let metrics = runner.measure(cardName: cardName, json: json)
                allMetrics.append(metrics)

                if !metrics.passed {
                    failures.append(metrics.summary)
                }
            } catch {
                failures.append("\(cardName): Failed to load - \(error.localizedDescription)")
            }
        }

        reportGenerator.addAll(allMetrics)
        reportGenerator.printReport()

        // Generate performance report file
        let reportsDir = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Snapshots/Reports")
            .path
        reportGenerator.generateJSONReport(to: "\(reportsDir)/performance-report.json")

        if !failures.isEmpty {
            XCTFail("Performance regressions detected in \(failures.count) cards:\n\(failures.joined(separator: "\n"))")
        }
    }

    // MARK: - XCTest Measure Blocks (for Xcode performance tracking)

    func testMeasureParseTime_simpleText() throws {
        let json = try loadTestCard(named: "simple-text")

        measure {
            for _ in 0..<100 {
                _ = try? parser.parse(json)
            }
        }
    }

    func testMeasureParseTime_advancedCombined() throws {
        let json = try loadTestCard(named: "advanced-combined")

        measure {
            for _ in 0..<50 {
                _ = try? parser.parse(json)
            }
        }
    }

    func testMeasureParseTime_allCards() throws {
        let cardNames = Self.allTestCardNames
        var allJson: [String] = []

        for cardName in cardNames {
            if let json = try? loadTestCard(named: cardName) {
                allJson.append(json)
            }
        }

        measure {
            for json in allJson {
                _ = try? parser.parse(json)
            }
        }
    }

    func testMeasureRenderTime_simpleText() throws {
        let json = try loadTestCard(named: "simple-text")

        measure {
            let view = AdaptiveCardView(cardJson: json)
            let _ = renderView(view, configuration: .iPhone15Pro)
        }
    }

    func testMeasureRenderTime_advancedCombined() throws {
        let json = try loadTestCard(named: "advanced-combined")

        measure {
            let view = AdaptiveCardView(cardJson: json)
            let _ = renderView(view, configuration: .iPhone15Pro)
        }
    }

    // MARK: - Optimization-Specific Benchmarks

    /// Tests CardElement.id generation performance.
    /// After P0 fix: id should be deterministic hash-based, not UUID-based.
    /// This benchmark ensures id generation is fast and stable.
    func testPerformance_cardElementIdStability() throws {
        let textBlock = TextBlock(text: "Test")
        let element = CardElement.textBlock(textBlock)

        measure {
            for _ in 0..<10000 {
                _ = element.id
            }
        }
    }

    /// Tests that CardElement.id produces stable results.
    /// Before fix: UUID() generated new ID on every access
    /// After fix: Hash-based ID is stable
    func testCardElementIdDeterminism() throws {
        let textBlock = TextBlock(text: "Benchmark Test")
        let element = CardElement.textBlock(textBlock)

        let ids = (0..<1000).map { _ in element.id }
        let uniqueIds = Set(ids)

        XCTAssertEqual(uniqueIds.count, 1, "CardElement.id must be deterministic - all 1000 accesses should return the same value")
    }

    /// Tests CardElement.id uniqueness across different elements
    func testCardElementIdUniqueness() throws {
        var ids = Set<String>()

        // Create 1000 different text blocks
        for i in 0..<1000 {
            let textBlock = TextBlock(text: "Text \(i)")
            let element = CardElement.textBlock(textBlock)
            ids.insert(element.id)
        }

        XCTAssertEqual(ids.count, 1000, "Different elements should produce different IDs")
    }

    /// Tests expression evaluation performance with singleton function registry.
    /// After optimization: Functions are registered once at app launch, not per evaluator.
    func testPerformance_expressionEvaluationWithSingleton() throws {
        let parser = ExpressionParser()
        measure {
            for _ in 0..<1000 {
                let context = DataContext(data: ["name": "John", "age": 30])
                let evaluator = ExpressionEvaluator(context: context)
                if let expr = try? parser.parse("concat('Hello, ', name, '! You are ', string(age), ' years old.')") {
                    _ = try? evaluator.evaluate(expr)
                }
            }
        }
    }

    /// Tests thread safety doesn't significantly impact performance
    func testPerformance_concurrentParsing() throws {
        let json = try loadTestCard(named: "simple-text")

        measure {
            DispatchQueue.concurrentPerform(iterations: 100) { _ in
                _ = try? parser.parse(json)
            }
        }
    }

    /// Tests thread safety of element renderer registry
    func testPerformance_concurrentRendererRegistration() throws {
        let registry = ElementRendererRegistry.shared

        measure {
            DispatchQueue.concurrentPerform(iterations: 100) { i in
                registry.register("TestType\(i)") { element in
                    Text("Test")
                }
            }
        }
    }
}
#endif // canImport(UIKit)
