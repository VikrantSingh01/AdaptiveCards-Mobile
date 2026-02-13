import XCTest
import SwiftUI
@testable import ACCore
@testable import ACRendering

/// Rendering performance benchmarks for Adaptive Cards.
///
/// Uses XCTest's built-in measure() for Xcode performance tracking.
/// For comprehensive performance measurement with thresholds and reporting,
/// see Tests/VisualTests/CardPerformanceTests.swift
final class RenderingBenchmarks: XCTestCase {

    private let parser = CardParser()

    func testRenderSimpleCard() throws {
        let json = """
        {"type":"AdaptiveCard","version":"1.5","body":[{"type":"TextBlock","text":"Hello"}]}
        """
        let card = try parser.parse(json)

        measure {
            for _ in 0..<50 {
                let _ = AdaptiveCardView(cardJson: json)
            }
        }

        XCTAssertNotNil(card.body)
    }

    func testRenderComplexCard() throws {
        let json = """
        {"type":"AdaptiveCard","version":"1.5","body":[
          {"type":"Container","items":[
            {"type":"TextBlock","text":"Title","weight":"bolder"},
            {"type":"ColumnSet","columns":[
              {"type":"Column","items":[{"type":"TextBlock","text":"Left"}]},
              {"type":"Column","items":[{"type":"TextBlock","text":"Right"}]}
            ]}
          ]},
          {"type":"FactSet","facts":[
            {"title":"Fact 1","value":"Value 1"},
            {"title":"Fact 2","value":"Value 2"},
            {"title":"Fact 3","value":"Value 3"}
          ]},
          {"type":"Input.Text","id":"field1"},
          {"type":"Input.Toggle","id":"field2","title":"Toggle"}
        ],"actions":[{"type":"Action.Submit","title":"Submit"}]}
        """

        measure {
            for _ in 0..<20 {
                let _ = AdaptiveCardView(cardJson: json)
            }
        }
    }

    func testViewCreationOverhead() throws {
        let json = """
        {"type":"AdaptiveCard","version":"1.5","body":[{"type":"TextBlock","text":"Test"}]}
        """

        measure {
            for _ in 0..<100 {
                let _ = AdaptiveCardView(
                    cardJson: json,
                    hostConfig: HostConfig()
                )
            }
        }
    }
}
