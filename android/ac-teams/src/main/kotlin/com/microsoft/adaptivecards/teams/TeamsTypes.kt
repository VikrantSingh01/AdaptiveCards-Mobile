package com.microsoft.adaptivecards.teams

interface AuthTokenProvider {
    suspend fun getToken(): String
}

enum class TeamsTheme {
    LIGHT, DARK, HIGH_CONTRAST
}

data class DeepLinkInfo(
    val scheme: String,
    val host: String,
    val path: String,
    val parameters: Map<String, String>
)
