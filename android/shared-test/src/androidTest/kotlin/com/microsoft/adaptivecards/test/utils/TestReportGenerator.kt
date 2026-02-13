package com.microsoft.adaptivecards.test.utils

import android.util.Log
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Generates structured JSON and HTML reports from visual regression test results.
 */
class TestReportGenerator(private val storage: ScreenshotStorage) {

    companion object {
        private const val TAG = "TestReportGenerator"
        private val json = Json { prettyPrint = true; encodeDefaults = true }
    }

    private val entries = mutableListOf<TestResultEntry>()
    private val startTime = System.currentTimeMillis()

    /** Record a single test result. */
    fun record(entry: TestResultEntry) {
        entries.add(entry)
        Log.d(TAG, "Recorded: ${entry.testName} [${entry.configKey}] => ${entry.status}")
    }

    /** Record a comparison result with all context. */
    fun record(
        testName: String,
        cardFile: String,
        configKey: String,
        configDescription: String,
        result: ComparisonResult?,
        baselineExists: Boolean,
        error: String? = null
    ) {
        val status = when {
            error != null -> TestStatus.ERROR
            !baselineExists -> TestStatus.NEW_BASELINE
            result == null -> TestStatus.ERROR
            result.matches -> TestStatus.PASSED
            else -> TestStatus.FAILED
        }

        record(
            TestResultEntry(
                testName = testName,
                cardFile = cardFile,
                configKey = configKey,
                configDescription = configDescription,
                status = status,
                diffPercentage = result?.diffPercentage,
                maxPixelDelta = result?.maxPixelDelta,
                mismatchedPixels = result?.mismatchedPixelCount,
                totalPixels = result?.totalPixels,
                error = error
            )
        )
    }

    /** Generate the JSON report and write to disk. */
    fun generateJsonReport(): File {
        val report = TestReport(
            timestamp = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).format(Date()),
            durationMs = System.currentTimeMillis() - startTime,
            deviceKey = storage.deviceKey(),
            summary = buildSummary(),
            results = entries.sortedBy { it.testName }
        )

        val reportFile = File(storage.reportsDir, "visual_regression_report.json")
        reportFile.writeText(json.encodeToString(report))
        Log.d(TAG, "JSON report written to: ${reportFile.absolutePath}")
        return reportFile
    }

    /** Generate an HTML report for easy visual inspection. */
    fun generateHtmlReport(): File {
        val summary = buildSummary()
        val html = buildString {
            appendLine("<!DOCTYPE html>")
            appendLine("<html lang=\"en\"><head>")
            appendLine("<meta charset=\"UTF-8\">")
            appendLine("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">")
            appendLine("<title>Adaptive Cards Visual Regression Report</title>")
            appendLine("<style>")
            appendLine(CSS_STYLES)
            appendLine("</style></head><body>")
            appendLine("<div class=\"container\">")
            appendLine("<h1>Adaptive Cards Visual Regression Report</h1>")
            appendLine("<p class=\"timestamp\">Generated: ${Date()}</p>")
            appendLine("<p>Device: ${storage.deviceKey()}</p>")

            // Summary cards
            appendLine("<div class=\"summary\">")
            appendLine(summaryCard("Total", summary.total, "total"))
            appendLine(summaryCard("Passed", summary.passed, "passed"))
            appendLine(summaryCard("Failed", summary.failed, "failed"))
            appendLine(summaryCard("New Baselines", summary.newBaselines, "new"))
            appendLine(summaryCard("Errors", summary.errors, "error"))
            appendLine("</div>")

            // Pass rate
            val passRate = if (summary.total > 0) {
                "%.1f".format((summary.passed.toDouble() / summary.total) * 100)
            } else "N/A"
            appendLine("<div class=\"pass-rate\">Pass Rate: $passRate%</div>")

            // Results table
            appendLine("<table><thead><tr>")
            appendLine("<th>Test</th><th>Card</th><th>Configuration</th><th>Status</th><th>Diff %</th><th>Details</th>")
            appendLine("</tr></thead><tbody>")

            for (entry in entries.sortedBy { it.testName }) {
                val statusClass = when (entry.status) {
                    TestStatus.PASSED -> "status-passed"
                    TestStatus.FAILED -> "status-failed"
                    TestStatus.NEW_BASELINE -> "status-new"
                    TestStatus.ERROR -> "status-error"
                }
                appendLine("<tr class=\"$statusClass\">")
                appendLine("<td>${entry.testName}</td>")
                appendLine("<td>${entry.cardFile}</td>")
                appendLine("<td>${entry.configDescription}</td>")
                appendLine("<td><span class=\"badge $statusClass\">${entry.status.name}</span></td>")
                appendLine("<td>${entry.diffPercentage?.let { "%.4f".format(it) } ?: "-"}</td>")
                appendLine("<td>${entry.error ?: "${entry.mismatchedPixels ?: 0}/${entry.totalPixels ?: 0} px"}</td>")
                appendLine("</tr>")
            }

            appendLine("</tbody></table>")
            appendLine("</div></body></html>")
        }

        val htmlFile = File(storage.reportsDir, "visual_regression_report.html")
        htmlFile.writeText(html)
        Log.d(TAG, "HTML report written to: ${htmlFile.absolutePath}")
        return htmlFile
    }

    // ------------------------------------------------------------------
    // Internals
    // ------------------------------------------------------------------

    private fun buildSummary(): TestSummary {
        return TestSummary(
            total = entries.size,
            passed = entries.count { it.status == TestStatus.PASSED },
            failed = entries.count { it.status == TestStatus.FAILED },
            newBaselines = entries.count { it.status == TestStatus.NEW_BASELINE },
            errors = entries.count { it.status == TestStatus.ERROR }
        )
    }

    private fun summaryCard(label: String, count: Int, cssClass: String): String {
        return "<div class=\"summary-card $cssClass\"><div class=\"count\">$count</div><div class=\"label\">$label</div></div>"
    }
}

