// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

import Foundation
import ACCore

/// Typed action events delivered to the host via `onCardAction`.
/// Only host-facing actions are included — ShowCard, ToggleVisibility, and Popover
/// are internal state transitions handled by the SDK.
public enum CardActionEvent {
    /// User triggered Action.Submit. Input values are pre-validated and pre-gathered.
    case submit(action: SubmitAction, inputValues: [String: Any])

    /// User triggered Action.OpenUrl. URL is pre-validated against the allowlist.
    case openUrl(action: OpenUrlAction, url: URL)

    /// User triggered Action.Execute. Input values are pre-validated and pre-gathered.
    case execute(action: ExecuteAction, inputValues: [String: Any])

    /// Card declares it needs a refresh.
    case refreshRequested(userIds: [String]?)

    /// Card requires authentication before an action can proceed.
    case authRequired(scheme: String, connectionName: String?)
}
