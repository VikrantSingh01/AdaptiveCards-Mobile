// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.core.models

import com.microsoft.adaptivecards.core.parsing.BackgroundImageSerializer
import com.microsoft.adaptivecards.core.parsing.CardElementSerializer
import com.microsoft.adaptivecards.core.parsing.TextRunSerializer
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.Transient
import kotlinx.serialization.json.JsonElement

@Serializable(with = CardElementSerializer::class)
sealed interface CardElement {
    val type: String
    val id: String?
    val isVisible: Boolean
    val separator: Boolean
    val spacing: Spacing?
    val height: BlockElementHeight?
    val requires: Map<String, String>?
    val fallback: JsonElement?
}

/**
 * Represents an unknown or unsupported element type
 * Used for forward compatibility with future element types
 */
@Serializable
@SerialName("Unknown")
data class UnknownElement(
    @Transient override val type: String = "Unknown",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val unknownType: String? = null  // Store the actual type for debugging
) : CardElement

@Serializable
@SerialName("TextBlock")
data class TextBlock(
    @Transient override val type: String = "TextBlock",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val text: String = "",
    val color: Color? = null,
    val fontType: FontType? = null,
    val size: FontSize? = null,
    val weight: FontWeight? = null,
    val wrap: Boolean? = null,
    val maxLines: Int? = null,
    val horizontalAlignment: HorizontalAlignment? = null,
    val isSubtle: Boolean? = null,
    val style: String? = null,
    val targetWidth: String? = null
) : CardElement

@Serializable
@SerialName("Image")
data class Image(
    @Transient override val type: String = "Image",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val url: String,
    val altText: String? = null,
    val backgroundColor: String? = null,
    val size: ImageSize? = null,
    val style: ImageStyle? = null,
    val width: String? = null,
    val horizontalAlignment: HorizontalAlignment? = null,
    val selectAction: CardAction? = null,
    val targetWidth: String? = null,
    val themedUrls: Map<String, String>? = null,
    val forceLoad: Boolean? = null,
    val fitMode: String? = null,
    /** Explicit pixel height from JSON (e.g. "32px"). Extracted by CardElementSerializer because
     *  the base `height` field is typed as BlockElementHeight enum. */
    @Transient val pixelHeight: String? = null
) : CardElement

@Serializable
@SerialName("Container")
data class Container(
    @Transient override val type: String = "Container",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val items: List<CardElement>? = null,
    val selectAction: CardAction? = null,
    val style: ContainerStyle? = null,
    val verticalContentAlignment: VerticalContentAlignment? = null,
    val bleed: Boolean? = null,
    val backgroundImage: BackgroundImage? = null,
    val minHeight: String? = null,
    val targetWidth: String? = null,
    val rtl: Boolean? = null,
    /** When true, render a border stroke around the container using the style's borderColor. */
    val showBorder: Boolean? = null,
    /** When true, apply rounded corners from hostConfig.cornerRadius.container. */
    val roundedCorners: Boolean? = null,
    /** Layout descriptor (FlowLayout or AreaGridLayout). When null, uses default stack layout. */
    val layout: Layout? = null,
    /** Responsive layouts array. Each layout has a targetWidth condition; the first match is used.
     *  Falls back to `layout` (singular) or default stack layout. */
    val layouts: List<Layout>? = null
) : CardElement

@Serializable(with = BackgroundImageSerializer::class)
data class BackgroundImage(
    val url: String,
    val fillMode: String? = null,
    val horizontalAlignment: HorizontalAlignment? = null,
    val verticalAlignment: VerticalAlignment? = null
)

@Serializable
@SerialName("ColumnSet")
data class ColumnSet(
    @Transient override val type: String = "ColumnSet",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val columns: List<Column>? = null,
    val selectAction: CardAction? = null,
    val style: ContainerStyle? = null,
    val bleed: Boolean? = null,
    val minHeight: String? = null,
    val horizontalAlignment: HorizontalAlignment? = null,
    val targetWidth: String? = null
) : CardElement

@Serializable
data class Column(
    val id: String? = null,
    val isVisible: Boolean = true,
    val separator: Boolean = false,
    val spacing: Spacing? = null,
    val items: List<CardElement>? = null,
    val selectAction: CardAction? = null,
    val style: ContainerStyle? = null,
    val verticalContentAlignment: VerticalContentAlignment? = null,
    @Serializable(with = FlexibleStringSerializer::class)
    val width: String? = null,
    val bleed: Boolean? = null,
    val backgroundImage: BackgroundImage? = null,
    val minHeight: String? = null,
    val rtl: Boolean? = null,
    val requires: Map<String, String>? = null,
    val fallback: JsonElement? = null,
    val targetWidth: String? = null
)

@Serializable
@SerialName("FactSet")
data class FactSet(
    @Transient override val type: String = "FactSet",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val facts: List<Fact>
) : CardElement

