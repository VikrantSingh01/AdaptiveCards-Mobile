package com.microsoft.adaptivecards.core.models

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonElement

@Serializable
data class AdaptiveCard(
    val type: String = "AdaptiveCard",
    @SerialName("\$schema")
    val schema: String? = null,
    val version: String = "1.6",
    val body: List<CardElement>? = null,
    val actions: List<CardAction>? = null,
    val selectAction: CardAction? = null,
    val fallbackText: String? = null,
    val backgroundImage: BackgroundImage? = null,
    val minHeight: String? = null,
    val speak: String? = null,
    val lang: String? = null,
    val verticalContentAlignment: VerticalContentAlignment? = null,
    val rtl: Boolean? = null,
    val refresh: Refresh? = null,
    val authentication: Authentication? = null,
    val metadata: JsonElement? = null,
    val references: List<DocumentReference>? = null
)

/**
 * A reference entry for CitationRun inlines.
 * Parsed from the top-level `references` array in an AdaptiveCard.
 */
@Serializable
data class DocumentReference(
    val type: String? = null,
    val title: String? = null,
    val icon: String? = null,
    val url: String? = null,
    val abstract: String? = null
)
