import XCTest
import SwiftUI
@testable import ACCore
@testable import ACRendering

/// Legacy snapshot tests for verifying visual consistency of rendered cards.
///
/// For comprehensive visual regression testing, see the VisualTests target
/// which provides a full snapshot comparison framework with:
/// - Baseline image storage and comparison
/// - Multi-device/configuration matrix testing
/// - Diff image generation
/// - HTML/JSON report generation
///
/// See: Tests/VisualTests/
final class CardSnapshotTests: XCTestCase {

    private let parser = CardParser()

    func testSimpleTextCard_lightMode() throws {
        let cardJSON = """
        {"type":"AdaptiveCard","version":"1.5","body":[{"type":"TextBlock","text":"Hello"}]}
        """
        let card = try parser.parse(cardJSON)
        XCTAssertNotNil(card.body)
        XCTAssertEqual(card.body?.count, 1)
        if case .textBlock(let textBlock) = card.body?[0] {
            XCTAssertEqual(textBlock.text, "Hello")
        } else {
            XCTFail("Expected TextBlock")
        }
    }

    func testSimpleTextCard_darkMode() throws {
        let cardJSON = """
        {"type":"AdaptiveCard","version":"1.5","body":[{"type":"TextBlock","text":"Hello"}]}
        """
        let card = try parser.parse(cardJSON)
        XCTAssertNotNil(card.body)
        // Dark mode rendering validation is handled by VisualTests target
    }
}