@Serializable
data class Fact(
    val title: String,
    val value: String
)

@Serializable
enum class ImageSetStyle {
    @SerialName("Grid") Grid,
    @SerialName("Stacked") Stacked
}

@Serializable
@SerialName("ImageSet")
data class ImageSet(
    @Transient override val type: String = "ImageSet",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val images: List<Image>,
    val imageSize: ImageSize? = null,
    val style: ImageSetStyle? = null,
    val offset: Int? = null
) : CardElement

@Serializable
@SerialName("ActionSet")
data class ActionSet(
    @Transient override val type: String = "ActionSet",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val actions: List<CardAction>,
    val mode: ActionSetMode? = null,
    val targetWidth: String? = null
) : CardElement

@Serializable
@SerialName("Media")
data class Media(
    @Transient override val type: String = "Media",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val sources: List<MediaSource>,
    val poster: String? = null,
    val altText: String? = null,
    val captionSources: List<CaptionSource>? = null
) : CardElement

@Serializable
data class MediaSource(
    val mimeType: String,
    val url: String
)

@Serializable
data class CaptionSource(
    val mimeType: String,
    val url: String,
    val label: String? = null
)

@Serializable
@SerialName("RichTextBlock")
data class RichTextBlock(
    @Transient override val type: String = "RichTextBlock",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val inlines: List<InlineElement>,
    val horizontalAlignment: HorizontalAlignment? = null
) : CardElement

/**
 * Polymorphic inline element within a RichTextBlock.
 * Supports TextRun (styled text) and CitationRun (citation badge).
 */
@Serializable(with = com.microsoft.adaptivecards.core.parsing.InlineElementSerializer::class)
sealed interface InlineElement {
    val text: String
}

@Serializable(with = TextRunSerializer::class)
data class TextRun(
    val type: String = "TextRun",
    override val text: String,
    val color: Color? = null,
    val fontType: FontType? = null,
    val size: FontSize? = null,
    val weight: FontWeight? = null,
    val isSubtle: Boolean? = null,
    val italic: Boolean? = null,
    val strikethrough: Boolean? = null,
    val underline: Boolean? = null,
    val highlight: Boolean? = null,
    val selectAction: CardAction? = null
) : InlineElement

/**
 * An inline citation badge that renders as a superscript `[N]` reference.
 */
data class CitationRun(
    val type: String = "CitationRun",
    override val text: String,
    val referenceIndex: Int
) : InlineElement

@Serializable
@SerialName("Icon")
data class Icon(
    @Transient override val type: String = "Icon",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val name: String = "",
    val size: String? = null,
    val color: Color? = null,
    val style: String? = null,
    val selectAction: CardAction? = null,
    val targetWidth: String? = null,
    val horizontalAlignment: HorizontalAlignment? = null
) : CardElement

@Serializable
@SerialName("Badge")
data class Badge(
    @Transient override val type: String = "Badge",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val text: String = "",
    val style: String? = null,
    val appearance: String? = null,
    val icon: String? = null,
    val size: String? = null,
    val shape: String? = null,
    val targetWidth: String? = null,
    val horizontalAlignment: HorizontalAlignment? = null
) : CardElement

@Serializable
@SerialName("Table")
data class Table(
    @Transient override val type: String = "Table",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val columns: List<TableColumnDefinition>? = null,
    val rows: List<TableRow>,
    val firstRowAsHeaders: Boolean? = null,
    val showGridLines: Boolean? = null,
    val gridStyle: ContainerStyle? = null,
    val horizontalCellContentAlignment: HorizontalAlignment? = null,
    val verticalCellContentAlignment: VerticalContentAlignment? = null,
    val targetWidth: String? = null
) : CardElement

@Serializable
data class TableColumnDefinition(
    val width: String? = null,
    val horizontalCellContentAlignment: HorizontalAlignment? = null,
    val verticalCellContentAlignment: VerticalContentAlignment? = null
)

@Serializable
data class TableRow(
    val cells: List<TableCell>,
    val style: ContainerStyle? = null,
    val horizontalCellContentAlignment: HorizontalAlignment? = null,
    val verticalCellContentAlignment: VerticalContentAlignment? = null
)

@Serializable
data class TableCell(
    val items: List<CardElement>? = null,
    val selectAction: CardAction? = null,
    val style: ContainerStyle? = null,
    val verticalContentAlignment: VerticalContentAlignment? = null,
    val horizontalCellContentAlignment: HorizontalAlignment? = null,
    val bleed: Boolean? = null,
    val backgroundImage: BackgroundImage? = null,
    val minHeight: String? = null,
    val rtl: Boolean? = null,
    val layouts: List<Layout>? = null
) {
    /** Active layout — first from layouts array, or null for default stack */
    val layout: Layout? get() = layouts?.firstOrNull()
}
