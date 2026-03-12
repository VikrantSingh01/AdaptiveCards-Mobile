// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
import ACCore

@MainActor
public class PopoverActionHandler {
    public static func handle(action: PopoverAction, delegate: ActionDelegate?) {
        // TODO: Add appropriate delegate method for PopoverAction
        print("PopoverAction triggered: \(action)")
    }
}
