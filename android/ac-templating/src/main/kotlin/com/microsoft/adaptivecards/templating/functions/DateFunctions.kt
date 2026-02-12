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

            val formatter = SimpleDateFormat(formatString ?: "yyyy-MM-dd", Locale.US)
            return formatter.format(date)
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
            val calendar = Calendar.getInstance()
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
            val calendar = Calendar.getInstance()
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
            val calendar = Calendar.getInstance()
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

            // Try standard formats
            val formats = listOf("yyyy-MM-dd", "yyyy-MM-dd'T'HH:mm:ss", "MM/dd/yyyy")
            for (format in formats) {
                try {
                    val formatter = SimpleDateFormat(format, Locale.US)
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
