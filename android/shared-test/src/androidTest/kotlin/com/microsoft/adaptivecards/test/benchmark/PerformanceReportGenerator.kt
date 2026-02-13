package com.microsoft.adaptivecards.test.benchmark

import android.content.Context
import android.os.Build
import android.util.Log
import androidx.test.core.app.ApplicationProvider
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Generates structured performance reports from benchmark data.
 *
 * This supplements the raw AndroidX Benchmark output with a
 * human-friendly summary report including baseline comparisons.
 *
 * Reports are written to:
 *   /sdcard/Android/data/<pkg>/files/performance-reports/
 */
object PerformanceReportGenerator {

    private const val TAG = "PerformanceReport"
    private val json = Json { prettyPrint = true; encodeDefaults = true }

    private val entries = mutableListOf<PerformanceMeasurement>()

    /** Record a performance measurement. */
    fun record(measurement: PerformanceMeasurement) {
        entries.add(measurement)
        Log.d(TAG, "Recorded: ${measurement.testName} = ${measurement.medianNs / 1_000_000.0} ms")
    }

    /** Record a measurement from raw timing data. */
    fun record(
        testName: String,
        category: String,
        warmupIterations: Int = 0,
        measuredIterations: Int = 0,
        medianNs: Long,
        minNs: Long,
        maxNs: Long,
        p90Ns: Long = medianNs,
        p99Ns: Long = maxNs,
        allocatedBytes: Long = 0
    ) {
        record(
            PerformanceMeasurement(
                testName = testName,
                category = category,
                warmupIterations = warmupIterations,
                measuredIterations = measuredIterations,
                medianNs = medianNs,
                minNs = minNs,
                maxNs = maxNs,
                p90Ns = p90Ns,
                p99Ns = p99Ns,
                allocatedBytes = allocatedBytes
            )
        )
    }

    /** Generate the JSON performance report. */
    fun generateReport(): File {
        val context: Context = ApplicationProvider.getApplicationContext()
        val reportsDir = File(context.getExternalFilesDir(null), "performance-reports").apply { mkdirs() }

        val report = PerformanceReport(
            timestamp = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).format(Date()),
            device = DeviceInfo(
                manufacturer = Build.MANUFACTURER,
                model = Build.MODEL,
                sdkVersion = Build.VERSION.SDK_INT,
                abi = Build.SUPPORTED_ABIS.firstOrNull() ?: "unknown"
            ),
            summary = buildSummary(),
            baselines = PERFORMANCE_BASELINES,
            measurements = entries.sortedBy { it.testName }
        )

        val reportFile = File(reportsDir, "performance_report.json")
        reportFile.writeText(json.encodeToString(report))
        Log.d(TAG, "Performance report: ${reportFile.absolutePath}")

        // Also generate a readable summary
        val summaryFile = File(reportsDir, "performance_summary.txt")
        summaryFile.writeText(buildTextSummary(report))
        Log.d(TAG, "Performance summary: ${summaryFile.absolutePath}")

        return reportFile
    }

    private fun buildSummary(): PerformanceSummary {
        val parsingTests = entries.filter { it.category == "parsing" }
        val renderingTests = entries.filter { it.category == "rendering" }
        val memoryTests = entries.filter { it.category == "memory" }

        return PerformanceSummary(
            totalMeasurements = entries.size,
            parsingCount = parsingTests.size,
            renderingCount = renderingTests.size,
            memoryCount = memoryTests.size,
            averageParsingMs = if (parsingTests.isNotEmpty()) {
                parsingTests.map { it.medianNs }.average() / 1_000_000.0
            } else 0.0,
            averageRenderingMs = if (renderingTests.isNotEmpty()) {
                renderingTests.map { it.medianNs }.average() / 1_000_000.0
            } else 0.0,
            regressions = detectRegressions()
        )
    }

    private fun detectRegressions(): List<RegressionInfo> {
        val regressions = mutableListOf<RegressionInfo>()
        for (measurement in entries) {
            val baseline = PERFORMANCE_BASELINES[measurement.testName] ?: continue
            val medianMs = measurement.medianNs / 1_000_000.0
            if (medianMs > baseline.maxAcceptableMs) {
                regressions.add(
                    RegressionInfo(
                        testName = measurement.testName,
                        baselineMs = baseline.expectedMs,
                        actualMs = medianMs,
                        thresholdMs = baseline.maxAcceptableMs,
                        percentageOver = ((medianMs - baseline.maxAcceptableMs) / baseline.maxAcceptableMs) * 100
                    )
                )
            }
        }
        return regressions
    }

    private fun buildTextSummary(report: PerformanceReport): String = buildString {
        appendLine("=== Adaptive Cards Performance Report ===")
        appendLine("Generated: ${report.timestamp}")
        appendLine("Device: ${report.device.manufacturer} ${report.device.model} (API ${report.device.sdkVersion})")
        appendLine()

        appendLine("--- Summary ---")
        appendLine("Total measurements: ${report.summary.totalMeasurements}")
        appendLine("Parsing: ${report.summary.parsingCount} tests, avg ${"%.2f".format(report.summary.averageParsingMs)} ms")
        appendLine("Rendering: ${report.summary.renderingCount} tests, avg ${"%.2f".format(report.summary.averageRenderingMs)} ms")
        appendLine("Memory: ${report.summary.memoryCount} tests")
        appendLine()

        if (report.summary.regressions.isNotEmpty()) {
            appendLine("!!! REGRESSIONS DETECTED !!!")
            for (reg in report.summary.regressions) {
                appendLine("  ${reg.testName}: ${"%.2f".format(reg.actualMs)} ms " +
                    "(threshold: ${"%.2f".format(reg.thresholdMs)} ms, " +
                    "${"%.1f".format(reg.percentageOver)}% over)")
            }
            appendLine()
        }

        appendLine("--- Measurements ---")
        appendLine(String.format("%-40s %10s %10s %10s %10s", "Test", "Median(ms)", "Min(ms)", "Max(ms)", "Status"))
        appendLine("-".repeat(90))
        for (m in report.measurements) {
            val medianMs = m.medianNs / 1_000_000.0
            val minMs = m.minNs / 1_000_000.0
            val maxMs = m.maxNs / 1_000_000.0
            val baseline = PERFORMANCE_BASELINES[m.testName]
            val status = when {
                baseline == null -> "NO BASELINE"
                medianMs > baseline.maxAcceptableMs -> "REGRESSION"
                medianMs > baseline.expectedMs -> "WARN"
                else -> "OK"
            }
            appendLine(String.format("%-40s %10.2f %10.2f %10.2f %10s",
                m.testName, medianMs, minMs, maxMs, status))
        }
    }
}

