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
import kotlinx.serialization.json.JsonEncoder
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

/**
 * Icon descriptor that can be decoded from either a plain string (`"Calendar"`)
 * or an object (`{"name": "Calendar", "style": "Regular"}`).
 */
@Serializable(with = IconDescriptorSerializer::class)
data class IconDescriptor(
    val name: String,
    val style: String? = null,
    val size: String? = null
) {
    /** Convenience: the icon name string regardless of how it was encoded */
    override fun toString(): String = name
}

object IconDescriptorSerializer : KSerializer<IconDescriptor> {
    override val descriptor: SerialDescriptor = buildClassSerialDescriptor("IconDescriptor")

    override fun deserialize(decoder: Decoder): IconDescriptor {
        val jsonDecoder = decoder as? JsonDecoder
            ?: return IconDescriptor(name = decoder.decodeString())
        return when (val element = jsonDecoder.decodeJsonElement()) {
            is JsonPrimitive -> IconDescriptor(name = element.content)
            else -> {
                val obj = element.jsonObject
                IconDescriptor(
                    name = obj["name"]?.jsonPrimitive?.content ?: "",
                    style = obj["style"]?.jsonPrimitive?.content,
                    size = obj["size"]?.jsonPrimitive?.content
                )
            }
        }
    }

    override fun serialize(encoder: Encoder, value: IconDescriptor) {
        val jsonEncoder = encoder as? JsonEncoder ?: return
        if (value.style == null && value.size == null) {
            jsonEncoder.encodeJsonElement(JsonPrimitive(value.name))
        } else {
            val obj = buildMap<String, JsonElement> {
                put("name", JsonPrimitive(value.name))
                value.style?.let { put("style", JsonPrimitive(it)) }
                value.size?.let { put("size", JsonPrimitive(it)) }
            }
            jsonEncoder.encodeJsonElement(kotlinx.serialization.json.JsonObject(obj))
        }
    }
}

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
    val description: String? = null,
    val icon: IconDescriptor? = null,
    val iconPosition: String? = null,
    val selectAction: CardAction? = null,
    val badge: String? = null,
    val style: String? = null
) : CardElement {
    /** Convenience accessor: the icon name as a string regardless of how it was encoded */
    val iconName: String? get() = icon?.name
}
