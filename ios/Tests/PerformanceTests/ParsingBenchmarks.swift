import XCTest
@testable import ACCore

/// Parsing performance benchmarks for Adaptive Cards.
///
/// Uses XCTest's built-in measure() for Xcode performance tracking.
/// For comprehensive performance measurement with thresholds and reporting,
/// see Tests/VisualTests/CardPerformanceTests.swift
final class ParsingBenchmarks: XCTestCase {

    private let parser = CardParser()

    func testParseSimpleCard() throws {
        let json = """
        {"type":"AdaptiveCard","version":"1.5","body":[{"type":"TextBlock","text":"Hello"}]}
        """

        measure {
            for _ in 0..<100 {
                _ = try? parser.parse(json)
            }
        }
    }

    func testParseComplexCard() throws {
        let json = """
        {"type":"AdaptiveCard","version":"1.5","body":[
          {"type":"Container","items":[
            {"type":"TextBlock","text":"Title","weight":"bolder"},
            {"type":"ColumnSet","columns":[
              {"type":"Column","items":[{"type":"TextBlock","text":"Left"}]},
              {"type":"Column","items":[{"type":"TextBlock","text":"Right"}]}
            ]}
          ]},
          {"type":"Input.Text","id":"field1"},
          {"type":"Input.Toggle","id":"field2","title":"Toggle"}
        ],"actions":[{"type":"Action.Submit","title":"Submit"}]}
        """

        measure {
            for _ in 0..<100 {
                _ = try? parser.parse(json)
            }
        }
    }

    func testParseCardWithAllInputTypes() throws {
        let json = """
        {"type":"AdaptiveCard","version":"1.6","body":[
          {"type":"Input.Text","id":"text1","label":"Name"},
          {"type":"Input.Number","id":"num1","label":"Age"},
          {"type":"Input.Date","id":"date1","label":"Date"},
          {"type":"Input.Time","id":"time1","label":"Time"},
          {"type":"Input.Toggle","id":"toggle1","title":"Agree"},
          {"type":"Input.ChoiceSet","id":"choice1","choices":[
            {"title":"Option A","value":"a"},
            {"title":"Option B","value":"b"},
            {"title":"Option C","value":"c"}
          ]}
        ],"actions":[{"type":"Action.Submit","title":"Submit"}]}
        """

        measure {
            for _ in 0..<100 {
                _ = try? parser.parse(json)
            }
        }
    }

    func testParseAndEncodeRoundTrip() throws {
        let json = """
        {"type":"AdaptiveCard","version":"1.6","body":[
          {"type":"Container","items":[
            {"type":"TextBlock","text":"Title","weight":"bolder","size":"large"},
            {"type":"TextBlock","text":"Subtitle","isSubtle":true}
          ]},
          {"type":"FactSet","facts":[
            {"title":"Fact 1","value":"Value 1"},
            {"title":"Fact 2","value":"Value 2"}
          ]}
        ]}
        """

        measure {
            for _ in 0..<50 {
                if let card = try? parser.parse(json) {
                    _ = try? parser.encode(card)
                }
            }
        }
    }
}
