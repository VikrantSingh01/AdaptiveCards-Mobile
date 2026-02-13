package com.microsoft.adaptivecards.rendering.snapshots

import java.io.File

/**
 * Shared utility for loading test card JSON files from the shared/test-cards/ directory.
 * Used by both CardElementSnapshotTests and TeamsCardSnapshotTests.
 */
object TestCardLoader {
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
