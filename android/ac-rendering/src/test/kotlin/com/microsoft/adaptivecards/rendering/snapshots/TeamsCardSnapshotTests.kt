package com.microsoft.adaptivecards.rendering.snapshots

import app.cash.paparazzi.Paparazzi
import com.microsoft.adaptivecards.core.hostconfig.TeamsHostConfig
import com.microsoft.adaptivecards.hostconfig.HostConfigProvider
import com.microsoft.adaptivecards.rendering.composables.AdaptiveCardView
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel
import org.junit.Assume.assumeNotNull
import org.junit.Rule
import org.junit.Test

/**
 * Snapshot tests for Adaptive Cards rendered with Teams host config.
 *
 * Validates that cards render correctly with Teams-specific styling
 * (colors, fonts, spacing) as they would appear in Microsoft Teams.
 *
 * Record:  `./gradlew :ac-rendering:recordPaparazziDebug`
 * Verify:  `./gradlew :ac-rendering:verifyPaparazziDebug`
 */
class TeamsCardSnapshotTests {

    @get:Rule
    val paparazzi = Paparazzi(
        maxPercentDifference = 0.1
    )

    // MARK: - Core Cards with Teams Theme

    @Test fun teamsSnapshot_simpleText() = snapshotTeamsCard("simple-text")
    @Test fun teamsSnapshot_containers() = snapshotTeamsCard("containers")
    @Test fun teamsSnapshot_allInputs() = snapshotTeamsCard("all-inputs")
    @Test fun teamsSnapshot_allActions() = snapshotTeamsCard("all-actions")
    @Test fun teamsSnapshot_table() = snapshotTeamsCard("table")
    @Test fun teamsSnapshot_carousel() = snapshotTeamsCard("carousel")
    @Test fun teamsSnapshot_accordion() = snapshotTeamsCard("accordion")
    @Test fun teamsSnapshot_tabSet() = snapshotTeamsCard("tab-set")
    @Test fun teamsSnapshot_compoundButtons() = snapshotTeamsCard("compound-buttons")
    @Test fun teamsSnapshot_rating() = snapshotTeamsCard("rating")

    // MARK: - Official Samples (Teams real-world scenarios)

    @Test fun teamsSnapshot_activityUpdate() = snapshotTeamsCard("official-samples/activity-update")
    @Test fun teamsSnapshot_calendarReminder() = snapshotTeamsCard("official-samples/calendar-reminder")
    @Test fun teamsSnapshot_inputFormOfficial() = snapshotTeamsCard("official-samples/input-form-official")

    // MARK: - Helper

    private fun snapshotTeamsCard(name: String) {
        val json = TestCardLoader.loadCardJsonOrNull(name)
        assumeNotNull("Skipping: card $name.json not found", json)

        paparazzi.snapshot(name = "teams_${name.replace("/", "_")}") {
            HostConfigProvider(hostConfig = TeamsHostConfig.create()) {
                AdaptiveCardView(cardJson = json!!, viewModel = CardViewModel())
            }
        }
    }
}
