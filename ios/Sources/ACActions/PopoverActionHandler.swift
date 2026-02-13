import SwiftUI
import ACCore

@MainActor
public class PopoverActionHandler {
    public static func handle(action: PopoverAction, delegate: ActionDelegate?) {
        // TODO: Add appropriate delegate method for PopoverAction
        print("PopoverAction triggered: \(action)")
    }
}
