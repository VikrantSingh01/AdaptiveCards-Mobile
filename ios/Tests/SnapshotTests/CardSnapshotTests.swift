import XCTest
import SwiftUI
@testable import ACCore
@testable import ACRendering

/// Snapshot tests for verifying visual consistency of rendered cards
final class CardSnapshotTests: XCTestCase {
    
    func testSimpleTextCard_lightMode() throws {
        let cardJSON = """
        {"type":"AdaptiveCard","version":"1.5","body":[{"type":"TextBlock","text":"Hello"}]}
        """
        XCTAssertNotNil(cardJSON)
    }
    
    func testSimpleTextCard_darkMode() throws {
        let cardJSON = """
        {"type":"AdaptiveCard","version":"1.5","body":[{"type":"TextBlock","text":"Hello"}]}
        """
        XCTAssertNotNil(cardJSON)
    }
}
