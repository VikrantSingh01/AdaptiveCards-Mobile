package com.microsoft.adaptivecards.test.screenshot

import android.util.Log
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.microsoft.adaptivecards.core.hostconfig.HostConfig
import com.microsoft.adaptivecards.core.hostconfig.HostConfigParser
import com.microsoft.adaptivecards.core.hostconfig.TeamsHostConfig
import com.microsoft.adaptivecards.test.utils.*
import org.junit.AfterClass
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Focused visual regression tests for theme rendering.
 *
 * Tests a representative set of cards under:
 * - Light theme with default host config
 * - Dark theme with default host config
 * - Light theme with Teams host config
 * - Dark theme with Teams host config
 *
 * This ensures colour tokens, backgrounds, foreground colours, and
 * container styles render correctly under all theme/host-config combos.
 *
 * Run:
 * ```
 * ./gradlew :shared-test:connectedAndroidTest \
 *   -Pandroid.testInstrumentationRunnerArguments.class=com.microsoft.adaptivecards.test.screenshot.ThemeScreenshotTest
 * ```
 */
@RunWith(AndroidJUnit4::class)
class ThemeScreenshotTest : BaseCardScreenshotTest() {

    companion object {
        private const val TAG = "ThemeScreenshotTest"

        @JvmStatic
        @AfterClass
        fun generateReports() {
            try {
                reportGenerator.generateJsonReport()
                reportGenerator.generateHtmlReport()
                Log.d(TAG, "Theme test reports generated")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to generate reports", e)
            }
        }
    }

    override val testConfigurations: List<TestConfiguration>
        get() = listOf(
            TestConfiguration(DeviceConfig.PHONE_PORTRAIT, ThemeConfig.LIGHT),
            TestConfiguration(DeviceConfig.PHONE_PORTRAIT, ThemeConfig.DARK),
            TestConfiguration(DeviceConfig.TABLET_PORTRAIT, ThemeConfig.LIGHT),
            TestConfiguration(DeviceConfig.TABLET_PORTRAIT, ThemeConfig.DARK)
        )

    override val cardFiles: List<String>
        get() = THEME_CARD_FILES

    // ------------------------------------------------------------------
    // Default host config
    // ------------------------------------------------------------------

    @Test
    fun simpleTextThemes() {
        runVisualRegressionTest("simple-text.json")
    }

    @Test
    fun containersThemes() {
        runVisualRegressionTest("containers.json")
    }

    @Test
    fun fluentThemingThemes() {
        runVisualRegressionTest("fluent-theming.json")
    }

    @Test
    fun allActionsThemes() {
        runVisualRegressionTest("all-actions.json")
    }

    @Test
    fun allInputsThemes() {
        runVisualRegressionTest("all-inputs.json")
    }

    @Test
    fun compoundButtonsThemes() {
        runVisualRegressionTest("compound-buttons.json")
    }

    @Test
    fun progressIndicatorsThemes() {
        runVisualRegressionTest("progress-indicators.json")
    }

    @Test
    fun ratingThemes() {
        runVisualRegressionTest("rating.json")
    }

    @Test
    fun tableThemes() {
        runVisualRegressionTest("table.json")
    }
}

private val THEME_CARD_FILES = listOf(
    "simple-text.json",
    "containers.json",
    "fluent-theming.json",
    "all-actions.json",
    "all-inputs.json",
    "compound-buttons.json",
    "progress-indicators.json",
    "rating.json",
    "table.json"
)
