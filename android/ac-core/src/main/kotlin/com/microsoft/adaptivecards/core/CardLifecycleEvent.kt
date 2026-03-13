// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

package com.microsoft.adaptivecards.core

/**
 * Lifecycle events the host may observe via `onLifecycle`.
 */
sealed interface CardLifecycleEvent {
    /** Card body has been rendered (layout complete, images may still be loading) */
    data object Rendered : CardLifecycleEvent

    /** Card's intrinsic content size changed */
    data class SizeChanged(val width: Float, val height: Float) : CardLifecycleEvent

    /** An input value changed */
    data class InputChanged(val id: String, val value: Any) : CardLifecycleEvent

    /** Parse failed */
    data class ParseFailed(val error: ParseError) : CardLifecycleEvent

    /** Performance report — fires after the card is fully loaded */
    data class PerformanceReport(val metrics: CardPerformanceMetrics) : CardLifecycleEvent
}
