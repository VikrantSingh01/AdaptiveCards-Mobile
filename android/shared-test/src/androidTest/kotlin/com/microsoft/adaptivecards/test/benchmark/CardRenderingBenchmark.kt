package com.microsoft.adaptivecards.test.benchmark

import android.util.Log
import androidx.benchmark.junit4.BenchmarkRule
import androidx.benchmark.junit4.measureRepeated
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import com.microsoft.adaptivecards.test.utils.*
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Performance benchmarks for Adaptive Card Compose rendering.
 *
 * Measures the time to set content, compose, and lay out cards of
 * varying complexity. Each benchmark sets the card content via the
 * Compose test rule and waits for the composition to settle.
 *
 * Run:
 * ```
 * ./gradlew :shared-test:connectedAndroidTest \
 *   -Pandroid.testInstrumentationRunnerArguments.class=com.microsoft.adaptivecards.test.benchmark.CardRenderingBenchmark
 * ```
 */
@RunWith(AndroidJUnit4::class)
class CardRenderingBenchmark {

    companion object {
        private const val TAG = "CardRenderingBenchmark"
        private val PHONE_LIGHT = TestConfiguration(
            DeviceConfig.PHONE_PORTRAIT,
            ThemeConfig.LIGHT
        )
    }

    @get:Rule
    val benchmarkRule = BenchmarkRule()

    @get:Rule
    val composeTestRule = createComposeRule()

    private lateinit var simpleTextJson: String
    private lateinit var containersJson: String
    private lateinit var allActionsJson: String
    private lateinit var allInputsJson: String
    private lateinit var tableJson: String
    private lateinit var advancedCombinedJson: String
    private lateinit var edgeDeeplyNestedJson: String
    private lateinit var carouselJson: String

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
        carouselJson = assets.open("carousel.json").bufferedReader().readText()
    }

    // ------------------------------------------------------------------
    // Simple card rendering
    // ------------------------------------------------------------------

    @Test
    fun renderSimpleText() {
        benchmarkRule.measureRepeated {
            composeTestRule.setCardContent(simpleTextJson, PHONE_LIGHT)
            composeTestRule.waitForIdle()
        }
    }

    // ------------------------------------------------------------------
    // Medium complexity rendering
    // ------------------------------------------------------------------

    @Test
    fun renderContainers() {
        benchmarkRule.measureRepeated {
            composeTestRule.setCardContent(containersJson, PHONE_LIGHT)
            composeTestRule.waitForIdle()
        }
    }

    @Test
    fun renderAllActions() {
        benchmarkRule.measureRepeated {
            composeTestRule.setCardContent(allActionsJson, PHONE_LIGHT)
            composeTestRule.waitForIdle()
        }
    }

    @Test
    fun renderAllInputs() {
        benchmarkRule.measureRepeated {
            composeTestRule.setCardContent(allInputsJson, PHONE_LIGHT)
            composeTestRule.waitForIdle()
        }
    }

    @Test
    fun renderTable() {
        benchmarkRule.measureRepeated {
            composeTestRule.setCardContent(tableJson, PHONE_LIGHT)
            composeTestRule.waitForIdle()
        }
    }

    // ------------------------------------------------------------------
    // High complexity rendering
    // ------------------------------------------------------------------

    @Test
    fun renderAdvancedCombined() {
        benchmarkRule.measureRepeated {
            composeTestRule.setCardContent(advancedCombinedJson, PHONE_LIGHT)
            composeTestRule.waitForIdle()
        }
    }

    @Test
    fun renderCarousel() {
        benchmarkRule.measureRepeated {
            composeTestRule.setCardContent(carouselJson, PHONE_LIGHT)
            composeTestRule.waitForIdle()
        }
    }

    // ------------------------------------------------------------------
    // Stress tests
    // ------------------------------------------------------------------

    @Test
    fun renderDeeplyNested() {
        benchmarkRule.measureRepeated {
            composeTestRule.setCardContent(edgeDeeplyNestedJson, PHONE_LIGHT)
            composeTestRule.waitForIdle()
        }
    }

    // ------------------------------------------------------------------
    // Theme switching
    // ------------------------------------------------------------------

    @Test
    fun renderSimpleTextDark() {
        val darkConfig = TestConfiguration(DeviceConfig.PHONE_PORTRAIT, ThemeConfig.DARK)
        benchmarkRule.measureRepeated {
            composeTestRule.setCardContent(simpleTextJson, darkConfig)
            composeTestRule.waitForIdle()
        }
    }

    @Test
    fun renderContainersDark() {
        val darkConfig = TestConfiguration(DeviceConfig.PHONE_PORTRAIT, ThemeConfig.DARK)
        benchmarkRule.measureRepeated {
            composeTestRule.setCardContent(containersJson, darkConfig)
            composeTestRule.waitForIdle()
        }
    }

    // ------------------------------------------------------------------
    // Large font scale rendering
    // ------------------------------------------------------------------

    @Test
    fun renderSimpleTextLargeFont() {
        val largeFont = TestConfiguration(
            DeviceConfig.PHONE_PORTRAIT,
            ThemeConfig.LIGHT,
            FontScaleConfig.MAXIMUM
        )
        benchmarkRule.measureRepeated {
            composeTestRule.setCardContent(simpleTextJson, largeFont)
            composeTestRule.waitForIdle()
        }
    }
}
