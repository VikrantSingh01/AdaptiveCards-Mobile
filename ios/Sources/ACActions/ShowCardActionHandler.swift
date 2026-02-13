import Foundation
import ACCore

public class ShowCardActionHandler {
    private let toggleCard: (String) -> Void

    public init(toggleCard: @escaping (String) -> Void) {
        self.toggleCard = toggleCard
    }

    public func handle(_ action: ShowCardAction) {
        // Generate a unique ID for this show card action
        let cardId = action.id ?? UUID().uuidString
        toggleCard(cardId)
    }
}
