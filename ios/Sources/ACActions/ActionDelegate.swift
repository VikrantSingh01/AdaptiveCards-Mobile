import Foundation
import ACCore

/// Protocol for handling action events from Adaptive Cards
public protocol ActionDelegate: AnyObject {
    /// Called when an Action.Submit is triggered
    func onSubmit(data: [String: Any], actionId: String?)

    /// Called when an Action.OpenUrl is triggered
    func onOpenUrl(url: URL, actionId: String?)

    /// Called when an Action.Execute is triggered
    func onExecute(verb: String?, data: [String: Any], actionId: String?)

    /// Called when an Action.ShowCard is triggered
    func onShowCard(actionId: String?, isExpanded: Bool)

    /// Called when an Action.ToggleVisibility is triggered
    func onToggleVisibility(targetElementIds: [String])
}

/// Default implementation providing empty handlers
public extension ActionDelegate {
    func onSubmit(data: [String: Any], actionId: String?) {
        print("Submit action triggered with data: \(data)")
    }

    func onOpenUrl(url: URL, actionId: String?) {
        print("OpenUrl action triggered with URL: \(url)")
    }

    func onExecute(verb: String?, data: [String: Any], actionId: String?) {
        print("Execute action triggered with verb: \(verb ?? "nil"), data: \(data)")
    }

    func onShowCard(actionId: String?, isExpanded: Bool) {
        // Default: no-op (card expansion handled internally by CardViewModel)
    }

    func onToggleVisibility(targetElementIds: [String]) {
        // Default: no-op (visibility toggling handled internally by CardViewModel)
    }
}
