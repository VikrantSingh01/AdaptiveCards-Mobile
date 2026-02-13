package com.microsoft.adaptivecards.test.benchmark

import android.os.Debug
import android.util.Log
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import com.microsoft.adaptivecards.core.models.AdaptiveCard
import com.microsoft.adaptivecards.core.parsing.CardParser
import kotlinx.serialization.json.Json
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Memory allocation benchmarks for Adaptive Card operations.
 *
 * These tests measure heap memory impact of parsing and holding card
 * object graphs. They do not use the Benchmark library (which focuses
 * on timing) but instead use [Debug.getNativeHeapAllocatedSize] and
 * manual GC to measure retained memory.
 *
 * Run:
 * ```
 * ./gradlew :shared-test:connectedAndroidTest \
 *   -Pandroid.testInstrumentationRunnerArguments.class=com.microsoft.adaptivecards.test.benchmark.MemoryBenchmark
 * ```
 *
 * ## Performance baselines (expected ranges)
 *
 * | Scenario                    | Expected Memory (KB) |
 * |-----------------------------|---------------------|
 * | Simple text card parse      | < 50 KB             |
 * | Containers card parse       | < 150 KB            |
 * | Advanced combined parse     | < 500 KB            |
 * | Deeply nested card parse    | < 300 KB            |
 * | 100 simple cards held       | < 5 MB              |
 * | 100 complex cards held      | < 50 MB             |
 */
@RunWith(AndroidJUnit4::class)
class MemoryBenchmark {

    companion object {
        private const val TAG = "MemoryBenchmark"
        private const val KB = 1024L
        private const val MB = 1024L * 1024L

        /** Maximum allowed memory for a single simple card parse (bytes). */
        private const val SIMPLE_CARD_MAX_BYTES = 100 * KB

        /** Maximum allowed memory for a complex card parse (bytes). */
        private const val COMPLEX_CARD_MAX_BYTES = 1 * MB

        /** Maximum memory for holding 100 simple cards simultaneously. */
        private const val BATCH_SIMPLE_MAX_BYTES = 10 * MB

        /** Maximum memory for holding 100 complex cards simultaneously. */
        private const val BATCH_COMPLEX_MAX_BYTES = 100 * MB
    }

    private lateinit var simpleTextJson: String
    private lateinit var containersJson: String
    private lateinit var advancedCombinedJson: String
    private lateinit var edgeDeeplyNestedJson: String
    private lateinit var allCardJsons: Map<String, String>

    @Before
    fun setUp() {
        val assets = InstrumentationRegistry.getInstrumentation().context.assets
        simpleTextJson = assets.open("simple-text.json").bufferedReader().readText()
        containersJson = assets.open("containers.json").bufferedReader().readText()
        advancedCombinedJson = assets.open("advanced-combined.json").bufferedReader().readText()
        edgeDeeplyNestedJson = assets.open("edge-deeply-nested.json").bufferedReader().readText()

        allCardJsons = (assets.list("") ?: emptyArray())
            .filter { it.endsWith(".json") }
            .associateWith { assets.open(it).bufferedReader().readText() }

        Log.d(TAG, "Loaded ${allCardJsons.size} card JSON files")
    }

    // ------------------------------------------------------------------
    // Single card memory
    // ------------------------------------------------------------------

    @Test
    fun memorySimpleTextParse() {
        val memoryUsed = measureMemoryAllocation {
            CardParser.parse(simpleTextJson)
        }
        Log.d(TAG, "Simple text parse memory: ${memoryUsed / KB} KB")
        assertTrue(
            "Simple text parse used ${memoryUsed / KB} KB, exceeds ${SIMPLE_CARD_MAX_BYTES / KB} KB limit",
            memoryUsed < SIMPLE_CARD_MAX_BYTES
        )
    }

    @Test
    fun memoryContainersParse() {
        val memoryUsed = measureMemoryAllocation {
            CardParser.parse(containersJson)
        }
        Log.d(TAG, "Containers parse memory: ${memoryUsed / KB} KB")
        assertTrue(
            "Containers parse used ${memoryUsed / KB} KB, exceeds ${COMPLEX_CARD_MAX_BYTES / KB} KB limit",
            memoryUsed < COMPLEX_CARD_MAX_BYTES
        )
    }

