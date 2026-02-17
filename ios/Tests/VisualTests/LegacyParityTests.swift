#if canImport(UIKit)
import XCTest
import SwiftUI
@testable import ACCore
@testable import ACRendering
@testable import ACInputs

// MARK: - Legacy Parity Tests

/// Compares greenfield SwiftUI-rendered Adaptive Cards against golden-path
/// PNG baselines exported from the legacy ObjC/C++ renderer.
///
/// Workflow:
///   1. Legacy repo generates PNGs via ACRParityBaselineTests → shared/golden-baselines/legacy/
///   2. Copy those PNGs into this repo's shared/golden-baselines/legacy/
///   3. Run these tests — each renders the same parity card via SwiftUI,
///      records a greenfield regression baseline, and compares against
///      the legacy golden baseline.
///
/// The parity comparison is **reporting-only** — it generates diff images
/// and a JSON report but does NOT fail the test suite. This is because
/// cross-renderer diffs (UIKit/ObjC vs SwiftUI) are expected to be high
/// initially (60-90%) and will improve over time as the greenfield
/// renderer matures.
///
/// What DOES fail:
///   - Card parsing errors (JSON load failures)
///   - Greenfield render failures
///   - Greenfield regression snapshot mismatches (intra-renderer, 1% tolerance)
///
/// Record greenfield baselines (first run or after greenfield changes):
///   `RECORD_SNAPSHOTS=1 swift test --filter LegacyParityTests`
final class LegacyParityTests: CardSnapshotTestCase {

    // MARK: - Configuration

    /// Tolerance for greenfield regression snapshots (intra-renderer).
    /// The parity comparison against legacy baselines is reporting-only
    /// and does not use this tolerance.
    override var snapshotTolerance: Double { 0.01 }

