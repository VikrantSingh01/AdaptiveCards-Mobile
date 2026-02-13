package com.microsoft.adaptivecards.core

import com.microsoft.adaptivecards.core.parsing.CardParser
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test

/**
 * Tests for SchemaValidator with v1.6 schema validation and round-trip serialization
 */
class SchemaValidatorTest {
    
    private lateinit var validator: SchemaValidator
    private val json = Json { prettyPrint = true; ignoreUnknownKeys = true }
    
    @BeforeEach
    fun setUp() {
        validator = SchemaValidator()
    }
    
    // MARK: - Basic Validation Tests
    
    @Test
    fun testValidSimpleCard() {
        val cardJson = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "TextBlock",
                    "text": "Hello World"
                }
            ]
        }
        """.trimIndent()
        
        val errors = validator.validate(cardJson)
        assertTrue(errors.isEmpty(), "Valid card should have no errors")
    }
    
    @Test
    fun testMissingType() {
        val cardJson = """
        {
            "version": "1.6",
            "body": []
        }
        """.trimIndent()
        
        val errors = validator.validate(cardJson)
        assertFalse(errors.isEmpty())
        assertTrue(errors.any { it.path == "$.type" })
    }
    
    @Test
    fun testMissingVersion() {
        val cardJson = """
        {
            "type": "AdaptiveCard",
            "body": []
        }
        """.trimIndent()
        
        val errors = validator.validate(cardJson)
        assertFalse(errors.isEmpty())
        assertTrue(errors.any { it.path == "$.version" })
    }
    
    @Test
    fun testInvalidVersion() {
        val cardJson = """
        {
            "type": "AdaptiveCard",
            "version": "invalid",
            "body": []
        }
        """.trimIndent()
        
        val errors = validator.validate(cardJson)
        assertFalse(errors.isEmpty())
        assertTrue(errors.any { it.path == "$.version" && it.message.contains("Invalid version format") })
    }
    
    @Test
    fun testVersion16Accepted() {
        val cardJson = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": []
        }
        """.trimIndent()
        
        val errors = validator.validate(cardJson)
        assertTrue(errors.isEmpty(), "Version 1.6 should be accepted")
    }
    
    @Test
    fun testUnknownElementType() {
        val cardJson = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "UnknownElement",
                    "text": "Test"
                }
            ]
        }
        """.trimIndent()
        
        val errors = validator.validate(cardJson)
        assertFalse(errors.isEmpty())
        assertTrue(errors.any { it.path.contains("body[0].type") })
    }
    
    // MARK: - v1.6 Element Tests
    
    @Test
    fun testTableElementValidation() {
        val cardJson = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "Table",
                    "columns": [],
                    "rows": []
                }
            ]
        }
        """.trimIndent()
        
        val errors = validator.validate(cardJson)
        assertTrue(errors.isEmpty(), "Table element should be valid in v1.6")
    }
    
    @Test
    fun testCompoundButtonValidation() {
        val cardJson = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "CompoundButton",
                    "title": "Button Title"
                }
            ]
        }
        """.trimIndent()
        
        val errors = validator.validate(cardJson)
        assertTrue(errors.isEmpty(), "CompoundButton should be valid in v1.6")
    }
    
    // MARK: - Action Validation Tests
    
    @Test
    fun testActionExecuteValidation() {
        val cardJson = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "actions": [
                {
                    "type": "Action.Execute",
                    "title": "Execute",
                    "verb": "doAction"
                }
            ]
        }
        """.trimIndent()
        
        val errors = validator.validate(cardJson)
        assertTrue(errors.isEmpty(), "Action.Execute should be valid in v1.6")
    }
    
    @Test
    fun testUnknownActionType() {
        val cardJson = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "actions": [
                {
                    "type": "Action.Unknown",
                    "title": "Unknown"
                }
            ]
        }
        """.trimIndent()
        
        val errors = validator.validate(cardJson)
        assertFalse(errors.isEmpty())
        assertTrue(errors.any { it.path.contains("actions[0].type") })
    }
    
    @Test
    fun testAllValidActionTypes() {
        val cardJson = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "actions": [
                {"type": "Action.Submit", "title": "Submit"},
                {"type": "Action.OpenUrl", "title": "Open", "url": "https://example.com"},
                {"type": "Action.ShowCard", "title": "Show"},
                {"type": "Action.ToggleVisibility", "title": "Toggle"},
                {"type": "Action.Execute", "title": "Execute"}
            ]
        }
        """.trimIndent()
        
        val errors = validator.validate(cardJson)
        assertTrue(errors.isEmpty(), "All standard action types should be valid")
    }
    
    // MARK: - Round-Trip Serialization Tests
    
    @Test
    fun testRoundTripSimpleCard() {
        val originalJSON = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "TextBlock",
                    "text": "Hello World",
                    "wrap": true
                }
            ]
        }
        """.trimIndent()
        
        // Parse JSON to model
        val card = CardParser.parse(originalJSON)
        
        // Serialize back to JSON
        val serializedJSON = CardParser.serialize(card)
        
        // Parse again to ensure round-trip consistency
        val reparsedCard = CardParser.parse(serializedJSON)
        assertEquals(card.version, reparsedCard.version)
        assertEquals(card.body?.size, reparsedCard.body?.size)
    }

    @Test
    fun testRoundTripComplexCard() {
        val originalJSON = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "Container",
                    "items": [
                        {
                            "type": "TextBlock",
                            "text": "Title",
                            "size": "Large"
                        },
                        {
                            "type": "Image",
                            "url": "https://example.com/image.png"
                        }
                    ]
                },
                {
                    "type": "Input.Text",
                    "id": "name",
                    "placeholder": "Enter name"
                }
            ],
            "actions": [
                {
                    "type": "Action.Submit",
                    "title": "Submit"
                }
            ]
        }
        """.trimIndent()
        
        // Parse, serialize, and validate
        val card = CardParser.parse(originalJSON)
        
        val serializedJSON = CardParser.serialize(card)
        
        // Verify structure is preserved via round-trip
        val reparsedCard = CardParser.parse(serializedJSON)
        assertEquals(card.body?.size, reparsedCard.body?.size)
        assertEquals(card.actions?.size, reparsedCard.actions?.size)
    }
    
    @Test
    fun testRoundTripWithTable() {
        val originalJSON = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "Table",
                    "columns": [
                        {"width": "auto"},
                        {"width": "stretch"}
                    ],
                    "rows": [
                        {
                            "cells": [
                                {"items": [{"type": "TextBlock", "text": "Cell 1"}]},
                                {"items": [{"type": "TextBlock", "text": "Cell 2"}]}
                            ]
                        }
                    ]
                }
            ]
        }
        """.trimIndent()
        
        val card = CardParser.parse(originalJSON)
        
        val serializedJSON = CardParser.serialize(card)
        
        // Verify round-trip produces parseable JSON
        val reparsedCard = CardParser.parse(serializedJSON)
        assertNotNull(reparsedCard.body)
    }
    
    // MARK: - Chart Extension Tests
    
    @Test
    fun testChartElementsValidation() {
        val cardJson = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {"type": "DonutChart", "data": []},
                {"type": "BarChart", "data": []},
                {"type": "LineChart", "data": []},
                {"type": "PieChart", "data": []}
            ]
        }
        """.trimIndent()
        
        val errors = validator.validate(cardJson)
        assertTrue(errors.isEmpty(), "Chart elements should be recognized as valid extensions")
    }
    
    // MARK: - Edge Cases
    
    @Test
    fun testEmptyCard() {
        val cardJson = """
        {
            "type": "AdaptiveCard",
            "version": "1.6"
        }
        """.trimIndent()
        
        val errors = validator.validate(cardJson)
        assertTrue(errors.isEmpty(), "Empty card (no body/actions) should be valid")
    }
    
    @Test
    fun testInvalidJSON() {
        val cardJson = "{ invalid json }"
        
        val errors = validator.validate(cardJson)
        assertFalse(errors.isEmpty())
        assertTrue(errors.any { it.path == "$" })
    }
    
    @Test
    fun testNonObjectJSON() {
        val cardJson = "[\"array\"]"
        
        val errors = validator.validate(cardJson)
        assertFalse(errors.isEmpty())
    }
}
