package com.microsoft.adaptivecards.templating.functions

import com.microsoft.adaptivecards.templating.ExpressionFunction

/**
 * Type conversion functions for the expression engine.
 * Ported from production Teams-AdaptiveCards-Mobile SDK.
 */
object ConversionFunctions {
    fun register(functions: MutableMap<String, ExpressionFunction>) {
        functions["parseInt"] = ParseIntFunction()
        functions["parseFloat"] = ParseFloatFunction()
        functions["toString"] = ToStringFunction()
        functions["toNumber"] = ToNumberFunction()
        functions["toBool"] = ToBoolFunction()
        functions["float"] = ParseFloatFunction()    // alias
        functions["int"] = ParseIntFunction()        // alias
        functions["string"] = ToStringFunction()     // alias
    }
}

/** Converts a value to an integer */
private class ParseIntFunction : ExpressionFunction {
    override fun call(arguments: List<Any?>): Any? {
        if (arguments.size != 1) throw IllegalArgumentException("parseInt requires 1 argument, got ${arguments.size}")
        return when (val value = arguments[0]) {
            is Number -> value.toInt().toDouble()
            is String -> value.toIntOrNull()?.toDouble()
                ?: value.toDoubleOrNull()?.toInt()?.toDouble()
                ?: throw IllegalArgumentException("Cannot parse '$value' as integer")
            is Boolean -> if (value) 1.0 else 0.0
            null -> 0.0
            else -> throw IllegalArgumentException("Cannot convert ${value::class.simpleName} to integer")
        }
    }
}

/** Converts a value to a floating-point number */
private class ParseFloatFunction : ExpressionFunction {
    override fun call(arguments: List<Any?>): Any? {
        if (arguments.size != 1) throw IllegalArgumentException("parseFloat requires 1 argument, got ${arguments.size}")
        return when (val value = arguments[0]) {
            is Number -> value.toDouble()
            is String -> value.toDoubleOrNull()
                ?: throw IllegalArgumentException("Cannot parse '$value' as float")
            is Boolean -> if (value) 1.0 else 0.0
            null -> 0.0
            else -> throw IllegalArgumentException("Cannot convert ${value::class.simpleName} to float")
        }
    }
}

/** Converts a value to its string representation */
private class ToStringFunction : ExpressionFunction {
    override fun call(arguments: List<Any?>): Any? {
        if (arguments.size != 1) throw IllegalArgumentException("toString requires 1 argument, got ${arguments.size}")
        return when (val value = arguments[0]) {
            is String -> value
            is Double -> if (value == value.toLong().toDouble()) value.toLong().toString() else value.toString()
            is Number -> value.toString()
            is Boolean -> value.toString()
            null -> ""
            else -> value.toString()
        }
    }
}

/** Converts a value to a number */
private class ToNumberFunction : ExpressionFunction {
    override fun call(arguments: List<Any?>): Any? {
        if (arguments.size != 1) throw IllegalArgumentException("toNumber requires 1 argument, got ${arguments.size}")
        return when (val value = arguments[0]) {
            is Number -> value.toDouble()
            is String -> value.toDoubleOrNull()
                ?: throw IllegalArgumentException("Cannot convert '$value' to number")
            is Boolean -> if (value) 1.0 else 0.0
            null -> 0.0
            else -> throw IllegalArgumentException("Cannot convert ${value::class.simpleName} to number")
        }
    }
}

/** Converts a value to a boolean */
private class ToBoolFunction : ExpressionFunction {
    override fun call(arguments: List<Any?>): Any? {
        if (arguments.size != 1) throw IllegalArgumentException("toBool requires 1 argument, got ${arguments.size}")
        return when (val value = arguments[0]) {
            is Boolean -> value
            is Number -> value.toDouble() != 0.0
            is String -> {
                val lower = value.lowercase()
                when {
                    lower == "true" || lower == "1" || lower == "yes" -> true
                    lower == "false" || lower == "0" || lower == "no" || lower.isEmpty() -> false
                    else -> value.isNotEmpty()
                }
            }
            is List<*> -> value.isNotEmpty()
            null -> false
            else -> true
        }
    }
}
