import Foundation
import ACCore
import ACActions

/// Protocol for handling actions
public protocol ActionHandler {
    func handle(
        _ action: CardAction,
        delegate: ActionDelegate?,
        viewModel: CardViewModel
    )
}

/// Default action handler implementation
public class DefaultActionHandler: ActionHandler {
    public init() {}
    
    public func handle(
        _ action: CardAction,
        delegate: ActionDelegate?,
        viewModel: CardViewModel
    ) {
        switch action {
        case .submit(let submitAction):
            let handler = SubmitActionHandler(
                delegate: delegate,
                gatherInputs: { viewModel.gatherInputs() }
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
                gatherInputs: { viewModel.gatherInputs() }
            )
            handler.handle(executeAction)
            
        case .toggleVisibility(let toggleAction):
            let handler = ToggleVisibilityHandler(
                toggleVisibility: { elementId, isVisible in
                    viewModel.toggleVisibility(elementId: elementId, isVisible: isVisible)
                }
            )
            handler.handle(toggleAction)
        }
    }
}
