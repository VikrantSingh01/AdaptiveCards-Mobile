import XCTest
@testable import ACCore

/// Regression tests that parse ALL shared test card JSONs through the SDK's CardParser.
/// Catches Codable decoder failures (missing enum cases, type mismatches, etc.)
/// before they reach the UI layer.
///
/// Run: swift test --filter CardParsingRegressionTests
final class CardParsingRegressionTests: XCTestCase {

    private var parser: CardParser!
    private var testCardPaths: [String] = []

    override func setUp() {
        super.setUp()
        parser = CardParser()
        testCardPaths = findTestCards()
    }

    // MARK: - Teams Official Samples (must all parse)

    func testTeamsOfficialCardsAllParse() throws {
        let cards = testCardPaths.filter { $0.contains("teams-official-samples") && !$0.contains("-data.json") }
        XCTAssertGreaterThan(cards.count, 0, "No teams-official-samples found")

        var failures: [(String, String)] = []
        for path in cards {
            let filename = URL(fileURLWithPath: path).lastPathComponent
            let json = try String(contentsOfFile: path, encoding: .utf8)
            do {
                _ = try parser.parse(json)
            } catch {
                failures.append((filename, error.localizedDescription))
            }
        }

        if !failures.isEmpty {
            let report = failures.map { "  \($0.0): \($0.1)" }.joined(separator: "\n")
            XCTFail("\(failures.count) Teams Official cards failed to parse:\n\(report)")
        }
    }

    // MARK: - Official Samples

    func testOfficialSamplesAllParse() throws {
        let cards = testCardPaths.filter { $0.contains("official-samples") && !$0.contains("-data.json") }
        XCTAssertGreaterThan(cards.count, 0, "No official-samples found")

        var failures: [(String, String)] = []
        for path in cards {
            let filename = URL(fileURLWithPath: path).lastPathComponent
            let json = try String(contentsOfFile: path, encoding: .utf8)
            do {
                _ = try parser.parse(json)
            } catch {
                failures.append((filename, error.localizedDescription))
            }
        }

        if !failures.isEmpty {
            let report = failures.map { "  \($0.0): \($0.1)" }.joined(separator: "\n")
            XCTFail("\(failures.count) Official Sample cards failed to parse:\n\(report)")
        }
    }

    // MARK: - Built-in Test Cards

    func testBuiltInCardsAllParse() throws {
        let builtInCards = testCardPaths.filter {
            !$0.contains("official-samples") &&
            !$0.contains("teams-official-samples") &&
            !$0.contains("element-samples") &&
            !$0.contains("teams-templated") &&
            !$0.contains("-data.json")
        }

        var failures: [(String, String)] = []
        for path in builtInCards {
            let filename = URL(fileURLWithPath: path).lastPathComponent
            let json = try String(contentsOfFile: path, encoding: .utf8)
            do {
                _ = try parser.parse(json)
            } catch {
                failures.append((filename, error.localizedDescription))
            }
        }

        if !failures.isEmpty {
            let report = failures.map { "  \($0.0): \($0.1)" }.joined(separator: "\n")
            XCTFail("\(failures.count) built-in cards failed to parse:\n\(report)")
        }
    }

    // MARK: - Element Samples

    func testElementSamplesAllParse() throws {
        let cards = testCardPaths.filter { $0.contains("element-samples") && !$0.contains("-data.json") }

        var failures: [(String, String)] = []
        for path in cards {
            let filename = URL(fileURLWithPath: path).lastPathComponent
            let json = try String(contentsOfFile: path, encoding: .utf8)
            do {
                _ = try parser.parse(json)
            } catch {
                failures.append((filename, error.localizedDescription))
            }
        }

        if !failures.isEmpty {
            let report = failures.map { "  \($0.0): \($0.1)" }.joined(separator: "\n")
            XCTFail("\(failures.count) element sample cards failed to parse:\n\(report)")
        }
    }

    // MARK: - Helpers

    private func findTestCards() -> [String] {
        // Walk up from source to find shared/test-cards
        var dir = URL(fileURLWithPath: #file).deletingLastPathComponent()
        for _ in 0..<10 {
            let testCardsDir = dir.appendingPathComponent("shared/test-cards")
            if FileManager.default.fileExists(atPath: testCardsDir.path) {
                return findJSONFiles(in: testCardsDir.path)
            }
            dir = dir.deletingLastPathComponent()
        }
        return []
    }

    private func findJSONFiles(in directory: String) -> [String] {
        guard let enumerator = FileManager.default.enumerator(atPath: directory) else { return [] }
        var files: [String] = []
        while let path = enumerator.nextObject() as? String {
            if path.hasSuffix(".json") {
                files.append("\(directory)/\(path)")
            }
        }
        return files.sorted()
    }
}
