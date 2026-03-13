// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.templating.functions

import com.microsoft.adaptivecards.templating.EvaluationException
import com.microsoft.adaptivecards.templating.ExpressionFunction
import kotlin.math.abs
import kotlin.math.ceil
import kotlin.math.floor
import kotlin.math.round

/**
 * Mathematical functions for template expressions
 */
object MathFunctions {
    fun register(functions: MutableMap<String, ExpressionFunction>) {
        functions["add"] = Add()
        functions["sub"] = Sub()
        functions["mul"] = Mul()
        functions["div"] = Div()
        functions["mod"] = Mod()
        functions["min"] = Min()
        functions["max"] = Max()
        functions["round"] = Round()
        functions["floor"] = Floor()
        functions["ceil"] = Ceil()
        functions["abs"] = Abs()
        functions["sum"] = Sum()
        functions["formatNumber"] = FormatNumber()
    }

    // MARK: - Function Implementations

    class Add : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size < 2) {
                throw EvaluationException("add expects at least 2 arguments, got ${arguments.size}")
            }
            return arguments.fold(0.0) { acc, arg -> acc + toNumber(arg) }
        }
    }

    class Sub : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 2) {
                throw EvaluationException("sub expects 2 arguments, got ${arguments.size}")
            }
            return toNumber(arguments[0]) - toNumber(arguments[1])
        }
    }

    class Mul : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size < 2) {
                throw EvaluationException("mul expects at least 2 arguments, got ${arguments.size}")
            }
            return arguments.fold(1.0) { acc, arg -> acc * toNumber(arg) }
        }
    }

    class Div : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 2) {
                throw EvaluationException("div expects 2 arguments, got ${arguments.size}")
            }

            val divisor = toNumber(arguments[1])
            if (divisor == 0.0) {
                throw EvaluationException("Division by zero")
            }

            return toNumber(arguments[0]) / divisor
        }
    }

    class Mod : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 2) {
                throw EvaluationException("mod expects 2 arguments, got ${arguments.size}")
            }

            val divisor = toNumber(arguments[1])
            if (divisor == 0.0) {
                throw EvaluationException("Division by zero")
            }

            return toNumber(arguments[0]) % divisor
        }
    }

    class Min : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.isEmpty()) {
                throw EvaluationException("min expects at least 1 argument")
            }
            // If single argument is an array, find min within it
            if (arguments.size == 1 && arguments[0] is List<*>) {
                val array = arguments[0] as? List<*> ?: return 0.0 // pre-commit:allow
                return array.map { toNumber(it) }.minOrNull() ?: 0.0
            }
            return arguments.map { toNumber(it) }.minOrNull() ?: 0.0
        }
    }

    class Max : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.isEmpty()) {
                throw EvaluationException("max expects at least 1 argument")
            }
            // If single argument is an array, find max within it
            if (arguments.size == 1 && arguments[0] is List<*>) {
                val array = arguments[0] as? List<*> ?: return 0.0 // pre-commit:allow
                return array.map { toNumber(it) }.maxOrNull() ?: 0.0
            }
            return arguments.map { toNumber(it) }.maxOrNull() ?: 0.0
        }
    }

    class Sum : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 1) {
                throw EvaluationException("sum expects 1 argument, got ${arguments.size}")
            }
            // Sum elements of an array
            if (arguments[0] is List<*>) {
                val array = arguments[0] as? List<*> ?: return 0.0 // pre-commit:allow
                return array.fold(0.0) { acc, element -> acc + toNumber(element) }
            }
            return toNumber(arguments[0])
        }
    }

    class Round : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 1) {
                throw EvaluationException("round expects 1 argument, got ${arguments.size}")
            }
            return round(toNumber(arguments[0]))
        }
    }

    class Floor : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 1) {
                throw EvaluationException("floor expects 1 argument, got ${arguments.size}")
            }
            return floor(toNumber(arguments[0]))
        }
    }

    class Ceil : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 1) {
                throw EvaluationException("ceil expects 1 argument, got ${arguments.size}")
            }
            return ceil(toNumber(arguments[0]))
        }
    }

    class Abs : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 1) {
                throw EvaluationException("abs expects 1 argument, got ${arguments.size}")
            }
            return abs(toNumber(arguments[0]))
        }
    }

    /**
     * Formats a number to a specified number of decimal places.
     * Usage: formatNumber(128.9, 2) → "128.90"
     */
    class FormatNumber : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 2) {
                throw EvaluationException("formatNumber expects 2 arguments, got ${arguments.size}")
            }

            val number = toNumber(arguments[0])
            val decimals = toNumber(arguments[1]).toInt()

            return String.format("%.${decimals}f", number)
        }
    }

    // MARK: - Helper

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
