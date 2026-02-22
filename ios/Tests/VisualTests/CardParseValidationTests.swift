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
            let failList = parseFailures.joined(separator: "\n  ✗ ")
            XCTFail("Failed to parse \(parseFailures.count)/\(cards.count) cards:\n  ✗ \(failList)")
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
            XCTFail("Parse failures:\n\(failures.joined(separator: "\n"))")
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

        for subdir in subdirs {
            let subPath = "\(dir)/\(subdir)"
            guard let files = try? FileManager.default.contentsOfDirectory(atPath: subPath) else { continue }
            let jsonFiles = files.filter { $0.hasSuffix(".json") }

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
            XCTFail("Parse failures in subdirectories:\n\(totalFailures.joined(separator: "\n"))")
        }
    }
}
