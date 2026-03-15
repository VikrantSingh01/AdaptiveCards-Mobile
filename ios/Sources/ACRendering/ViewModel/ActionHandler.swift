// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import Foundation
import ACCore
import ACActions

/// Protocol for handling actions
public protocol ActionHandler {
    @MainActor
    func handle(
        _ action: CardAction,
        delegate: ActionDelegate?,
        viewModel: CardViewModel
    )
}

/// Default action handler implementation
public class DefaultActionHandler: ActionHandler {
    public init() {}

    @MainActor
    public func handle(
        _ action: CardAction,
        delegate: ActionDelegate?,
        viewModel: CardViewModel
    ) {
        switch action {
        case .submit(let submitAction):
            let handler = SubmitActionHandler(
                delegate: delegate,
                gatherInputs: { viewModel.gatherInputValues() }
            )
            handler.handle(submitAction)

        case .openUrl(let openUrlAction):
            let handler = OpenUrlActionHandler(delegate: delegate)
            handler.handle(openUrlAction)

        case .showCard(let showCardAction):
            let handler = ShowCardActionHandler(
                toggleCard: { cardId in viewModel.toggleShowCard(cardId: cardId) }
            )
            handler.handle(showCardAction)

        case .execute(let executeAction):
            let handler = ExecuteActionHandler(
                delegate: delegate,
                gatherInputs: { viewModel.gatherInputValues() }
            )
            handler.handle(executeAction)

        case .toggleVisibility(let toggleAction):
            let handler = ToggleVisibilityHandler(
                toggleVisibility: { elementId, isVisible in
                    viewModel.toggleVisibility(elementId: elementId, isVisible: isVisible)
                }
            )
            handler.handle(toggleAction)

        case .popover(let popoverAction):
            let actionId = popoverAction.id ?? "popover_\(popoverAction.title ?? UUID().uuidString)"
            viewModel.togglePopover(actionId: actionId)

        case .runCommands(let runCommandsAction):
            RunCommandsActionHandler.handle(action: runCommandsAction, delegate: delegate)

        case .openUrlDialog(let openUrlDialogAction):
            OpenUrlDialogActionHandler.handle(action: openUrlDialogAction, delegate: delegate)

        case .resetInputs(let resetAction):
            let targetIds = resetAction.targetInputIds ?? []
            for inputId in targetIds {
                viewModel.setInputValue(id: inputId, value: "")
            }

        case .unknown:
            // Silently ignore unknown action types
            break
        }
    }
}
