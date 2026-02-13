package com.microsoft.adaptivecards.test.screenshot

import android.util.Log
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.microsoft.adaptivecards.test.utils.TestConfiguration
import org.junit.AfterClass
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Smoke test subset for quick CI validation.
 *
 * Uses the smoke test matrix (2 devices x 2 themes x 2 font scales x 2 locales = 16 configs)
 * with a carefully selected subset of representative card files.
 *
 * Run:
 * ```
 * ./gradlew :shared-test:connectedAndroidTest \
 *   -Pandroid.testInstrumentationRunnerArguments.class=com.microsoft.adaptivecards.test.screenshot.SmokeScreenshotTest
 * ```
 */
@RunWith(AndroidJUnit4::class)
class SmokeScreenshotTest : BaseCardScreenshotTest() {

    companion object {
        private const val TAG = "SmokeScreenshotTest"

        @JvmStatic
        @AfterClass
        fun generateReports() {
            try {
                reportGenerator.generateJsonReport()
                reportGenerator.generateHtmlReport()
                Log.d(TAG, "Smoke test reports generated")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to generate reports", e)
            }
        }
    }

    override val testConfigurations: List<TestConfiguration>
        get() = TestConfiguration.smokeTestMatrix()

    override val cardFiles: List<String>
        get() = SMOKE_CARD_FILES

    @Test
    fun simpleText() {
        runVisualRegressionTest("simple-text.json")
    }

    @Test
    fun containers() {
        runVisualRegressionTest("containers.json")
    }

    @Test
    fun allActions() {
        runVisualRegressionTest("all-actions.json")
    }

    @Test
    fun allInputs() {
        runVisualRegressionTest("all-inputs.json")
    }

    @Test
    fun table() {
        runVisualRegressionTest("table.json")
    }

    @Test
    fun fluentTheming() {
        runVisualRegressionTest("fluent-theming.json")
    }

    @Test
    fun edgeRtlContent() {
        runVisualRegressionTest("edge-rtl-content.json")
    }

    @Test
    fun edgeLongText() {
        runVisualRegressionTest("edge-long-text.json")
    }

    // --- Official samples ---

    @Test
    fun officialActivityUpdate() {
        runVisualRegressionTest("official-samples/activity-update.json")
    }

    @Test
    fun officialFlightDetails() {
        runVisualRegressionTest("official-samples/flight-details.json")
    }

    @Test
    fun officialWeatherLarge() {
        runVisualRegressionTest("official-samples/weather-large.json")
    }

    @Test
    fun officialStockUpdate() {
        runVisualRegressionTest("official-samples/stock-update.json")
    }

    @Test
    fun officialInputForm() {
        runVisualRegressionTest("official-samples/input-form-official.json")
    }

    @Test
    fun officialInputFormRtl() {
        runVisualRegressionTest("official-samples/input-form-rtl.json")
    }

    // --- Element samples ---

    @Test
    fun elementTableBasic() {
        runVisualRegressionTest("element-samples/table-basic.json")
    }

    @Test
    fun elementCarouselBasic() {
        runVisualRegressionTest("element-samples/carousel-basic.json")
    }

    @Test
    fun elementAdaptiveCardRtl() {
        runVisualRegressionTest("element-samples/adaptive-card-rtl.json")
    }

    @Test
    fun elementTextblockStyle() {
        runVisualRegressionTest("element-samples/textblock-style.json")
    }
}

private val SMOKE_CARD_FILES = listOf(
    // Existing
    "simple-text.json",
    "containers.json",
    "all-actions.json",
    "all-inputs.json",
    "table.json",
    "fluent-theming.json",
    "edge-rtl-content.json",
    "edge-long-text.json",
    // Official samples
    "official-samples/activity-update.json",
    "official-samples/flight-details.json",
    "official-samples/weather-large.json",
    "official-samples/stock-update.json",
    "official-samples/input-form-official.json",
    "official-samples/input-form-rtl.json",
    // Element samples
    "element-samples/table-basic.json",
    "element-samples/carousel-basic.json",
    "element-samples/adaptive-card-rtl.json",
    "element-samples/textblock-style.json"
)
