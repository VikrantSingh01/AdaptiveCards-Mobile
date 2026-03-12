package com.microsoft.adaptivecards.core.models

import kotlinx.serialization.KSerializer
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.Transient
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.descriptors.buildClassSerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import kotlinx.serialization.json.JsonDecoder
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

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

@Serializable(with = TargetElementSerializer::class)
data class TargetElement(
    val elementId: String,
    val isVisible: Boolean? = null
)

/**
 * Per the Adaptive Card spec, targetElements entries can be either:
 * - A string: just the element ID (e.g., "myElement")
 * - An object: { "elementId": "myElement", "isVisible": true }
 */
object TargetElementSerializer : KSerializer<TargetElement> {
    override val descriptor: SerialDescriptor = buildClassSerialDescriptor("TargetElement")

    override fun deserialize(decoder: Decoder): TargetElement {
        val jsonDecoder = decoder as JsonDecoder
        val element = jsonDecoder.decodeJsonElement()
        return when (element) {
            is JsonPrimitive -> TargetElement(elementId = element.content)
            else -> {
                val obj = element.jsonObject
                TargetElement(
                    elementId = obj["elementId"]?.jsonPrimitive?.content ?: "",
                    isVisible = obj["isVisible"]?.jsonPrimitive?.content?.toBooleanStrictOrNull()
                )
            }
        }
    }

    override fun serialize(encoder: Encoder, value: TargetElement) {
        val jsonEncoder = encoder as kotlinx.serialization.json.JsonEncoder
        if (value.isVisible == null) {
            jsonEncoder.encodeJsonElement(JsonPrimitive(value.elementId))
        } else {
            jsonEncoder.encodeJsonElement(
                kotlinx.serialization.json.buildJsonObject {
                    put("elementId", JsonPrimitive(value.elementId))
                    put("isVisible", JsonPrimitive(value.isVisible))
                }
            )
        }
    }
}

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
    val popoverBody: List<CardElement> = emptyList(),
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
