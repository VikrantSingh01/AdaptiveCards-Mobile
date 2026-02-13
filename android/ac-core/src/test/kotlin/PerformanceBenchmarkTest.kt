package com.microsoft.adaptivecards.core

import com.microsoft.adaptivecards.core.models.*
import com.microsoft.adaptivecards.core.parsing.CardParser
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*
import kotlin.system.measureNanoTime
import kotlin.system.measureTimeMillis

/**
 * Performance benchmarks for Adaptive Cards parsing and model operations.
 *
 * These tests measure the impact of key optimizations:
 * - UnknownElement handling (null safety)
 * - Parse-time validation warnings
 * - Thread-safe parsing
 */
class PerformanceBenchmarkTest {

    companion object {
        private const val ITERATIONS_SMALL = 1000
        private const val ITERATIONS_MEDIUM = 100
        private const val ITERATIONS_LARGE = 10

        // Simple card JSON for parsing tests
        private val SIMPLE_CARD_JSON = """
            {
                "type": "AdaptiveCard",
                "version": "1.5",
                "body": [
                    {
                        "type": "TextBlock",
                        "text": "Hello World"
                    }
                ]
            }
        """.trimIndent()

        // Card with inputs for validation testing
        private val INPUTS_CARD_JSON = """
            {
                "type": "AdaptiveCard",
                "version": "1.5",
                "body": [
                    {
                        "type": "Input.Text",
                        "id": "name",
                        "placeholder": "Enter your name"
                    },
                    {
                        "type": "Input.Number",
                        "id": "age",
                        "placeholder": "Enter your age"
                    },
                    {
                        "type": "Input.Toggle",
                        "id": "subscribe",
                        "title": "Subscribe to newsletter"
                    }
                ]
            }
        """.trimIndent()

        // Card with unknown elements for UnknownElement testing
        private val UNKNOWN_ELEMENTS_CARD_JSON = """
            {
                "type": "AdaptiveCard",
                "version": "1.5",
                "body": [
                    {
                        "type": "TextBlock",
                        "text": "Known element"
                    },
                    {
                        "type": "FutureElement",
                        "someProperty": "value"
                    },
                    {
                        "type": "AnotherUnknownElement",
                        "data": "test"
                    }
                ]
            }
        """.trimIndent()

        // Complex nested card
        private val COMPLEX_CARD_JSON = """
            {
                "type": "AdaptiveCard",
                "version": "1.5",
                "body": [
                    {
                        "type": "Container",
                        "items": [
                            {
                                "type": "ColumnSet",
                                "columns": [
                                    {
                                        "width": "auto",
                                        "items": [
                                            {
                                                "type": "Image",
                                                "url": "https://example.com/image.jpg",
                                                "size": "Medium"
                                            }
                                        ]
                                    },
                                    {
                                        "width": "stretch",
                                        "items": [
                                            {
                                                "type": "TextBlock",
                                                "text": "Title",
                                                "weight": "Bolder",
                                                "size": "Large"
                                            },
                                            {
                                                "type": "TextBlock",
                                                "text": "Subtitle",
                                                "isSubtle": true
                                            }
                                        ]
                                    }
                                ]
                            }
                        ]
                    }
                ]
            }
        """.trimIndent()
    }

    // MARK: - Parsing Performance Tests

    @Test
    fun `benchmark simple card parsing`() {
        // Warmup
        repeat(10) {
            CardParser.parse(SIMPLE_CARD_JSON)
        }

        // Measure
        val times = mutableListOf<Long>()
        repeat(ITERATIONS_SMALL) {
            val time = measureNanoTime {
                CardParser.parse(SIMPLE_CARD_JSON)
            }
            times.add(time)
        }

        val avgNanos = times.average()
        val avgMillis = avgNanos / 1_000_000.0

        println("Simple card parsing: ${String.format("%.3f", avgMillis)}ms average over $ITERATIONS_SMALL iterations")
        println("  Min: ${String.format("%.3f", times.minOrNull()!! / 1_000_000.0)}ms")
        println("  Max: ${String.format("%.3f", times.maxOrNull()!! / 1_000_000.0)}ms")

        // Assert reasonable performance (should be well under 10ms)
        assertTrue(avgMillis < 10.0, "Simple card parsing should average under 10ms, got ${String.format("%.3f", avgMillis)}ms")
    }

