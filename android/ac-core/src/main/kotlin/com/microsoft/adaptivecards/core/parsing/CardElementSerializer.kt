package com.microsoft.adaptivecards.core.parsing

import com.microsoft.adaptivecards.core.models.*
import kotlinx.serialization.DeserializationStrategy
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.json.JsonContentPolymorphicSerializer
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

/**
 * Custom polymorphic serializer for CardElement that captures unknown types
 */
object CardElementSerializer : JsonContentPolymorphicSerializer<CardElement>(CardElement::class) {
    override fun selectDeserializer(element: JsonElement): DeserializationStrategy<CardElement> {
        val type = element.jsonObject["type"]?.jsonPrimitive?.content
        
        return when (type) {
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
            "RatingDisplay" -> RatingDisplay.serializer()
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
            else -> UnknownElementWithTypeSerializer(type)
        }
    }
}

/**
 * Custom deserializer that creates UnknownElement with the captured type
 */
class UnknownElementWithTypeSerializer(private val originalType: String?) : 
    DeserializationStrategy<UnknownElement> {
    override val descriptor: SerialDescriptor = UnknownElement.serializer().descriptor

    override fun deserialize(decoder: Decoder): UnknownElement {
        val unknownElement = UnknownElement.serializer().deserialize(decoder)
        return unknownElement.copy(unknownType = originalType)
    }
}
