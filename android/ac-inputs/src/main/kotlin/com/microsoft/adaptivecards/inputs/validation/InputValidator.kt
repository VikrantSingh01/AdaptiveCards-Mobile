package com.microsoft.adaptivecards.inputs.validation

/**
 * Input validator for Adaptive Card inputs
 */
object InputValidator {
    
    /**
     * Validate text input
     */
    fun validateText(
        value: String,
        isRequired: Boolean,
        regex: String? = null,
        maxLength: Int? = null,
        errorMessage: String? = null
    ): String? {
        // Check required
        if (isRequired && value.isBlank()) {
            return errorMessage ?: "This field is required"
        }
        
        // Check max length
        if (maxLength != null && value.length > maxLength) {
            return errorMessage ?: "Maximum length is $maxLength characters"
        }
        
        // Check regex
        if (regex != null && value.isNotBlank()) {
            val pattern = Regex(regex)
            if (!pattern.matches(value)) {
                return errorMessage ?: "Invalid format"
            }
        }
        
        return null
    }
    
    /**
     * Validate number input
     */
    fun validateNumber(
        value: Double?,
        isRequired: Boolean,
        min: Double? = null,
        max: Double? = null,
        errorMessage: String? = null
    ): String? {
        // Check required
        if (isRequired && value == null) {
            return errorMessage ?: "This field is required"
        }
        
        if (value != null) {
            // Check min
            if (min != null && value < min) {
                return errorMessage ?: "Minimum value is $min"
            }
            
            // Check max
            if (max != null && value > max) {
                return errorMessage ?: "Maximum value is $max"
            }
        }
        
        return null
    }
    
    /**
     * Validate date input
     */
    fun validateDate(
        value: String?,
        isRequired: Boolean,
        min: String? = null,
        max: String? = null,
        errorMessage: String? = null
    ): String? {
        // Check required
        if (isRequired && value.isNullOrBlank()) {
            return errorMessage ?: "This field is required"
        }
        
        // Additional date range validation could be added here
        
        return null
    }
    
    /**
     * Validate time input
     */
    fun validateTime(
        value: String?,
        isRequired: Boolean,
        min: String? = null,
        max: String? = null,
        errorMessage: String? = null
    ): String? {
        // Check required
        if (isRequired && value.isNullOrBlank()) {
            return errorMessage ?: "This field is required"
        }
        
        // Additional time range validation could be added here
        
        return null
    }
    
    /**
     * Validate toggle input
     */
    fun validateToggle(
        value: Boolean?,
        isRequired: Boolean,
        errorMessage: String? = null
    ): String? {
        // Check required
        if (isRequired && value == null) {
            return errorMessage ?: "This field is required"
        }
        
        return null
    }
    
    /**
     * Validate choice set input
     */
    fun validateChoiceSet(
        value: String?,
        isRequired: Boolean,
        errorMessage: String? = null
    ): String? {
        // Check required
        if (isRequired && value.isNullOrBlank()) {
            return errorMessage ?: "Please select an option"
        }
        
        return null
    }
}
