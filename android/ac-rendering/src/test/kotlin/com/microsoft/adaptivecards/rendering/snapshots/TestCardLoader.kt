package com.microsoft.adaptivecards.rendering.snapshots

import java.io.File

/**
 * Shared utility for loading test card JSON files from the shared/test-cards/ directory.
 * Used by CardElementSnapshotTests, TeamsCardSnapshotTests, and AllCardsDiscoveryTests.
 */
object TestCardLoader {

    /** Try multiple relative paths to find the shared/test-cards/ directory */
    private val testCardsDir: File? by lazy {
        listOf(
            "../../shared/test-cards",
            "../shared/test-cards",
            "shared/test-cards",
            "../../../shared/test-cards"
        ).map { File(it) }.firstOrNull { it.isDirectory }
    }

    /**
     * Loads a test card JSON file by name (supports paths like "official-samples/activity-update").
     * Returns null if the file cannot be found.
     */
    fun loadCardJsonOrNull(name: String): String? {
        val dir = testCardsDir ?: return null
        val file = File(dir, "$name.json")
        return if (file.exists()) file.readText() else null
    }

    /**
     * Loads a test card JSON file by name.
     * Throws if the file cannot be found.
     */
    fun loadCardJson(name: String): String {
        return loadCardJsonOrNull(name)
            ?: error("Test card not found: $name.json (searched from: ${testCardsDir?.absolutePath ?: "no dir found"})")
    }

    /**
     * Loads a card JSON by relative path (e.g., "official-samples/activity-update.json").
     */
    fun loadCardByPath(relativePath: String): String? {
        val dir = testCardsDir ?: return null
        val file = File(dir, relativePath)
        return if (file.exists()) file.readText() else null
    }

    /**
     * Recursively discovers all .json card files under shared/test-cards/.
     * Returns list of relative paths.
     */
    fun discoverAllCards(): List<String> {
        val dir = testCardsDir ?: return emptyList()
        return dir.walkTopDown()
            .filter { it.isFile && it.extension == "json" }
            .map { it.relativeTo(dir).path }
            .sorted()
            .toList()
    }

    /**
     * Returns the total count of discoverable card files.
     */
    fun totalCardCount(): Int = discoverAllCards().size
}
