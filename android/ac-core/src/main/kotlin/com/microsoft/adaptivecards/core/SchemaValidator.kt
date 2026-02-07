package com.microsoft.adaptivecards.core

data class SchemaValidationError(
    val path: String,
    val message: String,
    val expected: String? = null,
    val actual: String? = null
)

class SchemaValidator {
    fun validate(json: String): List<SchemaValidationError> {
        val errors = mutableListOf<SchemaValidationError>()
        
        val jsonObject = try {
            kotlinx.serialization.json.Json.parseToJsonElement(json).jsonObject
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
            val type = jsonObject["type"]?.jsonPrimitive?.content
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
            val version = jsonObject["version"]?.jsonPrimitive?.content
            if (version != null && !version.matches(Regex("""^\d+\.\d+$"""))) {
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
            try {
                val bodyArray = body.jsonArray
                bodyArray.forEachIndexed { index, element ->
                    errors.addAll(validateElement(element.jsonObject, "$.body[$index]"))
                }
            } catch (e: Exception) {
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
            try {
                actions.jsonArray
            } catch (e: Exception) {
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
        element: kotlinx.serialization.json.JsonObject,
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
            val type = element["type"]?.jsonPrimitive?.content
            val validTypes = setOf(
                "TextBlock", "Image", "Media", "RichTextBlock", "Container", "ColumnSet",
                "ImageSet", "FactSet", "ActionSet", "Table", "Input.Text", "Input.Number",
                "Input.Date", "Input.Time", "Input.Toggle", "Input.ChoiceSet", "Carousel",
                "Accordion", "CodeBlock", "Rating", "Input.Rating", "ProgressBar", "Spinner",
                "TabSet", "List", "CompoundButton", "DonutChart", "BarChart", "LineChart", "PieChart"
            )
            
            if (type != null && type !in validTypes) {
                errors.add(SchemaValidationError(
                    path = "$path.type",
                    message = "Unknown element type",
                    expected = "One of: ${validTypes.joinToString(", ")}",
                    actual = type
                ))
            }
        }
        
        return errors
    }
}