    @Test
    fun `benchmark complex card parsing`() {
        // Warmup
        repeat(5) {
            CardParser.parse(COMPLEX_CARD_JSON)
        }

        // Measure
        val times = mutableListOf<Long>()
        repeat(ITERATIONS_MEDIUM) {
            val time = measureNanoTime {
                CardParser.parse(COMPLEX_CARD_JSON)
            }
            times.add(time)
        }

        val avgNanos = times.average()
        val avgMillis = avgNanos / 1_000_000.0

        println("Complex card parsing: ${String.format("%.3f", avgMillis)}ms average over $ITERATIONS_MEDIUM iterations")
        println("  Min: ${String.format("%.3f", times.minOrNull()!! / 1_000_000.0)}ms")
        println("  Max: ${String.format("%.3f", times.maxOrNull()!! / 1_000_000.0)}ms")

        // Assert reasonable performance (should be under 50ms)
        assertTrue(avgMillis < 50.0, "Complex card parsing should average under 50ms, got ${String.format("%.3f", avgMillis)}ms")
    }

    // MARK: - UnknownElement Handling Tests

    @Test
    fun `benchmark unknown element handling`() {
        // Warmup
        repeat(10) {
            CardParser.parse(UNKNOWN_ELEMENTS_CARD_JSON)
        }

        // Measure
        val times = mutableListOf<Long>()
        repeat(ITERATIONS_MEDIUM) {
            val time = measureNanoTime {
                val card = CardParser.parse(UNKNOWN_ELEMENTS_CARD_JSON)
                // Verify unknown elements are handled correctly
                assertNotNull(card.body)
            }
            times.add(time)
        }

        val avgNanos = times.average()
        val avgMillis = avgNanos / 1_000_000.0

        println("Unknown element handling: ${String.format("%.3f", avgMillis)}ms average over $ITERATIONS_MEDIUM iterations")

        // Parse and verify unknown elements are present
        val card = CardParser.parse(UNKNOWN_ELEMENTS_CARD_JSON)
        val unknownCount = card.body?.count { it is UnknownElement } ?: 0
        println("  Unknown elements detected: $unknownCount")

        assertTrue(unknownCount > 0, "Should detect unknown elements")
    }

    @Test
    fun `verify unknown elements are UnknownElement type`() {
        val card = CardParser.parse(UNKNOWN_ELEMENTS_CARD_JSON)

        val elements = card.body ?: emptyList()
        val unknownElements = elements.filterIsInstance<UnknownElement>()

        // Should have 2 unknown elements (FutureElement and AnotherUnknownElement)
        assertTrue(unknownElements.size >= 2, "Should have at least 2 unknown elements, got ${unknownElements.size}")

        // Verify they are UnknownElement type, not fallback to another type
        unknownElements.forEach { element ->
            assertEquals("Unknown", element.type)
            println("Unknown element with original type: ${element.unknownType}")
        }
    }

    // MARK: - Input Validation Performance Tests

