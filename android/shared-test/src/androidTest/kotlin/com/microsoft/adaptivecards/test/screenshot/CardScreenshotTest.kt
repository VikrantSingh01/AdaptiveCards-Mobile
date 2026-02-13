package com.microsoft.adaptivecards.test.screenshot

import android.util.Log
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.microsoft.adaptivecards.test.utils.TestConfiguration
import org.junit.AfterClass
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Comprehensive visual regression tests for all Adaptive Card types.
 *
 * This test class loads every card JSON from `shared/test-cards/`, renders
 * it across the core set of device/theme/font/locale configurations, and
 * compares screenshots against stored baselines.
 *
 * Run all visual regression tests:
 * ```
 * ./gradlew :shared-test:connectedAndroidTest \
 *   -Pandroid.testInstrumentationRunnerArguments.class=com.microsoft.adaptivecards.test.screenshot.CardScreenshotTest
 * ```
 *
 * Update all baselines:
 * ```
 * ./gradlew :shared-test:connectedAndroidTest \
 *   -Pandroid.testInstrumentationRunnerArguments.class=com.microsoft.adaptivecards.test.screenshot.CardScreenshotTest \
 *   -Pandroid.testInstrumentationRunnerArguments.updateBaselines=true
 * ```
 */
@RunWith(AndroidJUnit4::class)
class CardScreenshotTest : BaseCardScreenshotTest() {

    companion object {
        private const val TAG = "CardScreenshotTest"

        @JvmStatic
        @AfterClass
        fun generateReports() {
            try {
                reportGenerator.generateJsonReport()
                reportGenerator.generateHtmlReport()
                Log.d(TAG, "Reports generated successfully")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to generate reports", e)
            }
        }
    }

    override val testConfigurations: List<TestConfiguration>
        get() = TestConfiguration.coreMatrix()

    override val cardFiles: List<String>
        get() = ALL_CARD_FILES

    // ------------------------------------------------------------------
    // Text & Typography
    // ------------------------------------------------------------------

    @Test
    fun simpleText() {
        runVisualRegressionTest("simple-text.json")
    }

    @Test
    fun markdown() {
        runVisualRegressionTest("markdown.json")
    }

    @Test
    fun richText() {
        runVisualRegressionTest("rich-text.json")
    }

    @Test
    fun codeBlock() {
        runVisualRegressionTest("code-block.json")
    }

    // ------------------------------------------------------------------
    // Containers & Layout
    // ------------------------------------------------------------------

    @Test
    fun containers() {
        runVisualRegressionTest("containers.json")
    }

    @Test
    fun responsiveLayout() {
        runVisualRegressionTest("responsive-layout.json")
    }

    @Test
    fun tabSet() {
        runVisualRegressionTest("tab-set.json")
    }

    @Test
    fun accordion() {
        runVisualRegressionTest("accordion.json")
    }

    @Test
    fun carousel() {
        runVisualRegressionTest("carousel.json")
    }

    @Test
    fun list() {
        runVisualRegressionTest("list.json")
    }

    // ------------------------------------------------------------------
    // Data Display
    // ------------------------------------------------------------------

    @Test
    fun table() {
        runVisualRegressionTest("table.json")
    }

    @Test
    fun dataGrid() {
        runVisualRegressionTest("datagrid.json")
    }

    @Test
    fun charts() {
        runVisualRegressionTest("charts.json")
    }

    // ------------------------------------------------------------------
    // Actions
    // ------------------------------------------------------------------

    @Test
    fun allActions() {
        runVisualRegressionTest("all-actions.json")
    }

    @Test
    fun popoverAction() {
        runVisualRegressionTest("popover-action.json")
    }

    @Test
    fun splitButtons() {
        runVisualRegressionTest("split-buttons.json")
    }

    // ------------------------------------------------------------------
    // Inputs
    // ------------------------------------------------------------------

    @Test
    fun allInputs() {
        runVisualRegressionTest("all-inputs.json")
    }

    @Test
    fun inputForm() {
        runVisualRegressionTest("input-form.json")
    }

    @Test
    fun rating() {
        runVisualRegressionTest("rating.json")
    }

    // ------------------------------------------------------------------
    // Media
    // ------------------------------------------------------------------

