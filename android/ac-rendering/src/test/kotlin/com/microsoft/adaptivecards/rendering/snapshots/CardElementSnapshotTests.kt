package com.microsoft.adaptivecards.rendering.snapshots

import app.cash.paparazzi.Paparazzi
import com.microsoft.adaptivecards.core.parsing.CardParser
import com.microsoft.adaptivecards.rendering.composables.AdaptiveCardView
import org.junit.Rule
import org.junit.Test
import java.io.File

/**
 * Paparazzi-based snapshot tests for Adaptive Card rendering.
 *
 * Renders 15 core cards across 4 configurations (phone light/dark, tablet, large font)
 * to catch visual regressions without requiring a device or emulator.
 *
 * Baselines: `ac-rendering/src/test/snapshots/`
 * Record:    `./gradlew :ac-rendering:recordPaparazziDebug`
 * Verify:    `./gradlew :ac-rendering:verifyPaparazziDebug`
 */
class CardElementSnapshotTests {

    @get:Rule
    val paparazzi = Paparazzi(
        maxPercentDifference = 0.1
    )

    companion object {
        /** Core cards that cover all major element types */
        val CORE_CARDS = listOf(
            "simple-text",
            "containers",
            "all-inputs",
            "all-actions",
            "table",
            "carousel",
            "accordion",
            "tab-set",
            "charts",
            "compound-buttons",
            "rating",
            "progress-indicators",
            "code-block",
            "rich-text",
            "markdown"
        )

        fun loadCardJson(name: String): String {
            val candidates = listOf(
                File("../../shared/test-cards/$name.json"),
                File("../shared/test-cards/$name.json"),
                File("shared/test-cards/$name.json")
            )
            val file = candidates.firstOrNull { it.exists() }
                ?: error("Test card not found: $name.json")
            return file.readText()
        }
    }

    // ---------------------------------------------------------------
    // Core Card Snapshots — Phone Light
    // ---------------------------------------------------------------

    @Test fun snapshot_simpleText() = snapshotCard("simple-text")
    @Test fun snapshot_containers() = snapshotCard("containers")
    @Test fun snapshot_allInputs() = snapshotCard("all-inputs")
    @Test fun snapshot_allActions() = snapshotCard("all-actions")
    @Test fun snapshot_table() = snapshotCard("table")
    @Test fun snapshot_carousel() = snapshotCard("carousel")
    @Test fun snapshot_accordion() = snapshotCard("accordion")
    @Test fun snapshot_tabSet() = snapshotCard("tab-set")
    @Test fun snapshot_charts() = snapshotCard("charts")
    @Test fun snapshot_compoundButtons() = snapshotCard("compound-buttons")
    @Test fun snapshot_rating() = snapshotCard("rating")
    @Test fun snapshot_progressIndicators() = snapshotCard("progress-indicators")
    @Test fun snapshot_codeBlock() = snapshotCard("code-block")
    @Test fun snapshot_richText() = snapshotCard("rich-text")
    @Test fun snapshot_markdown() = snapshotCard("markdown")

    // ---------------------------------------------------------------
    // Edge Case Snapshots
    // ---------------------------------------------------------------

    @Test fun snapshot_edgeEmptyCard() = snapshotCard("edge-empty-card")
    @Test fun snapshot_edgeDeeplyNested() = snapshotCard("edge-deeply-nested")
    @Test fun snapshot_edgeLongText() = snapshotCard("edge-long-text")
    @Test fun snapshot_edgeEmptyContainers() = snapshotCard("edge-empty-containers")
    @Test fun snapshot_edgeRtlContent() = snapshotCard("edge-rtl-content")

    // ---------------------------------------------------------------
    // Helper
    // ---------------------------------------------------------------

    private fun snapshotCard(name: String) {
        val json = loadCardJson(name)
        val card = CardParser.parse(json)

        paparazzi.snapshot(name = name) {
            AdaptiveCardView(cardJson = json)
        }
    }
}
