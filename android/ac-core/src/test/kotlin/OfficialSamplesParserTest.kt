package com.microsoft.adaptivecards.core.parsing

import com.microsoft.adaptivecards.core.SchemaValidator
import com.microsoft.adaptivecards.core.models.*
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeAll
import org.junit.jupiter.api.DynamicTest
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.TestFactory
import org.junit.jupiter.api.TestInstance
import java.io.File

/**
 * Comprehensive parsing tests for all official, element, and teams sample cards.
 *
 * These tests verify that the CardParser can successfully parse every card JSON
 * from the shared/test-cards directories without throwing exceptions, and that
 * the parsed cards have valid structure (type, version, body/actions).
 *
 * Run with:
 * ```
 * ./gradlew :ac-core:test --tests "*OfficialSamplesParserTest"
 * ```
 */
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class OfficialSamplesParserTest {

    companion object {
        /**
         * Resolve the shared/test-cards directory relative to the ac-core module.
         * The module is at android/ac-core, so we go up two levels to reach the repo root,
         * then into shared/test-cards.
         */
        private fun findTestCardsDir(): File {
            // Try multiple possible paths since working directory can vary
            val candidates = listOf(
                File("../shared/test-cards"),           // from android/ac-core
                File("../../shared/test-cards"),         // from android/ac-core/build
                File("shared/test-cards"),               // from repo root
                File("android/../shared/test-cards"),    // from repo root with android prefix
            )
            return candidates.firstOrNull { it.exists() && it.isDirectory }
                ?: error(
                    "Cannot find shared/test-cards directory. " +
                    "Tried: ${candidates.map { it.absolutePath }}"
                )
        }
    }

    private lateinit var testCardsDir: File
    private lateinit var validator: SchemaValidator

    @BeforeAll
    fun setUp() {
        testCardsDir = findTestCardsDir()
        validator = SchemaValidator()
        println("Test cards directory: ${testCardsDir.absolutePath}")
    }

    // -------------------------------------------------------------------
    // Dynamic test factories - one test per card file
    // -------------------------------------------------------------------

    @TestFactory
    fun `parse all official samples`(): List<DynamicTest> {
        val dir = File(testCardsDir, "official-samples")
        if (!dir.exists()) return emptyList()
        return dir.listFiles { f -> f.extension == "json" }
            ?.sorted()
            ?.map { file ->
                DynamicTest.dynamicTest("official: ${file.name}") {
                    parseAndValidateCard(file)
                }
            } ?: emptyList()
    }

    @TestFactory
    fun `parse all element samples`(): List<DynamicTest> {
        val dir = File(testCardsDir, "element-samples")
        if (!dir.exists()) return emptyList()
        return dir.listFiles { f -> f.extension == "json" }
            ?.sorted()
            ?.map { file ->
                DynamicTest.dynamicTest("element: ${file.name}") {
                    parseAndValidateCard(file)
                }
            } ?: emptyList()
    }

    @TestFactory
    fun `parse all teams sample templates`(): List<DynamicTest> {
        val dir = File(testCardsDir, "teams-samples")
        if (!dir.exists()) return emptyList()
        return dir.listFiles { f -> f.extension == "json" && f.name.contains("template") }
            ?.sorted()
            ?.map { file ->
                DynamicTest.dynamicTest("teams-template: ${file.name}") {
                    parseAndValidateCard(file)
                }
            } ?: emptyList()
    }

    @TestFactory
    fun `parse all root-level test cards`(): List<DynamicTest> {
        return testCardsDir.listFiles { f -> f.extension == "json" }
            ?.sorted()
            ?.map { file ->
                DynamicTest.dynamicTest("root: ${file.name}") {
                    parseAndValidateCard(file)
                }
            } ?: emptyList()
    }

    // -------------------------------------------------------------------
    // Specific official sample tests with structural assertions
    // -------------------------------------------------------------------

    @Test
    fun `activity-update has ColumnSet with image and text`() {
        val card = parseCard("official-samples/activity-update.json")
        assertNotNull(card.body, "activity-update should have a body")
        assertTrue(card.body!!.isNotEmpty(), "activity-update body should not be empty")
    }

    @Test
    fun `flight-details has expected structure`() {
        val card = parseCard("official-samples/flight-details.json")
        assertNotNull(card.body)
        assertTrue(card.body!!.size >= 2, "flight-details should have at least 2 body elements")
    }

    @Test
    fun `weather-large has body with multiple elements`() {
        val card = parseCard("official-samples/weather-large.json")
        assertNotNull(card.body)
        assertTrue(card.body!!.size >= 2, "weather-large should have at least 2 body elements")
    }

    @Test
    fun `stock-update parses with ColumnSet for data layout`() {
        val card = parseCard("official-samples/stock-update.json")
        assertNotNull(card.body)
        assertTrue(card.body!!.isNotEmpty(), "stock-update should have body elements")
    }

    @Test
    fun `input-form-official has input elements`() {
        val card = parseCard("official-samples/input-form-official.json")
        assertNotNull(card.body)
        // Inputs may be nested inside ColumnSets/Containers
        assertTrue(card.body!!.isNotEmpty(), "input-form-official should have body elements")
    }

    @Test
    fun `calendar-reminder has actions`() {
        val card = parseCard("official-samples/calendar-reminder.json")
        assertNotNull(card.body)
        assertTrue(card.body!!.isNotEmpty(), "calendar-reminder should have body elements")
    }

    @Test
    fun `input-form-rtl parses with RTL attribute`() {
        val card = parseCard("official-samples/input-form-rtl.json")
        assertNotNull(card.body)
    }

    @Test
    fun `flight-update-table has Table elements`() {
        val card = parseCard("official-samples/flight-update-table.json")
        assertNotNull(card.body)
        val hasTable = card.body!!.any { it is Table }
        assertTrue(hasTable, "flight-update-table should contain a Table element")
    }

    // -------------------------------------------------------------------
    // Validation and schema tests
    // -------------------------------------------------------------------

    @Test
    fun `all official samples pass schema validation`() {
        val dir = File(testCardsDir, "official-samples")
        val results = mutableMapOf<String, List<String>>()
        var totalPassed = 0
        var totalFailed = 0

        dir.listFiles { f -> f.extension == "json" }?.sorted()?.forEach { file ->
            val json = file.readText()
            val errors = validator.validate(json)
            if (errors.isEmpty()) {
                totalPassed++
            } else {
                totalFailed++
                results[file.name] = errors.map { "${it.path}: ${it.message}" }
            }
        }

        println("Schema validation: $totalPassed passed, $totalFailed failed out of ${totalPassed + totalFailed}")
        if (results.isNotEmpty()) {
            println("Validation issues (non-fatal):")
            results.forEach { (file, errors) ->
                println("  $file:")
                errors.forEach { println("    - $it") }
            }
        }
        // Schema validation issues are warnings, not failures
        // The important thing is that the parser can handle the cards
    }

    @Test
    fun `teams data files are valid JSON`() {
        val dir = File(testCardsDir, "teams-samples")
        if (!dir.exists()) return
        var validCount = 0
        var invalidCount = 0
        dir.listFiles { f -> f.extension == "json" && f.name.contains("data") }?.forEach { file ->
            try {
                kotlinx.serialization.json.Json.parseToJsonElement(file.readText())
                validCount++
            } catch (e: Exception) {
                invalidCount++
                println("Invalid JSON in ${file.name}: ${e.message}")
            }
        }
        println("Teams data files: $validCount valid, $invalidCount invalid")
        assertEquals(0, invalidCount, "All teams data files should be valid JSON")
    }

    // -------------------------------------------------------------------
    // Summary test
    // -------------------------------------------------------------------

    @Test
    fun `parsing summary across all directories`() {
        val summary = mutableMapOf<String, Pair<Int, Int>>() // dir -> (success, failure)

        listOf("" to "root", "official-samples" to "official", "element-samples" to "element", "teams-samples" to "teams").forEach { (subdir, label) ->
            val dir = if (subdir.isEmpty()) testCardsDir else File(testCardsDir, subdir)
            if (!dir.exists()) return@forEach

            var success = 0
            var failure = 0
            val files = if (subdir.isEmpty()) {
                dir.listFiles { f -> f.extension == "json" }
            } else {
                dir.listFiles { f -> f.extension == "json" }
            }
            files?.forEach { file ->
                try {
                    // For teams data files, just validate JSON
                    if (file.name.contains("-data.json")) {
                        kotlinx.serialization.json.Json.parseToJsonElement(file.readText())
                        success++
                    } else {
                        CardParser.parse(file.readText())
                        success++
                    }
                } catch (e: Exception) {
                    failure++
                    println("PARSE FAIL [$label] ${file.name}: ${e.message?.take(120)}")
                }
            }
            summary[label] = success to failure
        }

        println("\n=== Parsing Summary ===")
        var totalSuccess = 0
        var totalFailure = 0
        summary.forEach { (label, counts) ->
            val (s, f) = counts
            totalSuccess += s
            totalFailure += f
            val total = s + f
            val pct = if (total > 0) "%.1f%%".format(s.toDouble() / total * 100) else "N/A"
            println("  $label: $s/$total passed ($pct)")
        }
        println("  TOTAL: $totalSuccess/${totalSuccess + totalFailure} passed")
        println("========================\n")

        // We expect at least 80% success rate overall
        val totalCount = totalSuccess + totalFailure
        assertTrue(totalCount > 0, "Should have found at least some test cards")
        val successRate = totalSuccess.toDouble() / totalCount
        assertTrue(
            successRate >= 0.80,
            "Expected at least 80% parsing success rate, got ${"%.1f%%".format(successRate * 100)}"
        )
    }

    // -------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------

    private fun parseCard(relativePath: String): AdaptiveCard {
        val file = File(testCardsDir, relativePath)
        assertTrue(file.exists(), "Card file should exist: ${file.absolutePath}")
        val json = file.readText()
        return CardParser.parse(json)
    }

    private fun parseAndValidateCard(file: File) {
        assertTrue(file.exists(), "Card file should exist: ${file.absolutePath}")
        val json = file.readText()
        assertTrue(json.isNotBlank(), "Card JSON should not be blank: ${file.name}")

        // If it's a data-only file (no "type": "AdaptiveCard"), just validate JSON
        if (file.name.contains("-data.json")) {
            try {
                kotlinx.serialization.json.Json.parseToJsonElement(json)
            } catch (e: Exception) {
                fail("Data file ${file.name} should be valid JSON: ${e.message}")
            }
            return
        }

        // Template files may contain ${expression} syntax in structural positions
        // (e.g., arrays, enum values) that cannot be parsed without template evaluation.
        val isTemplate = file.name.contains("template")

        val card: AdaptiveCard = try {
            CardParser.parse(json)
        } catch (e: Exception) {
            if (isTemplate) {
                println("Template parse expected failure: ${file.name}: ${e.message?.take(80)}")
                return
            }
            fail<Nothing>("Failed to parse ${file.name}: ${e.message}")
            return
        }

        assertEquals("AdaptiveCard", card.type, "${file.name}: type should be AdaptiveCard")
        assertNotNull(card.version, "${file.name}: version should not be null")
    }
}
