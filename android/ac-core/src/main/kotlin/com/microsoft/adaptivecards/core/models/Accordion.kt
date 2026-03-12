package com.microsoft.adaptivecards.core.models

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.Transient
import kotlinx.serialization.json.JsonElement

@Serializable
@SerialName("Accordion")
data class Accordion(
    @Transient override val type: String = "Accordion",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val panels: List<AccordionPanel>,
    val expandMode: ExpandMode = ExpandMode.SINGLE
) : CardElement

@Serializable
data class AccordionPanel(
    val title: String,
    val content: List<CardElement>,
    val isExpanded: Boolean? = null
)
