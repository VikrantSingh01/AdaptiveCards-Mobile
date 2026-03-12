package com.microsoft.adaptivecards.core.models

import kotlinx.serialization.KSerializer
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.descriptors.PrimitiveKind
import kotlinx.serialization.descriptors.PrimitiveSerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder

/**
 * Generic case-insensitive enum serializer for Adaptive Cards.
 *
 * The AC spec treats enum values as case-insensitive (e.g. "small", "Small", "SMALL"
 * are all valid). This serializer handles that by matching on lowercase.
 *
 * @param serialName The descriptor name
 * @param defaultValue Fallback when no match is found
 * @param entries Map of lowercase string → enum value
 */
open class CaseInsensitiveEnumSerializer<E : Enum<E>>(
    serialName: String,
    private val defaultValue: E,
    private val entries: Map<String, E>
) : KSerializer<E> {
    override val descriptor = PrimitiveSerialDescriptor(serialName, PrimitiveKind.STRING)

    override fun serialize(encoder: Encoder, value: E) =
        encoder.encodeString(value.name)

    override fun deserialize(decoder: Decoder): E =
        entries[decoder.decodeString().lowercase()] ?: defaultValue

    companion object {
        /** Build a lowercase lookup map from enum values, keyed by lowercase enum name. */
        inline fun <reified E : Enum<E>> buildEntries(): Map<String, E> =
            enumValues<E>().associateBy { it.name.lowercase() }
    }
}

// --- Enum definitions with case-insensitive serialization ---

@Serializable(with = HorizontalAlignmentSerializer::class)
enum class HorizontalAlignment {
    @SerialName("Left") Left,
    @SerialName("Center") Center,
    @SerialName("Right") Right
}

object HorizontalAlignmentSerializer : CaseInsensitiveEnumSerializer<HorizontalAlignment>(
    "HorizontalAlignment", HorizontalAlignment.Left,
    CaseInsensitiveEnumSerializer.buildEntries()
)

@Serializable(with = VerticalAlignmentSerializer::class)
enum class VerticalAlignment {
    @SerialName("Top") Top,
    @SerialName("Center") Center,
    @SerialName("Bottom") Bottom
}

object VerticalAlignmentSerializer : CaseInsensitiveEnumSerializer<VerticalAlignment>(
    "VerticalAlignment", VerticalAlignment.Top,
    CaseInsensitiveEnumSerializer.buildEntries()
)

@Serializable(with = VerticalContentAlignmentSerializer::class)
enum class VerticalContentAlignment {
    @SerialName("Top") Top,
    @SerialName("Center") Center,
    @SerialName("Bottom") Bottom
}

object VerticalContentAlignmentSerializer : CaseInsensitiveEnumSerializer<VerticalContentAlignment>(
    "VerticalContentAlignment", VerticalContentAlignment.Top,
    CaseInsensitiveEnumSerializer.buildEntries()
)

@Serializable(with = SpacingSerializer::class)
enum class Spacing {
    @SerialName("None") None,
    @SerialName("ExtraSmall") ExtraSmall,
    @SerialName("Small") Small,
    @SerialName("Default") Default,
    @SerialName("Medium") Medium,
    @SerialName("Large") Large,
    @SerialName("ExtraLarge") ExtraLarge,
    @SerialName("Padding") Padding
}

object SpacingSerializer : CaseInsensitiveEnumSerializer<Spacing>(
    "Spacing", Spacing.Default,
    CaseInsensitiveEnumSerializer.buildEntries()
)

@Serializable(with = FontTypeSerializer::class)
enum class FontType {
    @SerialName("Default") Default,
    @SerialName("Monospace") Monospace
}

object FontTypeSerializer : CaseInsensitiveEnumSerializer<FontType>(
    "FontType", FontType.Default,
    CaseInsensitiveEnumSerializer.buildEntries()
)

@Serializable(with = FontSizeSerializer::class)
enum class FontSize {
    @SerialName("Small") Small,
    @SerialName("Default") Default,
    @SerialName("Medium") Medium,
    @SerialName("Large") Large,
    @SerialName("ExtraLarge") ExtraLarge
}

object FontSizeSerializer : CaseInsensitiveEnumSerializer<FontSize>(
    "FontSize", FontSize.Default,
    CaseInsensitiveEnumSerializer.buildEntries()
)

