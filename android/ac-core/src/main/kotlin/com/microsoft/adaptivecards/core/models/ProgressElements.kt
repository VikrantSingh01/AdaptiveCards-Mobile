// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.core.models

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.Transient
import kotlinx.serialization.json.JsonElement

@Serializable
@SerialName("ProgressBar")
data class ProgressBar(
    @Transient override val type: String = "ProgressBar",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val value: Double = 0.0,
    val max: Double? = null,
    val label: String? = null,
    val color: String? = null
) : CardElement {
    /** Normalized progress fraction (0.0–1.0).
     * When max is explicitly set: value / max.
     * When max is null and value <= 1: treat as 0–1 fraction.
     * When max is null and value > 1: treat as 0–100 scale. */
    val normalizedValue: Double
        get() {
            val m = max
            if (m != null) {
                return if (m > 0) (value / m).coerceIn(0.0, 1.0) else 0.0
            }
            return if (value in 0.0..1.0) {
                value.coerceAtLeast(0.0)
            } else {
                (value / 100.0).coerceIn(0.0, 1.0)
            }
        }
}

@Serializable
@SerialName("ProgressRing")
data class ProgressRing(
    @Transient override val type: String = "ProgressRing",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val label: String? = null,
    val labelPosition: String? = null,
    val size: String? = null,
    val color: String? = null,
    val horizontalAlignment: HorizontalAlignment? = null
) : CardElement

@Serializable
@SerialName("Spinner")
data class Spinner(
    @Transient override val type: String = "Spinner",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val size: SpinnerSize? = null,
    val label: String? = null
) : CardElement
