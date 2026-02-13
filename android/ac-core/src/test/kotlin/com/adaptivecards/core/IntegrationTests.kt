package com.adaptivecards.core

import com.microsoft.adaptivecards.core.models.*
import com.microsoft.adaptivecards.core.parsing.CardParser
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import java.io.File

/**
 * Integration tests for cross-platform rendering parity
 * Validates that all shared test cards parse correctly and handle edge cases
 */
class IntegrationTests {
    
    private lateinit var testCardsPath: String
    
    @BeforeEach
    fun setup() {
        // Path to shared test cards (relative to project root)
        testCardsPath = "../../../shared/test-cards"
    }
    
    // MARK: - Core Test Cards
    
    @Test
    fun `parse simple text card`() {
        val json = loadTestCard("simple-text")
        val card = CardParser.parse(json)
        
        assertEquals("1.6", card.version)
        assertNotNull(card.body)
        assertEquals(2, card.body?.size)
        assertNotNull(card.actions)
        assertEquals(1, card.actions?.size)
    }
    
    @Test
    fun `parse containers card`() {
        val json = loadTestCard("containers")
        val card = CardParser.parse(json)
        
        assertNotNull(card.body)
        assertEquals(2, card.body?.size)
        
        // Verify container
        val firstElement = card.body?.get(0)
        assertTrue(firstElement is Container)
        val container = firstElement as Container
        assertNotNull(container.items)
        assertEquals(ContainerStyle.Emphasis, container.style)
        
        // Verify column set
        val secondElement = card.body?.get(1)
        assertTrue(secondElement is ColumnSet)
    }
    
    @Test
    fun `parse all inputs card`() {
        val json = loadTestCard("all-inputs")
        val card = CardParser.parse(json)
        
        assertNotNull(card.body)
        assertEquals(7, card.body?.size)
        
        // Verify all input types exist
        val inputTypes = mutableSetOf<String>()
        card.body?.forEach { element ->
            when (element) {
                is InputText -> inputTypes.add("InputText")
                is InputNumber -> inputTypes.add("InputNumber")
                is InputDate -> inputTypes.add("InputDate")
                is InputTime -> inputTypes.add("InputTime")
                is InputToggle -> inputTypes.add("InputToggle")
                is InputChoiceSet -> inputTypes.add("InputChoiceSet")
                else -> {}
            }
        }
        
        assertTrue(inputTypes.contains("InputText"))
        assertTrue(inputTypes.contains("InputNumber"))
        assertTrue(inputTypes.contains("InputDate"))
        assertTrue(inputTypes.contains("InputTime"))
        assertTrue(inputTypes.contains("InputToggle"))
        assertTrue(inputTypes.contains("InputChoiceSet"))
    }
    
    @Test
    fun `parse all actions card`() {
        val json = loadTestCard("all-actions")
        val card = CardParser.parse(json)
        
        assertNotNull(card.actions)
        assertTrue(card.actions!!.isNotEmpty())
        
        // Verify various action types from both top-level and body ActionSets
        val actionTypes = mutableSetOf<String>()
        val allActions = mutableListOf<CardAction>()
        card.actions?.let { allActions.addAll(it) }
        card.body?.filterIsInstance<ActionSet>()?.forEach { allActions.addAll(it.actions) }

        allActions.forEach { action ->
            when (action) {
                is ActionSubmit -> actionTypes.add("Submit")
                is ActionOpenUrl -> actionTypes.add("OpenUrl")
                is ActionShowCard -> actionTypes.add("ShowCard")
                is ActionToggleVisibility -> actionTypes.add("ToggleVisibility")
                else -> {}
            }
        }

        assertTrue(actionTypes.contains("Submit"))
        assertTrue(actionTypes.contains("OpenUrl"))
        assertTrue(actionTypes.contains("ToggleVisibility"))
    }
    
    // MARK: - Advanced Elements Tests
    
    @Test
    fun `parse carousel card`() {
        val json = loadTestCard("carousel")
        val card = CardParser.parse(json)
        
        assertNotNull(card.body)
        assertTrue(card.body!!.isNotEmpty())
        
        // Find carousel element
        var foundCarousel = false
        card.body?.forEach { element ->
            if (element is Carousel) {
                foundCarousel = true
                assertNotNull(element.pages)
                assertTrue(element.pages!!.isNotEmpty())
            }
        }
        
        assertTrue(foundCarousel, "Carousel element not found")
    }
    
