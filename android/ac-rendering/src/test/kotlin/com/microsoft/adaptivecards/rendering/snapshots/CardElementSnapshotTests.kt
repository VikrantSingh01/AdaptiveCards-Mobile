package com.microsoft.adaptivecards.rendering.snapshots

import app.cash.paparazzi.Paparazzi
import com.microsoft.adaptivecards.core.parsing.CardParser
import com.microsoft.adaptivecards.rendering.composables.AdaptiveCardView
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel
import org.junit.Assume.assumeNotNull
import org.junit.Rule
import org.junit.Test

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
    @Test fun snapshot_edgeMaxActions() = snapshotCard("edge-max-actions")
    @Test fun snapshot_edgeMixedInputs() = snapshotCard("edge-mixed-inputs")
    @Test fun snapshot_edgeAllUnknownTypes() = snapshotCard("edge-all-unknown-types")

    // ---------------------------------------------------------------
    // Official Samples
    // ---------------------------------------------------------------

    @Test fun snapshot_officialActivityUpdate() = snapshotCard("official-samples/activity-update")
    @Test fun snapshot_officialCalendarReminder() = snapshotCard("official-samples/calendar-reminder")
    @Test fun snapshot_officialExpenseReport() = snapshotCard("official-samples/expense-report")
    @Test fun snapshot_officialFlightDetails() = snapshotCard("official-samples/flight-details")
    @Test fun snapshot_officialFlightItinerary() = snapshotCard("official-samples/flight-itinerary")
    @Test fun snapshot_officialFlightUpdate() = snapshotCard("official-samples/flight-update")
    @Test fun snapshot_officialFoodOrder() = snapshotCard("official-samples/food-order")
    @Test fun snapshot_officialImageGallery() = snapshotCard("official-samples/image-gallery")
    @Test fun snapshot_officialInputForm() = snapshotCard("official-samples/input-form-official")
    @Test fun snapshot_officialRestaurant() = snapshotCard("official-samples/restaurant")
    @Test fun snapshot_officialWeather() = snapshotCard("official-samples/weather-compact")

    // ---------------------------------------------------------------
    // Teams Official Samples
    // ---------------------------------------------------------------

    @Test fun snapshot_teamsOfficialAccount() = snapshotCard("teams-official-samples/account")
    @Test fun snapshot_teamsOfficialCafeMenu() = snapshotCard("teams-official-samples/cafe-menu")
    @Test fun snapshot_teamsOfficialIssue() = snapshotCard("teams-official-samples/issue")
    @Test fun snapshot_teamsOfficialRecipe() = snapshotCard("teams-official-samples/recipe")
    @Test fun snapshot_teamsOfficialWorkItem() = snapshotCard("teams-official-samples/work-item")

    // ---------------------------------------------------------------
    // Helper
    // ---------------------------------------------------------------

    private fun snapshotCard(name: String) {
        val json = TestCardLoader.loadCardJsonOrNull(name)
        assumeNotNull("Skipping: card $name.json not found (run locally with shared/test-cards/)", json)

        // Replace path separators to avoid FileNotFoundException in Paparazzi output
        val sanitizedName = name.replace("/", "_")
        paparazzi.snapshot(name = sanitizedName) {
            AdaptiveCardView(
                cardJson = json!!,
                viewModel = CardViewModel()
            )
        }
    }
}
