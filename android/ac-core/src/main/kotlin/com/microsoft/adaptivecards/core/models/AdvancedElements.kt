package com.microsoft.adaptivecards.core.models

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonElement

// Carousel Element
@Serializable
@SerialName("Carousel")
data class Carousel(
    override val type: String = "Carousel",
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

// Accordion Element
@Serializable
@SerialName("Accordion")
data class Accordion(
    override val type: String = "Accordion",
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

// CodeBlock Element
@Serializable
@SerialName("CodeBlock")
data class CodeBlock(
    override val type: String = "CodeBlock",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val code: String,
    val language: String? = null,
    val startLineNumber: Int? = null,
    val wrap: Boolean? = null
) : CardElement

// Rating Display Element
@Serializable
@SerialName("Rating")
data class RatingDisplay(
    override val type: String = "Rating",
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

// Rating Input Element
@Serializable
@SerialName("Input.Rating")
data class RatingInput(
    override val type: String = "Input.Rating",
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

// ProgressBar Element
@Serializable
@SerialName("ProgressBar")
data class ProgressBar(
    override val type: String = "ProgressBar",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val value: Double,
    val label: String? = null,
    val color: String? = null
) : CardElement

// Spinner Element
@Serializable
@SerialName("Spinner")
data class Spinner(
    override val type: String = "Spinner",
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

// TabSet Element
@Serializable
@SerialName("TabSet")
data class TabSet(
    override val type: String = "TabSet",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val tabs: List<Tab>,
    val selectedTabId: String? = null
) : CardElement

@Serializable
data class Tab(
    val id: String,
    val title: String,
    val icon: String? = null,
    val items: List<CardElement>
)

// List Element
@Serializable
@SerialName("List")
data class ListElement(
    override val type: String = "List",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val items: List<CardElement>,
    val maxHeight: String? = null,
    val style: String? = null
) : CardElement

// CompoundButton Element
@Serializable
@SerialName("CompoundButton")
data class CompoundButton(
    override val type: String = "CompoundButton",
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

