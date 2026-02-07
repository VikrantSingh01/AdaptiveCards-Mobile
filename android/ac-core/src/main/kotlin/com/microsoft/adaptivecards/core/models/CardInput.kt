package com.microsoft.adaptivecards.core.models

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonElement

@Serializable
sealed interface CardInput : CardElement {
    val label: String?
    val isRequired: Boolean
    val errorMessage: String?
}

@Serializable
@SerialName("Input.Text")
data class InputText(
    override val type: String = "Input.Text",
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
    val placeholder: String? = null,
    val value: String? = null,
    val isMultiline: Boolean? = null,
    val maxLength: Int? = null,
    val style: TextInputStyle? = null,
    val inlineAction: CardAction? = null,
    val regex: String? = null
) : CardInput

@Serializable
@SerialName("Input.Number")
data class InputNumber(
    override val type: String = "Input.Number",
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
    val placeholder: String? = null,
    val value: Double? = null,
    val min: Double? = null,
    val max: Double? = null
) : CardInput

@Serializable
@SerialName("Input.Date")
data class InputDate(
    override val type: String = "Input.Date",
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
    val placeholder: String? = null,
    val value: String? = null,
    val min: String? = null,
    val max: String? = null
) : CardInput

@Serializable
@SerialName("Input.Time")
data class InputTime(
    override val type: String = "Input.Time",
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
    val placeholder: String? = null,
    val value: String? = null,
    val min: String? = null,
    val max: String? = null
) : CardInput

@Serializable
@SerialName("Input.Toggle")
data class InputToggle(
    override val type: String = "Input.Toggle",
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
    val title: String,
    val value: String? = null,
    val valueOn: String? = null,
    val valueOff: String? = null,
    val wrap: Boolean? = null
) : CardInput

@Serializable
@SerialName("Input.ChoiceSet")
data class InputChoiceSet(
    override val type: String = "Input.ChoiceSet",
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
    val choices: List<Choice>,
    val style: ChoiceInputStyle? = null,
    val value: String? = null,
    val isMultiSelect: Boolean? = null,
    val placeholder: String? = null,
    val wrap: Boolean? = null
) : CardInput

@Serializable
data class Choice(
    val title: String,
    val value: String
)
