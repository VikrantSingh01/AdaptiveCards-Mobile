#if canImport(UIKit)
import XCTest
import SwiftUI
@testable import ACCore
@testable import ACRendering

/// Automatically discovers and renders **every** card JSON in the shared/test-cards/
/// directory tree (including subdirectories like official-samples/, element-samples/,
/// teams-samples/, teams-official-samples/).
///
/// This is the "render every card in an isolated table view" pipeline equivalent.
/// Each card is rendered via AdaptiveCardView and snapshot-compared against baselines.
///
/// ## Usage
///
/// Record all baselines:
/// ```
/// RECORD_SNAPSHOTS=1 swift test --filter AllCardsDiscoveryTests
/// ```
///
/// Verify against baselines:
/// ```
/// swift test --filter AllCardsDiscoveryTests
/// ```
///
/// Run only the quick smoke test (one config per card):
/// ```
/// swift test --filter AllCardsDiscoveryTests/testAllCards_smokeTest
/// ```
final class AllCardsDiscoveryTests: CardSnapshotTestCase {

    // MARK: - Card Discovery

    /// Recursively discovers all .json card files under shared/test-cards/
    static var allDiscoveredCards: [(name: String, relativePath: String)] {
        let baseDir = testCardsDirectory
        let fileManager = FileManager.default

        guard let enumerator = fileManager.enumerator(
            at: URL(fileURLWithPath: baseDir),
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var cards: [(name: String, relativePath: String)] = []

        while let url = enumerator.nextObject() as? URL {
            guard url.pathExtension == "json" else { continue }

            // Get the relative path from test-cards/ root
            let fullPath = url.path
            let relativePath = String(fullPath.dropFirst(baseDir.count + 1)) // +1 for "/"
            let name = relativePath
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: ".json", with: "")

            cards.append((name: name, relativePath: relativePath))
        }

        return cards.sorted { $0.name < $1.name }
    }

    /// Loads a card JSON from a relative path under test-cards/
    func loadCard(relativePath: String) throws -> String {
        let fullPath = "\(Self.testCardsDirectory)/\(relativePath)"
        let url = URL(fileURLWithPath: fullPath)
        let data = try Data(contentsOf: url)
        guard let json = String(data: data, encoding: .utf8) else {
            throw CardTestError.invalidEncoding(name: relativePath)
        }
        return json
    }

    // MARK: - Smoke Test (1 config per card — fast)

    /// Renders every discovered card at iPhone 15 Pro size.
    /// This is the fastest "does every card render without crashing?" gate.
    func testAllCards_smokeTest() {
        let cards = Self.allDiscoveredCards
        XCTAssertGreaterThan(cards.count, 0, "No test cards discovered — check shared/test-cards/ path")

        var failures: [String] = []
        var successCount = 0

        for card in cards {
            do {
                let json = try loadCard(relativePath: card.relativePath)
                let view = createCardView(json: json)
                let result = assertSnapshot(
                    of: view,
                    named: card.name,
                    configuration: .iPhone15Pro
                )
                if result.passed || recordMode {
                    successCount += 1
                } else {
                    failures.append("\(card.name): \(result.message)")
                }
            } catch {
                failures.append("\(card.name): Load error — \(error.localizedDescription)")
            }
        }

        print("""

        ═══════════════════════════════════════════════════════════
        ALL CARDS SMOKE TEST RESULTS
        ═══════════════════════════════════════════════════════════
        Total Cards: \(cards.count)
        Passed:      \(successCount)
        Failed:      \(failures.count)
        Mode:        \(recordMode ? "RECORDING BASELINES" : "COMPARING")
        ═══════════════════════════════════════════════════════════
        """)

        if !failures.isEmpty && !recordMode {
            print("FAILURES:")
            for f in failures { print("  ✗ \(f)") }
        }
    }

    // MARK: - Core Matrix (4 configs per card — CI gate)

