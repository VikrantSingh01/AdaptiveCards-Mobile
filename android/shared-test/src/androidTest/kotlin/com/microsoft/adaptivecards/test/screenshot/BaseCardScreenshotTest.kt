package com.microsoft.adaptivecards.test.screenshot

import android.content.Context
import android.graphics.Bitmap
import android.util.Log
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.test.core.app.ApplicationProvider
import androidx.test.platform.app.InstrumentationRegistry
import com.microsoft.adaptivecards.core.hostconfig.HostConfig
import com.microsoft.adaptivecards.core.hostconfig.HostConfigParser
import com.microsoft.adaptivecards.test.utils.*
import org.junit.After
import org.junit.Assert
import org.junit.Before
import org.junit.Rule

/**
 * Base class for Adaptive Card visual regression tests.
 *
 * Subclasses override [testConfigurations] and [cardFiles] to define which
 * card/configuration combinations to test. The base class provides:
 *
 * - Automated card JSON loading from assets
 * - Screenshot capture via Compose test rules
 * - Baseline comparison with diff generation
 * - Report recording for each test variant
 *
 * ### Update baselines
 *
 * Pass the instrumentation argument `updateBaselines=true` to promote all
 * current screenshots as the new baselines instead of comparing:
 *
 * ```
 * ./gradlew :shared-test:connectedAndroidTest \
 *   -Pandroid.testInstrumentationRunnerArguments.updateBaselines=true
 * ```
 *
 * ### Quick smoke test
 *
 * Use [TestConfiguration.smokeTestMatrix] to run a reduced configuration set:
 *
 * ```kotlin
 * override val testConfigurations get() = TestConfiguration.smokeTestMatrix()
 * ```
 */
abstract class BaseCardScreenshotTest {

    companion object {
        private const val TAG = "BaseCardScreenshotTest"
        private const val UPDATE_BASELINES_KEY = "updateBaselines"

        /** Shared report generator across all test classes in a single run. */
        @JvmStatic
        protected val reportGenerator: TestReportGenerator by lazy {
            TestReportGenerator(ScreenshotStorage(ApplicationProvider.getApplicationContext()))
        }
    }

    @get:Rule
    val composeTestRule = createComposeRule()

    protected lateinit var context: Context
    protected lateinit var storage: ScreenshotStorage
    protected lateinit var hostConfig: HostConfig

    /** Whether to update baselines instead of comparing against them. */
    protected val updateBaselines: Boolean by lazy {
        InstrumentationRegistry.getArguments()
            .getString(UPDATE_BASELINES_KEY, "false")
            .toBoolean()
    }

    /** Comparison config to use. Override to relax/tighten tolerance. */
    open val comparisonConfig: ComparisonConfig
        get() = ComparisonConfig(
            maxDiffPercentage = 0.1,
            perPixelThreshold = 10,
            generateDiffImage = true
        )

    /** The set of test configurations to run for each card. */
    abstract val testConfigurations: List<TestConfiguration>

    /** The card JSON file names (from shared/test-cards/) to test. */
    abstract val cardFiles: List<String>

    /** Optional host config override. */
    open fun provideHostConfig(): HostConfig = HostConfigParser.default()

    @Before
    open fun setUp() {
        context = ApplicationProvider.getApplicationContext()
        storage = ScreenshotStorage(context)
        hostConfig = provideHostConfig()
        Log.d(TAG, "setUp: updateBaselines=$updateBaselines, configs=${testConfigurations.size}, cards=${cardFiles.size}")
    }

    @After
    open fun tearDown() {
        // Individual test cleanup if needed.
    }

    // ------------------------------------------------------------------
    // Core test execution
    // ------------------------------------------------------------------

