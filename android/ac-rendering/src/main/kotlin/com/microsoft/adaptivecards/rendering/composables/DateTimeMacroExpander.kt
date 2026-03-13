// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.rendering.composables

import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

/**
 * Expands Adaptive Cards `{{DATE(...)}}` and `{{TIME(...)}}` macros in text strings.
 *
 * These are Adaptive Cards built-in functions (not template expressions) that format
 * ISO 8601 date strings into localized date/time displays.
 *
 * Formats:
 * - `{{DATE(iso-date, SHORT)}}` → "May 3, 2019"
 * - `{{DATE(iso-date, LONG)}}` → "Friday, May 3, 2019"
 * - `{{DATE(iso-date, COMPACT)}}` → "5/3/2019"
 * - `{{TIME(iso-date)}}` → "8:00 PM"
 */
object DateTimeMacroExpander {

    /**
     * Expand all `{{DATE(...)}}` and `{{TIME(...)}}` macros in the given string.
     */
    fun expand(text: String): String {
        if (!text.contains("{{")) return text

        var result = text

        // Expand {{DATE(...)}} macros
        result = expandPattern(result, "{{DATE(", ")}}") { content ->
            expandDateMacro(content)
        }

        // Expand {{TIME(...)}} macros
        result = expandPattern(result, "{{TIME(", ")}}") { content ->
            expandTimeMacro(content)
        }

        return result
    }

    // MARK: - Private

    private fun expandPattern(
        text: String,
        prefix: String,
        suffix: String,
        handler: (String) -> String?
    ): String {
        val sb = StringBuilder()
        var searchStart = 0

        while (searchStart < text.length) {
            val prefixIdx = text.indexOf(prefix, searchStart)
            if (prefixIdx == -1) {
                sb.append(text, searchStart, text.length)
                break
            }

            val contentStart = prefixIdx + prefix.length
            val suffixIdx = text.indexOf(suffix, contentStart)
            if (suffixIdx == -1) {
                sb.append(text, searchStart, text.length)
                break
            }

            val content = text.substring(contentStart, suffixIdx)
            val replacement = handler(content)

            if (replacement != null) {
                sb.append(text, searchStart, prefixIdx)
                sb.append(replacement)
                searchStart = suffixIdx + suffix.length
            } else {
                sb.append(text, searchStart, suffixIdx + suffix.length)
                searchStart = suffixIdx + suffix.length
            }
        }

        return sb.toString()
    }

    /** Expand a DATE macro content like "2019-05-03T20:00:00+0000, SHORT" */
    private fun expandDateMacro(content: String): String? {
        val parts = content.split(",", limit = 2).map { it.trim() }

        val dateString = parts.firstOrNull()?.takeIf { it.isNotEmpty() } ?: return null
        val date = parseISO8601(dateString) ?: return null

        val style = if (parts.size > 1) parts[1].uppercase() else "COMPACT"

        val dateFormat = when (style) {
            "LONG" -> DateFormat.getDateInstance(DateFormat.FULL, Locale.getDefault())
            "SHORT" -> DateFormat.getDateInstance(DateFormat.MEDIUM, Locale.getDefault())
            else -> DateFormat.getDateInstance(DateFormat.SHORT, Locale.getDefault()) // COMPACT
        }

        return dateFormat.format(date)
    }

    /** Expand a TIME macro content like "2019-05-03T20:00:00+0000" */
    private fun expandTimeMacro(content: String): String? {
        val dateString = content.trim().takeIf { it.isNotEmpty() } ?: return null
        val date = parseISO8601(dateString) ?: return null

        val timeFormat = DateFormat.getTimeInstance(DateFormat.SHORT, Locale.getDefault())
        return timeFormat.format(date)
    }

    /** Parse an ISO 8601 date string with multiple format fallbacks. */
    private fun parseISO8601(string: String): Date? {
        val patterns = listOf(
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ssXXX",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd"
        )

        for (pattern in patterns) {
            try {
                val sdf = SimpleDateFormat(pattern, Locale.US)
                if (pattern.endsWith("'Z'")) {
                    sdf.timeZone = TimeZone.getTimeZone("UTC")
                }
                return sdf.parse(string)
            } catch (_: Exception) {
                // Try next pattern
            }
        }

        return null
    }
}