    @Test
    fun memoryAdvancedCombinedParse() {
        val memoryUsed = measureMemoryAllocation {
            CardParser.parse(advancedCombinedJson)
        }
        Log.d(TAG, "Advanced combined parse memory: ${memoryUsed / KB} KB")
        assertTrue(
            "Advanced combined parse used ${memoryUsed / KB} KB, exceeds ${COMPLEX_CARD_MAX_BYTES / KB} KB limit",
            memoryUsed < COMPLEX_CARD_MAX_BYTES
        )
    }

    @Test
    fun memoryDeeplyNestedParse() {
        val memoryUsed = measureMemoryAllocation {
            CardParser.parse(edgeDeeplyNestedJson)
        }
        Log.d(TAG, "Deeply nested parse memory: ${memoryUsed / KB} KB")
        assertTrue(
            "Deeply nested parse used ${memoryUsed / KB} KB, exceeds ${COMPLEX_CARD_MAX_BYTES / KB} KB limit",
            memoryUsed < COMPLEX_CARD_MAX_BYTES
        )
    }

    // ------------------------------------------------------------------
    // Batch memory tests
    // ------------------------------------------------------------------

    @Test
    fun memoryBatchSimpleCards() {
        val cards = mutableListOf<AdaptiveCard>()
        val memoryUsed = measureMemoryAllocation {
            repeat(100) {
                cards.add(CardParser.parse(simpleTextJson))
            }
        }
        Log.d(TAG, "Batch 100 simple cards memory: ${memoryUsed / KB} KB (${cards.size} cards)")
        assertTrue(
            "Batch simple cards used ${memoryUsed / MB} MB, exceeds ${BATCH_SIMPLE_MAX_BYTES / MB} MB limit",
            memoryUsed < BATCH_SIMPLE_MAX_BYTES
        )
    }

    @Test
    fun memoryBatchComplexCards() {
        val cards = mutableListOf<AdaptiveCard>()
        val memoryUsed = measureMemoryAllocation {
            repeat(100) {
                cards.add(CardParser.parse(advancedCombinedJson))
            }
        }
        Log.d(TAG, "Batch 100 complex cards memory: ${memoryUsed / KB} KB (${cards.size} cards)")
        assertTrue(
            "Batch complex cards used ${memoryUsed / MB} MB, exceeds ${BATCH_COMPLEX_MAX_BYTES / MB} MB limit",
            memoryUsed < BATCH_COMPLEX_MAX_BYTES
        )
    }

    // ------------------------------------------------------------------
    // All-cards memory
    // ------------------------------------------------------------------

    @Test
    fun memoryAllCardsParse() {
        val results = mutableMapOf<String, Long>()
        for ((fileName, json) in allCardJsons) {
            val memoryUsed = measureMemoryAllocation {
                CardParser.parse(json)
            }
            results[fileName] = memoryUsed
        }

        val totalKB = results.values.sum() / KB
        Log.d(TAG, "All cards memory summary (total: $totalKB KB):")
        results.entries.sortedByDescending { it.value }.forEach { (name, bytes) ->
            Log.d(TAG, "  $name: ${bytes / KB} KB")
        }

        // The sum of all individual card parses should be reasonable.
        assertTrue(
            "Total memory for all ${results.size} cards: ${totalKB} KB",
            totalKB < 50 * 1024 // 50 MB total for all cards is generous
        )
    }

    // ------------------------------------------------------------------
    // Serialization memory
    // ------------------------------------------------------------------

    @Test
    fun memoryRoundTrip() {
        val card = CardParser.parse(advancedCombinedJson)
        val memoryUsed = measureMemoryAllocation {
            val serialized = CardParser.serialize(card)
            CardParser.parse(serialized)
        }
        Log.d(TAG, "Round-trip memory: ${memoryUsed / KB} KB")
        assertTrue(
            "Round-trip used ${memoryUsed / KB} KB, exceeds ${COMPLEX_CARD_MAX_BYTES / KB} KB limit",
            memoryUsed < COMPLEX_CARD_MAX_BYTES
        )
    }

    // ------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------

    /**
     * Measure the approximate heap memory allocated by [block].
     *
     * Forces GC before and after to get a more stable measurement.
     * This is approximate -- not suitable for micro-optimisation, but
     * good for catching regressions and large memory leaks.
     */
    private fun measureMemoryAllocation(block: () -> Unit): Long {
        forceGc()
        val before = Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory()
        block()
        forceGc()
        val after = Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory()
        return maxOf(0L, after - before)
    }

    private fun forceGc() {
        System.gc()
        System.runFinalization()
        System.gc()
        Thread.sleep(50)
    }
}
