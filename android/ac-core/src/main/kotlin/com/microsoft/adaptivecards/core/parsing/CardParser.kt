package com.microsoft.adaptivecards.core.parsing

import com.microsoft.adaptivecards.core.models.*
import kotlinx.serialization.json.Json
import kotlinx.serialization.modules.SerializersModule
import kotlinx.serialization.modules.polymorphic
import kotlinx.serialization.modules.subclass

object CardParser {
    private val json = Json {
        classDiscriminator = "type"
        ignoreUnknownKeys = true
        isLenient = true
        prettyPrint = true
        serializersModule = SerializersModule {
            polymorphic(CardElement::class) {
                subclass(TextBlock::class)
                subclass(Image::class)
                subclass(Container::class)
                subclass(ColumnSet::class)
                subclass(FactSet::class)
                subclass(ImageSet::class)
                subclass(ActionSet::class)
                subclass(Media::class)
                subclass(RichTextBlock::class)
                subclass(Table::class)
                subclass(InputText::class)
                subclass(InputNumber::class)
                subclass(InputDate::class)
                subclass(InputTime::class)
                subclass(InputToggle::class)
                subclass(InputChoiceSet::class)
            }
            polymorphic(CardAction::class) {
                subclass(ActionSubmit::class)
                subclass(ActionOpenUrl::class)
                subclass(ActionShowCard::class)
                subclass(ActionExecute::class)
                subclass(ActionToggleVisibility::class)
            }
        }
    }

    /**
     * Parse a JSON string into an AdaptiveCard
     */
    fun parse(jsonString: String): AdaptiveCard {
        return json.decodeFromString(AdaptiveCard.serializer(), jsonString)
    }

    /**
     * Serialize an AdaptiveCard to JSON string
     */
    fun serialize(card: AdaptiveCard): String {
        return json.encodeToString(AdaptiveCard.serializer(), card)
    }

    /**
     * Parse with custom configuration
     */
    fun parseWithConfig(jsonString: String, jsonConfig: Json = json): AdaptiveCard {
        return jsonConfig.decodeFromString(AdaptiveCard.serializer(), jsonString)
    }
}