    @Test
    fun `benchmark input card parsing with validation`() {
        // Warmup
        repeat(10) {
            CardParser.parse(INPUTS_CARD_JSON)
        }

        // Measure
        val times = mutableListOf<Long>()
        repeat(ITERATIONS_MEDIUM) {
            val time = measureNanoTime {
                val card = CardParser.parse(INPUTS_CARD_JSON)
                // Access body to trigger any lazy validation
                assertNotNull(card.body)
            }
            times.add(time)
        }

        val avgNanos = times.average()
        val avgMillis = avgNanos / 1_000_000.0

        println("Input card parsing: ${String.format("%.3f", avgMillis)}ms average over $ITERATIONS_MEDIUM iterations")

        // Parse and verify all inputs have IDs
        val card = CardParser.parse(INPUTS_CARD_JSON)
        val inputs = card.body?.filterIsInstance<CardInput>() ?: emptyList()
        println("  Inputs found: ${inputs.size}")

        inputs.forEach { input ->
            assertNotNull(input.id, "Input of type ${input.type} should have an ID")
        }
    }

    // MARK: - Thread Safety Performance Tests

    @Test
    fun `benchmark concurrent parsing`() {
        // Warmup
        repeat(10) {
            CardParser.parse(SIMPLE_CARD_JSON)
        }

        val threadCount = 10
        val iterationsPerThread = 100

        val totalTime = measureTimeMillis {
            val threads = (1..threadCount).map {
                Thread {
                    repeat(iterationsPerThread) {
                        CardParser.parse(SIMPLE_CARD_JSON)
                    }
                }
            }

            threads.forEach { it.start() }
            threads.forEach { it.join() }
        }

        val totalIterations = threadCount * iterationsPerThread
        val avgMillis = totalTime.toDouble() / totalIterations

        println("Concurrent parsing ($threadCount threads, $iterationsPerThread iterations each):")
        println("  Total time: ${totalTime}ms")
        println("  Average per parse: ${String.format("%.3f", avgMillis)}ms")
        println("  Throughput: ${String.format("%.1f", totalIterations.toDouble() / (totalTime / 1000.0))} parses/second")

        // Should complete in reasonable time (under 10 seconds total)
        assertTrue(totalTime < 10000, "Concurrent parsing should complete in under 10 seconds")
    }

    // MARK: - Serialization Round-Trip Performance

    @Test
    fun `benchmark serialization round-trip`() {
        val card = CardParser.parse(COMPLEX_CARD_JSON)

        // Warmup
        repeat(10) {
            val json = CardParser.serialize(card)
            CardParser.parse(json)
        }

        // Measure
        val times = mutableListOf<Long>()
        repeat(ITERATIONS_MEDIUM) {
            val time = measureNanoTime {
                val json = CardParser.serialize(card)
                val parsed = CardParser.parse(json)
                assertNotNull(parsed)
            }
            times.add(time)
        }

        val avgNanos = times.average()
        val avgMillis = avgNanos / 1_000_000.0

        println("Serialization round-trip: ${String.format("%.3f", avgMillis)}ms average over $ITERATIONS_MEDIUM iterations")

        // Assert reasonable performance (should be under 100ms)
        assertTrue(avgMillis < 100.0, "Round-trip should average under 100ms, got ${String.format("%.3f", avgMillis)}ms")
    }

    // MARK: - Memory Efficiency Tests

    @Test
    fun `benchmark memory usage for large batch parsing`() {
        val runtime = Runtime.getRuntime()
        runtime.gc() // Request garbage collection before test

        val memoryBefore = runtime.totalMemory() - runtime.freeMemory()

        val cards = mutableListOf<AdaptiveCard>()
        val time = measureTimeMillis {
            repeat(100) {
                cards.add(CardParser.parse(COMPLEX_CARD_JSON))
            }
        }

        val memoryAfter = runtime.totalMemory() - runtime.freeMemory()
        val memoryUsed = (memoryAfter - memoryBefore) / (1024.0 * 1024.0) // Convert to MB

        println("Batch parsing (100 complex cards):")
        println("  Total time: ${time}ms")
        println("  Average: ${String.format("%.2f", time / 100.0)}ms per card")
        println("  Memory used: ${String.format("%.2f", memoryUsed)}MB")
        println("  Memory per card: ${String.format("%.2f", memoryUsed / 100.0)}MB")

        // Keep reference to prevent GC
        assertTrue(cards.size == 100)
    }
}
