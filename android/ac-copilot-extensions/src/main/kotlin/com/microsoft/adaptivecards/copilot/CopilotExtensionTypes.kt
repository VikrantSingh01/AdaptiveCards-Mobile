package com.microsoft.adaptivecards.copilot

import kotlinx.serialization.Serializable

@Serializable
data class Citation(
    val id: String,
    val title: String,
    val url: String? = null,
    val snippet: String? = null,
    val index: Int,
    /** File type for icon display (e.g., "pdf", "docx", "xlsx") */
    val fileType: String? = null,
    /** Source application name */
    val sourceName: String? = null
)

@Serializable
data class Reference(
    val id: String,
    val title: String,
    val url: String? = null,
    val snippet: String? = null,
    val iconUrl: String? = null,
    val type: ReferenceType,
    /** Preview image URL */
    val thumbnailUrl: String? = null,
    /** Sensitivity label (e.g., "Confidential") */
    val sensitivityLabel: String? = null
) {
    @Serializable
    enum class ReferenceType {
        FILE, URL, DOCUMENT, EMAIL, MEETING, PERSON, MESSAGE
    }
}

sealed class StreamingState {
    data object Idle : StreamingState()
    data object Streaming : StreamingState()
    data object Complete : StreamingState()
    data class Error(val message: String) : StreamingState()
}

/** Represents a Copilot response with streaming, CoT, citations, and references */
data class CopilotResponse(
    val streamingState: StreamingState = StreamingState.Idle,
    val streamingContent: StreamingContent? = null,
    val chainOfThought: ChainOfThoughtData? = null,
    val citations: List<Citation> = emptyList(),
    val references: List<Reference> = emptyList()
)
