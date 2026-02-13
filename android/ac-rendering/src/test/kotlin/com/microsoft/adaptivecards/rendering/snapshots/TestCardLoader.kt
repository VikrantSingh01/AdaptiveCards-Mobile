package com.microsoft.adaptivecards.rendering.snapshots

import java.io.File

/**
 * Shared utility for loading test card JSON files from the shared/test-cards/ directory.
 * Used by both CardElementSnapshotTests and TeamsCardSnapshotTests.
 */
object TestCardLoader {

    /**
     * Loads a test card JSON file by name.
     * Returns null if the file cannot be found (e.g., on CI where paths differ).
     */
    fun loadCardJsonOrNull(name: String): String? {
        val candidates = listOf(
            File("../../shared/test-cards/$name.json"),
            File("../shared/test-cards/$name.json"),
            File("shared/test-cards/$name.json"),
            File("../../../shared/test-cards/$name.json")
        )
        return candidates.firstOrNull { it.exists() }?.readText()
    }

    /**
     * Loads a test card JSON file by name.
     * Throws if the file cannot be found.
     */
    fun loadCardJson(name: String): String {
        return loadCardJsonOrNull(name)
            ?: error("Test card not found: $name.json")
    }
}
