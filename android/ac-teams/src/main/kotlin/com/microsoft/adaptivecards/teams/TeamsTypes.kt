// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

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
