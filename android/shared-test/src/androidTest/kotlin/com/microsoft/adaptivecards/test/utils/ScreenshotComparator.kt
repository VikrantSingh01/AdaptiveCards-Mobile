package com.microsoft.adaptivecards.test.utils

import android.graphics.Bitmap
import android.graphics.Color
import kotlin.math.abs
import kotlin.math.sqrt

/**
 * Result of a screenshot comparison.
 *
 * @property matches True if the screenshots match within the configured tolerance.
 * @property diffPercentage Percentage of pixels that differ (0.0 to 100.0).
 * @property maxPixelDelta The maximum per-channel pixel difference encountered.
 * @property diffBitmap Optional diff image highlighting mismatched pixels.
 * @property mismatchedPixelCount Number of pixels that exceeded the per-pixel threshold.
 * @property totalPixels Total number of pixels compared.
 */
data class ComparisonResult(
    val matches: Boolean,
    val diffPercentage: Double,
    val maxPixelDelta: Int,
    val diffBitmap: Bitmap?,
    val mismatchedPixelCount: Int,
    val totalPixels: Int
) {
    /** Human-readable summary suitable for test reports. */
    fun summary(): String = buildString {
        appendLine("Comparison Result:")
        appendLine("  Match: $matches")
        appendLine("  Diff Percentage: ${"%.4f".format(diffPercentage)}%")
        appendLine("  Max Pixel Delta: $maxPixelDelta")
        appendLine("  Mismatched Pixels: $mismatchedPixelCount / $totalPixels")
    }
}

/**
 * Configuration for screenshot comparison tolerance.
 *
 * @property maxDiffPercentage Maximum allowable percentage of differing pixels (0.0-100.0).
 * @property perPixelThreshold Per-channel difference threshold (0-255) before a pixel counts as different.
 * @property generateDiffImage Whether to generate a visual diff bitmap.
 * @property diffHighlightColor Color used to highlight diff pixels when generating a diff image.
 * @property antiAliasingTolerance Additional tolerance for anti-aliasing artefacts at edges.
 */
data class ComparisonConfig(
    val maxDiffPercentage: Double = 0.1,
    val perPixelThreshold: Int = 10,
    val generateDiffImage: Boolean = true,
    val diffHighlightColor: Int = Color.RED,
    val antiAliasingTolerance: Int = 2
)

/**
 * Utility for comparing two bitmaps pixel-by-pixel.
 *
 * The comparator supports configurable per-pixel and aggregate thresholds,
 * optional anti-aliasing tolerance, and diff-image generation.
 */
object ScreenshotComparator {

    /**
     * Compare two bitmaps and return a detailed [ComparisonResult].
     *
     * If the bitmaps differ in dimensions they are always treated as non-matching
     * and the diff image (if requested) will be the [actual] bitmap tinted with the
     * highlight colour.
     */
    fun compare(
        baseline: Bitmap,
        actual: Bitmap,
        config: ComparisonConfig = ComparisonConfig()
    ): ComparisonResult {
        // Dimension mismatch is always a failure.
        if (baseline.width != actual.width || baseline.height != actual.height) {
            return ComparisonResult(
                matches = false,
                diffPercentage = 100.0,
                maxPixelDelta = 255,
                diffBitmap = if (config.generateDiffImage) createSizeMismatchDiff(actual, config) else null,
                mismatchedPixelCount = maxOf(baseline.width * baseline.height, actual.width * actual.height),
                totalPixels = maxOf(baseline.width * baseline.height, actual.width * actual.height)
            )
        }

        val width = baseline.width
        val height = baseline.height
        val totalPixels = width * height

        val baselinePixels = IntArray(totalPixels)
        val actualPixels = IntArray(totalPixels)
        baseline.getPixels(baselinePixels, 0, width, 0, 0, width, height)
        actual.getPixels(actualPixels, 0, width, 0, 0, width, height)

        val diffPixels = if (config.generateDiffImage) IntArray(totalPixels) else null

        var mismatchedCount = 0
        var maxDelta = 0

        for (i in 0 until totalPixels) {
            val bp = baselinePixels[i]
            val ap = actualPixels[i]

            val dr = abs(Color.red(bp) - Color.red(ap))
            val dg = abs(Color.green(bp) - Color.green(ap))
            val db = abs(Color.blue(bp) - Color.blue(ap))
            val da = abs(Color.alpha(bp) - Color.alpha(ap))

            val channelMax = maxOf(dr, dg, db, da)
            maxDelta = maxOf(maxDelta, channelMax)

            val isAntiAliased = config.antiAliasingTolerance > 0 &&
                isAntiAliasingPixel(baselinePixels, actualPixels, i, width, height, config.antiAliasingTolerance)

            val exceedsThreshold = channelMax > config.perPixelThreshold && !isAntiAliased

            if (exceedsThreshold) {
                mismatchedCount++
                diffPixels?.set(i, config.diffHighlightColor)
            } else {
                // Dim matched pixels in the diff image for contrast.
                diffPixels?.set(i, dimPixel(ap))
            }
        }

        val diffPercentage = (mismatchedCount.toDouble() / totalPixels) * 100.0
        val matches = diffPercentage <= config.maxDiffPercentage

        val diffBitmap = diffPixels?.let { pixels ->
            Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888).also {
                it.setPixels(pixels, 0, width, 0, 0, width, height)
            }
        }

