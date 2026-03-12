package com.microsoft.adaptivecards.core.models

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.Transient
import kotlinx.serialization.json.JsonElement

@Serializable
@SerialName("Carousel")
data class Carousel(
    @Transient override val type: String = "Carousel",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val pages: List<CarouselPage>,
    val timer: Int? = null,
    val initialPage: Int? = null
) : CardElement

@Serializable
data class CarouselPage(
    val items: List<CardElement>,
    val selectAction: CardAction? = null
)