    /// Renders every discovered card across the core config set:
    /// iPhone 15 Pro (light), iPhone 15 Pro (dark), iPad, Accessibility XXXL.
    func testAllCards_coreMatrix() {
        let cards = Self.allDiscoveredCards
        let configs = SnapshotConfiguration.core
        let reporter = SnapshotTestReporter()

        XCTAssertGreaterThan(cards.count, 0, "No test cards discovered")

        for card in cards {
            do {
                let json = try loadCard(relativePath: card.relativePath)
                let view = createCardView(json: json)

                let startTime = CFAbsoluteTimeGetCurrent()
                let results = assertSnapshots(
                    of: view,
                    named: card.name,
                    configurations: configs
                )
                let duration = CFAbsoluteTimeGetCurrent() - startTime

                for (i, result) in results.enumerated() {
                    reporter.record(
                        cardName: card.name,
                        configuration: configs[i].name,
                        result: result,
                        duration: duration / Double(configs.count)
                    )
                }
            } catch {
                // Record load failure
                reporter.record(
                    cardName: card.name,
                    configuration: "load",
                    result: SnapshotDiffResult(
                        passed: false,
                        diffPercentage: 1.0,
                        baselinePath: nil,
                        actualPath: nil,
                        diffPath: nil,
                        message: "Load error: \(error.localizedDescription)"
                    ),
                    duration: 0
                )
            }
        }

        // Generate reports
        let reportsDir = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Snapshots/Reports")
            .path

        reporter.generateJSONReport(to: "\(reportsDir)/all-cards-core-report.json")
        reporter.generateHTMLReport(to: "\(reportsDir)/all-cards-core-report.html")
        reporter.printSummary()
    }

    // MARK: - Parse-Only Validation (no rendering — ultra fast)

    /// Validates that every discovered card parses without errors.
    /// This is the fastest possible gate — no rendering, just JSON → model.
    func testAllCards_parseOnly() {
        let cards = Self.allDiscoveredCards
        XCTAssertGreaterThan(cards.count, 0, "No test cards discovered")

        var parseFailures: [String] = []

        for card in cards {
            do {
                let json = try loadCard(relativePath: card.relativePath)
                let _ = try parser.parse(json)
            } catch {
                parseFailures.append("\(card.relativePath): \(error.localizedDescription)")
            }
        }

        print("""

        ═══════════════════════════════════════════════════════════
        ALL CARDS PARSE VALIDATION
        ═══════════════════════════════════════════════════════════
        Total Cards:   \(cards.count)
        Parse Success: \(cards.count - parseFailures.count)
        Parse Failed:  \(parseFailures.count)
        ═══════════════════════════════════════════════════════════
        """)

        if !parseFailures.isEmpty {
            let failList = parseFailures.joined(separator: "\n  ✗ ")
            XCTFail("Failed to parse \(parseFailures.count) cards:\n  ✗ \(failList)")
        }
    }

    // MARK: - Subdirectory-Specific Tests

    /// Tests all official Adaptive Cards samples
    func testOfficialSamples_coreMatrix() {
        runSubdirectoryTests(subdirectory: "official-samples", configurations: SnapshotConfiguration.core)
    }

    /// Tests all element-level samples
    func testElementSamples_smokeTest() {
        runSubdirectoryTests(subdirectory: "element-samples", configurations: [.iPhone15Pro])
    }

    /// Tests all Teams-formatted samples
    func testTeamsSamples_coreMatrix() {
        runSubdirectoryTests(subdirectory: "teams-samples", configurations: SnapshotConfiguration.core)
    }

    /// Tests all Teams official samples
    func testTeamsOfficialSamples_coreMatrix() {
        runSubdirectoryTests(subdirectory: "teams-official-samples", configurations: SnapshotConfiguration.core)
    }

    // MARK: - Helpers

    private func runSubdirectoryTests(
        subdirectory: String,
        configurations: [SnapshotConfiguration]
    ) {
        let subDir = "\(Self.testCardsDirectory)/\(subdirectory)"
        let fileManager = FileManager.default

        guard let files = try? fileManager.contentsOfDirectory(atPath: subDir) else {
            // Subdirectory doesn't exist — skip gracefully
            print("⚠️  Subdirectory \(subdirectory) not found, skipping")
            return
        }

        let jsonFiles = files
            .filter { $0.hasSuffix(".json") }
            .sorted()

        guard !jsonFiles.isEmpty else {
            print("⚠️  No JSON files in \(subdirectory)")
            return
        }

        var failures: [String] = []

        for file in jsonFiles {
            let relativePath = "\(subdirectory)/\(file)"
            let name = "\(subdirectory)_\(file.replacingOccurrences(of: ".json", with: ""))"

            do {
                let json = try loadCard(relativePath: relativePath)
                let view = createCardView(json: json)
                let results = assertSnapshots(
                    of: view,
                    named: name,
                    configurations: configurations
                )
                let failedResults = results.filter { !$0.passed }
                if !failedResults.isEmpty && !recordMode {
                    failures.append(contentsOf: failedResults.map { "\(name): \($0.message)" })
                }
            } catch {
                failures.append("\(name): \(error.localizedDescription)")
            }
        }

        print("  \(subdirectory): \(jsonFiles.count) cards, \(failures.count) failures")
    }
}
#endif // canImport(UIKit)