// ------------------------------------------------------------------
// Data models
// ------------------------------------------------------------------

@Serializable
data class PerformanceMeasurement(
    val testName: String,
    val category: String,
    val warmupIterations: Int = 0,
    val measuredIterations: Int = 0,
    val medianNs: Long,
    val minNs: Long,
    val maxNs: Long,
    val p90Ns: Long = medianNs,
    val p99Ns: Long = maxNs,
    val allocatedBytes: Long = 0
)

@Serializable
data class DeviceInfo(
    val manufacturer: String,
    val model: String,
    val sdkVersion: Int,
    val abi: String
)

@Serializable
data class PerformanceSummary(
    val totalMeasurements: Int,
    val parsingCount: Int,
    val renderingCount: Int,
    val memoryCount: Int,
    val averageParsingMs: Double,
    val averageRenderingMs: Double,
    val regressions: List<RegressionInfo>
)

@Serializable
data class RegressionInfo(
    val testName: String,
    val baselineMs: Double,
    val actualMs: Double,
    val thresholdMs: Double,
    val percentageOver: Double
)

@Serializable
data class PerformanceBaseline(
    val expectedMs: Double,
    val maxAcceptableMs: Double
)

@Serializable
data class PerformanceReport(
    val timestamp: String,
    val device: DeviceInfo,
    val summary: PerformanceSummary,
    val baselines: Map<String, PerformanceBaseline>,
    val measurements: List<PerformanceMeasurement>
)

// ------------------------------------------------------------------
// Performance baselines (thresholds)
// ------------------------------------------------------------------

/**
 * Baseline performance expectations.
 *
 * These values are initial estimates. After the first benchmark run,
 * update them with actual measured values. The maxAcceptableMs should
 * be set to ~2x the expected value to allow for device variation while
 * still catching significant regressions.
 */
val PERFORMANCE_BASELINES = mapOf(
    // Parsing baselines (ms)
    "parseSimpleText" to PerformanceBaseline(expectedMs = 1.0, maxAcceptableMs = 5.0),
    "parseContainers" to PerformanceBaseline(expectedMs = 3.0, maxAcceptableMs = 10.0),
    "parseAllActions" to PerformanceBaseline(expectedMs = 3.0, maxAcceptableMs = 10.0),
    "parseAllInputs" to PerformanceBaseline(expectedMs = 5.0, maxAcceptableMs = 15.0),
    "parseTable" to PerformanceBaseline(expectedMs = 3.0, maxAcceptableMs = 10.0),
    "parseAdvancedCombined" to PerformanceBaseline(expectedMs = 10.0, maxAcceptableMs = 30.0),
    "parseCharts" to PerformanceBaseline(expectedMs = 5.0, maxAcceptableMs = 15.0),
    "parseDeeplyNested" to PerformanceBaseline(expectedMs = 5.0, maxAcceptableMs = 20.0),
    "parseLongText" to PerformanceBaseline(expectedMs = 2.0, maxAcceptableMs = 10.0),
    "roundTripSimpleText" to PerformanceBaseline(expectedMs = 2.0, maxAcceptableMs = 10.0),
    "roundTripAdvancedCombined" to PerformanceBaseline(expectedMs = 15.0, maxAcceptableMs = 50.0),

    // Rendering baselines (ms)
    "renderSimpleText" to PerformanceBaseline(expectedMs = 50.0, maxAcceptableMs = 150.0),
    "renderContainers" to PerformanceBaseline(expectedMs = 80.0, maxAcceptableMs = 250.0),
    "renderAllActions" to PerformanceBaseline(expectedMs = 80.0, maxAcceptableMs = 250.0),
    "renderAllInputs" to PerformanceBaseline(expectedMs = 100.0, maxAcceptableMs = 300.0),
    "renderTable" to PerformanceBaseline(expectedMs = 80.0, maxAcceptableMs = 250.0),
    "renderAdvancedCombined" to PerformanceBaseline(expectedMs = 150.0, maxAcceptableMs = 500.0),
    "renderCarousel" to PerformanceBaseline(expectedMs = 100.0, maxAcceptableMs = 300.0),
    "renderDeeplyNested" to PerformanceBaseline(expectedMs = 100.0, maxAcceptableMs = 350.0)
)
