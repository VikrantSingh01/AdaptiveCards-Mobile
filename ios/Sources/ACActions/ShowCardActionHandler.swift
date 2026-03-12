import Foundation
import ACCore

public class ShowCardActionHandler {
    private let toggleCard: (String) -> Void

    public init(toggleCard: @escaping (String) -> Void) {
        self.toggleCard = toggleCard
    }

    public func handle(_ action: ShowCardAction) {
        // Use action.id if available, otherwise generate a stable fallback
        // matching the CardAction.Identifiable.id pattern
        let cardId = action.id ?? "showCard_\(action.title ?? "unknown")"
        toggleCard(cardId)
    }
}
