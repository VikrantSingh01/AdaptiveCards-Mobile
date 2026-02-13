package com.microsoft.adaptivecards.test.utils

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Environment
import android.util.Log
import java.io.File
import java.io.FileOutputStream

/**
 * Manages the storage, retrieval, and lifecycle of baseline and actual screenshots.
 *
 * Directory layout (on device external storage):
 * ```
 *   /sdcard/Android/data/<pkg>/files/screenshots/
 *     baselines/
 *       <testName>_<configKey>.png
 *     actuals/
 *       <testName>_<configKey>.png
 *     diffs/
 *       <testName>_<configKey>_diff.png
 *     reports/
 *       report.json
 * ```
 *
 * When running in asset-baseline mode, baselines are loaded from the
 * `androidTest/snapshots/` assets directory instead.
 */
class ScreenshotStorage(private val context: Context) {

    companion object {
        private const val TAG = "ScreenshotStorage"
        private const val BASELINES_DIR = "baselines"
        private const val ACTUALS_DIR = "actuals"
        private const val DIFFS_DIR = "diffs"
        private const val REPORTS_DIR = "reports"
        private const val ROOT_DIR = "screenshots"
        private const val ASSET_BASELINES_PATH = "snapshots"
    }

    private val rootDir: File by lazy {
        val dir = File(context.getExternalFilesDir(null), ROOT_DIR)
        dir.mkdirs()
        dir
    }

    val baselinesDir: File by lazy { ensureDir(BASELINES_DIR) }
    val actualsDir: File by lazy { ensureDir(ACTUALS_DIR) }
    val diffsDir: File by lazy { ensureDir(DIFFS_DIR) }
    val reportsDir: File by lazy { ensureDir(REPORTS_DIR) }

    // ------------------------------------------------------------------
    // Save operations
    // ------------------------------------------------------------------

    /** Save a screenshot as an actual (current run) result. */
    fun saveActual(bitmap: Bitmap, testName: String, configKey: String): File {
        val file = File(actualsDir, fileName(testName, configKey))
        saveBitmap(bitmap, file)
        Log.d(TAG, "Saved actual: ${file.absolutePath}")
        return file
    }

    /** Save a diff image. */
    fun saveDiff(bitmap: Bitmap, testName: String, configKey: String): File {
        val file = File(diffsDir, "${testName}_${configKey}_diff.png")
        saveBitmap(bitmap, file)
        Log.d(TAG, "Saved diff: ${file.absolutePath}")
        return file
    }

    /**
     * Promote the current actual screenshot to be the new baseline.
     * Used when the `--update-baselines` flag is set.
     */
    fun promoteActualToBaseline(testName: String, configKey: String): Boolean {
        val actual = File(actualsDir, fileName(testName, configKey))
        if (!actual.exists()) return false
        val baseline = File(baselinesDir, fileName(testName, configKey))
        return actual.copyTo(baseline, overwrite = true).exists()
    }

    // ------------------------------------------------------------------
    // Load operations
    // ------------------------------------------------------------------

    /**
     * Load the baseline for a given test/config combination.
     *
     * Checks the device filesystem first, then falls back to the bundled
     * `androidTest/snapshots` assets.
     */
    fun loadBaseline(testName: String, configKey: String): Bitmap? {
        // 1. On-device baselines (updated via promoteActualToBaseline)
        val file = File(baselinesDir, fileName(testName, configKey))
        if (file.exists()) {
            return BitmapFactory.decodeFile(file.absolutePath)
        }

        // 2. Asset baselines (bundled in the APK)
        return loadBaselineFromAssets(testName, configKey)
    }

    /** Load a previously-saved actual screenshot. */
    fun loadActual(testName: String, configKey: String): Bitmap? {
        val file = File(actualsDir, fileName(testName, configKey))
        if (!file.exists()) return null
        return BitmapFactory.decodeFile(file.absolutePath)
    }

    /** Check whether a baseline exists for a given test/config. */
    fun hasBaseline(testName: String, configKey: String): Boolean {
        val file = File(baselinesDir, fileName(testName, configKey))
        if (file.exists()) return true
        return try {
            val assetPath = "$ASSET_BASELINES_PATH/${fileName(testName, configKey)}"
            context.assets.open(assetPath).use { true }
        } catch (_: Exception) {
            false
        }
    }

    // ------------------------------------------------------------------
    // Cleanup
    // ------------------------------------------------------------------

    /** Delete all actuals and diffs from the current run. */
    fun cleanCurrentRun() {
        actualsDir.listFiles()?.forEach { it.delete() }
        diffsDir.listFiles()?.forEach { it.delete() }
        Log.d(TAG, "Cleaned current run artefacts")
    }

    /** Delete everything, including baselines. Use with care. */
    fun cleanAll() {
        rootDir.deleteRecursively()
        rootDir.mkdirs()
        Log.d(TAG, "Cleaned all screenshot data")
    }

    // ------------------------------------------------------------------
    // Device info
    // ------------------------------------------------------------------

    /** Build a descriptive device key for the current device. */
    fun deviceKey(): String {
        return "${Build.MANUFACTURER}_${Build.MODEL}_API${Build.VERSION.SDK_INT}"
            .replace("\\s+".toRegex(), "_")
            .lowercase()
    }

    // ------------------------------------------------------------------
    // Internal helpers
    // ------------------------------------------------------------------

    private fun fileName(testName: String, configKey: String): String {
        return "${testName}_${configKey}.png"
    }

    private fun ensureDir(name: String): File {
        val dir = File(rootDir, name)
        dir.mkdirs()
        return dir
    }

    private fun saveBitmap(bitmap: Bitmap, file: File) {
        FileOutputStream(file).use { out ->
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
        }
    }

    private fun loadBaselineFromAssets(testName: String, configKey: String): Bitmap? {
        return try {
            val assetPath = "$ASSET_BASELINES_PATH/${fileName(testName, configKey)}"
            context.assets.open(assetPath).use { inputStream ->
                BitmapFactory.decodeStream(inputStream)
            }
        } catch (e: Exception) {
            Log.d(TAG, "No asset baseline found for $testName/$configKey")
            null
        }
    }
}
