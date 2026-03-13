// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.core

import com.microsoft.adaptivecards.core.models.AdaptiveCard

/**
 * Warning generated during card parsing (non-fatal issues like unknown element types)
 */
data class ParseWarning(
    /** The type of warning */
    val code: Code,
    /** Human-readable description */
    val message: String,
    /** The JSON path where the warning occurred, if available */
    val path: String? = null
) {
    enum class Code {
        UNKNOWN_ELEMENT_TYPE,
        UNKNOWN_ACTION_TYPE,
        MISSING_INPUT_ID,
        FALLBACK_USED
    }
}

/**
 * Error types for card parsing failures
 */
sealed class ParseError(override val message: String) : Exception(message) {
    class InvalidJSON(msg: String) : ParseError("Invalid JSON: $msg")
    class DecodingFailed(msg: String) : ParseError("Decoding failed: $msg")
    class Timeout : ParseError("Parse operation timed out")
    class Empty : ParseError("Empty JSON string")
}

/**
 * Result of parsing an Adaptive Card JSON string.
 * Contains the parsed card (if successful), any warnings, and any error.
 */
data class ParseResult(
    /** The parsed card, or null if parsing failed */
    val card: AdaptiveCard? = null,
    /** Non-fatal warnings encountered during parsing */
    val warnings: List<ParseWarning> = emptyList(),
    /** The error if parsing failed, null on success */
    val error: ParseError? = null,
    /** Time taken to parse in milliseconds (0 if served from cache) */
    val parseTimeMs: Double = 0.0,
    /** Whether the result was served from cache */
    val cacheHit: Boolean = false
) {
    /** Whether parsing succeeded (card is non-null) */
    val isValid: Boolean get() = card != null
}