        return ComparisonResult(
            matches = matches,
            diffPercentage = diffPercentage,
            maxPixelDelta = maxDelta,
            diffBitmap = diffBitmap,
            mismatchedPixelCount = mismatchedCount,
            totalPixels = totalPixels
        )
    }

    /**
     * Quick equality check without generating a diff bitmap.
     * More memory-efficient when you only need a pass/fail.
     */
    fun quickCompare(baseline: Bitmap, actual: Bitmap, config: ComparisonConfig = ComparisonConfig()): Boolean {
        return compare(baseline, actual, config.copy(generateDiffImage = false)).matches
    }

    // ---- private helpers ----

    /**
     * Heuristic to detect whether a pixel difference is caused by anti-aliasing.
     * Checks whether neighbouring pixels in the baseline show a similar gradient.
     */
    private fun isAntiAliasingPixel(
        baselinePixels: IntArray,
        actualPixels: IntArray,
        index: Int,
        width: Int,
        height: Int,
        tolerance: Int
    ): Boolean {
        val x = index % width
        val y = index / width

        // Check the 8-connected neighbours.
        var hasHighContrastNeighbour = false
        var hasLowContrastNeighbour = false

        for (dy in -1..1) {
            for (dx in -1..1) {
                if (dx == 0 && dy == 0) continue
                val nx = x + dx
                val ny = y + dy
                if (nx < 0 || nx >= width || ny < 0 || ny >= height) continue

                val ni = ny * width + nx
                val bpNeighbour = baselinePixels[ni]
                val bpCenter = baselinePixels[index]

                val neighbourDelta = pixelDistance(bpCenter, bpNeighbour)
                if (neighbourDelta > 40) hasHighContrastNeighbour = true
                if (neighbourDelta <= tolerance) hasLowContrastNeighbour = true
            }
        }

        // Anti-aliasing typically occurs at edges where a high-contrast neighbour exists
        // alongside low-contrast neighbours.
        return hasHighContrastNeighbour && hasLowContrastNeighbour
    }

    /** Euclidean distance between two ARGB pixels across all four channels. */
    private fun pixelDistance(a: Int, b: Int): Double {
        val dr = Color.red(a) - Color.red(b)
        val dg = Color.green(a) - Color.green(b)
        val db = Color.blue(a) - Color.blue(b)
        val da = Color.alpha(a) - Color.alpha(b)
        return sqrt((dr * dr + dg * dg + db * db + da * da).toDouble())
    }

    /** Dim a pixel to 30% brightness for the diff overlay. */
    private fun dimPixel(pixel: Int): Int {
        return Color.argb(
            Color.alpha(pixel),
            (Color.red(pixel) * 0.3).toInt(),
            (Color.green(pixel) * 0.3).toInt(),
            (Color.blue(pixel) * 0.3).toInt()
        )
    }

    /** When sizes mismatch, return the actual bitmap entirely highlighted. */
    private fun createSizeMismatchDiff(actual: Bitmap, config: ComparisonConfig): Bitmap {
        val width = actual.width
        val height = actual.height
        val pixels = IntArray(width * height)
        for (i in pixels.indices) {
            pixels[i] = config.diffHighlightColor
        }
        return Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888).also {
            it.setPixels(pixels, 0, width, 0, 0, width, height)
        }
    }
}
