// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

package com.microsoft.adaptivecards.core

import com.microsoft.adaptivecards.core.models.*

/**
 * Typed action events delivered to the host via `onAction`.
 * Only host-facing actions are included — ShowCard, ToggleVisibility, and Popover
 * are internal state transitions handled by the SDK.
 */
sealed interface CardActionEvent {
    /** User triggered Action.Submit. Input values are pre-validated and pre-gathered. */
    data class Submit(
        val action: ActionSubmit,
        val inputValues: Map<String, Any>
    ) : CardActionEvent

    /** User triggered Action.OpenUrl. URL is pre-validated against the allowlist. */
    data class OpenUrl(
        val action: ActionOpenUrl,
        val url: String
    ) : CardActionEvent

    /** User triggered Action.Execute. Input values are pre-validated and pre-gathered. */
    data class Execute(
        val action: ActionExecute,
        val inputValues: Map<String, Any>
    ) : CardActionEvent

    /** Card declares it needs a refresh. */
    data class RefreshRequested(
        val userIds: List<String>?
    ) : CardActionEvent

    /** Card requires authentication before an action can proceed. */
    data class AuthRequired(
        val scheme: String,
        val connectionName: String?
    ) : CardActionEvent
}
