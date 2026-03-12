import XCTest
@testable import ACActions
@testable import ACCore

/// Tests that parsing and handling edge-case/malformed actions never crashes.
/// Uses the shared test card edge-action-crashes.json and programmatic action construction.
final class ActionCrashResilienceTests: XCTestCase {

    // MARK: - Parsing Crash Resilience

    func testEdgeActionCrashCardParses() throws {
        let json = """
        {
          "type": "AdaptiveCard",
          "version": "1.6",
          "body": [{"type": "TextBlock", "text": "Test"}],
          "actions": [
            {"type": "Action.OpenUrl", "title": "Empty URL", "url": ""},
            {"type": "Action.OpenUrl", "title": "Blocked", "url": "javascript:alert(1)"},
            {"type": "Action.ToggleVisibility", "title": "Empty targets", "targetElements": []},
            {"type": "Action.Submit", "title": "Null data", "data": null},
            {"type": "Action.Execute", "title": "No verb"},
            {"type": "Action.RunCommands", "title": "Empty", "commands": []},
            {"type": "Action.OpenUrlDialog", "title": "Empty URL", "url": ""},
            {"type": "Action.ShowCard", "title": "Nested", "card": {
              "type": "AdaptiveCard", "version": "1.6",
              "body": [{"type": "TextBlock", "text": "Level 1"}],
              "actions": [{"type": "Action.ShowCard", "title": "L2", "card": {
                "type": "AdaptiveCard", "version": "1.6",
                "body": [{"type": "TextBlock", "text": "Level 2"}]
              }}]
            }}
          ]
        }
        """

        let data = json.data(using: .utf8)!
        let card = try JSONDecoder().decode(AdaptiveCard.self, from: data)
        XCTAssertNotNil(card.actions)
        XCTAssertGreaterThan(card.actions!.count, 0)
    }

    func testUnknownActionTypeDecodesGracefully() throws {
        let json = """
        {
          "type": "AdaptiveCard",
          "version": "1.6",
          "body": [{"type": "TextBlock", "text": "Test"}],
          "actions": [
            {"type": "Action.FutureType", "title": "Unknown Action"}
          ]
        }
        """

        let data = json.data(using: .utf8)!
        let card = try JSONDecoder().decode(AdaptiveCard.self, from: data)
        XCTAssertEqual(card.actions?.count, 1)

        if case .unknown(let type) = card.actions?.first {
            XCTAssertEqual(type, "Action.FutureType")
        } else {
            XCTFail("Expected .unknown case for unrecognized action type")
        }
    }

    // MARK: - Handler Crash Resilience

    func testOpenUrlEmptyStringDoesNotCrash() {
        let delegate = MockActionDelegate()
        let handler = OpenUrlActionHandler(delegate: delegate)
        handler.handle(OpenUrlAction(url: ""))
        XCTAssertEqual(delegate.openUrlCalls.count, 0)
    }

    func testOpenUrlBlockedSchemeDoesNotCrash() {
        let delegate = MockActionDelegate()
        let handler = OpenUrlActionHandler(delegate: delegate)
        handler.handle(OpenUrlAction(url: "javascript:void(0)"))
        XCTAssertEqual(delegate.openUrlCalls.count, 0)
    }

    func testOpenUrlFileSchemeBlocked() {
        let delegate = MockActionDelegate()
        let handler = OpenUrlActionHandler(delegate: delegate)
        handler.handle(OpenUrlAction(url: "file:///etc/passwd"))
        XCTAssertEqual(delegate.openUrlCalls.count, 0)
    }

    func testSubmitNilDataDoesNotCrash() {
        let delegate = MockActionDelegate()
        let handler = SubmitActionHandler(delegate: delegate, gatherInputs: { [:] })
        handler.handle(SubmitAction())
        XCTAssertEqual(delegate.submitCalls.count, 1)
    }

    func testExecuteNoVerbDoesNotCrash() {
        let delegate = MockActionDelegate()
        let handler = ExecuteActionHandler(delegate: delegate, gatherInputs: { [:] })
        handler.handle(ExecuteAction())
        XCTAssertEqual(delegate.executeCalls.count, 1)
    }

    func testToggleVisibilityEmptyTargetsDoesNotCrash() {
        var toggleCount = 0
        let handler = ToggleVisibilityHandler(toggleVisibility: { _, _ in toggleCount += 1 })
        handler.handle(ToggleVisibilityAction(targetElements: []))
        XCTAssertEqual(toggleCount, 0)
    }

    func testShowCardDeeplyNestedDoesNotCrash() {
        // 5 levels of nesting — should parse and handle without stack overflow
        var toggledIds: [String] = []
        let handler = ShowCardActionHandler(toggleCard: { id in toggledIds.append(id) })

        let level3 = AdaptiveCard(body: [.textBlock(TextBlock(text: "Level 3"))])
        let level2 = AdaptiveCard(
            body: [.textBlock(TextBlock(text: "Level 2"))],
            actions: [.showCard(ShowCardAction(id: "sc3", card: level3))]
        )
        let level1 = AdaptiveCard(
            body: [.textBlock(TextBlock(text: "Level 1"))],
            actions: [.showCard(ShowCardAction(id: "sc2", card: level2))]
        )
        let topAction = ShowCardAction(id: "sc1", card: level1)

        handler.handle(topAction)
        XCTAssertEqual(toggledIds, ["sc1"])
    }

    @MainActor
    func testPopoverNilContentDoesNotCrash() {
        PopoverActionHandler.handle(action: PopoverAction(), delegate: nil)
    }

    @MainActor
    func testRunCommandsEmptyDoesNotCrash() {
        RunCommandsActionHandler.handle(action: RunCommandsAction(commands: []), delegate: nil)
    }

    @MainActor
    func testOpenUrlDialogEmptyUrlDoesNotCrash() {
        OpenUrlDialogActionHandler.handle(action: OpenUrlDialogAction(url: ""), delegate: nil)
    }

    // MARK: - Nil Delegate Resilience

    func testSubmitWithNilDelegateDoesNotCrash() {
        let handler = SubmitActionHandler(delegate: nil, gatherInputs: { ["k": "v"] })
        handler.handle(SubmitAction(data: AnyCodable(["a": "b"])))
    }

    func testOpenUrlWithNilDelegateDoesNotCrash() {
        let handler = OpenUrlActionHandler(delegate: nil)
        handler.handle(OpenUrlAction(url: "https://example.com"))
    }

    func testExecuteWithNilDelegateDoesNotCrash() {
        let handler = ExecuteActionHandler(delegate: nil, gatherInputs: { [:] })
        handler.handle(ExecuteAction(verb: "test"))
    }
}
