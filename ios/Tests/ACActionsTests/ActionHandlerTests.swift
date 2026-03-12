import XCTest
@testable import ACActions
@testable import ACCore

/// Mock delegate that records all action callbacks for verification
final class MockActionDelegate: ActionDelegate {
    var submitCalls: [(data: [String: Any], actionId: String?)] = []
    var openUrlCalls: [(url: URL, actionId: String?)] = []
    var executeCalls: [(verb: String?, data: [String: Any], actionId: String?)] = []
    var showCardCalls: [(actionId: String?, isExpanded: Bool)] = []
    var toggleVisibilityCalls: [[String]] = []

    func onSubmit(data: [String: Any], actionId: String?) {
        submitCalls.append((data, actionId))
    }

    func onOpenUrl(url: URL, actionId: String?) {
        openUrlCalls.append((url, actionId))
    }

    func onExecute(verb: String?, data: [String: Any], actionId: String?) {
        executeCalls.append((verb, data, actionId))
    }

    func onShowCard(actionId: String?, isExpanded: Bool) {
        showCardCalls.append((actionId, isExpanded))
    }

    func onToggleVisibility(targetElementIds: [String]) {
        toggleVisibilityCalls.append(targetElementIds)
    }
}

/// Tests for all 8 action handler types using MockActionDelegate
final class ActionHandlerTests: XCTestCase {

    var delegate: MockActionDelegate!

    override func setUp() {
        super.setUp()
        delegate = MockActionDelegate()
    }

    // MARK: - Action.Submit

    func testSubmitWithDataAndInputs() {
        let inputs = ["name": "John", "email": "john@test.com"]
        let handler = SubmitActionHandler(
            delegate: delegate,
            gatherInputs: { inputs as [String: Any] }
        )
        let action = SubmitAction(
            id: "submit1",
            data: AnyCodable(["key": "value"])
        )

        handler.handle(action)

        XCTAssertEqual(delegate.submitCalls.count, 1)
        let call = delegate.submitCalls[0]
        XCTAssertEqual(call.actionId, "submit1")
        XCTAssertEqual(call.data["name"] as? String, "John")
        XCTAssertEqual(call.data["email"] as? String, "john@test.com")
        XCTAssertEqual(call.data["key"] as? String, "value")
    }

    func testSubmitWithAssociatedInputsNone() {
        let handler = SubmitActionHandler(
            delegate: delegate,
            gatherInputs: { ["input1": "should_not_appear"] as [String: Any] }
        )
        let action = SubmitAction(
            id: "submit2",
            data: AnyCodable(["only": "this"]),
            associatedInputs: AssociatedInputs.none
        )

        handler.handle(action)

        XCTAssertEqual(delegate.submitCalls.count, 1)
        let call = delegate.submitCalls[0]
        XCTAssertNil(call.data["input1"])
        XCTAssertEqual(call.data["only"] as? String, "this")
    }

    func testSubmitWithNilData() {
        let handler = SubmitActionHandler(
            delegate: delegate,
            gatherInputs: { [:] }
        )
        let action = SubmitAction(id: "submit3")

        handler.handle(action)

        XCTAssertEqual(delegate.submitCalls.count, 1)
        XCTAssertTrue(delegate.submitCalls[0].data.isEmpty)
    }

    func testSubmitWithStringData() {
        let handler = SubmitActionHandler(
            delegate: delegate,
            gatherInputs: { [:] }
        )
        let action = SubmitAction(
            id: "submit4",
            data: AnyCodable("raw-string-data"),
            associatedInputs: AssociatedInputs.none
        )

        handler.handle(action)

        XCTAssertEqual(delegate.submitCalls.count, 1)
        XCTAssertEqual(delegate.submitCalls[0].data["data"] as? String, "raw-string-data")
    }

    // MARK: - Action.OpenUrl

    func testOpenUrlValidHttps() {
        let handler = OpenUrlActionHandler(delegate: delegate)
        let action = OpenUrlAction(id: "openurl1", url: "https://adaptivecards.io")

        handler.handle(action)

        XCTAssertEqual(delegate.openUrlCalls.count, 1)
        XCTAssertEqual(delegate.openUrlCalls[0].url.absoluteString, "https://adaptivecards.io")
        XCTAssertEqual(delegate.openUrlCalls[0].actionId, "openurl1")
    }

    func testOpenUrlValidMailto() {
        let handler = OpenUrlActionHandler(delegate: delegate)
        let action = OpenUrlAction(url: "mailto:user@example.com")

        handler.handle(action)

        XCTAssertEqual(delegate.openUrlCalls.count, 1)
    }

    func testOpenUrlValidTel() {
        let handler = OpenUrlActionHandler(delegate: delegate)
        let action = OpenUrlAction(url: "tel:+1234567890")

        handler.handle(action)

        XCTAssertEqual(delegate.openUrlCalls.count, 1)
    }

    func testOpenUrlBlockedJavascript() {
        let handler = OpenUrlActionHandler(delegate: delegate)
        let action = OpenUrlAction(url: "javascript:alert(1)")

        handler.handle(action)

        XCTAssertEqual(delegate.openUrlCalls.count, 0, "javascript: scheme should be blocked")
    }

    func testOpenUrlBlockedDataScheme() {
        let handler = OpenUrlActionHandler(delegate: delegate)
        let action = OpenUrlAction(url: "data:text/html,<h1>XSS</h1>")

        handler.handle(action)

        XCTAssertEqual(delegate.openUrlCalls.count, 0, "data: scheme should be blocked")
    }

    func testOpenUrlEmptyString() {
        let handler = OpenUrlActionHandler(delegate: delegate)
        let action = OpenUrlAction(url: "")

        handler.handle(action)

        XCTAssertEqual(delegate.openUrlCalls.count, 0, "Empty URL should not trigger delegate")
    }

