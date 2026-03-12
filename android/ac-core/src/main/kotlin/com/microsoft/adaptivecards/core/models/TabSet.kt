package com.microsoft.adaptivecards.core.models

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.Transient
import kotlinx.serialization.json.JsonElement

@Serializable
@SerialName("TabSet")
data class TabSet(
    @Transient override val type: String = "TabSet",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val tabs: List<Tab>,
    val selectedTabId: String? = null
) : CardElement

@Serializable
data class Tab(
    val id: String,
    val title: String,
    val icon: String? = null,
    val items: List<CardElement>
)
