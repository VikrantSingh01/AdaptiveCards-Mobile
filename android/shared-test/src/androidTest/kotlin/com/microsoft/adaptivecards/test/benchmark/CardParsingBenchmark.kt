package com.microsoft.adaptivecards.test.benchmark

import android.util.Log
import androidx.benchmark.junit4.BenchmarkRule
import androidx.benchmark.junit4.measureRepeated
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import com.microsoft.adaptivecards.core.parsing.CardParser
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Performance benchmarks for Adaptive Card JSON parsing.
 *
 * Uses the AndroidX Benchmark library to produce stable, statistically
 * significant measurements of parse time for each card complexity level.
 *
 * Run:
 * ```
 * ./gradlew :shared-test:connectedAndroidTest \
 *   -Pandroid.testInstrumentationRunnerArguments.class=com.microsoft.adaptivecards.test.benchmark.CardParsingBenchmark
 * ```
 *
 * Benchmark results are written to the device at:
 *   /sdcard/Android/data/<pkg>/files/benchmarks/
 */
@RunWith(AndroidJUnit4::class)
class CardParsingBenchmark {

    companion object {
        private const val TAG = "CardParsingBenchmark"
    }

    @get:Rule
    val benchmarkRule = BenchmarkRule()

    private lateinit var simpleTextJson: String
    private lateinit var containersJson: String
    private lateinit var allActionsJson: String
    private lateinit var allInputsJson: String
    private lateinit var tableJson: String
    private lateinit var advancedCombinedJson: String
    private lateinit var edgeDeeplyNestedJson: String
    private lateinit var edgeLongTextJson: String
    private lateinit var chartsJson: String
    private lateinit var templatingNestedJson: String

    @Before
    fun setUp() {
        val assets = InstrumentationRegistry.getInstrumentation().context.assets
        simpleTextJson = assets.open("simple-text.json").bufferedReader().readText()
        containersJson = assets.open("containers.json").bufferedReader().readText()
        allActionsJson = assets.open("all-actions.json").bufferedReader().readText()
        allInputsJson = assets.open("all-inputs.json").bufferedReader().readText()
        tableJson = assets.open("table.json").bufferedReader().readText()
        advancedCombinedJson = assets.open("advanced-combined.json").bufferedReader().readText()
        edgeDeeplyNestedJson = assets.open("edge-deeply-nested.json").bufferedReader().readText()
        edgeLongTextJson = assets.open("edge-long-text.json").bufferedReader().readText()
        chartsJson = assets.open("charts.json").bufferedReader().readText()
        templatingNestedJson = assets.open("templating-nested.json").bufferedReader().readText()

        Log.d(TAG, "Card JSON sizes: simple=${simpleTextJson.length}, " +
            "containers=${containersJson.length}, " +
            "allActions=${allActionsJson.length}, " +
            "advanced=${advancedCombinedJson.length}, " +
            "deeplyNested=${edgeDeeplyNestedJson.length}")
    }

    // ------------------------------------------------------------------
    // Simple cards (baseline)
    // ------------------------------------------------------------------

    @Test
    fun parseSimpleText() {
        benchmarkRule.measureRepeated {
            CardParser.parse(simpleTextJson)
        }
    }

    // ------------------------------------------------------------------
    // Medium complexity
    // ------------------------------------------------------------------

    @Test
    fun parseContainers() {
        benchmarkRule.measureRepeated {
            CardParser.parse(containersJson)
        }
    }

    @Test
    fun parseAllActions() {
        benchmarkRule.measureRepeated {
            CardParser.parse(allActionsJson)
        }
    }

    @Test
    fun parseAllInputs() {
        benchmarkRule.measureRepeated {
            CardParser.parse(allInputsJson)
        }
    }

    @Test
    fun parseTable() {
        benchmarkRule.measureRepeated {
            CardParser.parse(tableJson)
        }
    }

    // ------------------------------------------------------------------
    // High complexity
    // ------------------------------------------------------------------

    @Test
    fun parseAdvancedCombined() {
        benchmarkRule.measureRepeated {
            CardParser.parse(advancedCombinedJson)
        }
    }

    @Test
    fun parseCharts() {
        benchmarkRule.measureRepeated {
            CardParser.parse(chartsJson)
        }
    }

    @Test
    fun parseTemplatingNested() {
        benchmarkRule.measureRepeated {
            CardParser.parse(templatingNestedJson)
        }
    }

    // ------------------------------------------------------------------
    // Stress tests
    // ------------------------------------------------------------------

    @Test
    fun parseDeeplyNested() {
        benchmarkRule.measureRepeated {
            CardParser.parse(edgeDeeplyNestedJson)
        }
    }

    @Test
    fun parseLongText() {
        benchmarkRule.measureRepeated {
            CardParser.parse(edgeLongTextJson)
        }
    }

    // ------------------------------------------------------------------
    // Serialization round-trip
    // ------------------------------------------------------------------

    @Test
    fun roundTripSimpleText() {
        benchmarkRule.measureRepeated {
            val card = CardParser.parse(simpleTextJson)
            CardParser.serialize(card)
        }
    }

    @Test
    fun roundTripAdvancedCombined() {
        benchmarkRule.measureRepeated {
            val card = CardParser.parse(advancedCombinedJson)
            CardParser.serialize(card)
        }
    }
}
