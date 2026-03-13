// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.core.parsing

import com.microsoft.adaptivecards.core.models.*
import kotlinx.serialization.DeserializationStrategy
import kotlinx.serialization.InternalSerializationApi
import kotlinx.serialization.KSerializer
import kotlinx.serialization.serializer
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.descriptors.buildClassSerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonDecoder
import kotlinx.serialization.json.JsonEncoder
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

/**
 * Custom polymorphic serializer for CardElement.
 *
 * Implements [KSerializer] directly to control both serialization and deserialization.
 * During serialization, injects the "type" discriminator field that @Transient suppresses.
 * During deserialization, routes to the correct concrete serializer based on the "type" JSON field,
 * falling back to [UnknownElement] for unrecognised types.
 *
 * Performance optimisations over the original implementation:
 * - **HashMap lookup** for O(1) type→serializer dispatch (vs linear when-expression)
 * - **Image handling isolated** to a dedicated [ImageDeserializer] — avoids branching on
 *   every element in the hot path
 */
@OptIn(InternalSerializationApi::class)
object CardElementSerializer : KSerializer<CardElement> {
    override val descriptor: SerialDescriptor = buildClassSerialDescriptor("CardElement")

    /** Pre-built map from JSON "type" values to their concrete deserializers. O(1) lookup. */
    private val deserializerMap: Map<String, DeserializationStrategy<out CardElement>> = buildMap {
        put("TextBlock", TextBlock.serializer())
        put("Image", ImageDeserializer)
        put("Container", Container.serializer())
        put("ColumnSet", ColumnSet.serializer())
        put("FactSet", FactSet.serializer())
        put("ImageSet", ImageSet.serializer())
        put("ActionSet", ActionSet.serializer())
        put("Media", Media.serializer())
        put("RichTextBlock", RichTextBlock.serializer())
        put("Table", Table.serializer())
        put("Icon", Icon.serializer())
        put("Badge", Badge.serializer())
        put("Input.Text", InputText.serializer())
        put("Input.Number", InputNumber.serializer())
        put("Input.Date", InputDate.serializer())
        put("Input.Time", InputTime.serializer())
        put("Input.Toggle", InputToggle.serializer())
        put("Input.ChoiceSet", InputChoiceSet.serializer())
        put("Carousel", Carousel.serializer())
        put("Accordion", Accordion.serializer())
        put("CodeBlock", CodeBlock.serializer())
        put("Rating", RatingDisplay.serializer())
        put("Input.Rating", RatingInput.serializer())
        put("ProgressBar", ProgressBar.serializer())
        put("Spinner", Spinner.serializer())
        put("TabSet", TabSet.serializer())
        put("List", ListElement.serializer())
        put("CompoundButton", CompoundButton.serializer())
        put("DonutChart", DonutChart.serializer())
        put("BarChart", BarChart.serializer())
        put("LineChart", LineChart.serializer())
        put("PieChart", PieChart.serializer())
        put("Input.DataGrid", InputDataGrid.serializer())
    }

    override fun serialize(encoder: Encoder, value: CardElement) {
        val jsonEncoder = encoder as? JsonEncoder ?: return
        @Suppress("UNCHECKED_CAST")
        val concreteSerializer = value::class.serializer() as KSerializer<CardElement>
        val jsonElement = jsonEncoder.json.encodeToJsonElement(concreteSerializer, value)
        val jsonObject = jsonElement.jsonObject.toMutableMap()
        jsonObject["type"] = JsonPrimitive(value.type)
        jsonEncoder.encodeJsonElement(kotlinx.serialization.json.JsonObject(jsonObject))
    }

    override fun deserialize(decoder: Decoder): CardElement {
        val jsonDecoder = decoder as? JsonDecoder
            ?: throw IllegalStateException("CardElementSerializer requires JsonDecoder")
        val element = jsonDecoder.decodeJsonElement()
        val type = element.jsonObject["type"]?.jsonPrimitive?.content

        if (type.isNullOrEmpty()) {
            return jsonDecoder.json.decodeFromJsonElement(UnknownElement.serializer(), element)
        }

        val deserializer = deserializerMap[type]
        return if (deserializer != null) {
            jsonDecoder.json.decodeFromJsonElement(deserializer, element)
        } else {
            val unknown = jsonDecoder.json.decodeFromJsonElement(UnknownElement.serializer(), element)
            unknown.copy(unknownType = type)
        }
    }
}

