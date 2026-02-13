import SwiftUI
import ACCore

@MainActor
public class RunCommandsActionHandler {
    public static func handle(action: RunCommandsAction, delegate: ActionDelegate?) {
        // TODO: Add appropriate delegate method for RunCommandsAction
        print("RunCommandsAction triggered: \(action)")
    }
}
