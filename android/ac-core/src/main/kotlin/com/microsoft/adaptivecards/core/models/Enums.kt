package com.microsoft.adaptivecards.core.models

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
enum class HorizontalAlignment {
    @SerialName("left") Left,
    @SerialName("center") Center,
    @SerialName("right") Right
}

@Serializable
enum class VerticalAlignment {
    @SerialName("top") Top,
    @SerialName("center") Center,
    @SerialName("bottom") Bottom
}

@Serializable
enum class VerticalContentAlignment {
    @SerialName("top") Top,
    @SerialName("center") Center,
    @SerialName("bottom") Bottom
}

@Serializable
enum class Spacing {
    @SerialName("none") None,
    @SerialName("small") Small,
    @SerialName("default") Default,
    @SerialName("medium") Medium,
    @SerialName("large") Large,
    @SerialName("extraLarge") ExtraLarge,
    @SerialName("padding") Padding
}

@Serializable
enum class FontType {
    @SerialName("default") Default,
    @SerialName("monospace") Monospace
}

@Serializable
enum class FontSize {
    @SerialName("small") Small,
    @SerialName("default") Default,
    @SerialName("medium") Medium,
    @SerialName("large") Large,
    @SerialName("extraLarge") ExtraLarge
}

@Serializable
enum class FontWeight {
    @SerialName("default") Default,
    @SerialName("lighter") Lighter,
    @SerialName("bolder") Bolder
}

@Serializable
enum class Color {
    @SerialName("default") Default,
    @SerialName("dark") Dark,
    @SerialName("light") Light,
    @SerialName("accent") Accent,
    @SerialName("good") Good,
    @SerialName("warning") Warning,
    @SerialName("attention") Attention
}

@Serializable
enum class ImageSize {
    @SerialName("auto") Auto,
    @SerialName("stretch") Stretch,
    @SerialName("small") Small,
    @SerialName("medium") Medium,
    @SerialName("large") Large
}

@Serializable
enum class ImageStyle {
    @SerialName("default") Default,
    @SerialName("person") Person
}

@Serializable
enum class ContainerStyle {
    @SerialName("default") Default,
    @SerialName("emphasis") Emphasis,
    @SerialName("good") Good,
    @SerialName("attention") Attention,
    @SerialName("warning") Warning,
    @SerialName("accent") Accent
}

@Serializable
enum class ActionStyle {
    @SerialName("default") Default,
    @SerialName("positive") Positive,
    @SerialName("destructive") Destructive
}

@Serializable
enum class HeightType {
    @SerialName("auto") Auto,
    @SerialName("stretch") Stretch
}

@Serializable
enum class BlockElementHeight {
    @SerialName("auto") Auto,
    @SerialName("stretch") Stretch
}

@Serializable
enum class ChoiceInputStyle {
    @SerialName("compact") Compact,
    @SerialName("expanded") Expanded,
    @SerialName("filtered") Filtered
}

@Serializable
enum class TextInputStyle {
    @SerialName("text") Text,
    @SerialName("tel") Tel,
    @SerialName("url") Url,
    @SerialName("email") Email,
    @SerialName("password") Password
}

@Serializable
enum class AssociatedInputs {
    @SerialName("auto") Auto,
    @SerialName("none") None
}

@Serializable
enum class ActionMode {
    @SerialName("primary") Primary,
    @SerialName("secondary") Secondary
}

@Serializable
enum class TargetWidth {
    @SerialName("narrow") Narrow,
    @SerialName("standard") Standard,
    @SerialName("wide") Wide,
    @SerialName("veryWide") VeryWide
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
