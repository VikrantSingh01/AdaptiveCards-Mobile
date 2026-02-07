import SwiftUI
import ACCore

@MainActor
public class RunCommandsActionHandler {
    public static func handle(action: RunCommandsAction, delegate: ActionDelegate?) {
        delegate?.didTriggerAction(action)
    }
}
