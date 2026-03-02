package com.microsoft.adaptivecards.core

/**
 * Central feature flag registry for the AdaptiveCards Mobile SDK.
 *
 * All flags default to `false` — new behavior is opt-in.
 * Set flags before rendering any cards, typically during app initialization.
 *
 * ```kotlin
 * // Enable copilot streaming extensions
 * AdaptiveCardFeatureFlags.enableCopilotStreamingExtensions = true
 *
 * // Enable visual parity fixes
 * AdaptiveCardFeatureFlags.useParityFontMetrics = true
 * ```
 *
 * These flags gate changes from the proxy/integration branch:
 * - Copilot extensions: PR #37 (ChainOfThought + Streaming)
 * - Visual parity: PR #39 delta (font metrics, layout, image, element styling)
 */
object AdaptiveCardFeatureFlags {

    // region Copilot Streaming Extensions (PR #37)

    /**
     * When `true`, enables ChainOfThought and Streaming text views and models.
     * These are new Copilot-specific card extensions for reasoning visualization
     * and progressive text rendering.
     *
     * Affected types: [ChainOfThoughtView], [ChainOfThoughtModels],
     * [StreamingTextView], [StreamingModels], [CopilotExtensionTypes] (new registrations)
     */
    @JvmStatic
    var enableCopilotStreamingExtensions: Boolean = false

    // endregion

    // region Visual Parity Flags (PR #39 delta over #38)

    /**
     * When `true`, applies updated font metrics for text rendering parity with
     * the web/desktop SDK. Affects line-height calculations and font size mapping.
     *
     * Affected views: TextBlockView, RichTextBlockView
     */
    @JvmStatic
    var useParityFontMetrics: Boolean = false

    /**
     * When `true`, applies corrected padding, spacing, and alignment behavior
     * for container-based layouts to match web/desktop SDK rendering.
     *
     * Affected views: ContainerView, ColumnView, ColumnSetView
     */
    @JvmStatic
    var useParityLayoutFixes: Boolean = false

    /**
     * When `true`, applies updated image sizing and aspect-ratio behavior
     * to match web/desktop SDK rendering.
     *
     * Affected views: ImageView
     */
    @JvmStatic
    var useParityImageBehavior: Boolean = false

    /**
     * When `true`, applies visual styling corrections for miscellaneous elements
     * including fact sets, tables, action buttons, and rich text blocks.
     *
     * Affected views: FactSetView, TableView, ActionButton, RichTextBlockView
     */
    @JvmStatic
    var useParityElementStyling: Boolean = false

    // endregion

    // region Convenience

    /**
     * Returns `true` if any visual parity flag is enabled.
     */
    @JvmStatic
    val anyVisualParityEnabled: Boolean
        get() = useParityFontMetrics || useParityLayoutFixes ||
                useParityImageBehavior || useParityElementStyling

    /**
     * Enables all visual parity flags at once.
     */
    @JvmStatic
    fun enableAllVisualParity() {
        useParityFontMetrics = true
        useParityLayoutFixes = true
        useParityImageBehavior = true
        useParityElementStyling = true
    }

    /**
     * Resets all flags to their defaults (`false`).
     */
    @JvmStatic
    fun resetAll() {
        enableCopilotStreamingExtensions = false
        useParityFontMetrics = false
        useParityLayoutFixes = false
        useParityImageBehavior = false
        useParityElementStyling = false
    }

    // endregion
}
