package com.microsoft.adaptivecards.core.models

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonElement

@Serializable
sealed interface CardAction {
    val type: String
    val id: String?
    val title: String?
    val iconUrl: String?
    val style: ActionStyle?
    val tooltip: String?
    val isEnabled: Boolean
    val mode: ActionMode?
    val requires: Map<String, String>?
    val fallback: JsonElement?
}

@Serializable
@SerialName("Action.Submit")
data class ActionSubmit(
    override val type: String = "Action.Submit",
    override val id: String? = null,
    override val title: String? = null,
    override val iconUrl: String? = null,
    override val style: ActionStyle? = null,
    override val tooltip: String? = null,
    override val isEnabled: Boolean = true,
    override val mode: ActionMode? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val data: JsonElement? = null,
    val associatedInputs: AssociatedInputs? = null
) : CardAction

@Serializable
@SerialName("Action.OpenUrl")
data class ActionOpenUrl(
    override val type: String = "Action.OpenUrl",
    override val id: String? = null,
    override val title: String? = null,
    override val iconUrl: String? = null,
    override val style: ActionStyle? = null,
    override val tooltip: String? = null,
    override val isEnabled: Boolean = true,
    override val mode: ActionMode? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val url: String
) : CardAction

@Serializable
@SerialName("Action.ShowCard")
data class ActionShowCard(
    override val type: String = "Action.ShowCard",
    override val id: String? = null,
    override val title: String? = null,
    override val iconUrl: String? = null,
    override val style: ActionStyle? = null,
    override val tooltip: String? = null,
    override val isEnabled: Boolean = true,
    override val mode: ActionMode? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val card: AdaptiveCard
) : CardAction

@Serializable
@SerialName("Action.Execute")
data class ActionExecute(
    override val type: String = "Action.Execute",
    override val id: String? = null,
    override val title: String? = null,
    override val iconUrl: String? = null,
    override val style: ActionStyle? = null,
    override val tooltip: String? = null,
    override val isEnabled: Boolean = true,
    override val mode: ActionMode? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val verb: String? = null,
    val data: JsonElement? = null,
    val associatedInputs: AssociatedInputs? = null
) : CardAction

@Serializable
@SerialName("Action.ToggleVisibility")
data class ActionToggleVisibility(
    override val type: String = "Action.ToggleVisibility",
    override val id: String? = null,
    override val title: String? = null,
    override val iconUrl: String? = null,
    override val style: ActionStyle? = null,
    override val tooltip: String? = null,
    override val isEnabled: Boolean = true,
    override val mode: ActionMode? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val targetElements: List<TargetElement>
) : CardAction

@Serializable
data class TargetElement(
    val elementId: String,
    val isVisible: Boolean? = null
)
