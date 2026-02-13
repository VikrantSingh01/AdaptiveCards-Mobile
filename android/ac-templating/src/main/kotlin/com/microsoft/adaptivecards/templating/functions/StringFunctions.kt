package com.microsoft.adaptivecards.templating.functions

import com.microsoft.adaptivecards.templating.EvaluationException
import com.microsoft.adaptivecards.templating.ExpressionFunction

/**
 * String manipulation functions for template expressions
 */
object StringFunctions {
    fun register(functions: MutableMap<String, ExpressionFunction>) {
        functions["toLower"] = ToLower()
        functions["toUpper"] = ToUpper()
        functions["substring"] = Substring()
        functions["indexOf"] = IndexOf()
        functions["length"] = Length()
        functions["replace"] = Replace()
        functions["split"] = Split()
        functions["join"] = Join()
        functions["trim"] = Trim()
        functions["startsWith"] = StartsWith()
        functions["endsWith"] = EndsWith()
        functions["contains"] = Contains()
        functions["format"] = Format()
        functions["concat"] = Concat()
        functions["string"] = ToString()
    }

    // MARK: - Function Implementations

    class ToLower : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 1) {
                throw EvaluationException("toLower expects 1 argument, got ${arguments.size}")
            }
            val str = arguments[0] as? String ?: return arguments[0]
            return str.lowercase()
        }
    }

    class ToUpper : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 1) {
                throw EvaluationException("toUpper expects 1 argument, got ${arguments.size}")
            }
            val str = arguments[0] as? String ?: return arguments[0]
            return str.uppercase()
        }
    }

    class Substring : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size < 2 || arguments.size > 3) {
                throw EvaluationException("substring expects 2 or 3 arguments, got ${arguments.size}")
            }

            val str = arguments[0] as? String ?: return arguments[0]
            val start = coerceToInt(arguments[1])

            if (start < 0 || start >= str.length) {
                return str
            }

            return if (arguments.size == 3) {
                val length = coerceToInt(arguments[2])
                val endIndex = minOf(start + length, str.length)
                str.substring(start, endIndex)
            } else {
                str.substring(start)
            }
        }
    }

    class IndexOf : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 2) {
                throw EvaluationException("indexOf expects 2 arguments, got ${arguments.size}")
            }

            val str = arguments[0] as? String ?: return -1
            val search = arguments[1] as? String ?: return -1

            return str.indexOf(search)
        }
    }

    class Length : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 1) {
                throw EvaluationException("length expects 1 argument, got ${arguments.size}")
            }

            return when (val arg = arguments[0]) {
                is String -> arg.length
                is List<*> -> arg.size
                is Map<*, *> -> arg.size
                else -> 0
            }
        }
    }

    class Replace : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 3) {
                throw EvaluationException("replace expects 3 arguments, got ${arguments.size}")
            }

            val str = arguments[0] as? String ?: return arguments[0]
            val search = arguments[1] as? String ?: return arguments[0]
            val replacement = arguments[2] as? String ?: return arguments[0]

            return str.replace(search, replacement)
        }
    }

    class Split : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 2) {
                throw EvaluationException("split expects 2 arguments, got ${arguments.size}")
            }

            val str = arguments[0] as? String ?: return listOf(arguments[0])
            val delimiter = arguments[1] as? String ?: return listOf(arguments[0])

            return str.split(delimiter)
        }
    }

    class Join : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 2) {
                throw EvaluationException("join expects 2 arguments, got ${arguments.size}")
            }

            val array = arguments[0] as? List<*> ?: return ""
            val delimiter = arguments[1] as? String ?: return ""

            return array.joinToString(delimiter) { it.toString() }
        }
    }

    class Trim : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 1) {
                throw EvaluationException("trim expects 1 argument, got ${arguments.size}")
            }

            val str = arguments[0] as? String ?: return arguments[0]
            return str.trim()
        }
    }

    class StartsWith : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 2) {
                throw EvaluationException("startsWith expects 2 arguments, got ${arguments.size}")
            }

            val str = arguments[0] as? String ?: return false
            val prefix = arguments[1] as? String ?: return false

            return str.startsWith(prefix)
        }
    }

    class EndsWith : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 2) {
                throw EvaluationException("endsWith expects 2 arguments, got ${arguments.size}")
            }

            val str = arguments[0] as? String ?: return false
            val suffix = arguments[1] as? String ?: return false

            return str.endsWith(suffix)
        }
    }

    class Contains : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 2) {
                throw EvaluationException("contains expects 2 arguments, got ${arguments.size}")
            }

            when (val container = arguments[0]) {
                is String -> {
                    val search = arguments[1] as? String ?: return false
                    return container.contains(search)
                }
                is List<*> -> {
                    val search = arguments[1]
                    return container.any { it.toString() == search.toString() }
                }
                else -> return false
            }
        }
    }

    class Format : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.isEmpty()) {
                throw EvaluationException("format expects at least 1 argument")
            }

            val format = arguments[0] as? String ?: return arguments[0]
            var result = format

            arguments.drop(1).forEachIndexed { index, arg ->
                val placeholder = "{$index}"
                result = result.replace(placeholder, arg?.toString() ?: "")
            }

            return result
        }
    }

    class Concat : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.isEmpty()) {
                throw EvaluationException("concat expects at least 1 argument")
            }
            return arguments.joinToString("") { it?.toString() ?: "" }
        }
    }

    class ToString : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 1) {
                throw EvaluationException("string expects 1 argument, got ${arguments.size}")
            }
            val value = arguments[0] ?: return ""
            return when (value) {
                is Double -> if (value == value.toLong().toDouble()) value.toLong().toString() else value.toString()
                else -> value.toString()
            }
        }
    }

    // MARK: - Helper

    private fun coerceToInt(value: Any?): Int {
        return when (value) {
            is Int -> value
            is Double -> value.toInt()
            is Long -> value.toInt()
            is Float -> value.toInt()
            is String -> value.toIntOrNull() ?: 0
            else -> throw EvaluationException("Cannot convert $value to integer")
        }
    }
}
