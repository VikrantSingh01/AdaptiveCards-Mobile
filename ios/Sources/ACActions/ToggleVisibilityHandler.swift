import Foundation
import ACCore

public class ToggleVisibilityHandler {
    private let toggleVisibility: (String, Bool?) -> Void

    public init(toggleVisibility: @escaping (String, Bool?) -> Void) {
        self.toggleVisibility = toggleVisibility
    }

    public func handle(_ action: ToggleVisibilityAction) {
        for target in action.targetElements {
            toggleVisibility(target.elementId, target.isVisible)
        }
    }
}