// ------------------------------------------------------------------
// Data models
// ------------------------------------------------------------------

enum class TestStatus {
    PASSED, FAILED, NEW_BASELINE, ERROR
}

@Serializable
data class TestResultEntry(
    val testName: String,
    val cardFile: String,
    val configKey: String,
    val configDescription: String,
    val status: TestStatus,
    val diffPercentage: Double? = null,
    val maxPixelDelta: Int? = null,
    val mismatchedPixels: Int? = null,
    val totalPixels: Int? = null,
    val error: String? = null
)

@Serializable
data class TestSummary(
    val total: Int,
    val passed: Int,
    val failed: Int,
    val newBaselines: Int,
    val errors: Int
)

@Serializable
data class TestReport(
    val timestamp: String,
    val durationMs: Long,
    val deviceKey: String,
    val summary: TestSummary,
    val results: List<TestResultEntry>
)

// ------------------------------------------------------------------
// Test run listener (registered via instrumentationRunnerArguments)
// ------------------------------------------------------------------

/**
 * A JUnit RunListener that generates reports at the end of a test run.
 * Registered via `testInstrumentationRunnerArguments` in build.gradle.kts.
 *
 * Note: Actual report generation is triggered from the BaseCardScreenshotTest
 * class via @AfterClass, as the RunListener cannot easily access the report
 * generator instance. This listener logs test start/finish for debugging.
 */
class ScreenshotTestRunListener : org.junit.runner.notification.RunListener() {

    override fun testRunStarted(description: org.junit.runner.Description?) {
        Log.d("ScreenshotTestRunListener", "Visual regression test run started")
    }

    override fun testStarted(description: org.junit.runner.Description?) {
        Log.d("ScreenshotTestRunListener", "Test started: ${description?.displayName}")
    }

    override fun testFinished(description: org.junit.runner.Description?) {
        Log.d("ScreenshotTestRunListener", "Test finished: ${description?.displayName}")
    }

    override fun testFailure(failure: org.junit.runner.notification.Failure?) {
        Log.e("ScreenshotTestRunListener", "Test failed: ${failure?.description?.displayName}: ${failure?.message}")
    }

    override fun testRunFinished(result: org.junit.runner.Result?) {
        Log.d("ScreenshotTestRunListener",
            "Visual regression test run finished: ${result?.runCount} tests, ${result?.failureCount} failures")
    }
}

// ------------------------------------------------------------------
// CSS for the HTML report
// ------------------------------------------------------------------

private const val CSS_STYLES = """
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
           background: #f5f6fa; color: #2d3436; line-height: 1.6; }
    .container { max-width: 1200px; margin: 0 auto; padding: 24px; }
    h1 { margin-bottom: 8px; color: #0078d4; }
    .timestamp { color: #636e72; margin-bottom: 24px; }
    .summary { display: flex; gap: 16px; margin-bottom: 24px; flex-wrap: wrap; }
    .summary-card { flex: 1; min-width: 120px; background: white; border-radius: 8px;
                    padding: 16px; text-align: center; box-shadow: 0 2px 4px rgba(0,0,0,.1); }
    .summary-card .count { font-size: 2em; font-weight: 700; }
    .summary-card .label { font-size: 0.9em; color: #636e72; }
    .summary-card.passed .count { color: #00b894; }
    .summary-card.failed .count { color: #d63031; }
    .summary-card.new .count { color: #0984e3; }
    .summary-card.error .count { color: #fdcb6e; }
    .pass-rate { font-size: 1.2em; font-weight: 600; margin-bottom: 24px;
                 padding: 12px; background: white; border-radius: 8px;
                 box-shadow: 0 2px 4px rgba(0,0,0,.1); }
    table { width: 100%; border-collapse: collapse; background: white;
            border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,.1); }
    th { background: #0078d4; color: white; padding: 12px 16px; text-align: left; }
    td { padding: 10px 16px; border-bottom: 1px solid #eee; }
    tr:hover { background: #f8f9fa; }
    .badge { padding: 4px 10px; border-radius: 12px; font-size: 0.8em; font-weight: 600; }
    .status-passed .badge { background: #d4edda; color: #155724; }
    .status-failed .badge { background: #f8d7da; color: #721c24; }
    .status-new .badge { background: #cce5ff; color: #004085; }
    .status-error .badge { background: #fff3cd; color: #856404; }
"""
