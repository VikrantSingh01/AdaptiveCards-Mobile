package com.microsoft.adaptivecards.core.models

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.Transient
import kotlinx.serialization.json.JsonElement

@Serializable
@SerialName("Rating")
data class RatingDisplay(
    @Transient override val type: String = "Rating",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val value: Double,
    val count: Int? = null,
    val max: Int? = null,
    val size: RatingSize? = null
) : CardElement

@Serializable
@SerialName("Input.Rating")
data class RatingInput(
    @Transient override val type: String = "Input.Rating",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    override val label: String? = null,
    override val isRequired: Boolean = false,
    override val errorMessage: String? = null,
    val max: Int? = null,
    val value: Double? = null
) : CardInput
