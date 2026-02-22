package com.microsoft.adaptivecards.copilot

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.boolean
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.double
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

/**
 * Data models for Chain of Thought (CoT) UX.
 *
 * Ported from production Teams-AdaptiveCards-Mobile SDK.
 * CoT shows the reasoning steps Copilot goes through while processing a request.
 */
@Serializable
data class ChainOfThoughtData(
    /** The individual reasoning steps */
    val entries: List<ChainOfThoughtEntry>,
    /** Display state (e.g., "Thought for 1 min", "Thinking...") */
    val state: String,
    /** Whether the chain of thought is complete */
    val isDone: Boolean
) {
    companion object {
        private val json = Json { ignoreUnknownKeys = true; isLenient = true }

        /** Attempt to parse Chain of Thought JSON from text content */
        fun from(textContent: String): ChainOfThoughtData? {
            val cleaned = textContent.trim()
                .replace("&quot;", "\"")
                .replace("&amp;", "&")
                .replace("&lt;", "<")
                .replace("&gt;", ">")

            if (!cleaned.startsWith("{") || !cleaned.endsWith("}")) return null

            return try {
                json.decodeFromString<ChainOfThoughtData>(cleaned)
            } catch (_: Exception) {
                // Try fixing smart quotes
                val fixed = cleaned
                    .replace("\u201C", "\"")
                    .replace("\u201D", "\"")
                    .replace("\u2018", "'")
                    .replace("\u2019", "'")
                try {
                    json.decodeFromString<ChainOfThoughtData>(fixed)
                } catch (_: Exception) {
                    null
                }
            }
        }
    }
}

@Serializable
data class ChainOfThoughtEntry(
    /** The step header/title */
    val header: String,
    /** The detailed reasoning content */
    val content: String,
    /** Optional app info for tool use steps */
    val appInfo: AppInfo? = null
)

@Serializable
data class AppInfo(
    /** App/tool name */
    val name: String,
    /** URL for the app icon */
    val icon: String
)
