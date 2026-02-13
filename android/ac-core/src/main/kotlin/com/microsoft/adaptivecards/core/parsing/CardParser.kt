package com.microsoft.adaptivecards.core.parsing

import com.microsoft.adaptivecards.core.models.*
import kotlinx.serialization.json.Json
import kotlinx.serialization.modules.SerializersModule
import kotlinx.serialization.modules.polymorphic
import kotlinx.serialization.modules.subclass

object CardParser {
    private val json = Json {
        classDiscriminator = "type"  // Document expected JSON structure
        ignoreUnknownKeys = true
        isLenient = true
        prettyPrint = true
        coerceInputValues = true
        serializersModule = SerializersModule {
            polymorphic(CardElement::class) {
                defaultDeserializer { CardElementSerializer }
            }
            polymorphic(CardAction::class) {
                defaultDeserializer { ActionSubmit.serializer() }
                subclass(ActionSubmit::class)
                subclass(ActionOpenUrl::class)
                subclass(ActionShowCard::class)
                subclass(ActionExecute::class)
                subclass(ActionToggleVisibility::class)
                subclass(ActionPopover::class)
                subclass(ActionRunCommands::class)
                subclass(ActionOpenUrlDialog::class)
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
