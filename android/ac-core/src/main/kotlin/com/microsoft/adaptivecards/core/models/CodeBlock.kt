package com.microsoft.adaptivecards.core.models

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.Transient
import kotlinx.serialization.json.JsonElement

@Serializable
@SerialName("CodeBlock")
data class CodeBlock(
    @Transient override val type: String = "CodeBlock",
    override val id: String? = null,
    override val isVisible: Boolean = true,
    override val separator: Boolean = false,
    override val spacing: Spacing? = null,
    override val height: BlockElementHeight? = null,
    override val requires: Map<String, String>? = null,
    override val fallback: JsonElement? = null,
    val code: String,
    val language: String? = null,
    val startLineNumber: Int? = null,
    val wrap: Boolean? = null
) : CardElement
