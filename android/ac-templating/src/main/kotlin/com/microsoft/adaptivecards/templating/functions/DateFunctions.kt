// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.templating.functions

import com.microsoft.adaptivecards.templating.EvaluationException
import com.microsoft.adaptivecards.templating.ExpressionFunction
import java.text.SimpleDateFormat
import java.util.*

/**
 * Date and time functions for template expressions
 */
object DateFunctions {
    fun register(functions: MutableMap<String, ExpressionFunction>) {
        functions["formatDateTime"] = FormatDateTime()
        functions["formatTicks"] = FormatTicks()
        functions["formatEpoch"] = FormatEpoch()
        functions["addDays"] = AddDays()
        functions["addHours"] = AddHours()
        functions["getYear"] = GetYear()
        functions["getMonth"] = GetMonth()
        functions["getDay"] = GetDay()
        functions["dateDiff"] = DateDiff()
        functions["utcNow"] = UtcNow()
    }

    // MARK: - Function Implementations

    class FormatDateTime : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.isEmpty() || arguments.size > 2) {
                throw EvaluationException("formatDateTime expects 1 or 2 arguments, got ${arguments.size}")
            }

            val date = parseDate(arguments[0])
            val formatString = if (arguments.size > 1) arguments[1] as? String else "yyyy-MM-dd"

            // Auto-quote non-pattern letters (e.g. literal 'T' in ISO formats)
            val javaFormat = mapToJavaFormat(formatString ?: "yyyy-MM-dd")
            val formatter = SimpleDateFormat(javaFormat, Locale.US)
            formatter.timeZone = TimeZone.getTimeZone("UTC")
            return formatter.format(date)
        }

        private fun mapToJavaFormat(format: String): String = when (format) {
            "dddd" -> "EEEE"
            "ddd" -> "EEE"
            else -> {
                val sdfPatternChars = "GyYMLwWdDFEuaHhKkmsSzZX"
                val sb = StringBuilder()
                var inQuote = false
                for (ch in format) {
                    if (ch == '\'') {
                        sb.append(ch)
                        inQuote = !inQuote
                    } else if (!inQuote && ch.isLetter() && ch !in sdfPatternChars) {
                        sb.append("'").append(ch).append("'")
                    } else {
                        sb.append(ch)
                    }
                }
                sb.toString()
            }
        }
    }

    /**
     * Converts .NET ticks (100-nanosecond intervals since 0001-01-01) to a formatted date string.
     * Usage: formatTicks(ticksValue, 'yyyy-MM-dd')
     */
    class FormatTicks : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.isEmpty() || arguments.size > 2) {
                throw EvaluationException("formatTicks expects 1 or 2 arguments, got ${arguments.size}")
            }

            val ticks: Long = when (val arg = arguments[0]) {
                is Long -> arg
                is Int -> arg.toLong()
                is Double -> arg.toLong()
                is String -> arg.toLongOrNull()
                    ?: throw EvaluationException("formatTicks requires a numeric ticks value")
                else -> throw EvaluationException("formatTicks requires a numeric ticks value")
            }

            // .NET epoch: 0001-01-01T00:00:00Z
            // Unix epoch: 1970-01-01T00:00:00Z
            // Difference: 621355968000000000 ticks
            val unixEpochTicks = 621_355_968_000_000_000L
            val ticksPerMillisecond = 10_000L
            val unixMillis = (ticks - unixEpochTicks) / ticksPerMillisecond
            val date = Date(unixMillis)

            val formatString = if (arguments.size > 1) arguments[1] as? String else "yyyy-MM-dd"
            val formatter = SimpleDateFormat(formatString ?: "yyyy-MM-dd", Locale.US)
            formatter.timeZone = TimeZone.getTimeZone("UTC")
            return formatter.format(date)
        }
    }

    /**
     * Converts Unix epoch seconds to a formatted date string.
     * Usage: formatEpoch(1556913600, 'yyyy-MM-ddTHH:mm:ssZ') → "2019-05-03T20:00:00+0000"
     * Usage: formatEpoch(1556913600, 'dddd') → "Friday"
     * Default (no format): ISO 8601 for downstream {{DATE()}} / {{TIME()}} macros.
     */
    class FormatEpoch : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.isEmpty() || arguments.size > 2) {
                throw EvaluationException("formatEpoch expects 1 or 2 arguments, got ${arguments.size}")
            }

            val epochSeconds: Long = when (val arg = arguments[0]) {
                is Long -> arg
                is Int -> arg.toLong()
                is Double -> arg.toLong()
                is String -> arg.toLongOrNull()
                    ?: throw EvaluationException("formatEpoch requires a numeric epoch value")
                else -> throw EvaluationException("formatEpoch requires a numeric epoch value")
            }

            val date = Date(epochSeconds * 1000L)

            val formatString = if (arguments.size > 1) arguments[1] as? String else null
            // Map .NET/AC format patterns to Java SimpleDateFormat
            val javaFormat = formatString?.let { mapToJavaFormat(it) }
                ?: "yyyy-MM-dd'T'HH:mm:ss'Z'"
            val formatter = SimpleDateFormat(javaFormat, Locale.US)
            formatter.timeZone = TimeZone.getTimeZone("UTC")
            return formatter.format(date)
        }

        /** Map common .NET-style format patterns to Java SimpleDateFormat equivalents. */
        private fun mapToJavaFormat(format: String): String = when (format) {
            "dddd" -> "EEEE"           // Full day name (Monday, Tuesday…)
            "ddd" -> "EEE"             // Abbreviated day name (Mon, Tue…)
            "MMMM" -> "MMMM"          // Full month name
            "MMM" -> "MMM"             // Abbreviated month name
            else -> {
                // Quote unrecognized ASCII letters that aren't SimpleDateFormat pattern chars.
                // Common case: literal 'T' separator in ISO dates (yyyy-MM-ddTHH:mm:ssZ).
                val sdfPatternChars = "GyYMLwWdDFEuaHhKkmsSzZX"
                val sb = StringBuilder()
                var inQuote = false
                for (ch in format) {
                    if (ch == '\'') {
                        sb.append(ch)
                        inQuote = !inQuote
                    } else if (!inQuote && ch.isLetter() && ch !in sdfPatternChars) {
                        sb.append("'").append(ch).append("'")
                    } else {
                        sb.append(ch)
                    }
                }
                sb.toString()
            }
        }
    }

    class AddDays : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 2) {
                throw EvaluationException("addDays expects 2 arguments, got ${arguments.size}")
            }

            val date = parseDate(arguments[0])
            val days = toNumber(arguments[1]).toInt()

            val calendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"))
            calendar.time = date
            calendar.add(Calendar.DAY_OF_MONTH, days)

            val formatter = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US)
            formatter.timeZone = TimeZone.getTimeZone("UTC")
            return formatter.format(calendar.time)
        }
    }

    class AddHours : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 2) {
                throw EvaluationException("addHours expects 2 arguments, got ${arguments.size}")
            }

            val date = parseDate(arguments[0])
            val hours = toNumber(arguments[1]).toInt()

            val calendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"))
            calendar.time = date
            calendar.add(Calendar.HOUR_OF_DAY, hours)

            val formatter = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US)
            formatter.timeZone = TimeZone.getTimeZone("UTC")
            return formatter.format(calendar.time)
        }
    }

    class GetYear : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 1) {
                throw EvaluationException("getYear expects 1 argument, got ${arguments.size}")
            }

            val date = parseDate(arguments[0])
            val calendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"))
            calendar.time = date
            return calendar.get(Calendar.YEAR)
        }
    }

    class GetMonth : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 1) {
                throw EvaluationException("getMonth expects 1 argument, got ${arguments.size}")
            }

            val date = parseDate(arguments[0])
            val calendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"))
            calendar.time = date
            // Calendar.MONTH is 0-based (0-11), so add 1 to return 1-12 (January=1, December=12)
            return calendar.get(Calendar.MONTH) + 1
        }
    }

    class GetDay : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 1) {
                throw EvaluationException("getDay expects 1 argument, got ${arguments.size}")
            }

            val date = parseDate(arguments[0])
            val calendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"))
            calendar.time = date
            return calendar.get(Calendar.DAY_OF_MONTH)
        }
    }

    class DateDiff : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 2) {
                throw EvaluationException("dateDiff expects 2 arguments, got ${arguments.size}")
            }

            val date1 = parseDate(arguments[0])
            val date2 = parseDate(arguments[1])

            val diffInMillis = date2.time - date1.time
            return (diffInMillis / (1000 * 60 * 60 * 24)).toInt()
        }
    }

    class UtcNow : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.isNotEmpty()) {
                throw EvaluationException("utcNow expects 0 arguments, got ${arguments.size}")
            }

            val formatter = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US)
            formatter.timeZone = TimeZone.getTimeZone("UTC")
            return formatter.format(Date())
        }
    }

    // MARK: - Helpers

    private fun parseDate(value: Any?): Date {
        if (value is Date) {
            return value
        } else if (value is String) {
            // Try ISO 8601 format with timezone
            try {
                val formatter = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US)
                formatter.timeZone = TimeZone.getTimeZone("UTC")
                return formatter.parse(value) ?: Date()
            } catch (e: Exception) {
                // Ignore and try other formats
            }

            // Try ISO 8601 with timezone offset (+0000 / +00:00)
            try {
                val tzFormatter = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Locale.US)
                tzFormatter.timeZone = TimeZone.getTimeZone("UTC")
                return tzFormatter.parse(value) ?: Date()
            } catch (_: Exception) { }

            // Try standard formats (always use UTC to prevent off-by-one day shifts)
            val formats = listOf("yyyy-MM-dd", "yyyy-MM-dd'T'HH:mm:ss", "MM/dd/yyyy HH:mm:ss", "MM/dd/yyyy")
            for (format in formats) {
                try {
                    val formatter = SimpleDateFormat(format, Locale.US)
                    formatter.timeZone = TimeZone.getTimeZone("UTC")
                    return formatter.parse(value) ?: continue
                } catch (e: Exception) {
                    // Ignore and try next format
                }
            }
        }

        // Default to current date if parsing fails
        return Date()
    }

    private fun toNumber(value: Any?): Double {
        return when (value) {
            is Double -> value
            is Int -> value.toDouble()
            is Long -> value.toDouble()
            is Float -> value.toDouble()
            is String -> value.toDoubleOrNull() ?: 0.0
            is Boolean -> if (value) 1.0 else 0.0
            else -> 0.0
        }
    }
}
