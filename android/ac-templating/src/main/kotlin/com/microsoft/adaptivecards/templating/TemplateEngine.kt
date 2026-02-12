package com.microsoft.adaptivecards.templating

/**
 * Template engine for expanding Adaptive Card templates with data binding
 */
class TemplateEngine {
    private val parser = ExpressionParser()

    /**
     * Expand a template string with data binding
     * @param template Template string containing ${...} expressions
     * @param data Data object for binding
     * @return Expanded string
     */
    fun expand(template: String, data: Map<String, Any?>): String {
        val context = DataContext(data = data)
        return expandString(template, context)
    }

    /**
     * Expand a template JSON object with data binding
     * @param template Template JSON map
     * @param data Data object for binding
     * @return Expanded JSON map
     */
    fun expand(template: Map<String, Any?>, data: Map<String, Any?>): Map<String, Any?> {
        val context = DataContext(data = data)
        return expandDictionary(template, context)
    }

    /**
     * Expand any template value with data binding
     * @param template Template value (can be String, Map, List, or primitive)
     * @param data Data object for binding
     * @return Expanded value
     */
    fun expand(template: Any?, data: Any?): Any? {
        val context = DataContext(data = data)
        return expandValue(template, context)
    }

    // MARK: - Private Methods

    private fun expandString(string: String, context: DataContext): String {
        var result = string
        var searchIndex = 0

        while (searchIndex < result.length) {
            // Find next ${
            val startIndex = result.indexOf("\${", searchIndex)
            if (startIndex == -1) {
                break
            }

            // Find matching }
            var braceCount = 1
            var endIndex = startIndex + 2

            while (endIndex < result.length && braceCount > 0) {
                val char = result[endIndex]
                if (char == '{') {
                    braceCount++
                } else if (char == '}') {
                    braceCount--
                }

                if (braceCount > 0) {
                    endIndex++
                }
            }

            if (braceCount != 0) {
                throw TemplatingException("Unmatched brace in template expression")
            }

            // Extract expression
            val expression = result.substring(startIndex + 2, endIndex)

            // Evaluate expression
            val value = try {
                val parsedExpression = parser.parse(expression)
                val evaluator = ExpressionEvaluator(context)
                evaluator.evaluate(parsedExpression)
            } catch (e: Exception) {
                // On error, leave expression as-is or return empty string
                null
            }

            // Replace ${expression} with value
            val replacement = stringValue(value)
            result = result.substring(0, startIndex) + replacement + result.substring(endIndex + 1)

            // Update search position
            searchIndex = startIndex + replacement.length
        }

        return result
    }

    private fun expandDictionary(dict: Map<String, Any?>, context: DataContext): Map<String, Any?> {
        val result = mutableMapOf<String, Any?>()

        for ((key, value) in dict) {
            // Handle $when condition
            if (key == "\$when") {
                if (value is String) {
                    try {
                        val parsedExpression = parser.parse(value)
                        val evaluator = ExpressionEvaluator(context)
                        val conditionResult = evaluator.evaluate(parsedExpression)

                        // If condition is false, skip this entire dictionary
                        if (!toBool(conditionResult)) {
                            return emptyMap()
                        }
                    } catch (e: Exception) {
                        // If evaluation fails, skip this dictionary
                        return emptyMap()
                    }
                }
                continue // Don't include $when in output
            }

            // Expand value
            result[key] = expandValue(value, context)
        }

        return result
    }

    private fun expandArray(array: List<Any?>, context: DataContext): List<Any?> {
        val result = mutableListOf<Any?>()

        for (item in array) {
            if (item is Map<*, *>) {
                @Suppress("UNCHECKED_CAST")
                val dict = item as? Map<String, Any?> ?: continue

                // Check for $data iteration
                if (dict.containsKey("\$data")) {
                    val dataBinding = dict["\$data"] as? String
                    if (dataBinding != null) {
                        try {
                            val parsedExpression = parser.parse(dataBinding)
                            val evaluator = ExpressionEvaluator(context)
                            val dataValue = evaluator.evaluate(parsedExpression)

                            if (dataValue is List<*>) {
                                // Iterate over data array
                                dataValue.forEachIndexed { index, dataItem ->
                                    val childContext = context.createChild(dataItem, index)

                                    // Expand the template for this item (excluding $data key)
                                    val itemTemplate = dict.toMutableMap()
                                    itemTemplate.remove("\$data")

                                    val expandedItem = expandDictionary(itemTemplate, childContext)

                                    // Only add if not empty (could be filtered by $when)
                                    if (expandedItem.isNotEmpty()) {
                                        result.add(expandedItem)
                                    }
                                }
                                continue
                            }
                        } catch (e: Exception) {
                            // If evaluation fails, skip this item
                            continue
                        }
                    }
                }

                // Regular dictionary expansion
                val expandedDict = expandDictionary(dict, context)
                if (expandedDict.isNotEmpty()) {
                    result.add(expandedDict)
                }
            } else {
                result.add(expandValue(item, context))
            }
        }

        return result
    }

    private fun expandValue(value: Any?, context: DataContext): Any? {
        return when (value) {
            is String -> expandString(value, context)
            is Map<*, *> -> {
                @Suppress("UNCHECKED_CAST")
                expandDictionary(value as? Map<String, Any?> ?: emptyMap(), context)
            }
            is List<*> -> {
                @Suppress("UNCHECKED_CAST")
                expandArray(value as? List<Any?> ?: emptyList(), context)
            }
            else -> value
        }
    }

    // MARK: - Helpers

    private fun stringValue(value: Any?): String {
        return when (value) {
            is String -> value
            is Double -> {
                // Format numbers without unnecessary decimal places
                if (value % 1.0 == 0.0) {
                    value.toInt().toString()
                } else {
                    value.toString()
                }
            }
            is Int -> value.toString()
            is Boolean -> value.toString()
            null -> ""
            else -> value.toString()
        }
    }

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
}

/**
 * Exception thrown when template expansion fails
 */
class TemplatingException(message: String, cause: Throwable? = null) : Exception(message, cause)
