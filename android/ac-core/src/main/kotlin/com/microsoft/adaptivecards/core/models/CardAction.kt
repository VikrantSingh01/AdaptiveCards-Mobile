package com.microsoft.adaptivecards.core.models

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.Transient
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
    @Transient override val type: String = "Action.Submit",
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
    @Transient override val type: String = "Action.OpenUrl",
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
    @Transient override val type: String = "Action.ShowCard",
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
    @Transient override val type: String = "Action.Execute",
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
    @Transient override val type: String = "Action.ToggleVisibility",
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

@Serializable
@SerialName("Action.Popover")
data class ActionPopover(
    @Transient override val type: String = "Action.Popover",
    override val id: String? = null,
    override val title: String? = null,
    override val iconUrl: String? = null,
    override val style: ActionStyle? = null,
    override val tooltip: String? = null,
    override val isEnabled: Boolean = true,
    override val mode: ActionMode? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val popoverTitle: String? = null,
    val popoverBody: List<CardElement>,
    val dismissBehavior: String? = null
) : CardAction

@Serializable
@SerialName("Action.RunCommands")
data class ActionRunCommands(
    @Transient override val type: String = "Action.RunCommands",
    override val id: String? = null,
    override val title: String? = null,
    override val iconUrl: String? = null,
    override val style: ActionStyle? = null,
    override val tooltip: String? = null,
    override val isEnabled: Boolean = true,
    override val mode: ActionMode? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val commands: List<Command>
) : CardAction

@Serializable
data class Command(
    val type: String,
    val id: String,
    val data: JsonElement? = null
)

@Serializable
@SerialName("Action.OpenUrlDialog")
data class ActionOpenUrlDialog(
    @Transient override val type: String = "Action.OpenUrlDialog",
    override val id: String? = null,
    override val title: String? = null,
    override val iconUrl: String? = null,
    override val style: ActionStyle? = null,
    override val tooltip: String? = null,
    override val isEnabled: Boolean = true,
    override val mode: ActionMode? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val url: String,
    val dialogTitle: String? = null
) : CardAction
