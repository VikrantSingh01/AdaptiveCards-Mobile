// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.core

/**
 * Performance guardrails to protect against pathological cards that could freeze the UI.
 * Part of [CardConfiguration] — the host can tune these per-card.
 */
data class PerformanceGuardrails(
    /** Maximum number of elements rendered per card (default: 200) */
    val maxElementCount: Int = 200,

    /** Maximum nesting depth for containers (default: 10) */
    val maxNestingDepth: Int = 10,

    /** Maximum number of images loaded concurrently per card (default: 6) */
    val maxConcurrentImageLoads: Int = 6,

    /** Timeout for image loading before showing placeholder (default: 10s) */
    val imageTimeoutSeconds: Double = 10.0,

    /** Parse timeout — abort and show fallbackText if exceeded (default: 2s) */
    val parseTimeoutSeconds: Double = 2.0
) {
    companion object {
        val Default = PerformanceGuardrails()
    }
}
