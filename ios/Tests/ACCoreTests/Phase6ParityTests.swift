// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import XCTest
@testable import ACCore

/// Tests for Phase 6 Web/Desktop Spec Parity features.
final class Phase6ParityTests: XCTestCase {

    // MARK: - 6A: FeatureFlags.meetsRequirements

    func testMeetsRequirements_nilRequirements_returnsTrue() {
        let flags = FeatureFlags()
        XCTAssertTrue(flags.meetsRequirements(nil))
    }

    func testMeetsRequirements_emptyRequirements_returnsTrue() {
        let flags = FeatureFlags()
        XCTAssertTrue(flags.meetsRequirements([:]))
    }

    func testMeetsRequirements_wildcardVersion_featureRegistered_returnsTrue() {
        var flags = FeatureFlags()
        flags.register(name: "adaptiveCards", version: "1.5")
        XCTAssertTrue(flags.meetsRequirements(["adaptiveCards": "*"]))
    }

    func testMeetsRequirements_wildcardVersion_featureNotRegistered_returnsFalse() {
        let flags = FeatureFlags()
        XCTAssertFalse(flags.meetsRequirements(["adaptiveCards": "*"]))
    }

    func testMeetsRequirements_exactVersion_matches_returnsTrue() {
        var flags = FeatureFlags()
        flags.register(name: "adaptiveCards", version: "1.5")
        XCTAssertTrue(flags.meetsRequirements(["adaptiveCards": "1.5"]))
    }

    func testMeetsRequirements_exactVersion_mismatch_returnsFalse() {
        var flags = FeatureFlags()
        flags.register(name: "adaptiveCards", version: "1.4")
        XCTAssertFalse(flags.meetsRequirements(["adaptiveCards": "1.5"]))
    }

    func testMeetsRequirements_multipleRequirements_allMet_returnsTrue() {
        var flags = FeatureFlags()
        flags.register(name: "adaptiveCards", version: "1.5")
        flags.register(name: "myFeature", version: "2.0")
        XCTAssertTrue(flags.meetsRequirements(["adaptiveCards": "*", "myFeature": "2.0"]))
    }

    func testMeetsRequirements_multipleRequirements_oneMissing_returnsFalse() {
        var flags = FeatureFlags()
        flags.register(name: "adaptiveCards", version: "1.5")
        XCTAssertFalse(flags.meetsRequirements(["adaptiveCards": "*", "myFeature": "2.0"]))
    }

    // MARK: - 6A: Fallback parsing on unknown elements

    func testUnknownElement_parsesFallback() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                {
                    "type": "FutureElement",
                    "requires": { "abc": "*" },
                    "fallback": {
                        "type": "TextBlock",
                        "text": "Fallback content"
                    }
                }
            ]
        }
        """
        let card = try JSONDecoder().decode(AdaptiveCard.self, from: json.data(using: .utf8)!)
        let element = card.body?.first
        XCTAssertNotNil(element)
        if case .unknown(let type, let fallback) = element {
            XCTAssertEqual(type, "FutureElement")
            XCTAssertNotNil(fallback)
            if case .textBlock(let tb) = fallback {
                XCTAssertEqual(tb.text, "Fallback content")
            } else {
                XCTFail("Fallback should be a TextBlock")
            }
        } else {
            XCTFail("Expected .unknown element")
        }
    }

    func testUnknownElement_dropFallback() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                {
                    "type": "FutureElement",
                    "requires": { "abc": "*" },
                    "fallback": "drop"
                }
            ]
        }
        """
        let card = try JSONDecoder().decode(AdaptiveCard.self, from: json.data(using: .utf8)!)
        let element = card.body?.first
        if case .unknown(_, let fallback) = element {
            if case .unknown(let type, _) = fallback {
                XCTAssertEqual(type, "drop")
            } else {
                XCTFail("Expected drop fallback")
            }
        } else {
            XCTFail("Expected .unknown element")
        }
    }

    // MARK: - 6B: DataQuery parsing

    func testChoiceSetInput_parsesChoicesData() throws {
        let json = """
        {
            "type": "Input.ChoiceSet",
            "id": "city",
            "style": "filtered",
            "choices.data": {
                "dataset": "graph.microsoft.com/users",
                "count": 25
            },
            "choices": []
        }
        """
        let input = try JSONDecoder().decode(ChoiceSetInput.self, from: json.data(using: .utf8)!)
        XCTAssertNotNil(input.choicesData)
        XCTAssertEqual(input.choicesData?.dataset, "graph.microsoft.com/users")
        XCTAssertEqual(input.choicesData?.count, 25)
    }

    func testChoiceSetInput_noChoicesData() throws {
        let json = """
        {
            "type": "Input.ChoiceSet",
            "id": "color",
            "choices": [{"title": "Red", "value": "1"}]
        }
        """
        let input = try JSONDecoder().decode(ChoiceSetInput.self, from: json.data(using: .utf8)!)
        XCTAssertNil(input.choicesData)
        XCTAssertEqual(input.choices.count, 1)
    }

    // MARK: - 6C: CaptionSource parsing

    func testMedia_parsesCaptionSources() throws {
        let json = """
        {
            "type": "Media",
            "sources": [{"mimeType": "video/mp4", "url": "https://example.com/video.mp4"}],
            "captionSources": [
                {"mimeType": "text/vtt", "url": "https://example.com/captions.vtt", "label": "English"}
            ]
        }
        """
        let media = try JSONDecoder().decode(Media.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(media.captionSources?.count, 1)
        XCTAssertEqual(media.captionSources?.first?.mimeType, "text/vtt")
        XCTAssertEqual(media.captionSources?.first?.label, "English")
    }

    // MARK: - 6D: TextBlockStyle parsing

    func testTextBlock_parsesHeadingStyle() throws {
        let json = """
        {"type": "TextBlock", "text": "Hello", "style": "Heading"}
        """
        let tb = try JSONDecoder().decode(TextBlock.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(tb.style, .heading)
    }

    func testTextBlock_parsesColumnHeaderStyle() throws {
        let json = """
        {"type": "TextBlock", "text": "Name", "style": "ColumnHeader"}
        """
        let tb = try JSONDecoder().decode(TextBlock.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(tb.style, .columnHeader)
    }

    // MARK: - 6F: labelPosition / labelWidth parsing

    func testTextInput_parsesLabelPosition() throws {
        let json = """
        {
            "type": "Input.Text",
            "id": "name",
            "label": "Name",
            "labelPosition": "inline",
            "labelWidth": "60px"
        }
        """
        let input = try JSONDecoder().decode(TextInput.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(input.labelPosition, "inline")
        XCTAssertEqual(input.labelWidth, "60px")
    }

    func testTextInput_parsesNumericLabelWidth() throws {
        let json = """
        {
            "type": "Input.Text",
            "id": "name",
            "label": "Name",
            "labelPosition": "inline",
            "labelWidth": 40
        }
        """
        let input = try JSONDecoder().decode(TextInput.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(input.labelPosition, "inline")
        XCTAssertEqual(input.labelWidth, "40")
    }
}
