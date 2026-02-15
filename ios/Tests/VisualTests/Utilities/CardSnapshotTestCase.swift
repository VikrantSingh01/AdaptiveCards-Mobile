#if canImport(UIKit)
import XCTest
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
@testable import ACCore
@testable import ACRendering
@testable import ACInputs

/// Base class for Adaptive Card visual regression tests.
///
/// Provides convenience methods for:
/// - Loading test cards from the shared test-cards directory
/// - Rendering cards as AdaptiveCardView
/// - Running snapshot comparisons across multiple configurations
///
/// Subclass this to implement visual tests for specific cards or card groups.
open class CardSnapshotTestCase: SnapshotTestCase {

    // MARK: - Properties

    /// Shared card parser for all tests
    public let parser = CardParser()

    /// Default host config used for rendering
    public var hostConfig: HostConfig { HostConfig() }

    /// List of all available test card filenames at the top level (without extension)
    public static var allTestCardNames: [String] {
        let resourceDir = testCardsDirectory
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: resourceDir) else {
            return []
        }
        return files
            .filter { $0.hasSuffix(".json") }
            .map { String($0.dropLast(5)) }
            .sorted()
    }

    /// Recursively discovers all .json card files under shared/test-cards/,
    /// including subdirectories (official-samples/, element-samples/, etc.)
    /// Returns (displayName, relativePath) pairs.
    public static var allDiscoveredCardPaths: [(name: String, relativePath: String)] {
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

    /// Total count of all discoverable cards (including subdirectories)
    public static var totalCardCount: Int {
        allDiscoveredCardPaths.count
    }

    /// Path to the shared test-cards directory
    public static var testCardsDirectory: String {
        // Navigate from test file to shared/test-cards
        // File is at: ios/Tests/VisualTests/Utilities/CardSnapshotTestCase.swift
        let testFileURL = URL(fileURLWithPath: #filePath)
        let repoRoot = testFileURL
            .deletingLastPathComponent()  // Utilities/
            .deletingLastPathComponent()  // VisualTests/
            .deletingLastPathComponent()  // Tests/
            .deletingLastPathComponent()  // ios/
            .deletingLastPathComponent()  // repo root
        return repoRoot.appendingPathComponent("shared/test-cards").path
    }

    // MARK: - Card Loading

    /// Loads a test card JSON string by name from the shared test-cards directory
    public func loadTestCard(named name: String) throws -> String {
        let path = "\(Self.testCardsDirectory)/\(name).json"
        let url = URL(fileURLWithPath: path)

        guard FileManager.default.fileExists(atPath: path) else {
            throw CardTestError.cardNotFound(name: name, path: path)
        }

        let data = try Data(contentsOf: url)
        guard let json = String(data: data, encoding: .utf8) else {
            throw CardTestError.invalidEncoding(name: name)
        }
        return json
    }

    /// Loads and parses a test card by name
    public func loadAndParseCard(named name: String) throws -> AdaptiveCard {
        let json = try loadTestCard(named: name)
        return try parser.parse(json)
    }

    // MARK: - View Rendering Helpers

    /// Creates a synchronously-rendered card view from a JSON string.
    /// Unlike AdaptiveCardView (which parses asynchronously via onAppear),
    /// this pre-parses the card so the view is ready for immediate snapshot capture.
    public func createCardView(json: String, hostConfig: HostConfig? = nil) -> some View {
        let config = hostConfig ?? self.hostConfig
        // Pre-parse the card synchronously for snapshot testing
        if let card = try? parser.parse(json) {
            return AnyView(PreParsedCardView(card: card, hostConfig: config))
        } else {
            // Fallback: show error text so snapshots aren't blank
            return AnyView(
                Text("Parse Error")
                    .foregroundColor(.red)
                    .padding()
            )
        }
    }

    /// Creates a synchronously-rendered card view for a named test card
    public func createCardView(named name: String, hostConfig: HostConfig? = nil) throws -> some View {
        let json = try loadTestCard(named: name)
        return createCardView(json: json, hostConfig: hostConfig)
    }

    // MARK: - Snapshot Assertion Helpers

    /// Asserts a snapshot for a named test card with a single configuration
    @discardableResult
    public func assertCardSnapshot(
        named cardName: String,
        configuration: SnapshotConfiguration = .iPhone15Pro,
        hostConfig: HostConfig? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> SnapshotDiffResult {
        do {
            let json = try loadTestCard(named: cardName)
            let view = createCardView(json: json, hostConfig: hostConfig)
            return assertSnapshot(
                of: view,
                named: cardName,
                configuration: configuration,
                file: file,
                line: line
            )
        } catch {
            let result = SnapshotDiffResult(
                passed: false,
                diffPercentage: 1.0,
                baselinePath: nil,
                actualPath: nil,
                diffPath: nil,
                message: "Failed to load card '\(cardName)': \(error.localizedDescription)"
            )
            XCTFail(result.message, file: file, line: line)
            return result
        }
    }

    /// Asserts snapshots for a named test card across multiple configurations
    @discardableResult
    public func assertCardSnapshots(
        named cardName: String,
        configurations: [SnapshotConfiguration] = SnapshotConfiguration.core,
        hostConfig: HostConfig? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> [SnapshotDiffResult] {
        do {
            let json = try loadTestCard(named: cardName)
            let view = createCardView(json: json, hostConfig: hostConfig)
            return assertSnapshots(
                of: view,
                named: cardName,
                configurations: configurations,
                file: file,
                line: line
            )
        } catch {
            let result = SnapshotDiffResult(
                passed: false,
                diffPercentage: 1.0,
                baselinePath: nil,
                actualPath: nil,
                diffPath: nil,
                message: "Failed to load card '\(cardName)': \(error.localizedDescription)"
            )
            XCTFail(result.message, file: file, line: line)
            return [result]
        }
    }

    /// Runs visual regression for ALL test cards in the shared directory
    @discardableResult
    public func assertAllCardSnapshots(
        configurations: [SnapshotConfiguration] = [.iPhone15Pro],
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> [String: [SnapshotDiffResult]] {
        var allResults: [String: [SnapshotDiffResult]] = [:]

        for cardName in Self.allTestCardNames {
            let results = assertCardSnapshots(
                named: cardName,
                configurations: configurations,
                file: file,
                line: line
            )
            allResults[cardName] = results
        }

        return allResults
    }

    // MARK: - Parsing Validation Helpers

    /// Validates that a card parses without errors
    public func assertCardParses(named name: String, file: StaticString = #filePath, line: UInt = #line) {
        do {
            let _ = try loadAndParseCard(named: name)
        } catch {
            XCTFail("Card '\(name)' failed to parse: \(error.localizedDescription)", file: file, line: line)
        }
    }

    /// Validates that all test cards parse without errors
    public func assertAllCardsParse(file: StaticString = #filePath, line: UInt = #line) {
        var failures: [String] = []

        for cardName in Self.allTestCardNames {
            do {
                let _ = try loadAndParseCard(named: cardName)
            } catch {
                failures.append("\(cardName): \(error.localizedDescription)")
            }
        }

        if !failures.isEmpty {
            XCTFail("Failed to parse \(failures.count) cards:\n\(failures.joined(separator: "\n"))",
                    file: file, line: line)
        }
    }
}

// MARK: - Card Test Errors

public enum CardTestError: Error, LocalizedError {
    case cardNotFound(name: String, path: String)
    case invalidEncoding(name: String)
    case renderingFailed(name: String)

    public var errorDescription: String? {
        switch self {
        case .cardNotFound(let name, let path):
            return "Test card '\(name)' not found at path: \(path)"
        case .invalidEncoding(let name):
            return "Test card '\(name)' has invalid encoding"
        case .renderingFailed(let name):
            return "Failed to render test card '\(name)'"
        }
    }
}
#endif // canImport(UIKit)
