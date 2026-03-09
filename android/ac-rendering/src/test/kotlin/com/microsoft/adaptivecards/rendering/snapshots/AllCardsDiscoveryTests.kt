package com.microsoft.adaptivecards.rendering.snapshots

import app.cash.paparazzi.DeviceConfig
import app.cash.paparazzi.Paparazzi
import com.microsoft.adaptivecards.core.hostconfig.TeamsHostConfig
import com.microsoft.adaptivecards.hostconfig.HostConfigProvider
import com.microsoft.adaptivecards.rendering.composables.AdaptiveCardView
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel
import org.junit.Assume.assumeNotNull
import org.junit.Assume.assumeTrue
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.Parameterized
import java.io.File

/**
 * Automatically discovers and renders **every** card JSON in
 * `shared/test-cards/` (including all subdirectories).
 *
 * This is the "render every card" visual regression pipeline.
 *
 * Paparazzi runs entirely on the JVM — no emulator or device needed.
 *
 * Record baselines: `./gradlew :ac-rendering:recordPaparazziDebug`
 * Verify:           `./gradlew :ac-rendering:verifyPaparazziDebug`
 */
@RunWith(Parameterized::class)
class AllCardsDiscoveryTests(
    private val cardName: String,
    private val cardRelativePath: String
) {

    companion object {

        /**
         * Discovers all `.json` files recursively under `shared/test-cards/`.
         * Returns pairs of (displayName, relativePath).
         */
        @JvmStatic
        @Parameterized.Parameters(name = "{0}")
        fun discoverCards(): List<Array<String>> {
            val testCardsDir = findTestCardsDir() ?: return emptyList()

            return testCardsDir.walkTopDown()
                .filter { it.isFile && it.extension == "json" }
                .map { file ->
                    val relative = file.relativeTo(testCardsDir).path
                    val displayName = relative
                        .replace("/", "_")
                        .removeSuffix(".json")
                    arrayOf(displayName, relative)
                }
                .sortedBy { it[0] }
                .toList()
        }

        /** Try multiple relative paths to find shared/test-cards/ */
        private fun findTestCardsDir(): File? {
            val candidates = listOf(
                "../../shared/test-cards",
                "../shared/test-cards",
                "shared/test-cards",
                "../../../shared/test-cards"
            )
            return candidates
                .map { File(it) }
                .firstOrNull { it.isDirectory }
        }
    }

    @get:Rule
    val paparazzi = Paparazzi(
        maxPercentDifference = 0.1
    )

    // ---------------------------------------------------------------
    // Default Host Config — Phone Light
    // ---------------------------------------------------------------

    @Test
    fun snapshot_defaultConfig() {
        val json = loadCardJson()
        assumeNotNull("Card not found: $cardRelativePath", json)

        paparazzi.snapshot(name = cardName) {
            AdaptiveCardView(
                cardJson = json!!,
                viewModel = CardViewModel()
            )
        }
    }

    // ---------------------------------------------------------------
    // Teams Host Config — Phone Light
    // ---------------------------------------------------------------

    @Test
    fun snapshot_teamsConfig() {
        val json = loadCardJson()
        assumeNotNull("Card not found: $cardRelativePath", json)

        paparazzi.snapshot(name = "teams_$cardName") {
            HostConfigProvider(hostConfig = TeamsHostConfig.create()) {
                AdaptiveCardView(
                    cardJson = json!!,
                    viewModel = CardViewModel()
                )
            }
        }
    }

    // ---------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------

    private fun loadCardJson(): String? {
        val dir = findTestCardsDir() ?: return null
        val file = File(dir, cardRelativePath)
        return if (file.exists()) file.readText() else null
    }

    private fun findTestCardsDir(): File? {
        return Companion.findTestCardsDir()
    }
}
