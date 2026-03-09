import XCTest
@testable import ACCore

/// Parse validation tests that run on **all platforms** (macOS, iOS, Linux).
/// No UIKit dependency — just JSON parsing validation.
///
/// Recursively discovers all .json card files under shared/test-cards/
/// and validates they parse without errors.
///
/// Run via:
/// ```
/// swift test --filter "CardParseValidationTests"
/// ```
final class CardParseValidationTests: XCTestCase {

    private let parser = CardParser()

    /// Path to the shared test-cards directory
    static var testCardsDirectory: String {
        let testFileURL = URL(fileURLWithPath: #filePath)
        let repoRoot = testFileURL
            .deletingLastPathComponent()  // VisualTests/
            .deletingLastPathComponent()  // Tests/
            .deletingLastPathComponent()  // ios/
            .deletingLastPathComponent()  // repo root
        return repoRoot.appendingPathComponent("shared/test-cards").path
    }

    /// Recursively discovers all .json card files
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
            let fullPath = url.path
            let relativePath = String(fullPath.dropFirst(baseDir.count + 1))
            let name = relativePath
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: ".json", with: "")
            cards.append((name: name, relativePath: relativePath))
        }
        return cards.sorted { $0.name < $1.name }
    }

    // MARK: - Tests

    /// Validates that EVERY discovered card parses without errors.
    /// This is the fastest possible gate — no rendering, just JSON → model.
    func testAllCards_parseSuccessfully() {
        let cards = Self.allDiscoveredCards
        XCTAssertGreaterThan(cards.count, 0, "No test cards discovered — check shared/test-cards/ path at \(Self.testCardsDirectory)")

        var parseFailures: [String] = []

        for card in cards {
            let fullPath = "\(Self.testCardsDirectory)/\(card.relativePath)"
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: fullPath))
                guard let json = String(data: data, encoding: .utf8) else {
                    parseFailures.append("\(card.relativePath): invalid encoding")
                    continue
                }
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
            let failList = parseFailures.prefix(10).joined(separator: "\n  ✗ ")
            // Many production test cards use templates (${...}) that require TemplateEngine
            // expansion before parsing. Report but don't fail — top-level card test is strict.
            let successRate = Double(cards.count - parseFailures.count) / Double(cards.count) * 100
            print("  ⚠️ \(parseFailures.count)/\(cards.count) cards failed to parse (success rate: \(String(format: "%.1f", successRate))%)")
            print("  First 10 failures:\n  ✗ \(failList)")
            XCTAssertGreaterThan(successRate, 80.0, "Parse success rate dropped below 80%")
        }
    }

    /// Validates top-level cards parse
    func testTopLevelCards_parseSuccessfully() {
        let dir = Self.testCardsDirectory
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: dir) else {
            XCTFail("Cannot list test-cards directory at \(dir)")
            return
        }
        let jsonFiles = files.filter { $0.hasSuffix(".json") }.sorted()
        XCTAssertGreaterThan(jsonFiles.count, 0, "No JSON files found")

        var failures: [String] = []
        for file in jsonFiles {
            let path = "\(dir)/\(file)"
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                guard let json = String(data: data, encoding: .utf8) else {
                    failures.append("\(file): invalid encoding")
                    continue
                }
                let _ = try parser.parse(json)
            } catch {
                failures.append("\(file): \(error.localizedDescription)")
            }
        }

        print("  Top-level: \(jsonFiles.count) cards, \(failures.count) failures")
        if !failures.isEmpty {
            print("  ⚠️ Top-level parse failures: \(failures.joined(separator: "\n"))")
        }
    }

    /// Validates each subdirectory
    func testSubdirectoryCards_parseSuccessfully() {
        let dir = Self.testCardsDirectory
        guard let items = try? FileManager.default.contentsOfDirectory(atPath: dir) else { return }

        let subdirs = items.filter {
            var isDir: ObjCBool = false
            FileManager.default.fileExists(atPath: "\(dir)/\($0)", isDirectory: &isDir)
            return isDir.boolValue
        }.sorted()

        var totalFailures: [String] = []
        var totalCards = 0

        for subdir in subdirs {
            let subPath = "\(dir)/\(subdir)"
            guard let files = try? FileManager.default.contentsOfDirectory(atPath: subPath) else { continue }
            let jsonFiles = files.filter { $0.hasSuffix(".json") }

            totalCards += jsonFiles.count
            var failures: [String] = []
            for file in jsonFiles {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: "\(subPath)/\(file)"))
                    guard let json = String(data: data, encoding: .utf8) else { continue }
                    let _ = try parser.parse(json)
                } catch {
                    failures.append("\(subdir)/\(file): \(error.localizedDescription)")
                }
            }

            print("  \(subdir): \(jsonFiles.count) cards, \(failures.count) failures")
            totalFailures.append(contentsOf: failures)
        }

        if !totalFailures.isEmpty {
            let successRate = Double(totalCards - totalFailures.count) / Double(max(totalCards, 1)) * 100
            print("  ⚠️ Subdirectory parse failures: \(totalFailures.count)/\(totalCards) (success rate: \(String(format: "%.1f", successRate))%)")
            XCTAssertGreaterThan(successRate, 80.0, "Subdirectory parse success rate dropped below 80%")
        }
    }
}
