package com.microsoft.adaptivecards.copilot

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.boolean
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.double
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

/**
 * Streaming content phases and models.
 *
 * Ported from production Teams-AdaptiveCards-Mobile SDK.
 */
enum class StreamingPhase(val value: String) {
    START("start"),
    INFORMATIVE("informative"),
    STREAMING("streaming"),
    FINAL("final");

    companion object {
        fun from(rawValue: String): StreamingPhase? =
            entries.find { it.value.equals(rawValue, ignoreCase = true) }
    }
}

/**
 * Model for streaming content and state.
 */
@Serializable
data class StreamingContent(
    /** Unique message identifier */
    val messageID: String,
    /** Current phase */
    val phase: String,
    /** The text content being streamed */
    val content: String,
    /** Whether streaming is complete */
    val isComplete: Boolean,
    /** Reason the stream ended */
    val streamEndReason: String? = null,
    /** Characters per second for typing animation */
    val typingSpeed: Double? = null,
    /** Whether to show a stop button */
    val showStopButton: Boolean? = null,
    /** Whether to show a progress indicator */
    val showProgressIndicator: Boolean? = null
) {
    val streamingPhase: StreamingPhase?
        get() = StreamingPhase.from(phase)

    companion object {
        fun from(textContent: String): StreamingContent? =
            StreamingDataParser.parseStreamingData(textContent)
    }
}

/**
 * Helper for parsing streaming data from text content.
 */
object StreamingDataParser {
    private val json = Json { ignoreUnknownKeys = true; isLenient = true }

    fun parseStreamingData(text: String): StreamingContent? {
        if (!text.startsWith("{") || !text.endsWith("}")) return null

        return try {
            val element = json.parseToJsonElement(text)
            val obj = element.jsonObject

            val streamingEnabled = obj["streamingEnabled"]?.jsonPrimitive?.boolean ?: false
            if (!streamingEnabled) return null

            val messageID = obj["messageID"]?.jsonPrimitive?.contentOrNull ?: return null
            val phase = obj["phase"]?.jsonPrimitive?.contentOrNull ?: return null
            val content = obj["content"]?.jsonPrimitive?.contentOrNull ?: return null

            StreamingContent(
                messageID = messageID,
                phase = phase,
                content = content,
                isComplete = obj["isComplete"]?.jsonPrimitive?.boolean ?: false,
                streamEndReason = obj["streamEndReason"]?.jsonPrimitive?.contentOrNull,
                typingSpeed = try { obj["typingSpeed"]?.jsonPrimitive?.double } catch (_: Exception) { null },
                showStopButton = try { obj["showStopButton"]?.jsonPrimitive?.boolean } catch (_: Exception) { null },
                showProgressIndicator = try { obj["showProgressIndicator"]?.jsonPrimitive?.boolean } catch (_: Exception) { null }
            )
        } catch (_: Exception) {
            null
        }
    }

    fun isStreamingContent(text: String): Boolean = parseStreamingData(text) != null
}
