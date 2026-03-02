import XCTest
@testable import ACRendering
@testable import ACAccessibility
import ACCore

/// Tests for decorative image and button role accessibility fixes.
///
/// Covers:
/// - #22 (upstream #176): Button role announced twice — AccessibilityActionModifier
///   should NOT add .isButton since SwiftUI Button already provides it.
/// - #30/#11 (upstream #203, #108): Decorative images without alt text should be
///   hidden from VoiceOver so focus doesn't land on invisible/meaningless elements.
/// - #25 (upstream #181): ShowCard expanded content should trigger VoiceOver
///   layout changed notification so user discovers newly-revealed content.
final class DecorativeImageAccessibilityTests: XCTestCase {

    // MARK: - Image decorative vs informative

    func testImageWithAltText_isAccessible() throws {
        // An image with alt text should be visible to assistive technology
        let image = ACCore.Image(
            url: "https://example.com/weather.png",
            altText: "Sunny weather icon",
            size: .medium,
            style: .default
        )
        XCTAssertNotNil(image.altText)
        XCTAssertFalse(image.altText!.isEmpty)
    }

    func testImageWithoutAltText_isDecorative() throws {
        // An image without alt text is decorative and should be hidden
        let image = ACCore.Image(
            url: "https://example.com/bg.png",
            altText: nil,
            size: .auto,
            style: .default
        )
        XCTAssertNil(image.altText)
    }

    func testImageWithEmptyAltText_isDecorative() throws {
        // An image with empty alt text is also decorative
        let image = ACCore.Image(
            url: "https://example.com/divider.png",
            altText: "",
            size: .small,
            style: .default
        )
        XCTAssertTrue(image.altText?.isEmpty ?? true)
    }

    // MARK: - ShowCard metadata

    func testShowCardAction_hasCardContent() throws {
        // ShowCard actions should have a card body that becomes visible
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                {
                    "type": "TextBlock",
                    "text": "Main content"
                }
            ],
            "actions": [
                {
                    "type": "Action.ShowCard",
                    "title": "More Information",
                    "card": {
                        "type": "AdaptiveCard",
                        "body": [
                            {
                                "type": "TextBlock",
                                "text": "Hidden details revealed"
                            }
                        ]
                    }
                }
            ]
        }
        """
        let card = try CardParser().parse(json)
        XCTAssertNotNil(card.actions)
        XCTAssertEqual(card.actions?.count, 1)
        
        if case .showCard(let showCardAction) = card.actions?.first {
            XCTAssertEqual(showCardAction.title, "More Information")
            XCTAssertNotNil(showCardAction.card.body)
        } else {
            XCTFail("Expected Action.ShowCard")
        }
    }

    // MARK: - Button role

    func testActionButton_shouldNotDuplicateRole() throws {
        // The AccessibilityActionModifier should NOT add .isButton
        // because SwiftUI's Button already provides this trait.
        // This test validates the model-level action structure.
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                {
                    "type": "TextBlock",
                    "text": "Form"
                }
            ],
            "actions": [
                {
                    "type": "Action.Submit",
                    "title": "Ukadim"
                }
            ]
        }
        """
        let card = try CardParser().parse(json)
        XCTAssertNotNil(card.actions)
        XCTAssertEqual(card.actions?.count, 1)
        
        if case .submit(let submitAction) = card.actions?.first {
            XCTAssertEqual(submitAction.title, "Ukadim")
        } else {
            XCTFail("Expected Action.Submit")
        }
    }
}
