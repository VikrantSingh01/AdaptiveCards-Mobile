// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

import SwiftUI
import ACCore
import ACActions

// MARK: - View Modifiers for AdaptiveCardView

/// Environment key for card action handler
private struct CardActionHandlerKey: EnvironmentKey {
    static let defaultValue: ((CardActionEvent) -> Void)? = nil
}

/// Environment key for card lifecycle handler
private struct CardLifecycleHandlerKey: EnvironmentKey {
    static let defaultValue: ((CardLifecycleEvent) -> Void)? = nil
}

/// Environment key for CardHandle
private struct CardHandleKey: EnvironmentKey {
    static let defaultValue: CardHandle? = nil
}

extension EnvironmentValues {
    var cardActionHandler: ((CardActionEvent) -> Void)? {
        get { self[CardActionHandlerKey.self] }
        set { self[CardActionHandlerKey.self] = newValue }
    }

    var cardLifecycleHandler: ((CardLifecycleEvent) -> Void)? {
        get { self[CardLifecycleHandlerKey.self] }
        set { self[CardLifecycleHandlerKey.self] = newValue }
    }

    var cardHandle: CardHandle? {
        get { self[CardHandleKey.self] }
        set { self[CardHandleKey.self] = newValue }
    }
}

public extension View {
    /// Set a handler for card action events (Submit, OpenUrl, Execute).
    func onCardAction(_ handler: @escaping (CardActionEvent) -> Void) -> some View {
        environment(\.cardActionHandler, handler)
    }

    /// Set a handler for card lifecycle events (rendered, sizeChanged, inputChanged).
    func onCardLifecycle(_ handler: @escaping (CardLifecycleEvent) -> Void) -> some View {
        environment(\.cardLifecycleHandler, handler)
    }

    /// Attach a CardHandle for host-facing state access.
    func cardHandle(_ handle: CardHandle) -> some View {
        environment(\.cardHandle, handle)
    }
}
