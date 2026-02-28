package com.microsoft.adaptivecards.core.models

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
enum class HorizontalAlignment {
    @SerialName("Left") Left,
    @SerialName("Center") Center,
    @SerialName("Right") Right
}

@Serializable
enum class VerticalAlignment {
    @SerialName("Top") Top,
    @SerialName("Center") Center,
    @SerialName("Bottom") Bottom
}

@Serializable
enum class VerticalContentAlignment {
    @SerialName("Top") Top,
    @SerialName("Center") Center,
    @SerialName("Bottom") Bottom
}

@Serializable
enum class Spacing {
    @SerialName("None") None,
    @SerialName("Small") Small,
    @SerialName("Default") Default,
    @SerialName("Medium") Medium,
    @SerialName("Large") Large,
    @SerialName("ExtraLarge") ExtraLarge,
    @SerialName("Padding") Padding
}

@Serializable
enum class FontType {
    @SerialName("Default") Default,
    @SerialName("Monospace") Monospace
}

@Serializable
enum class FontSize {
    @SerialName("Small") Small,
    @SerialName("Default") Default,
    @SerialName("Medium") Medium,
    @SerialName("Large") Large,
    @SerialName("ExtraLarge") ExtraLarge
}

@Serializable
enum class FontWeight {
    @SerialName("Default") Default,
    @SerialName("Lighter") Lighter,
    @SerialName("Bolder") Bolder
}

@Serializable
enum class Color {
    @SerialName("Default") Default,
    @SerialName("Dark") Dark,
    @SerialName("Light") Light,
    @SerialName("Accent") Accent,
    @SerialName("Good") Good,
    @SerialName("Warning") Warning,
    @SerialName("Attention") Attention
}

@Serializable
enum class ImageSize {
    @SerialName("Auto") Auto,
    @SerialName("Stretch") Stretch,
    @SerialName("Small") Small,
    @SerialName("Medium") Medium,
    @SerialName("Large") Large
}

@Serializable
enum class ImageStyle {
    @SerialName("Default") Default,
    @SerialName("Person") Person
}

@Serializable
enum class ContainerStyle {
    @SerialName("Default") Default,
    @SerialName("Emphasis") Emphasis,
    @SerialName("Good") Good,
    @SerialName("Attention") Attention,
    @SerialName("Warning") Warning,
    @SerialName("Accent") Accent
}

@Serializable
enum class ActionStyle {
    @SerialName("Default") Default,
    @SerialName("Positive") Positive,
    @SerialName("Destructive") Destructive
}

@Serializable
enum class HeightType {
    @SerialName("Auto") Auto,
    @SerialName("Stretch") Stretch
}

@Serializable
enum class BlockElementHeight {
    @SerialName("Auto") Auto,
    @SerialName("Stretch") Stretch
}

@Serializable
enum class ChoiceInputStyle {
    @SerialName("Compact") Compact,
    @SerialName("Expanded") Expanded,
    @SerialName("Filtered") Filtered
}

@Serializable
enum class TextInputStyle {
    @SerialName("Text") Text,
    @SerialName("Tel") Tel,
    @SerialName("Url") Url,
    @SerialName("Email") Email,
    @SerialName("Password") Password
}

@Serializable
enum class AssociatedInputs {
    @SerialName("Auto") Auto,
    @SerialName("None") None
}

@Serializable
enum class ActionMode {
    @SerialName("Primary") Primary,
    @SerialName("Secondary") Secondary
}

@Serializable
enum class ActionSetMode {
    @SerialName("Default") Default,
    @SerialName("Overflow") Overflow
}

@Serializable
enum class TargetWidth {
    @SerialName("Narrow") Narrow,
    @SerialName("Standard") Standard,
    @SerialName("Wide") Wide,
    @SerialName("VeryWide") VeryWide
}

@Serializable
enum class ExpandMode {
    @SerialName("single") SINGLE,
    @SerialName("multiple") MULTIPLE
}

@Serializable
enum class RatingSize {
    @SerialName("small") SMALL,
    @SerialName("medium") MEDIUM,
    @SerialName("large") LARGE
}

@Serializable
enum class SpinnerSize {
    @SerialName("small") SMALL,
    @SerialName("medium") MEDIUM,
    @SerialName("large") LARGE
}

// Layout Types

@Serializable
enum class LayoutType {
    @SerialName("Layout.Stack") STACK,
    @SerialName("Layout.Flow") FLOW,
    @SerialName("Layout.AreaGrid") AREA_GRID
}

@Serializable
enum class ItemFit {
    @SerialName("Fit") FIT,
    @SerialName("Fill") FILL
}
