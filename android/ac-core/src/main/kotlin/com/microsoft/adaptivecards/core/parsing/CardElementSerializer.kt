package com.microsoft.adaptivecards.core.parsing

import com.microsoft.adaptivecards.core.models.*
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
 */
@OptIn(InternalSerializationApi::class)
object CardElementSerializer : KSerializer<CardElement> {
    override val descriptor: SerialDescriptor = buildClassSerialDescriptor("CardElement")

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

        val serializer: KSerializer<out CardElement>? = when (type) {
            "TextBlock" -> TextBlock.serializer()
            "Image" -> Image.serializer()
            "Container" -> Container.serializer()
            "ColumnSet" -> ColumnSet.serializer()
            "FactSet" -> FactSet.serializer()
            "ImageSet" -> ImageSet.serializer()
            "ActionSet" -> ActionSet.serializer()
            "Media" -> Media.serializer()
            "RichTextBlock" -> RichTextBlock.serializer()
            "Table" -> Table.serializer()
            "Icon" -> Icon.serializer()
            "Badge" -> Badge.serializer()
            "Input.Text" -> InputText.serializer()
            "Input.Number" -> InputNumber.serializer()
            "Input.Date" -> InputDate.serializer()
            "Input.Time" -> InputTime.serializer()
            "Input.Toggle" -> InputToggle.serializer()
            "Input.ChoiceSet" -> InputChoiceSet.serializer()
            "Carousel" -> Carousel.serializer()
            "Accordion" -> Accordion.serializer()
            "CodeBlock" -> CodeBlock.serializer()
            "Rating" -> RatingDisplay.serializer()
            "Input.Rating" -> RatingInput.serializer()
            "ProgressBar" -> ProgressBar.serializer()
            "Spinner" -> Spinner.serializer()
            "TabSet" -> TabSet.serializer()
            "List" -> ListElement.serializer()
            "CompoundButton" -> CompoundButton.serializer()
            "DonutChart" -> DonutChart.serializer()
            "BarChart" -> BarChart.serializer()
            "LineChart" -> LineChart.serializer()
            "PieChart" -> PieChart.serializer()
            "Input.DataGrid" -> InputDataGrid.serializer()
            else -> null
        }

        // Pre-process: sanitise Image elements before deserialization.
        // themedUrls is expected as a JSON object (Map) but some cards send a JSON array — strip it.
        val sanitisedElement = if (serializer != null && type == "Image") {
            val obj = element.jsonObject
            val themed = obj["themedUrls"]
            if (themed != null && themed is JsonArray) {
                JsonObject(obj.filterKeys { it != "themedUrls" })
            } else {
                element
            }
        } else {
            element
        }

        return if (serializer != null) {
            val decoded = jsonDecoder.json.decodeFromJsonElement(serializer, sanitisedElement)
            // For Image elements, extract pixel height (e.g. "32px") which the base
            // BlockElementHeight enum cannot represent
            if (decoded is Image) {
                val rawHeight = sanitisedElement.jsonObject["height"]?.jsonPrimitive?.content
                if (rawHeight != null && rawHeight.contains("px", ignoreCase = true)) {
                    decoded.copy(pixelHeight = rawHeight)
                } else {
                    decoded
                }
            } else {
                decoded
            }
        } else {
            val unknown = jsonDecoder.json.decodeFromJsonElement(UnknownElement.serializer(), element)
            unknown.copy(unknownType = type)
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