    func testOpenUrlInvalidString() {
        let handler = OpenUrlActionHandler(delegate: delegate)
        let action = OpenUrlAction(url: "not a valid url")

        handler.handle(action)

        XCTAssertEqual(delegate.openUrlCalls.count, 0, "Invalid URL should not trigger delegate")
    }

    // MARK: - Action.Execute

    func testExecuteWithVerbAndData() {
        let inputs = ["field1": "val1"]
        let handler = ExecuteActionHandler(
            delegate: delegate,
            gatherInputs: { inputs as [String: Any] }
        )
        let action = ExecuteAction(
            id: "exec1",
            verb: "doSomething",
            data: AnyCodable(["action": "test"])
        )

        handler.handle(action)

        XCTAssertEqual(delegate.executeCalls.count, 1)
        let call = delegate.executeCalls[0]
        XCTAssertEqual(call.verb, "doSomething")
        XCTAssertEqual(call.data["field1"] as? String, "val1")
        XCTAssertEqual(call.data["action"] as? String, "test")
        XCTAssertEqual(call.actionId, "exec1")
    }

    func testExecuteWithNoVerb() {
        let handler = ExecuteActionHandler(
            delegate: delegate,
            gatherInputs: { [:] }
        )
        let action = ExecuteAction(id: "exec2")

        handler.handle(action)

        XCTAssertEqual(delegate.executeCalls.count, 1)
        XCTAssertNil(delegate.executeCalls[0].verb)
    }

    // MARK: - Action.ShowCard

    func testShowCardToggle() {
        var toggledCardIds: [String] = []
        let handler = ShowCardActionHandler(toggleCard: { id in
            toggledCardIds.append(id)
        })
        let action = ShowCardAction(
            id: "showcard1",
            card: AdaptiveCard(body: [.textBlock(TextBlock(text: "Nested"))])
        )

        handler.handle(action)

        XCTAssertEqual(toggledCardIds.count, 1)
        XCTAssertEqual(toggledCardIds[0], "showcard1")
    }

    func testShowCardWithNoId() {
        var toggledCardIds: [String] = []
        let handler = ShowCardActionHandler(toggleCard: { id in
            toggledCardIds.append(id)
        })
        let action = ShowCardAction(
            title: "Show Details",
            card: AdaptiveCard(body: [.textBlock(TextBlock(text: "Details"))])
        )

        handler.handle(action)

        XCTAssertEqual(toggledCardIds.count, 1)
        XCTAssertEqual(toggledCardIds[0], "showCard_Show Details")
    }

    // MARK: - Action.ToggleVisibility

    func testToggleVisibilityMultipleTargets() {
        var toggles: [(String, Bool?)] = []
        let handler = ToggleVisibilityHandler(toggleVisibility: { id, vis in
            toggles.append((id, vis))
        })
        let action = ToggleVisibilityAction(
            targetElements: [
                ToggleVisibilityAction.TargetElement(elementId: "elem1", isVisible: true),
                ToggleVisibilityAction.TargetElement(elementId: "elem2", isVisible: false),
                ToggleVisibilityAction.TargetElement(elementId: "elem3")
            ]
        )

        handler.handle(action)

        XCTAssertEqual(toggles.count, 3)
        XCTAssertEqual(toggles[0].0, "elem1")
        XCTAssertEqual(toggles[0].1, true)
        XCTAssertEqual(toggles[1].0, "elem2")
        XCTAssertEqual(toggles[1].1, false)
        XCTAssertEqual(toggles[2].0, "elem3")
        XCTAssertNil(toggles[2].1)
    }

    func testToggleVisibilityEmptyTargets() {
        var toggles: [(String, Bool?)] = []
        let handler = ToggleVisibilityHandler(toggleVisibility: { id, vis in
            toggles.append((id, vis))
        })
        let action = ToggleVisibilityAction(targetElements: [])

        handler.handle(action)

        XCTAssertEqual(toggles.count, 0, "Empty targetElements should be a no-op")
    }

    // MARK: - Action.Popover

    @MainActor
    func testPopoverWithNilContent() {
        // Should not crash
        let action = PopoverAction(title: "Test Popover")
        PopoverActionHandler.handle(action: action, delegate: delegate)
        // No assertion needed — test passes if no crash
    }

    @MainActor
    func testPopoverWithContent() {
        // Should not crash
        let action = PopoverAction(
            title: "Test Popover",
            content: .textBlock(TextBlock(text: "Popover body"))
        )
        PopoverActionHandler.handle(action: action, delegate: delegate)
    }

    // MARK: - Action.RunCommands

    @MainActor
    func testRunCommandsEmpty() {
        let action = RunCommandsAction(commands: [])
        RunCommandsActionHandler.handle(action: action, delegate: delegate)
        // No crash = pass
    }

    @MainActor
    func testRunCommandsWithCommands() {
        let action = RunCommandsAction(commands: [
            RunCommandsAction.Command(type: "navigate", id: "nav1")
        ])
        RunCommandsActionHandler.handle(action: action, delegate: delegate)
    }

    // MARK: - Action.OpenUrlDialog

    @MainActor
    func testOpenUrlDialogValidUrl() {
        let action = OpenUrlDialogAction(url: "https://example.com", dialogTitle: "Test")
        OpenUrlDialogActionHandler.handle(action: action, delegate: delegate)
        // No crash = pass
    }

    @MainActor
    func testOpenUrlDialogEmptyUrl() {
        let action = OpenUrlDialogAction(url: "")
        OpenUrlDialogActionHandler.handle(action: action, delegate: delegate)
        // No crash = pass (empty URL should not crash)
    }
}
