// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
#if canImport(SafariServices)
import SafariServices
#endif
import ACCore

@MainActor
public class OpenUrlDialogActionHandler {
    public static func handle(action: OpenUrlDialogAction, delegate: ActionDelegate?) {
        guard let url = URL(string: action.url) else { return }
        // TODO: Add appropriate delegate method for OpenUrlDialogAction
        print("OpenUrlDialogAction triggered: \(url)")
    }
}
