package com.microsoft.adaptivecards.core

import kotlinx.serialization.json.*

data class SchemaValidationError(
    val path: String,
    val message: String,
    val expected: String? = null,
    val actual: String? = null
)

/**
 * Schema validator for Adaptive Cards v1.6
 * Validates card JSON against the v1.6 schema specification
 */
class SchemaValidator {
    companion object {
        /** Target schema version for validation */
        const val TARGET_SCHEMA_VERSION = "1.6"
        
        /** Valid element types in Adaptive Cards v1.6 (including custom chart extensions) */
        val VALID_ELEMENT_TYPES = setOf(
            // Core elements (v1.0)
            "TextBlock", "Image", "Media", "RichTextBlock",
            // Container elements (v1.0)
            "Container", "ColumnSet", "ImageSet", "FactSet", "ActionSet",
            // Input elements (v1.0)
            "Input.Text", "Input.Number", "Input.Date", "Input.Time", "Input.Toggle", "Input.ChoiceSet",
            // Advanced elements (v1.3+)
            "Carousel", "Accordion", "CodeBlock", "Rating", "Input.Rating", "ProgressBar", "Spinner",
            "TabSet", "List",
            // v1.6 elements
            "Table", "CompoundButton",
            // Custom chart extensions
            "DonutChart", "BarChart", "LineChart", "PieChart"
        )
        
        /** Valid action types in Adaptive Cards v1.6 */
        val VALID_ACTION_TYPES = setOf(
            "Action.Submit", "Action.OpenUrl", "Action.ShowCard",
            "Action.ToggleVisibility", "Action.Execute"
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
                    expected = "X.Y format (e.g., 1.6)",
                    actual = version
                ))
            }
            // Note: We accept versions up to and including 1.6
            // Higher versions are accepted but features may not be supported
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
            val actionsArray = actions as? JsonArray
            if (actionsArray != null) {
                actionsArray.forEachIndexed { index, action ->
                    val actionObj = action as? JsonObject
                    if (actionObj != null) {
                        errors.addAll(validateAction(actionObj, "$.actions[$index]"))
                    }
                }
            } else {
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
    
    /**
     * Validates an action object
     */
    private fun validateAction(
        action: JsonObject,
        path: String
    ): List<SchemaValidationError> {
        val errors = mutableListOf<SchemaValidationError>()

        if (!action.containsKey("type")) {
            errors.add(SchemaValidationError(
                path = "$path.type",
                message = "Missing required field",
                expected = "type: String",
                actual = "undefined"
            ))
        } else {
            val type = (action["type"] as? JsonPrimitive)?.content
            
            if (type != null && type !in VALID_ACTION_TYPES) {
                errors.add(SchemaValidationError(
                    path = "$path.type",
                    message = "Unknown action type",
                    expected = "One of: ${VALID_ACTION_TYPES.sorted().joinToString(", ")}",
                    actual = type
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
