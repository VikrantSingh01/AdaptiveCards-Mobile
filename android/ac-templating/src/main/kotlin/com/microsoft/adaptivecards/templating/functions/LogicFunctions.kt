package com.microsoft.adaptivecards.templating.functions

import com.microsoft.adaptivecards.templating.EvaluationException
import com.microsoft.adaptivecards.templating.ExpressionFunction

/**
 * Logic and comparison functions for template expressions
 */
object LogicFunctions {
    fun register(functions: MutableMap<String, ExpressionFunction>) {
        functions["if"] = If()
        functions["equals"] = Equals()
        functions["not"] = Not()
        functions["and"] = And()
        functions["or"] = Or()
        functions["greaterThan"] = GreaterThan()
        functions["lessThan"] = LessThan()
        functions["exists"] = Exists()
        functions["empty"] = Empty()
        functions["isMatch"] = IsMatch()
    }

    // MARK: - Function Implementations

    class If : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 3) {
                throw EvaluationException("if expects 3 arguments, got ${arguments.size}")
            }
            val condition = toBool(arguments[0])
            return if (condition) arguments[1] else arguments[2]
        }
    }

    class Equals : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 2) {
                throw EvaluationException("equals expects 2 arguments, got ${arguments.size}")
            }
            return isEqual(arguments[0], arguments[1])
        }
    }

    class Not : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 1) {
                throw EvaluationException("not expects 1 argument, got ${arguments.size}")
            }
            return !toBool(arguments[0])
        }
    }

    class And : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size < 2) {
                throw EvaluationException("and expects at least 2 arguments, got ${arguments.size}")
            }
            return arguments.all { toBool(it) }
        }
    }

    class Or : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size < 2) {
                throw EvaluationException("or expects at least 2 arguments, got ${arguments.size}")
            }
            return arguments.any { toBool(it) }
        }
    }

    class GreaterThan : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 2) {
                throw EvaluationException("greaterThan expects 2 arguments, got ${arguments.size}")
            }
            val left = toNumber(arguments[0])
            val right = toNumber(arguments[1])
            return left > right
        }
    }

    class LessThan : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 2) {
                throw EvaluationException("lessThan expects 2 arguments, got ${arguments.size}")
            }
            val left = toNumber(arguments[0])
            val right = toNumber(arguments[1])
            return left < right
        }
    }

    class Exists : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 1) {
                throw EvaluationException("exists expects 1 argument, got ${arguments.size}")
            }
            return arguments[0] != null
        }
    }

    class Empty : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 1) {
                throw EvaluationException("empty expects 1 argument, got ${arguments.size}")
            }

            return when (val arg = arguments[0]) {
                null -> true
                is String -> arg.isEmpty()
                is List<*> -> arg.isEmpty()
                is Map<*, *> -> arg.isEmpty()
                else -> false
            }
        }
    }

    class IsMatch : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 2) {
                throw EvaluationException("isMatch expects 2 arguments, got ${arguments.size}")
            }

            val str = arguments[0] as? String ?: return false
            val pattern = arguments[1] as? String ?: return false

            return try {
                str.matches(Regex(pattern))
            } catch (e: Exception) {
                false
            }
        }
    }

    // MARK: - Helpers

    private fun toBool(value: Any?): Boolean {
        return when (value) {
            is Boolean -> value
            is Double -> value != 0.0
            is Int -> value != 0
            is Long -> value != 0L
            is Float -> value != 0.0f
            is String -> value.isNotEmpty()
            null -> false
            is List<*> -> value.isNotEmpty()
            is Map<*, *> -> value.isNotEmpty()
            else -> true
        }
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

    private fun isEqual(left: Any?, right: Any?): Boolean {
        if (left == null && right == null) return true
        if (left == null || right == null) return false

        if (left is Number && right is Number) {
            return left.toDouble() == right.toDouble()
        }
        if (left is String && right is String) {
            return left == right
        }
        if (left is Boolean && right is Boolean) {
            return left == right
        }

        return left.toString() == right.toString()
    }
}
