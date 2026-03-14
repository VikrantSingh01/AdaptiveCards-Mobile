// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.templating

import org.json.JSONObject

/**
 * Template engine for expanding Adaptive Card templates with data binding
 */
class TemplateEngine {
    private val parser = ExpressionParser()

    /**
     * Resolve `${rs:key}` string resource references in a raw JSON string.
     * Must be called **before** template expansion or JSON parsing.
     *
     * @param json Raw card JSON string (may contain `${rs:key}` references)
     * @param locale Preferred locale for localized values (e.g. "en-US"). Falls back to `defaultValue`.
     * @return JSON string with all valid `${rs:key}` patterns replaced
     */
    fun resolveStringResources(json: String, locale: String? = null): String {
        val root = try { JSONObject(json) } catch (_: Exception) { return json }
        val resources = root.optJSONObject("resources") ?: return json
        val strings = resources.optJSONObject("strings") ?: return json

        // Build a flat lookup: key -> resolved string
        val lookup = mutableMapOf<String, String>()
        for (key in strings.keys()) {
            val entry = strings.optJSONObject(key) ?: continue
            val defaultValue = entry.optString("defaultValue", "")

            if (locale != null) {
                val localizedValues = entry.optJSONObject("localizedValues")
                if (localizedValues != null) {
                    // Case-insensitive locale match
                    val resolved = localizedValues.keys().asSequence().firstOrNull { localeKey ->
                        localeKey.equals(locale, ignoreCase = true)
                    }?.let { localizedValues.optString(it) }
                    lookup[key] = resolved ?: defaultValue
                } else {
                    lookup[key] = defaultValue
                }
            } else {
                lookup[key] = defaultValue
            }
        }

        if (lookup.isEmpty()) return json

        // Replace all ${rs:key} patterns (case-sensitive: only lowercase "rs:" is valid)
        var result = json
        for ((key, value) in lookup) {
            val escapedValue = value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
            result = result.replace("\${rs:$key}", escapedValue)
        }

        return result
    }

    /**
     * Expand a template string with data binding.
     * If the template is valid JSON, uses structured expansion (parse → expand → serialize)
     * to ensure the output remains valid JSON. Falls back to string-based expansion.
     * @param template Template string containing ${...} expressions
     * @param data Data object for binding
     * @return Expanded string
     */
    fun expand(template: String, data: Map<String, Any?>): String {
        // Try structured JSON expansion first (produces valid JSON output)
        try {
            val jsonObject = org.json.JSONObject(template)
            val parsed = jsonToMap(jsonObject)
            val context = DataContext(data = data)
            val expanded = expandDictionary(parsed, context)
            return toJsonObject(expanded).toString()
        } catch (_: Exception) {
            // Fallback to string-based expansion for non-JSON templates
        }
        val context = DataContext(data = data)
        return expandString(template, context)
    }

    /** Recursively converts a Map/List/primitive structure to org.json types */
    private fun toJsonValue(value: Any?): Any = when (value) {
        null -> org.json.JSONObject.NULL
        is Map<*, *> -> {
            val obj = org.json.JSONObject()
            for ((k, v) in value) {
                obj.put(k as? String ?: k.toString(), toJsonValue(v))
            }
            obj
        }
        is List<*> -> {
            val arr = org.json.JSONArray()
            for (item in value) {
                arr.put(toJsonValue(item))
            }
            arr
        }
        is Boolean, is Int, is Long, is Double, is Float, is String -> value
        else -> value.toString()
    }

    private fun toJsonObject(map: Map<String, Any?>): org.json.JSONObject {
        val obj = org.json.JSONObject()
        for ((key, value) in map) {
            obj.put(key, toJsonValue(value))
        }
        return obj
    }

    private fun jsonToMap(json: org.json.JSONObject): Map<String, Any?> {
        val map = mutableMapOf<String, Any?>()
        for (key in json.keys()) {
            map[key] = jsonElementToAny(json.get(key))
        }
        return map
    }

    private fun jsonElementToAny(value: Any?): Any? = when (value) {
        is org.json.JSONObject -> jsonToMap(value)
        is org.json.JSONArray -> (0 until value.length()).map { jsonElementToAny(value.get(it)) }
        org.json.JSONObject.NULL -> null
        else -> value
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
                        val parsedExpression = parser.parse(extractExpression(value))
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
                            val parsedExpression = parser.parse(extractExpression(dataBinding))
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
                            } else if (dataValue != null) {
                                // Single object: set as data context for this element
                                val childContext = DataContext(data = dataValue, root = context.root, index = null, parent = context)
                                val itemTemplate = dict.toMutableMap()
                                itemTemplate.remove("\$data")
                                val expandedItem = expandDictionary(itemTemplate, childContext)
                                if (expandedItem.isNotEmpty()) {
                                    result.add(expandedItem)
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
            is String -> {
                // If the entire string is a single ${expr}, return the native evaluated value
                // (preserving arrays, objects, numbers, booleans) instead of stringifying.
                val trimmed = value.trim()
                if (trimmed.startsWith("\${") && trimmed.endsWith("}")) {
                    // Verify it's a single expression (no text before/after, balanced braces)
                    var braceCount = 0
                    var firstCloseIndex = -1
                    for (i in 2 until trimmed.length) {
                        when (trimmed[i]) {
                            '{' -> braceCount++
                            '}' -> {
                                if (braceCount == 0) {
                                    firstCloseIndex = i
                                    break
                                }
                                braceCount--
                            }
                        }
                    }
                    if (firstCloseIndex == trimmed.length - 1) {
                        // Pure expression — return native value
                        val expression = trimmed.substring(2, trimmed.length - 1)
                        try {
                            val parsed = parser.parse(expression)
                            val evaluator = ExpressionEvaluator(context)
                            val result = evaluator.evaluate(parsed)
                            // Return native type for complex values; coerce null to empty string
                            return result ?: ""
                        } catch (_: Exception) {
                            return value // Leave as-is on error
                        }
                    }
                }
                expandString(value, context)
            }
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

    /**
     * Extract the raw expression from a template expression string.
     * If the string is wrapped in ${...}, strip the wrapper and return the inner expression.
     * Otherwise, return the string as-is.
     */
    private fun extractExpression(templateExpr: String): String {
        val trimmed = templateExpr.trim()
        return if (trimmed.startsWith("\${") && trimmed.endsWith("}")) {
            trimmed.substring(2, trimmed.length - 1)
        } else {
            trimmed
        }
    }

    private fun stringValue(value: Any?): String {
        return when (value) {
            is String -> value
            is Double -> {
                // Format numbers without unnecessary decimal places
                if (value % 1.0 == 0.0) {
                    value.toLong().toString()
                } else {
                    value.toString()
                }
            }
            is Int -> value.toString()
            is Long -> value.toString()
            is Boolean -> value.toString()
            null -> ""
            is Map<*, *> -> {
                // Serialize maps as valid JSON
                try {
                    org.json.JSONObject(value).toString()
                } catch (_: Exception) { "{}" }
            }
            is List<*> -> {
                // Serialize lists as valid JSON
                try {
                    org.json.JSONArray(value).toString()
                } catch (_: Exception) { "[]" }
            }
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
