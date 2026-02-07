package com.microsoft.adaptivecards.core.models

import kotlinx.serialization.Serializable

@Serializable
data class Authentication(
    val text: String? = null,
    val connectionName: String? = null,
    val tokenExchangeResource: TokenExchangeResource? = null,
    val buttons: List<AuthCardButton>? = null
)

@Serializable
data class AuthCardButton(
    val type: String,
    val title: String,
    val image: String? = null,
    val value: String
)

@Serializable
data class TokenExchangeResource(
    val id: String,
    val uri: String,
    val providerId: String
)

@Serializable
data class Refresh(
    val action: CardAction,
    val userIds: List<String>? = null
)
