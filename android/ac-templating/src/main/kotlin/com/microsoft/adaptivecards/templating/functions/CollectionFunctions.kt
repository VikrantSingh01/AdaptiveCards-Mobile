package com.microsoft.adaptivecards.templating.functions

import com.microsoft.adaptivecards.templating.EvaluationException
import com.microsoft.adaptivecards.templating.ExpressionFunction

/**
 * Collection manipulation functions for template expressions
 */
object CollectionFunctions {
    fun register(functions: MutableMap<String, ExpressionFunction>) {
        functions["count"] = Count()
        functions["first"] = First()
        functions["last"] = Last()
        functions["filter"] = Filter()
        functions["sort"] = Sort()
        functions["flatten"] = Flatten()
        functions["union"] = Union()
        functions["intersection"] = Intersection()
    }

    // MARK: - Function Implementations

    class Count : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 1) {
                throw EvaluationException("count expects 1 argument, got ${arguments.size}")
            }

            return when (val arg = arguments[0]) {
                is List<*> -> arg.size
                is Map<*, *> -> arg.size
                is String -> arg.length
                else -> 0
            }
        }
    }

    class First : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 1) {
                throw EvaluationException("first expects 1 argument, got ${arguments.size}")
            }

            val array = arguments[0] as? List<*> ?: return null
            return if (array.isNotEmpty()) array.first() else null
        }
    }

    class Last : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 1) {
                throw EvaluationException("last expects 1 argument, got ${arguments.size}")
            }

            val array = arguments[0] as? List<*> ?: return null
            return if (array.isNotEmpty()) array.last() else null
        }
    }

    class Filter : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.isEmpty()) {
                throw EvaluationException("filter expects at least 1 argument, got ${arguments.size}")
            }

            val array = arguments[0] as? List<*> ?: return emptyList<Any>()

            // Simple filter: keep non-null, non-empty elements
            return array.filter { element ->
                when {
                    element == null -> false
                    element is String -> element.isNotEmpty()
                    else -> true
                }
            }
        }
    }

    class Sort : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 1) {
                throw EvaluationException("sort expects 1 argument, got ${arguments.size}")
            }

            val array = arguments[0] as? List<*> ?: return emptyList<Any>()

            return array.sortedWith { left, right ->
                when {
                    left is Number && right is Number -> {
                        left.toDouble().compareTo(right.toDouble())
                    }
                    left is String && right is String -> {
                        left.compareTo(right)
                    }
                    else -> {
                        left.toString().compareTo(right.toString())
                    }
                }
            }
        }
    }

    class Flatten : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 1) {
                throw EvaluationException("flatten expects 1 argument, got ${arguments.size}")
            }

            val array = arguments[0] as? List<*> ?: return emptyList<Any>()

            val result = mutableListOf<Any?>()
            for (element in array) {
                if (element is List<*>) {
                    result.addAll(element)
                } else {
                    result.add(element)
                }
            }

            return result
        }
    }

    class Union : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 2) {
                throw EvaluationException("union expects 2 arguments, got ${arguments.size}")
            }

            val array1 = arguments[0] as? List<*> ?: return emptyList<Any>()
            val array2 = arguments[1] as? List<*> ?: return emptyList<Any>()

            val result = array1.toMutableList()
            for (element in array2) {
                val elementStr = element.toString()
                if (!result.any { it.toString() == elementStr }) {
                    result.add(element)
                }
            }

            return result
        }
    }

    class Intersection : ExpressionFunction {
        override fun call(arguments: List<Any?>): Any? {
            if (arguments.size != 2) {
                throw EvaluationException("intersection expects 2 arguments, got ${arguments.size}")
            }

            val array1 = arguments[0] as? List<*> ?: return emptyList<Any>()
            val array2 = arguments[1] as? List<*> ?: return emptyList<Any>()

            val array2Strings = array2.map { it.toString() }.toSet()
            return array1.filter { element ->
                val elementStr = element.toString()
                array2Strings.contains(elementStr)
            }
        }
    }
}
