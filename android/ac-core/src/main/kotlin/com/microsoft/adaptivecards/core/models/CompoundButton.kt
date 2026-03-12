package com.microsoft.adaptivecards.core.models

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.Transient
import kotlinx.serialization.json.JsonElement

@Serializable
@SerialName("CompoundButton")
data class CompoundButton(
    @Transient override val type: String = "CompoundButton",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val title: String,
    val subtitle: String? = null,
    val icon: String? = null,
    val iconPosition: String? = null,
    val action: CardAction? = null,
    val style: String? = null
) : CardElement