    @Test
    fun `parse accordion card`() {
        val json = loadTestCard("accordion")
        val card = CardParser.parse(json)
        
        assertNotNull(card.body)
        
        // Find accordion element
        var foundAccordion = false
        card.body?.forEach { element ->
            if (element is Accordion) {
                foundAccordion = true
                assertNotNull(element.panels)
                assertTrue(element.panels!!.isNotEmpty())
            }
        }
        
        assertTrue(foundAccordion, "Accordion element not found")
    }
    
    @Test
    fun `parse code block card`() {
        val json = loadTestCard("code-block")
        val card = CardParser.parse(json)
        
        assertNotNull(card.body)
        
        // Find code block element
        var foundCodeBlock = false
        card.body?.forEach { element ->
            if (element is CodeBlock) {
                foundCodeBlock = true
                assertNotNull(element.code)
            }
        }
        
        assertTrue(foundCodeBlock, "CodeBlock element not found")
    }
    
    @Test
    fun `parse rating card`() {
        val json = loadTestCard("rating")
        val card = CardParser.parse(json)
        
        assertNotNull(card.body)
        
        // Find rating elements
        var foundRating = false
        card.body?.forEach { element ->
            if (element is RatingDisplay || element is RatingInput) {
                foundRating = true
            }
        }
        
        assertTrue(foundRating, "Rating element not found")
    }
    
    @Test
    fun `parse progress indicators card`() {
        val json = loadTestCard("progress-indicators")
        val card = CardParser.parse(json)
        
        assertNotNull(card.body)
        
        // Find progress indicators
        var foundProgressBar = false
        var foundSpinner = false
        card.body?.forEach { element ->
            if (element is ProgressBar) {
                foundProgressBar = true
            }
            if (element is Spinner) {
                foundSpinner = true
            }
        }
        
        assertTrue(foundProgressBar || foundSpinner, "Progress indicator not found")
    }
    
    @Test
    fun `parse tab set card`() {
        val json = loadTestCard("tab-set")
        val card = CardParser.parse(json)
        
        assertNotNull(card.body)
        
        // Find tab set element
        var foundTabSet = false
        card.body?.forEach { element ->
            if (element is TabSet) {
                foundTabSet = true
                assertNotNull(element.tabs)
                assertTrue(element.tabs!!.isNotEmpty())
            }
        }
        
        assertTrue(foundTabSet, "TabSet element not found")
    }
    
    // MARK: - Edge Case Tests
    
    @Test
    fun `parse edge empty card`() {
        val json = loadTestCard("edge-empty-card")
        val card = CardParser.parse(json)
        
        assertEquals("1.6", card.version)
        assertNotNull(card.body)
        assertEquals(0, card.body?.size, "Empty card should have 0 body elements")
    }
    
    @Test
    fun `parse edge deeply nested`() {
        val json = loadTestCard("edge-deeply-nested")
        val card = CardParser.parse(json)
        
        assertEquals("1.6", card.version)
        assertNotNull(card.body)
        assertTrue(card.body!!.isNotEmpty())
        
        // Verify deep nesting doesn't cause crash
        val firstElement = card.body?.get(0)
        assertTrue(firstElement is Container, "Expected Container as first element")
    }
    
    @Test
    fun `parse edge all unknown types`() {
        val json = loadTestCard("edge-all-unknown-types")
        val card = CardParser.parse(json)
        
        assertEquals("1.6", card.version)
        assertNotNull(card.body)
        assertTrue(card.body!!.isNotEmpty())
        
        // The parser should handle unknown types gracefully
        // Some elements might be skipped or converted to unknown types
        assertTrue(card.body!!.isNotEmpty(), "Should parse card with unknown elements")
    }
    
    @Test
    fun `parse edge max actions`() {
        val json = loadTestCard("edge-max-actions")
        val card = CardParser.parse(json)
        
        assertEquals("1.6", card.version)
        assertNotNull(card.actions)
        assertTrue(card.actions!!.size >= 10, "Should have 10+ actions")
    }
    
    @Test
    fun `parse edge long text`() {
        val json = loadTestCard("edge-long-text")
        val card = CardParser.parse(json)
        
        assertEquals("1.6", card.version)
        assertNotNull(card.body)
        assertTrue(card.body!!.isNotEmpty())
        
        // Find text block with extremely long text
        var foundLongText = false
        card.body?.forEach { element ->
            if (element is TextBlock && element.text.length > 500) {
                foundLongText = true
            }
        }
        
        assertTrue(foundLongText, "Should have text block with very long text")
    }
    
    @Test
    fun `parse edge RTL content`() {
        val json = loadTestCard("edge-rtl-content")
        val card = CardParser.parse(json)
        
        assertEquals("1.6", card.version)
        assertNotNull(card.body)
        assertTrue(card.body!!.isNotEmpty())
        
        // Verify card parses successfully with RTL content
        assertTrue(true, "RTL content parsed successfully")
    }
    
