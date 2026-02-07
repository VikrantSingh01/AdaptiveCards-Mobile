package com.microsoft.adaptivecards.inputs.validation

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*

class InputValidatorTest {
    
    @Test
    fun `validate required text field - empty value`() {
        val error = InputValidator.validateText(
            value = "",
            isRequired = true
        )
        
        assertNotNull(error)
        assertTrue(error!!.contains("required"))
    }
    
    @Test
    fun `validate required text field - valid value`() {
        val error = InputValidator.validateText(
            value = "John Doe",
            isRequired = true
        )
        
        assertNull(error)
    }
    
    @Test
    fun `validate text with max length`() {
        val error = InputValidator.validateText(
            value = "This is a very long text that exceeds the maximum length",
            isRequired = false,
            maxLength = 10
        )
        
        assertNotNull(error)
        assertTrue(error!!.contains("Maximum length"))
    }
    
    @Test
    fun `validate text with regex pattern`() {
        val error = InputValidator.validateText(
            value = "invalid-email",
            isRequired = true,
            regex = "^[A-Za-z0-9+_.-]+@(.+)$"
        )
        
        assertNotNull(error)
    }
    
    @Test
    fun `validate text with valid regex pattern`() {
        val error = InputValidator.validateText(
            value = "user@example.com",
            isRequired = true,
            regex = "^[A-Za-z0-9+_.-]+@(.+)$"
        )
        
        assertNull(error)
    }
    
    @Test
    fun `validate number with min and max`() {
        var error = InputValidator.validateNumber(
            value = 5.0,
            isRequired = true,
            min = 10.0,
            max = 100.0
        )
        assertNotNull(error)
        assertTrue(error!!.contains("Minimum value"))
        
        error = InputValidator.validateNumber(
            value = 150.0,
            isRequired = true,
            min = 10.0,
            max = 100.0
        )
        assertNotNull(error)
        assertTrue(error!!.contains("Maximum value"))
        
        error = InputValidator.validateNumber(
            value = 50.0,
            isRequired = true,
            min = 10.0,
            max = 100.0
        )
        assertNull(error)
    }
    
    @Test
    fun `validate required number field`() {
        val error = InputValidator.validateNumber(
            value = null,
            isRequired = true
        )
        
        assertNotNull(error)
        assertTrue(error!!.contains("required"))
    }
    
    @Test
    fun `validate choice set - required with no selection`() {
        val error = InputValidator.validateChoiceSet(
            value = null,
            isRequired = true
        )
        
        assertNotNull(error)
        assertTrue(error!!.contains("select"))
    }
    
    @Test
    fun `validate choice set - required with selection`() {
        val error = InputValidator.validateChoiceSet(
            value = "option1",
            isRequired = true
        )
        
        assertNull(error)
    }
}