/**
 * Dedicated deserializer for Image elements, isolated from the main dispatch path.
 *
 * Handles two quirks that require pre-processing:
 * 1. `themedUrls` may arrive as a JSON array (invalid) instead of a JSON object — strip it.
 * 2. `height` may contain pixel values like "32px" that the BlockElementHeight enum can't
 *    represent — extract into the transient `pixelHeight` field.
 */
private object ImageDeserializer : DeserializationStrategy<Image> {
    private val delegate = Image.serializer()
    override val descriptor: SerialDescriptor = delegate.descriptor

    override fun deserialize(decoder: Decoder): Image {
        val jsonDecoder = decoder as? JsonDecoder
            ?: return delegate.deserialize(decoder)
        val element = jsonDecoder.decodeJsonElement()
        val obj = element.jsonObject

        // Sanitise: strip themedUrls if it arrived as an array instead of an object
        val sanitised = run {
            val themed = obj["themedUrls"]
            if (themed != null && themed is JsonArray) {
                JsonObject(obj.filterKeys { it != "themedUrls" })
            } else {
                element
            }
        }

        val image = jsonDecoder.json.decodeFromJsonElement(delegate, sanitised)

        // Extract pixel height (e.g. "32px") which the BlockElementHeight enum cannot represent
        val rawHeight = obj["height"]?.jsonPrimitive?.content
        return if (rawHeight != null && rawHeight.contains("px", ignoreCase = true)) {
            image.copy(pixelHeight = rawHeight)
        } else {
            image
        }
    }
}

/**
 * Handles both plain string shorthand and full TextRun object in RichTextBlock inlines.
 * Per Adaptive Cards spec, inlines can contain plain strings as shorthand for
 * `{"type": "TextRun", "text": "<string>"}`.
 *
 * Also used as the serializer for TextRun when it appears standalone (e.g., in
 * InlineElementSerializer delegation).
 */
object TextRunSerializer : KSerializer<TextRun> {
    override val descriptor: SerialDescriptor = buildClassSerialDescriptor("TextRun")

    override fun deserialize(decoder: Decoder): TextRun {
        val jsonDecoder = decoder as? JsonDecoder
            ?: return TextRun(text = decoder.decodeString())
        return when (val element = jsonDecoder.decodeJsonElement()) {
            is JsonPrimitive -> TextRun(text = element.content)
            else -> decodeTextRunFromJsonObject(element.jsonObject, jsonDecoder)
        }
    }

    internal fun decodeTextRunFromJsonObject(obj: JsonObject, jsonDecoder: JsonDecoder): TextRun {
        return TextRun(
            type = obj["type"]?.jsonPrimitive?.content ?: "TextRun",
            text = obj["text"]?.jsonPrimitive?.content ?: "",
            color = obj["color"]?.jsonPrimitive?.content
                ?.let { runCatching { Color.valueOf(it) }.getOrNull() },
            fontType = obj["fontType"]?.jsonPrimitive?.content
                ?.let { runCatching { FontType.valueOf(it) }.getOrNull() },
            size = obj["size"]?.jsonPrimitive?.content
                ?.let { runCatching { FontSize.valueOf(it) }.getOrNull() },
            weight = obj["weight"]?.jsonPrimitive?.content
                ?.let { runCatching { FontWeight.valueOf(it) }.getOrNull() },
            isSubtle = obj["isSubtle"]?.jsonPrimitive?.content?.toBooleanStrictOrNull(),
            italic = obj["italic"]?.jsonPrimitive?.content?.toBooleanStrictOrNull(),
            strikethrough = obj["strikethrough"]?.jsonPrimitive?.content?.toBooleanStrictOrNull(),
            underline = obj["underline"]?.jsonPrimitive?.content?.toBooleanStrictOrNull(),
            highlight = obj["highlight"]?.jsonPrimitive?.content?.toBooleanStrictOrNull(),
            selectAction = obj["selectAction"]?.let {
                runCatching {
                    jsonDecoder.json.decodeFromJsonElement(CardAction.serializer(), it)
                }.getOrNull()
            }
        )
    }

