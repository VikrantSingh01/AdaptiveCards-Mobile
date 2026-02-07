import XCTest
@testable import ACCore

final class ParsingBenchmarks: XCTestCase {
    
    func testParseSimpleCard() throws {
        let json = """
        {"type":"AdaptiveCard","version":"1.5","body":[{"type":"TextBlock","text":"Hello"}]}
        """
        
        measure {
            for _ in 0..<100 {
                _ = try? JSONDecoder().decode(AdaptiveCard.self, from: json.data(using: .utf8)!)
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
          {"type":"Input.Toggle","id":"field2"}
        ],"actions":[{"type":"Action.Submit","title":"Submit"}]}
        """
        
        measure {
            for _ in 0..<100 {
                _ = try? JSONDecoder().decode(AdaptiveCard.self, from: json.data(using: .utf8)!)
            }
        }
    }
}
