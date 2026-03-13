// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

import Foundation
import CoreGraphics
import ACCore

/// Lifecycle events the host may observe via `onCardLifecycle`.
public enum CardLifecycleEvent {
    /// Card body has been rendered (layout complete, images may still be loading)
    case rendered

    /// Card's intrinsic content size changed (e.g., ShowCard expanded, image loaded)
    case sizeChanged(CGSize)

    /// An input value changed
    case inputChanged(id: String, value: Any)

    /// Parse failed (useful for the json: convenience init)
    case parseFailed(ParseError)

    /// Performance report — fires after the card is fully loaded
    case performanceReport(CardPerformanceMetrics)
}