    @Test
    fun `parse edge mixed inputs`() {
        val json = loadTestCard("edge-mixed-inputs")
        val card = CardParser.parse(json)
        
        assertEquals("1.6", card.version)
        assertNotNull(card.body)
        assertTrue(card.body!!.size > 5)
        
        // Count input elements
        var inputCount = 0
        var displayCount = 0
        card.body?.forEach { element ->
            when (element) {
                is InputText, is InputNumber, is InputDate, is InputTime, is InputToggle, is InputChoiceSet, is RatingInput -> inputCount++
                is TextBlock, is Image, is Container, is FactSet -> displayCount++
                else -> {}
            }
        }
        
        assertTrue(inputCount > 0, "Should have input elements")
        assertTrue(displayCount > 0, "Should have display elements")
    }
    
    @Test
    fun `parse edge empty containers`() {
        val json = loadTestCard("edge-empty-containers")
        val card = CardParser.parse(json)
        
        assertEquals("1.6", card.version)
        assertNotNull(card.body)
        assertTrue(card.body!!.isNotEmpty())
        
        // Find empty containers
        var foundEmptyContainer = false
        card.body?.forEach { element ->
            if (element is Container && element.items?.isEmpty() == true) {
                foundEmptyContainer = true
            }
        }
        
        assertTrue(foundEmptyContainer, "Should have at least one empty container")
    }
    
    // MARK: - Round-Trip Tests
    
    @Test
    fun `round trip simple card`() {
        val json = loadTestCard("simple-text")
        val card = CardParser.parse(json)
        
        // Serialize back to JSON
        val encodedJson = CardParser.serialize(card)
        
        // Parse again
        val reparsedCard = CardParser.parse(encodedJson)
        
        assertEquals(card.version, reparsedCard.version)
        assertEquals(card.body?.size, reparsedCard.body?.size)
        assertEquals(card.actions?.size, reparsedCard.actions?.size)
    }
    
    @Test
    fun `round trip advanced card`() {
        val json = loadTestCard("advanced-combined")
        val card = CardParser.parse(json)
        
        // Serialize back to JSON
        val encodedJson = CardParser.serialize(card)
        
        // Parse again
        val reparsedCard = CardParser.parse(encodedJson)
        
        assertEquals(card.version, reparsedCard.version)
        assertEquals(card.body?.size, reparsedCard.body?.size)
    }
    
    @Test
    fun `round trip edge card`() {
        val json = loadTestCard("edge-mixed-inputs")
        val card = CardParser.parse(json)
        
        // Serialize back to JSON
        val encodedJson = CardParser.serialize(card)
        
        // Parse again
        val reparsedCard = CardParser.parse(encodedJson)
        
        assertEquals(card.version, reparsedCard.version)
        assertEquals(card.body?.size, reparsedCard.body?.size)
    }
    
    // MARK: - Performance Tests
    
    @Test
    fun `parsing performance`() {
        val json = loadTestCard("advanced-combined")
        
        // Warm up
        repeat(5) {
            CardParser.parse(json)
        }
        
        // Measure
        val startTime = System.nanoTime()
        repeat(100) {
            CardParser.parse(json)
        }
        val endTime = System.nanoTime()
        
        val avgTimeMs = (endTime - startTime) / 100_000_000.0
        println("Average parsing time: $avgTimeMs ms")
        
        // Should be under 50ms per the production requirements
        assertTrue(avgTimeMs < 50.0, "Parsing should be under 50ms")
    }
    
    // MARK: - Helper Methods
    
    private fun loadTestCard(name: String): String {
        // Try multiple paths to find the test cards
        val possiblePaths = listOf(
            "$testCardsPath/$name.json",
            "shared/test-cards/$name.json",
            "../shared/test-cards/$name.json",
            "../../shared/test-cards/$name.json",
            "../../../shared/test-cards/$name.json",
            "../../../../../../shared/test-cards/$name.json"
        )
        
        for (path in possiblePaths) {
            val file = File(path)
            if (file.exists()) {
                return file.readText()
            }
        }
        
        // If running from gradle, try relative to project root
        val projectRoot = System.getProperty("user.dir")
        val sharedPath = File(projectRoot).resolve("shared/test-cards/$name.json")
        if (sharedPath.exists()) {
            return sharedPath.readText()
        }
        
        throw IllegalArgumentException("Test card not found: $name.json. Tried paths: $possiblePaths")
    }
}
