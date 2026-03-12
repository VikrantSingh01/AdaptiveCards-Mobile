package com.microsoft.adaptivecards.core.models

/**
 * Width categories for responsive targetWidth filtering per Adaptive Cards spec.
 *
 * Breakpoints (in dp):
 * - VeryNarrow: < 300
 * - Narrow: 300–499
 * - Standard: 500–699
 * - Wide: ≥ 700
 */
enum class WidthCategory(val order: Int) {
    VeryNarrow(0),
    Narrow(1),
    Standard(2),
    Wide(3);

    companion object {
        /** Determine the width category from a dp value using hostConfig breakpoints. */
        fun fromDp(
            widthDp: Float,
            veryNarrowBreakpoint: Int = 216,
            narrowBreakpoint: Int = 413,
            standardBreakpoint: Int = 500
        ): WidthCategory = when {
            veryNarrowBreakpoint > 0 && widthDp <= veryNarrowBreakpoint -> VeryNarrow
            widthDp <= narrowBreakpoint -> Narrow
            widthDp <= standardBreakpoint -> Standard
            else -> Wide
        }

        /** Parse a category name (case-insensitive). Returns null for unrecognized names. */
        fun fromName(name: String): WidthCategory? = when (name.lowercase()) {
            "verynarrow" -> VeryNarrow
            "narrow" -> Narrow
            "standard" -> Standard
            "wide" -> Wide
            else -> null
        }
    }
}

/**
 * Evaluates whether an element's `targetWidth` constraint matches the current width category.
 *
 * Supported formats:
 * - `"VeryNarrow"`, `"Narrow"`, `"Standard"`, `"Wide"` — exact match
 * - `"AtLeast:Narrow"` — matches Narrow, Standard, Wide
 * - `"AtMost:Narrow"` — matches VeryNarrow, Narrow
 *
 * Returns `true` if targetWidth is null/blank (element always visible).
 */
fun shouldShowForTargetWidth(targetWidth: String?, currentCategory: WidthCategory): Boolean {
    if (targetWidth.isNullOrBlank()) return true

    val trimmed = targetWidth.trim()

    // "AtLeast:X" — current must be >= X
    if (trimmed.startsWith("AtLeast:", ignoreCase = true)) {
        val categoryName = trimmed.substringAfter(":")
        val threshold = WidthCategory.fromName(categoryName) ?: return true
        return currentCategory.order >= threshold.order
    }

    // "AtMost:X" — current must be <= X
    if (trimmed.startsWith("AtMost:", ignoreCase = true)) {
        val categoryName = trimmed.substringAfter(":")
        val threshold = WidthCategory.fromName(categoryName) ?: return true
        return currentCategory.order <= threshold.order
    }

    // Exact match
    val exact = WidthCategory.fromName(trimmed) ?: return true
    return currentCategory == exact
}

/**
 * Extension property to extract targetWidth from any CardElement.
 * Returns null for element types that don't support it.
 */
val CardElement.targetWidth: String?
    get() = when (this) {
        is TextBlock -> targetWidth
        is Image -> targetWidth
        is Container -> targetWidth
        is ActionSet -> targetWidth
        is ColumnSet -> targetWidth
        is Table -> targetWidth
        is Icon -> targetWidth
        is Badge -> targetWidth
        else -> null
    }