    override fun serialize(encoder: Encoder, value: TextRun) {
        val jsonEncoder = encoder as? JsonEncoder ?: return
        val obj = buildMap<String, kotlinx.serialization.json.JsonElement> {
            put("type", JsonPrimitive(value.type))
            put("text", JsonPrimitive(value.text))
            value.color?.let { put("color", JsonPrimitive(it.name)) }
            value.fontType?.let { put("fontType", JsonPrimitive(it.name)) }
            value.size?.let { put("size", JsonPrimitive(it.name)) }
            value.weight?.let { put("weight", JsonPrimitive(it.name)) }
            value.isSubtle?.let { put("isSubtle", JsonPrimitive(it)) }
            value.italic?.let { put("italic", JsonPrimitive(it)) }
            value.strikethrough?.let { put("strikethrough", JsonPrimitive(it)) }
            value.underline?.let { put("underline", JsonPrimitive(it)) }
            value.highlight?.let { put("highlight", JsonPrimitive(it)) }
            value.selectAction?.let {
                put("selectAction", jsonEncoder.json.encodeToJsonElement(CardAction.serializer(), it))
            }
        }
        jsonEncoder.encodeJsonElement(JsonObject(obj))
    }
}

/**
 * Polymorphic serializer for InlineElement within RichTextBlock inlines.
 * Routes to TextRun or CitationRun based on the "type" field.
 * Handles plain string shorthand (maps to TextRun).
 */
object InlineElementSerializer : KSerializer<InlineElement> {
    override val descriptor: SerialDescriptor = buildClassSerialDescriptor("InlineElement")

    override fun deserialize(decoder: Decoder): InlineElement {
        val jsonDecoder = decoder as? JsonDecoder
            ?: return TextRun(text = decoder.decodeString())
        return when (val element = jsonDecoder.decodeJsonElement()) {
            is JsonPrimitive -> TextRun(text = element.content)
            else -> {
                val obj = element.jsonObject
                val type = obj["type"]?.jsonPrimitive?.content
                when (type) {
                    "CitationRun" -> CitationRun(
                        text = obj["text"]?.jsonPrimitive?.content ?: "",
                        referenceIndex = obj["referenceIndex"]?.jsonPrimitive?.content?.toIntOrNull() ?: 0
                    )
                    else -> TextRunSerializer.decodeTextRunFromJsonObject(obj, jsonDecoder)
                }
            }
        }
    }

    override fun serialize(encoder: Encoder, value: InlineElement) {
        val jsonEncoder = encoder as? JsonEncoder ?: return
        when (value) {
            is TextRun -> TextRunSerializer.serialize(encoder, value)
            is CitationRun -> {
                val obj = buildMap<String, kotlinx.serialization.json.JsonElement> {
                    put("type", JsonPrimitive(value.type))
                    put("text", JsonPrimitive(value.text))
                    put("referenceIndex", JsonPrimitive(value.referenceIndex))
                }
                jsonEncoder.encodeJsonElement(JsonObject(obj))
            }
        }
    }
}

/**
 * Handles both string shorthand (`"backgroundImage": "url"`) and object format
 * (`"backgroundImage": { "url": "...", "fillMode": "..." }`).
 */
object BackgroundImageSerializer : KSerializer<BackgroundImage> {
    override val descriptor: SerialDescriptor =
        buildClassSerialDescriptor("BackgroundImage")

    override fun deserialize(decoder: Decoder): BackgroundImage {
        val jsonDecoder = decoder as? JsonDecoder
            ?: return BackgroundImage(url = decoder.decodeString())
        return when (val element = jsonDecoder.decodeJsonElement()) {
            is JsonPrimitive -> BackgroundImage(url = element.content)
            else -> {
                val obj = element.jsonObject
                BackgroundImage(
                    url = obj["url"]?.jsonPrimitive?.content ?: "",
                    fillMode = obj["fillMode"]?.jsonPrimitive?.content,
                    horizontalAlignment = obj["horizontalAlignment"]?.jsonPrimitive?.content
                        ?.let { runCatching { HorizontalAlignment.valueOf(it) }.getOrNull() },
                    verticalAlignment = obj["verticalAlignment"]?.jsonPrimitive?.content
                        ?.let { runCatching { VerticalAlignment.valueOf(it) }.getOrNull() }
                )
            }
        }
    }

    override fun serialize(encoder: Encoder, value: BackgroundImage) {
        val jsonEncoder = encoder as? JsonEncoder ?: return
        val obj = buildMap {
            put("url", JsonPrimitive(value.url))
            value.fillMode?.let { put("fillMode", JsonPrimitive(it)) }
        }
        jsonEncoder.encodeJsonElement(
            kotlinx.serialization.json.JsonObject(obj)
        )
    }
}
