import SwiftUI
import ACCore

@MainActor
public class PopoverActionHandler {
    public static func handle(action: PopoverAction, delegate: ActionDelegate?) {
        delegate?.didTriggerAction(action)
    }
}
