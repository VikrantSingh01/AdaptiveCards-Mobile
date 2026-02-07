package com.microsoft.adaptivecards.copilot

import kotlinx.serialization.Serializable

@Serializable
data class Citation(
    val id: String,
    val title: String,
    val url: String? = null,
    val snippet: String? = null,
    val index: Int
)

@Serializable
data class Reference(
    val id: String,
    val title: String,
    val url: String? = null,
    val snippet: String? = null,
    val iconUrl: String? = null,
    val type: ReferenceType
) {
    @Serializable
    enum class ReferenceType {
        FILE, URL, DOCUMENT
    }
}

sealed class StreamingState {
    object Idle : StreamingState()
    object Streaming : StreamingState()
    object Complete : StreamingState()
    data class Error(val error: Throwable) : StreamingState()
}
