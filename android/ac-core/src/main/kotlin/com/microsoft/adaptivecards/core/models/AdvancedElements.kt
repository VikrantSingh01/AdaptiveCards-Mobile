package com.microsoft.adaptivecards.core.models

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.Transient
import kotlinx.serialization.json.JsonElement

// Carousel Element
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

// Accordion Element
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

// CodeBlock Element
@Serializable
@SerialName("CodeBlock")
data class CodeBlock(
    @Transient override val type: String = "CodeBlock",
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

// Rating Input Element
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

// ProgressBar Element
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
    val value: Double,
    val label: String? = null,
    val color: String? = null
) : CardElement

// Spinner Element
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

// TabSet Element
@Serializable
@SerialName("TabSet")
data class TabSet(
    @Transient override val type: String = "TabSet",
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
    @Transient override val type: String = "List",
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

// Chart Data Point
@Serializable
data class ChartDataPoint(
    val label: String,
    val value: Double,
    val color: String? = null
)

// DonutChart Element
@Serializable
@SerialName("DonutChart")
data class DonutChart(
    @Transient override val type: String = "DonutChart",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val title: String? = null,
    val data: List<ChartDataPoint>,
    val colors: List<String>? = null,
    val size: String? = null,
    val showLegend: Boolean? = null,
    val innerRadiusRatio: Double? = null
) : CardElement

// BarChart Element
@Serializable
@SerialName("BarChart")
data class BarChart(
    @Transient override val type: String = "BarChart",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val title: String? = null,
    val data: List<ChartDataPoint>,
    val colors: List<String>? = null,
    val size: String? = null,
    val showLegend: Boolean? = null,
    val orientation: String? = null,
    val showValues: Boolean? = null
) : CardElement

// LineChart Element
@Serializable
@SerialName("LineChart")
data class LineChart(
    @Transient override val type: String = "LineChart",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val title: String? = null,
    val data: List<ChartDataPoint>,
    val colors: List<String>? = null,
    val size: String? = null,
    val showLegend: Boolean? = null,
    val showDataPoints: Boolean? = null,
    val smooth: Boolean? = null
) : CardElement

// PieChart Element
@Serializable
@SerialName("PieChart")
data class PieChart(
    @Transient override val type: String = "PieChart",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val title: String? = null,
    val data: List<ChartDataPoint>,
    val colors: List<String>? = null,
    val size: String? = null,
    val showLegend: Boolean? = null,
    val showPercentages: Boolean? = null
) : CardElement


