import XCTest
import SwiftUI
@testable import ACCore
@testable import ACRendering

final class RenderingBenchmarks: XCTestCase {
    
    func testRenderSimpleCard() throws {
        let json = """
        {"type":"AdaptiveCard","version":"1.5","body":[{"type":"TextBlock","text":"Hello"}]}
        """
        let data = json.data(using: .utf8)!
        let card = try JSONDecoder().decode(AdaptiveCard.self, from: data)
        
        measure {
            for _ in 0..<50 {
                let _ = Text(card.body.first?.type ?? "")
            }
        }
    }
}
