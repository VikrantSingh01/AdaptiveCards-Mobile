// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.core

import com.microsoft.adaptivecards.core.caching.CardCache
import com.microsoft.adaptivecards.core.hostconfig.HostConfig
import com.microsoft.adaptivecards.core.hostconfig.HostConfigParser

/**
 * Consolidated configuration for rendering an Adaptive Card.
 * Bundles host config, image provider, renderer overrides, and feature flags.
 *
 * ```kotlin
 * // Minimal
 * val config = CardConfiguration.Default
 *
 * // Production (Teams)
 * val config = CardConfiguration.teams(TeamsTheme.Dark).copy(
 *     imageProvider = TeamsImageProvider(authService)
 * )
 * ```
 */
data class CardConfiguration(
    /** Host configuration controlling theming, spacing, and layout */
    val hostConfig: HostConfig = HostConfigParser.default(),

    /** Custom image loader. When null, the SDK uses Coil with built-in caching. */
    val imageProvider: ImageProvider? = null,

    /** Custom element/action renderers that override built-in composables */
    val rendererOverrides: RendererOverrides = RendererOverrides(),

    /** Feature flags for conditional card content */
    val featureFlags: FeatureFlags = FeatureFlags(),

    /** Performance guardrails (element count cap, nesting depth, image throttling) */
    val guardrails: PerformanceGuardrails = PerformanceGuardrails.Default,

    /** Cache instance. Uses CardCache.shared by default. Set to null to disable caching. */
    val cache: CardCache? = CardCache.shared
) {
    companion object {
        /** Default configuration using Teams light host config */
        val Default = CardConfiguration()

        /** Creates a Teams-themed configuration */
        fun teams(theme: TeamsTheme): CardConfiguration {
            val hostConfig = when (theme) {
                TeamsTheme.Light -> HostConfigParser.teams()
                TeamsTheme.Dark -> HostConfigParser.teams() // TODO: teams dark config
            }
            return CardConfiguration(hostConfig = hostConfig)
        }
    }
}

/** Theme options for Teams configuration */
enum class TeamsTheme {
    Light,
    Dark
}

/**
 * Per-card renderer overrides. Replaces the singleton `GlobalElementRendererRegistry` pattern.
 * Overrides set here take precedence over the global registry.
 *
 * Renderer functions are stored type-erased. The rendering layer casts them to
 * the appropriate `@Composable` function type. Register via the rendering module's
 * extension functions for type-safe registration.
 */
class RendererOverrides {
    private val elementRenderers = mutableMapOf<String, Any>()
    private val actionRenderers = mutableMapOf<String, Any>()

    /** Register a custom element renderer (type-erased) */
    fun registerElement(type: String, renderer: Any) {
        elementRenderers[type] = renderer
    }

    /** Register a custom action renderer (type-erased) */
    fun registerAction(type: String, renderer: Any) {
        actionRenderers[type] = renderer
    }

    /** Get a custom element renderer, if registered */
    fun getElementRenderer(type: String): Any? = elementRenderers[type]

    /** Get a custom action renderer, if registered */
    fun getActionRenderer(type: String): Any? = actionRenderers[type]
}
