package com.microsoft.adaptivecards.core.parsing

import com.microsoft.adaptivecards.core.models.*
import kotlinx.serialization.InternalSerializationApi
import kotlinx.serialization.KSerializer
import kotlinx.serialization.serializer
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.descriptors.buildClassSerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import kotlinx.serialization.json.JsonDecoder
import kotlinx.serialization.json.JsonEncoder
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
        val jsonDecoder = decoder as JsonDecoder
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

        return if (serializer != null) {
            jsonDecoder.json.decodeFromJsonElement(serializer, element)
        } else {
            val unknown = jsonDecoder.json.decodeFromJsonElement(UnknownElement.serializer(), element)
            unknown.copy(unknownType = type)
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