    /// Directory containing legacy golden-path PNGs.
    private var legacyBaselinesDirectory: String {
        let testFileURL = URL(fileURLWithPath: #filePath)
        let repoRoot = testFileURL
            .deletingLastPathComponent()  // VisualTests/
            .deletingLastPathComponent()  // Tests/
            .deletingLastPathComponent()  // ios/
            .deletingLastPathComponent()  // repo root
        return repoRoot.appendingPathComponent("shared/golden-baselines/legacy").path
    }

    /// Directory containing shared parity card JSONs.
    private var parityCardsDirectory: String {
        let testFileURL = URL(fileURLWithPath: #filePath)
        let repoRoot = testFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return repoRoot.appendingPathComponent("shared/parity-cards").path
    }

    /// Output directory for parity comparison artifacts.
    private var parityOutputDirectory: String {
        let testFileURL = URL(fileURLWithPath: #filePath)
        let testsDir = testFileURL
            .deletingLastPathComponent()  // VisualTests/
        return URL(fileURLWithPath: testsDir.path)
            .appendingPathComponent("Snapshots/ParityResults").path
    }

    // MARK: - Helpers

    /// Loads a parity card JSON from shared/parity-cards/.
    private func loadParityCardJSON(named name: String) throws -> String {
        let path = "\(parityCardsDirectory)/\(name).json"
        guard FileManager.default.fileExists(atPath: path) else {
            throw ParityTestError.cardNotFound(name: name, path: path)
        }
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        guard let json = String(data: data, encoding: .utf8) else {
            throw ParityTestError.invalidEncoding(name: name)
        }
        return json
    }

    /// Loads the legacy golden-path PNG baseline.
    private func loadLegacyBaseline(named name: String) -> UIImage? {
        let path = "\(legacyBaselinesDirectory)/\(name).png"
        guard FileManager.default.fileExists(atPath: path),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }

    /// Core parity assertion: render via SwiftUI, compare against legacy PNG.
    ///
    /// When legacy baselines are not yet available, this falls back to
    /// recording greenfield-only baselines using the standard snapshot infra.
    @discardableResult
    private func assertLegacyParity(
        cardName: String,
        configuration: SnapshotConfiguration = .iPhone15Pro,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> ParityResult {
        // 1. Load and render via greenfield SwiftUI
        let json: String
        do {
            json = try loadParityCardJSON(named: cardName)
        } catch {
            XCTFail("Failed to load parity card '\(cardName)': \(error)", file: file, line: line)
            return ParityResult(cardName: cardName, status: .error, diffPercentage: 1.0, message: "Load failed: \(error)")
        }

        let view = createCardView(json: json)
        guard let greenfieldImage = renderView(view, configuration: configuration) else {
            XCTFail("Failed to render parity card '\(cardName)' via SwiftUI", file: file, line: line)
            return ParityResult(cardName: cardName, status: .renderFailed, diffPercentage: 1.0, message: "Render failed")
        }

        // Always record greenfield baseline for standalone regression
        let greenfieldSnapshotName = "parity_\(cardName)_\(configuration.name)"
        let _ = assertSnapshot(of: view, named: greenfieldSnapshotName, configuration: configuration, file: file, line: line)

        // 2. Check for legacy baseline
        guard let legacyImage = loadLegacyBaseline(named: cardName) else {
            print("PARITY: No legacy baseline for '\(cardName)' — greenfield-only snapshot recorded")
            return ParityResult(
                cardName: cardName,
                status: .noLegacyBaseline,
                diffPercentage: 0,
                message: "Legacy baseline not yet available. Greenfield snapshot recorded."
            )
        }

        // 3. Compare greenfield rendering against legacy baseline
        let diffPercentage = computeImageDifference(legacyImage, greenfieldImage)

        // Save comparison artifacts
        ensureDirectory(parityOutputDirectory)
        let actualPath = "\(parityOutputDirectory)/\(cardName)_greenfield.png"
        let legacyPath = "\(parityOutputDirectory)/\(cardName)_legacy.png"
        saveImageToPath(greenfieldImage, path: actualPath)
        saveImageToPath(legacyImage, path: legacyPath)

        if let diffImage = generateDiffImage(legacyImage, greenfieldImage) {
            let diffPath = "\(parityOutputDirectory)/\(cardName)_diff.png"
            saveImageToPath(diffImage, path: diffPath)
        }

        // Parity comparison is reporting-only — log results but do NOT XCTFail.
        // Cross-renderer diffs are expected to start high (60-90%) and improve over time.
        let parityThreshold = 0.10 // aspirational target, not enforced
        let passed = diffPercentage <= parityThreshold
        let formattedDiff = String(format: "%.2f%%", diffPercentage * 100)
        let formattedThreshold = String(format: "%.2f%%", parityThreshold * 100)

        if passed {
            print("✅ PARITY PASS: '\(cardName)' — diff \(formattedDiff) within \(formattedThreshold) threshold")
        } else {
            // Log but do NOT fail — this is an informational metric
            print("📊 PARITY DIFF: '\(cardName)' — diff \(formattedDiff) (threshold: \(formattedThreshold)). See: \(parityOutputDirectory)/\(cardName)_diff.png")
        }

        return ParityResult(
            cardName: cardName,
            status: passed ? .passed : .aboveThreshold,
            diffPercentage: diffPercentage,
            message: passed
                ? "Diff \(formattedDiff) within threshold"
                : "Diff \(formattedDiff) above \(formattedThreshold) threshold (informational)"
        )
    }

    private func ensureDirectory(_ path: String) {
        try? FileManager.default.createDirectory(
            atPath: path,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }

    private func saveImageToPath(_ image: UIImage, path: String) {
        if let data = image.pngData() {
            try? data.write(to: URL(fileURLWithPath: path), options: .atomic)
        }
    }

    // MARK: - Master Test: All Parity Cards

    /// Runs parity comparison for every card in shared/parity-cards/.
    /// Generates a summary report at the end.
    func testAllLegacyParity() {
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(atPath: parityCardsDirectory) else {
            XCTFail("Could not list parity-cards directory: \(parityCardsDirectory)")
            return
        }

        let cardNames = files
            .filter { $0.hasSuffix(".json") }
            .map { String($0.dropLast(5)) }  // Remove .json extension
            .sorted()

        XCTAssertGreaterThan(cardNames.count, 0, "No parity cards found")
        print("\n" + String(repeating: "=", count: 60))
        print("LEGACY PARITY TEST SUITE — \(cardNames.count) cards")
        print(String(repeating: "=", count: 60))

        var results: [ParityResult] = []

        for cardName in cardNames {
            let result = assertLegacyParity(cardName: cardName)
            results.append(result)
        }

        // Print summary
        let passed = results.filter { $0.status == .passed }.count
        let aboveThreshold = results.filter { $0.status == .aboveThreshold }.count
        let noBaseline = results.filter { $0.status == .noLegacyBaseline }.count
        let errors = results.filter { $0.status == .error || $0.status == .renderFailed }.count

        let avgDiff = results.isEmpty ? 0 : results.map(\.diffPercentage).reduce(0, +) / Double(results.count)

        print("\n" + String(repeating: "=", count: 60))
        print("PARITY SUMMARY:")
        print("  Within 10%:   \(passed)/\(results.count)")
        print("  Above 10%:    \(aboveThreshold)/\(results.count) (informational)")
        print("  No baseline:  \(noBaseline)/\(results.count)")
        print("  Errors:       \(errors)/\(results.count)")
        print("  Avg diff:     \(String(format: "%.1f%%", avgDiff * 100))")
        if !results.filter({ $0.status == .aboveThreshold }).isEmpty {
            print("\nCards above threshold (tracking for improvement):")
            for r in results where r.status == .aboveThreshold {
                print("  - \(r.cardName): \(String(format: "%.1f%%", r.diffPercentage * 100))")
            }
        }
        print(String(repeating: "=", count: 60) + "\n")

        // Write JSON report
        writeParityReport(results)
    }

    private func writeParityReport(_ results: [ParityResult]) {
        ensureDirectory(parityOutputDirectory)
        let reportPath = "\(parityOutputDirectory)/parity_report.json"

        let entries = results.map { r -> [String: Any] in
            [
                "card": r.cardName,
                "status": r.status.rawValue,
                "diffPercentage": r.diffPercentage,
                "message": r.message
            ]
        }

        let report: [String: Any] = [
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "tolerance": snapshotTolerance,
            "totalCards": results.count,
            "passed": results.filter { $0.status == .passed }.count,
            "aboveThreshold": results.filter { $0.status == .aboveThreshold }.count,
            "results": entries
        ]

        if let data = try? JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys]) {
            try? data.write(to: URL(fileURLWithPath: reportPath), options: .atomic)
            print("PARITY REPORT: \(reportPath)")
        }
    }

    // MARK: - Individual Parity Tests

    func testParity_textblockBasic() {
        assertLegacyParity(cardName: "parity-textblock-basic")
    }

    func testParity_imageSizes() {
        assertLegacyParity(cardName: "parity-image-sizes")
    }

    func testParity_containerStyles() {
        assertLegacyParity(cardName: "parity-container-styles")
    }

    func testParity_columnsetLayouts() {
        assertLegacyParity(cardName: "parity-columnset-layouts")
    }

    func testParity_factset() {
        assertLegacyParity(cardName: "parity-factset")
    }

    func testParity_imageset() {
        assertLegacyParity(cardName: "parity-imageset")
    }

    func testParity_actions() {
        assertLegacyParity(cardName: "parity-actions")
    }

    func testParity_richtext() {
        assertLegacyParity(cardName: "parity-richtext")
    }

    func testParity_table() {
        assertLegacyParity(cardName: "parity-table")
    }

    func testParity_activityUpdate() {
        assertLegacyParity(cardName: "parity-activity-update")
    }

    func testParity_nestedContainers() {
        assertLegacyParity(cardName: "parity-nested-containers")
    }

    func testParity_inputs() {
        assertLegacyParity(cardName: "parity-inputs")
    }
}

// MARK: - Supporting Types

enum ParityTestError: LocalizedError {
    case cardNotFound(name: String, path: String)
    case invalidEncoding(name: String)

    var errorDescription: String? {
        switch self {
        case .cardNotFound(let name, let path):
            return "Parity card '\(name)' not found at: \(path)"
        case .invalidEncoding(let name):
            return "Invalid encoding for parity card '\(name)'"
        }
    }
}

struct ParityResult {
    let cardName: String
    let status: ParityStatus
    let diffPercentage: Double
    let message: String
}

enum ParityStatus: String {
    case passed = "passed"
    case aboveThreshold = "above_threshold"
    case noLegacyBaseline = "no_legacy_baseline"
    case renderFailed = "render_failed"
    case error = "error"
}
#endif
