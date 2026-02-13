package com.microsoft.adaptivecards.test.screenshot

import android.util.Log
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.microsoft.adaptivecards.test.utils.*
import org.junit.AfterClass
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Visual regression tests focused on accessibility scenarios.
 *
 * Covers:
 * - Multiple font scales (1.0x, 1.3x, 1.5x, 2.0x) to ensure text wraps
 *   and layouts adapt without clipping or overflow.
 * - RTL locales (Arabic, Hebrew) to verify mirrored layout direction
 *   and correct text alignment.
 * - Combination of large fonts with RTL.
 *
 * Run:
 * ```
 * ./gradlew :shared-test:connectedAndroidTest \
 *   -Pandroid.testInstrumentationRunnerArguments.class=com.microsoft.adaptivecards.test.screenshot.AccessibilityScreenshotTest
 * ```
 */
@RunWith(AndroidJUnit4::class)
class AccessibilityScreenshotTest : BaseCardScreenshotTest() {

    companion object {
        private const val TAG = "AccessibilityScreenshotTest"

        @JvmStatic
        @AfterClass
        fun generateReports() {
            try {
                reportGenerator.generateJsonReport()
                reportGenerator.generateHtmlReport()
                Log.d(TAG, "Accessibility test reports generated")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to generate reports", e)
            }
        }
    }

    override val testConfigurations: List<TestConfiguration>
        get() = buildList {
            // All font scales on phone, LTR
            for (fontScale in FontScaleConfig.ALL) {
                add(TestConfiguration(DeviceConfig.PHONE_PORTRAIT, ThemeConfig.LIGHT, fontScale, LocaleConfig.ENGLISH))
            }
            // RTL locales at default and large font
            for (locale in listOf(LocaleConfig.ARABIC, LocaleConfig.HEBREW)) {
                add(TestConfiguration(DeviceConfig.PHONE_PORTRAIT, ThemeConfig.LIGHT, FontScaleConfig.DEFAULT, locale))
                add(TestConfiguration(DeviceConfig.PHONE_PORTRAIT, ThemeConfig.LIGHT, FontScaleConfig.LARGE, locale))
            }
            // Maximum font on small phone (stress test)
            add(TestConfiguration(DeviceConfig.SMALL_PHONE, ThemeConfig.LIGHT, FontScaleConfig.MAXIMUM))
            // Maximum font on tablet
            add(TestConfiguration(DeviceConfig.TABLET_PORTRAIT, ThemeConfig.LIGHT, FontScaleConfig.MAXIMUM))
        }

    override val cardFiles: List<String>
        get() = ACCESSIBILITY_CARD_FILES

    // ------------------------------------------------------------------
    // Font scale tests
    // ------------------------------------------------------------------

    @Test
    fun simpleTextAccessibility() {
        runVisualRegressionTest("simple-text.json")
    }

    @Test
    fun markdownAccessibility() {
        runVisualRegressionTest("markdown.json")
    }

    @Test
    fun richTextAccessibility() {
        runVisualRegressionTest("rich-text.json")
    }

    @Test
    fun containersAccessibility() {
        runVisualRegressionTest("containers.json")
    }

    @Test
    fun allInputsAccessibility() {
        runVisualRegressionTest("all-inputs.json")
    }

    @Test
    fun allActionsAccessibility() {
        runVisualRegressionTest("all-actions.json")
    }

    @Test
    fun tableAccessibility() {
        runVisualRegressionTest("table.json")
    }

    @Test
    fun edgeLongTextAccessibility() {
        runVisualRegressionTest("edge-long-text.json")
    }

    // ------------------------------------------------------------------
    // RTL-specific tests
    // ------------------------------------------------------------------

    @Test
    fun edgeRtlContentAccessibility() {
        runVisualRegressionTest("edge-rtl-content.json")
    }

    @Test
    fun compoundButtonsAccessibility() {
        runVisualRegressionTest("compound-buttons.json")
    }

    @Test
    fun tabSetAccessibility() {
        runVisualRegressionTest("tab-set.json")
    }
}

private val ACCESSIBILITY_CARD_FILES = listOf(
    "simple-text.json",
    "markdown.json",
    "rich-text.json",
    "containers.json",
    "all-inputs.json",
    "all-actions.json",
    "table.json",
    "edge-long-text.json",
    "edge-rtl-content.json",
    "compound-buttons.json",
    "tab-set.json"
)