@Serializable(with = FontWeightSerializer::class)
enum class FontWeight {
    @SerialName("Default") Default,
    @SerialName("Lighter") Lighter,
    @SerialName("Bolder") Bolder
}

object FontWeightSerializer : CaseInsensitiveEnumSerializer<FontWeight>(
    "FontWeight", FontWeight.Default,
    CaseInsensitiveEnumSerializer.buildEntries()
)

@Serializable(with = ColorSerializer::class)
enum class Color {
    @SerialName("Default") Default,
    @SerialName("Dark") Dark,
    @SerialName("Light") Light,
    @SerialName("Accent") Accent,
    @SerialName("Good") Good,
    @SerialName("Warning") Warning,
    @SerialName("Attention") Attention
}

object ColorSerializer : CaseInsensitiveEnumSerializer<Color>(
    "Color", Color.Default,
    CaseInsensitiveEnumSerializer.buildEntries()
)

@Serializable(with = ImageSizeSerializer::class)
enum class ImageSize {
    @SerialName("Auto") Auto,
    @SerialName("Stretch") Stretch,
    @SerialName("Small") Small,
    @SerialName("Medium") Medium,
    @SerialName("Large") Large
}

object ImageSizeSerializer : CaseInsensitiveEnumSerializer<ImageSize>(
    "ImageSize", ImageSize.Auto,
    CaseInsensitiveEnumSerializer.buildEntries()
)

@Serializable(with = ImageStyleSerializer::class)
enum class ImageStyle {
    @SerialName("Default") Default,
    @SerialName("Person") Person,
    @SerialName("RoundedCorners") RoundedCorners
}

object ImageStyleSerializer : CaseInsensitiveEnumSerializer<ImageStyle>(
    "ImageStyle", ImageStyle.Default,
    buildMap {
        putAll(CaseInsensitiveEnumSerializer.buildEntries<ImageStyle>())
        // Also handle "roundedcorners" → lowercased camelCase "roundedCorners"
        put("roundedcorners", ImageStyle.RoundedCorners)
    }
)

@Serializable(with = ContainerStyleSerializer::class)
enum class ContainerStyle {
    @SerialName("Default") Default,
    @SerialName("Emphasis") Emphasis,
    @SerialName("Good") Good,
    @SerialName("Attention") Attention,
    @SerialName("Warning") Warning,
    @SerialName("Accent") Accent
}

object ContainerStyleSerializer : CaseInsensitiveEnumSerializer<ContainerStyle>(
    "ContainerStyle", ContainerStyle.Default,
    CaseInsensitiveEnumSerializer.buildEntries()
)

@Serializable(with = ActionStyleSerializer::class)
enum class ActionStyle {
    @SerialName("Default") Default,
    @SerialName("Positive") Positive,
    @SerialName("Destructive") Destructive
}

object ActionStyleSerializer : CaseInsensitiveEnumSerializer<ActionStyle>(
    "ActionStyle", ActionStyle.Default,
    CaseInsensitiveEnumSerializer.buildEntries()
)

@Serializable(with = HeightTypeSerializer::class)
enum class HeightType {
    @SerialName("Auto") Auto,
    @SerialName("Stretch") Stretch
}

object HeightTypeSerializer : CaseInsensitiveEnumSerializer<HeightType>(
    "HeightType", HeightType.Auto,
    CaseInsensitiveEnumSerializer.buildEntries()
)

@Serializable(with = BlockElementHeightSerializer::class)
enum class BlockElementHeight {
    @SerialName("Auto") Auto,
    @SerialName("Stretch") Stretch
}

object BlockElementHeightSerializer : CaseInsensitiveEnumSerializer<BlockElementHeight>(
    "BlockElementHeight", BlockElementHeight.Auto,
    CaseInsensitiveEnumSerializer.buildEntries()
)

@Serializable(with = ChoiceInputStyleSerializer::class)
enum class ChoiceInputStyle {
    @SerialName("Compact") Compact,
    @SerialName("Expanded") Expanded,
    @SerialName("Filtered") Filtered
}

object ChoiceInputStyleSerializer : CaseInsensitiveEnumSerializer<ChoiceInputStyle>(
    "ChoiceInputStyle", ChoiceInputStyle.Compact,
    CaseInsensitiveEnumSerializer.buildEntries()
)