    @Test
    fun media() {
        runVisualRegressionTest("media.json")
    }

    // ------------------------------------------------------------------
    // Theming
    // ------------------------------------------------------------------

    @Test
    fun fluentTheming() {
        runVisualRegressionTest("fluent-theming.json")
    }

    // ------------------------------------------------------------------
    // Advanced Elements
    // ------------------------------------------------------------------

    @Test
    fun compoundButtons() {
        runVisualRegressionTest("compound-buttons.json")
    }

    @Test
    fun progressIndicators() {
        runVisualRegressionTest("progress-indicators.json")
    }

    @Test
    fun streamingCard() {
        runVisualRegressionTest("streaming-card.json")
    }

    @Test
    fun advancedCombined() {
        runVisualRegressionTest("advanced-combined.json")
    }

    // ------------------------------------------------------------------
    // Copilot / Teams
    // ------------------------------------------------------------------

    @Test
    fun copilotCitations() {
        runVisualRegressionTest("copilot-citations.json")
    }

    @Test
    fun teamsConnector() {
        runVisualRegressionTest("teams-connector.json")
    }

    @Test
    fun teamsTaskModule() {
        runVisualRegressionTest("teams-task-module.json")
    }

    // ------------------------------------------------------------------
    // Templating
    // ------------------------------------------------------------------

    @Test
    fun templatingBasic() {
        runVisualRegressionTest("templating-basic.json")
    }

    @Test
    fun templatingConditional() {
        runVisualRegressionTest("templating-conditional.json")
    }

    @Test
    fun templatingExpressions() {
        runVisualRegressionTest("templating-expressions.json")
    }

    @Test
    fun templatingIteration() {
        runVisualRegressionTest("templating-iteration.json")
    }

    @Test
    fun templatingNested() {
        runVisualRegressionTest("templating-nested.json")
    }

    @Test
    fun themedImages() {
        runVisualRegressionTest("themed-images.json")
    }

    // ------------------------------------------------------------------
    // Edge Cases
    // ------------------------------------------------------------------

    @Test
    fun edgeEmptyCard() {
        runVisualRegressionTest("edge-empty-card.json")
    }

    @Test
    fun edgeEmptyContainers() {
        runVisualRegressionTest("edge-empty-containers.json")
    }

    @Test
    fun edgeLongText() {
        runVisualRegressionTest("edge-long-text.json")
    }

    @Test
    fun edgeDeeplyNested() {
        runVisualRegressionTest("edge-deeply-nested.json")
    }

    @Test
    fun edgeMaxActions() {
        runVisualRegressionTest("edge-max-actions.json")
    }

    @Test
    fun edgeMixedInputs() {
        runVisualRegressionTest("edge-mixed-inputs.json")
    }

    @Test
    fun edgeRtlContent() {
        runVisualRegressionTest("edge-rtl-content.json")
    }

    @Test
    fun edgeAllUnknownTypes() {
        runVisualRegressionTest("edge-all-unknown-types.json")
    }
}

// ------------------------------------------------------------------
// All known card files for reference
// ------------------------------------------------------------------

private val ALL_CARD_FILES = listOf(
    "accordion.json",
    "advanced-combined.json",
    "all-actions.json",
    "all-inputs.json",
    "carousel.json",
    "charts.json",
    "code-block.json",
    "compound-buttons.json",
    "containers.json",
    "copilot-citations.json",
    "datagrid.json",
    "edge-all-unknown-types.json",
    "edge-deeply-nested.json",
    "edge-empty-card.json",
    "edge-empty-containers.json",
    "edge-long-text.json",
    "edge-max-actions.json",
    "edge-mixed-inputs.json",
    "edge-rtl-content.json",
    "fluent-theming.json",
    "input-form.json",
    "list.json",
    "markdown.json",
    "media.json",
    "popover-action.json",
    "progress-indicators.json",
    "rating.json",
    "responsive-layout.json",
    "rich-text.json",
    "simple-text.json",
    "split-buttons.json",
    "streaming-card.json",
    "tab-set.json",
    "table.json",
    "teams-connector.json",
    "teams-task-module.json",
    "templating-basic.json",
    "templating-conditional.json",
    "templating-expressions.json",
    "templating-iteration.json",
    "templating-nested.json",
    "themed-images.json"
)
