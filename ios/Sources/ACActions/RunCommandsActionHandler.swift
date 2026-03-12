// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
import ACCore

@MainActor
public class RunCommandsActionHandler {
    public static func handle(action: RunCommandsAction, delegate: ActionDelegate?) {
        // TODO: Add appropriate delegate method for RunCommandsAction
        print("RunCommandsAction triggered: \(action)")
    }
}