@Serializable(with = TextInputStyleSerializer::class)
enum class TextInputStyle {
    @SerialName("Text") Text,
    @SerialName("Tel") Tel,
    @SerialName("Url") Url,
    @SerialName("Email") Email,
    @SerialName("Password") Password
}

object TextInputStyleSerializer : CaseInsensitiveEnumSerializer<TextInputStyle>(
    "TextInputStyle", TextInputStyle.Text,
    CaseInsensitiveEnumSerializer.buildEntries()
)

@Serializable(with = AssociatedInputsSerializer::class)
enum class AssociatedInputs {
    @SerialName("Auto") Auto,
    @SerialName("None") None
}

object AssociatedInputsSerializer : CaseInsensitiveEnumSerializer<AssociatedInputs>(
    "AssociatedInputs", AssociatedInputs.Auto,
    CaseInsensitiveEnumSerializer.buildEntries()
)

@Serializable(with = ActionModeSerializer::class)
enum class ActionMode {
    Primary,
    Secondary
}

/** Case-insensitive deserializer — handles both "secondary" and "Secondary". */
object ActionModeSerializer : CaseInsensitiveEnumSerializer<ActionMode>(
    "ActionMode", ActionMode.Primary,
    CaseInsensitiveEnumSerializer.buildEntries()
)

@Serializable(with = ActionSetModeSerializer::class)
enum class ActionSetMode {
    @SerialName("Default") Default,
    @SerialName("Overflow") Overflow
}

object ActionSetModeSerializer : CaseInsensitiveEnumSerializer<ActionSetMode>(
    "ActionSetMode", ActionSetMode.Default,
    CaseInsensitiveEnumSerializer.buildEntries()
)

@Serializable(with = TargetWidthSerializer::class)
enum class TargetWidth {
    @SerialName("Narrow") Narrow,
    @SerialName("Standard") Standard,
    @SerialName("Wide") Wide,
    @SerialName("VeryWide") VeryWide
}

object TargetWidthSerializer : CaseInsensitiveEnumSerializer<TargetWidth>(
    "TargetWidth", TargetWidth.Standard,
    buildMap {
        putAll(CaseInsensitiveEnumSerializer.buildEntries<TargetWidth>())
        put("verywide", TargetWidth.VeryWide)
    }
)

@Serializable(with = ExpandModeSerializer::class)
enum class ExpandMode {
    @SerialName("single") SINGLE,
    @SerialName("multiple") MULTIPLE
}

object ExpandModeSerializer : CaseInsensitiveEnumSerializer<ExpandMode>(
    "ExpandMode", ExpandMode.SINGLE,
    CaseInsensitiveEnumSerializer.buildEntries()
)

@Serializable(with = RatingSizeSerializer::class)
enum class RatingSize {
    @SerialName("small") SMALL,
    @SerialName("medium") MEDIUM,
    @SerialName("large") LARGE
}

object RatingSizeSerializer : CaseInsensitiveEnumSerializer<RatingSize>(
    "RatingSize", RatingSize.MEDIUM,
    CaseInsensitiveEnumSerializer.buildEntries()
)

@Serializable(with = SpinnerSizeSerializer::class)
enum class SpinnerSize {
    @SerialName("small") SMALL,
    @SerialName("medium") MEDIUM,
    @SerialName("large") LARGE
}

object SpinnerSizeSerializer : CaseInsensitiveEnumSerializer<SpinnerSize>(
    "SpinnerSize", SpinnerSize.MEDIUM,
    CaseInsensitiveEnumSerializer.buildEntries()
)

// Layout Types

@Serializable
enum class LayoutType {
    @SerialName("Layout.Stack") STACK,
    @SerialName("Layout.Flow") FLOW,
    @SerialName("Layout.AreaGrid") AREA_GRID
}

@Serializable(with = ItemFitSerializer::class)
enum class ItemFit {
    @SerialName("Fit") FIT,
    @SerialName("Fill") FILL
}

object ItemFitSerializer : CaseInsensitiveEnumSerializer<ItemFit>(
    "ItemFit", ItemFit.FIT,
    CaseInsensitiveEnumSerializer.buildEntries()
)