    /**
     * Run the visual regression test for a single card across all configurations.
     *
     * Call this from each parameterised test method.
     */
    protected fun runVisualRegressionTest(cardFileName: String) {
        val cardJson = loadCardJson(cardFileName)
        val testName = cardFileName.removeSuffix(".json")

        val failures = mutableListOf<String>()

        for (config in testConfigurations) {
            try {
                val result = runSingleTest(testName, cardJson, cardFileName, config)
                if (!result) {
                    failures.add("${config.configKey}: visual mismatch detected")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error testing $testName with ${config.configKey}", e)
                reportGenerator.record(
                    testName = testName,
                    cardFile = cardFileName,
                    configKey = config.configKey,
                    configDescription = config.description,
                    result = null,
                    baselineExists = false,
                    error = e.message ?: "Unknown error"
                )
                failures.add("${config.configKey}: ${e.message}")
            }
        }

        if (failures.isNotEmpty() && !updateBaselines) {
            Assert.fail(
                "Visual regression failures for $cardFileName:\n${failures.joinToString("\n  - ", "  - ")}"
            )
        }
    }

    /**
     * Run a single card + configuration test case.
     *
     * @return true if the test passed (or baseline was updated).
     */
    private fun runSingleTest(
        testName: String,
        cardJson: String,
        cardFileName: String,
        config: TestConfiguration
    ): Boolean {
        // 1. Render the card
        composeTestRule.setCardContent(cardJson, config, hostConfig)
        composeTestRule.waitForCardRender()

        // 2. Capture screenshot
        val actual: Bitmap = composeTestRule.captureRootScreenshot()

        // 3. Save actual
        storage.saveActual(actual, testName, config.configKey)

        // 4. Handle baseline update mode
        if (updateBaselines) {
            storage.promoteActualToBaseline(testName, config.configKey)
            reportGenerator.record(
                testName = testName,
                cardFile = cardFileName,
                configKey = config.configKey,
                configDescription = config.description,
                result = null,
                baselineExists = false,
                error = null
            )
            Log.d(TAG, "Updated baseline for $testName / ${config.configKey}")
            return true
        }

        // 5. Load baseline
        val baseline = storage.loadBaseline(testName, config.configKey)
        if (baseline == null) {
            // No baseline yet -- save the current as baseline and record as new.
            storage.promoteActualToBaseline(testName, config.configKey)
            reportGenerator.record(
                testName = testName,
                cardFile = cardFileName,
                configKey = config.configKey,
                configDescription = config.description,
                result = null,
                baselineExists = false
            )
            Log.d(TAG, "No baseline for $testName / ${config.configKey} -- created new baseline")
            return true // new baselines are not failures
        }

        // 6. Compare
        val comparison = ScreenshotComparator.compare(baseline, actual, comparisonConfig)

        // 7. Save diff if there is one
        if (!comparison.matches && comparison.diffBitmap != null) {
            storage.saveDiff(comparison.diffBitmap, testName, config.configKey)
        }

        // 8. Record
        reportGenerator.record(
            testName = testName,
            cardFile = cardFileName,
            configKey = config.configKey,
            configDescription = config.description,
            result = comparison,
            baselineExists = true
        )

        Log.d(TAG, "$testName / ${config.configKey}: ${comparison.summary()}")
        return comparison.matches
    }

    // ------------------------------------------------------------------
    // Card JSON loading
    // ------------------------------------------------------------------

    /**
     * Load a card JSON file from the test assets.
     *
     * The file is expected to be in `shared/test-cards/` which is mapped
     * to the `androidTest` assets source set.
     */
    protected fun loadCardJson(fileName: String): String {
        return try {
            InstrumentationRegistry.getInstrumentation()
                .context
                .assets
                .open(fileName)
                .bufferedReader()
                .use { it.readText() }
        } catch (e: Exception) {
            throw IllegalStateException("Could not load card JSON '$fileName' from assets", e)
        }
    }

    /**
     * List all `.json` card files available in the assets.
     */
    protected fun listCardFiles(): List<String> {
        return try {
            InstrumentationRegistry.getInstrumentation()
                .context
                .assets
                .list("")
                ?.filter { it.endsWith(".json") }
                ?.sorted()
                ?: emptyList()
        } catch (e: Exception) {
            Log.e(TAG, "Could not list card files from assets", e)
            emptyList()
        }
    }
}
