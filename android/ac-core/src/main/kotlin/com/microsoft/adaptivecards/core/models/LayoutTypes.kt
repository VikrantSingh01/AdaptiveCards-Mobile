package com.microsoft.adaptivecards.core.models

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.DeserializationStrategy
import kotlinx.serialization.KSerializer
import kotlinx.serialization.builtins.ListSerializer
import kotlinx.serialization.builtins.serializer
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import kotlinx.serialization.json.JsonContentPolymorphicSerializer
import kotlinx.serialization.json.JsonDecoder
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonEncoder
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

/**
 * A type-erased layout descriptor for containers.
 * Containers can use FlowLayout, AreaGridLayout, or default stack layout.
 *
 * Ported from production AdaptiveCards C++ ObjectModel.
 */
@Serializable(with = LayoutSerializer::class)
sealed class Layout {
    abstract val type: LayoutType
    /** Responsive width condition (e.g. "atLeast:Standard"). Null means always applies. */
    abstract val targetWidth: String?
}

/**
 * Polymorphic serializer that dispatches based on the "type" field in JSON.
 */
object LayoutSerializer : JsonContentPolymorphicSerializer<Layout>(Layout::class) {
    override fun selectDeserializer(element: JsonElement): DeserializationStrategy<Layout> {
        val type = element.jsonObject["type"]?.jsonPrimitive?.content ?: ""
        return when {
            type.equals("Layout.Flow", ignoreCase = true) -> FlowLayout.serializer()
            type.equals("Layout.AreaGrid", ignoreCase = true) -> AreaGridLayout.serializer()
            else -> throw IllegalArgumentException("Unknown layout type: $type")
        }
    }
}

/**
 * A flow layout that wraps items across multiple rows, similar to CSS flexbox wrap.
 *
 * Ported from production AdaptiveCards C++ ObjectModel `FlowLayout` class.
 *
 * Example JSON:
 * ```json
 * {
 *   "type": "Layout.Flow",
 *   "itemFit": "Fit",
 *   "itemWidth": "100px",
 *   "columnSpacing": "Small",
 *   "rowSpacing": "Small"
 * }
 * ```
 */
@Serializable
@SerialName("Layout.Flow")
data class FlowLayout(
    override val type: LayoutType = LayoutType.FLOW,
    override val targetWidth: String? = null,

    /** How items should be sized: FIT (natural size) or FILL (stretch to fill row) */
    val itemFit: ItemFit? = null,

    /** Fixed width for items (e.g., "100px", "50%") */
    val itemWidth: String? = null,

    /** Minimum width for items (e.g., "80px") */
    val minItemWidth: String? = null,

    /** Maximum width for items (e.g., "200px") */
    val maxItemWidth: String? = null,

    /** Spacing between columns within a row */
    val columnSpacing: Spacing? = null,

    /** Spacing between rows */
    val rowSpacing: Spacing? = null,

    /** Horizontal alignment of items within the flow container */
    val horizontalAlignment: HorizontalAlignment? = null
) : Layout()

/**
 * A CSS Grid-like layout that places items into named areas.
 *
 * Ported from production AdaptiveCards C++ ObjectModel `AreaGridLayout` class.
 *
 * Example JSON:
 * ```json
 * {
 *   "type": "Layout.AreaGrid",
 *   "columns": ["1fr", "2fr", "1fr"],
 *   "areas": [
 *     { "name": "header", "row": 1, "column": 1, "columnSpan": 3 },
 *     { "name": "sidebar", "row": 2, "column": 1 },
 *     { "name": "content", "row": 2, "column": 2, "columnSpan": 2 }
 *   ],
 *   "columnSpacing": "Default",
 *   "rowSpacing": "Default"
 * }
 * ```
 */
@Serializable
@SerialName("Layout.AreaGrid")
data class AreaGridLayout(
    override val type: LayoutType = LayoutType.AREA_GRID,
    override val targetWidth: String? = null,

    /** Column definitions (e.g., ["1fr", "2fr", "auto", "100px", or numeric like 50]) */
    @Serializable(with = FlexibleStringListSerializer::class)
    val columns: List<String> = emptyList(),

    /** Named grid areas that define placement regions */
    val areas: List<GridArea> = emptyList(),

    /** Spacing between columns */
    val columnSpacing: Spacing? = null,

    /** Spacing between rows */
    val rowSpacing: Spacing? = null
) : Layout()

/**
 * A named area within an AreaGridLayout, specifying row/column placement and span.
 *
 * Ported from production AdaptiveCards C++ ObjectModel `GridArea` class.
 * Items placed in a Container with AreaGridLayout reference areas by name.
 */
@Serializable
data class GridArea(
    /** Name for this area, referenced by items */
    val name: String,

    /** Row position (1-based) */
    val row: Int = 1,

    /** Column position (1-based) */
    val column: Int = 1,

    /** Number of rows this area spans */
    val rowSpan: Int? = null,

    /** Number of columns this area spans */
    val columnSpan: Int? = null
)

/**
 * Serializer that accepts both string and numeric JSON array elements,
 * converting everything to String. Handles cases like `"columns": [50]` (numeric)
 * or `"columns": ["1fr", "2fr"]` (string).
 */
object FlexibleStringListSerializer : KSerializer<List<String>> {
    override val descriptor: SerialDescriptor =
        ListSerializer(String.serializer()).descriptor

    override fun deserialize(decoder: Decoder): List<String> {
        val jsonDecoder = decoder as? JsonDecoder
            ?: return ListSerializer(String.serializer()).deserialize(decoder)
        val array = jsonDecoder.decodeJsonElement().jsonArray
        return array.map { it.jsonPrimitive.content }
    }

    override fun serialize(encoder: Encoder, value: List<String>) {
        ListSerializer(String.serializer()).serialize(encoder, value)
    }
}
