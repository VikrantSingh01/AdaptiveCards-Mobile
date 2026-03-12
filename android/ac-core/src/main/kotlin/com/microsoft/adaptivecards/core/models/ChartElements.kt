package com.microsoft.adaptivecards.core.models

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.Transient
import kotlinx.serialization.json.JsonElement

@Serializable
data class ChartDataPoint(
    val label: String,
    val value: Double,
    val color: String? = null
)

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
