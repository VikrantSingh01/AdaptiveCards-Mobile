// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

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
