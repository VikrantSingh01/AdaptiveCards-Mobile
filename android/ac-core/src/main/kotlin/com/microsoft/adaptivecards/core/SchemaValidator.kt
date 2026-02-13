package com.microsoft.adaptivecards.core

import kotlinx.serialization.json.*

data class SchemaValidationError(
    val path: String,
    val message: String,
    val expected: String? = null,
    val actual: String? = null
)

class SchemaValidator {
    companion object {
        val VALID_ELEMENT_TYPES = setOf(
            "TextBlock", "Image", "Media", "RichTextBlock", "Container", "ColumnSet",
            "ImageSet", "FactSet", "ActionSet", "Table", "Input.Text", "Input.Number",
            "Input.Date", "Input.Time", "Input.Toggle", "Input.ChoiceSet", "Carousel",
            "Accordion", "CodeBlock", "Rating", "Input.Rating", "ProgressBar", "Spinner",
            "TabSet", "List", "CompoundButton", "DonutChart", "BarChart", "LineChart", "PieChart"
        )
    }
    
    fun validate(json: String): List<SchemaValidationError> {
        val errors = mutableListOf<SchemaValidationError>()
        
        val jsonObject = try {
            Json.parseToJsonElement(json) as? JsonObject ?: throw IllegalArgumentException("Expected JSON object")
        } catch (e: Exception) {
            errors.add(SchemaValidationError(
                path = "$",
                message = "Invalid JSON structure",
                expected = "Valid JSON object",
                actual = e.message ?: "Parse error"
            ))
            return errors
        }
        
        // Validate required fields
        if (!jsonObject.containsKey("type")) {
            errors.add(SchemaValidationError(
                path = "$.type",
                message = "Missing required field",
                expected = "type: String",
                actual = "undefined"
            ))
        } else {
            val type = (jsonObject["type"] as? JsonPrimitive)?.content
            if (type != "AdaptiveCard") {
                errors.add(SchemaValidationError(
                    path = "$.type",
                    message = "Invalid card type",
                    expected = "AdaptiveCard",
                    actual = type ?: "null"
                ))
            }
        }
        
        if (!jsonObject.containsKey("version")) {
            errors.add(SchemaValidationError(
                path = "$.version",
                message = "Missing required field",
                expected = "version: String",
                actual = "undefined"
            ))
        } else {
            val version = (jsonObject["version"] as? JsonPrimitive)?.content
            if (version != null && !Regex("""^\d+\.\d+$""").matches(version)) {
                errors.add(SchemaValidationError(
                    path = "$.version",
                    message = "Invalid version format",
                    expected = "X.Y format (e.g., 1.5)",
                    actual = version
                ))
            }
        }
        
        // Validate body array if present
        jsonObject["body"]?.let { body ->
            val bodyArray = body as? JsonArray
            if (bodyArray != null) {
                bodyArray.forEachIndexed { index, element ->
                    val elementObj = element as? JsonObject
                    if (elementObj != null) {
                        errors.addAll(validateElement(elementObj, "$.body[$index]"))
                    }
                }
            } else {
                errors.add(SchemaValidationError(
                    path = "$.body",
                    message = "Invalid type",
                    expected = "Array",
                    actual = body.toString()
                ))
            }
        }
        
        // Validate actions array if present
        jsonObject["actions"]?.let { actions ->
            if (actions !is JsonArray) {
                errors.add(SchemaValidationError(
                    path = "$.actions",
                    message = "Invalid type",
                    expected = "Array",
                    actual = actions.toString()
                ))
            }
        }
        
        return errors
    }
    
    private fun validateElement(
        element: JsonObject,
        path: String
    ): List<SchemaValidationError> {
        val errors = mutableListOf<SchemaValidationError>()

        if (!element.containsKey("type")) {
            errors.add(SchemaValidationError(
                path = "$path.type",
                message = "Missing required field",
                expected = "type: String",
                actual = "undefined"
            ))
        } else {
            val type = (element["type"] as? JsonPrimitive)?.content
            
            if (type != null && type !in VALID_ELEMENT_TYPES) {
                errors.add(SchemaValidationError(
                    path = "$path.type",
                    message = "Unknown element type",
                    expected = "One of: ${VALID_ELEMENT_TYPES.sorted().joinToString(", ")}",
                    actual = type
                ))
            }
        }
        
        return errors
    }
}
