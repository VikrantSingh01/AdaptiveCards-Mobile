package com.microsoft.adaptivecards.core

import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test

/**
 * Unit tests for [AdaptiveCardFeatureFlags] object.
 *
 * Validates that the feature flag registry works correctly:
 * - All flags default to `false`
 * - Individual flags can be toggled independently
 * - Convenience methods ([enableAllVisualParity], [resetAll]) work correctly
 * - [anyVisualParityEnabled] computed property is accurate
 * - Kotlin `object` singleton guarantees stable reference
 */
class AdaptiveCardFeatureFlagsTest {

    @BeforeEach
    fun setUp() {
        AdaptiveCardFeatureFlags.resetAll()
    }

    @AfterEach
    fun tearDown() {
        AdaptiveCardFeatureFlags.resetAll()
    }

    // region Default State Tests

    @Test
    fun `all flags default to false`() {
        assertFalse(AdaptiveCardFeatureFlags.enableCopilotStreamingExtensions,
            "enableCopilotStreamingExtensions should default to false")
        assertFalse(AdaptiveCardFeatureFlags.useParityFontMetrics,
            "useParityFontMetrics should default to false")
        assertFalse(AdaptiveCardFeatureFlags.useParityLayoutFixes,
            "useParityLayoutFixes should default to false")
        assertFalse(AdaptiveCardFeatureFlags.useParityImageBehavior,
            "useParityImageBehavior should default to false")
        assertFalse(AdaptiveCardFeatureFlags.useParityElementStyling,
            "useParityElementStyling should default to false")
    }

    @Test
    fun `anyVisualParityEnabled defaults to false`() {
        assertFalse(AdaptiveCardFeatureFlags.anyVisualParityEnabled,
            "anyVisualParityEnabled should be false when no flags set")
    }

    // endregion

    // region Individual Flag Toggle Tests

    @Test
    fun `enable copilot streaming extensions`() {
        AdaptiveCardFeatureFlags.enableCopilotStreamingExtensions = true
        assertTrue(AdaptiveCardFeatureFlags.enableCopilotStreamingExtensions)
        // Copilot flag should not affect visual parity
        assertFalse(AdaptiveCardFeatureFlags.anyVisualParityEnabled,
            "Copilot flag should not affect anyVisualParityEnabled")
    }

    @Test
    fun `enable parity font metrics`() {
        AdaptiveCardFeatureFlags.useParityFontMetrics = true
        assertTrue(AdaptiveCardFeatureFlags.useParityFontMetrics)
        assertTrue(AdaptiveCardFeatureFlags.anyVisualParityEnabled,
            "anyVisualParityEnabled should be true when font metrics enabled")
        // Other flags should remain false
        assertFalse(AdaptiveCardFeatureFlags.useParityLayoutFixes)
        assertFalse(AdaptiveCardFeatureFlags.useParityImageBehavior)
        assertFalse(AdaptiveCardFeatureFlags.useParityElementStyling)
    }

    @Test
    fun `enable parity layout fixes`() {
        AdaptiveCardFeatureFlags.useParityLayoutFixes = true
        assertTrue(AdaptiveCardFeatureFlags.useParityLayoutFixes)
        assertTrue(AdaptiveCardFeatureFlags.anyVisualParityEnabled)
    }

    @Test
    fun `enable parity image behavior`() {
        AdaptiveCardFeatureFlags.useParityImageBehavior = true
        assertTrue(AdaptiveCardFeatureFlags.useParityImageBehavior)
        assertTrue(AdaptiveCardFeatureFlags.anyVisualParityEnabled)
    }

    @Test
    fun `enable parity element styling`() {
        AdaptiveCardFeatureFlags.useParityElementStyling = true
        assertTrue(AdaptiveCardFeatureFlags.useParityElementStyling)
        assertTrue(AdaptiveCardFeatureFlags.anyVisualParityEnabled)
    }

    // endregion

    // region Convenience Method Tests

    @Test
    fun `enableAllVisualParity enables all parity flags`() {
        AdaptiveCardFeatureFlags.enableAllVisualParity()

        assertTrue(AdaptiveCardFeatureFlags.useParityFontMetrics)
        assertTrue(AdaptiveCardFeatureFlags.useParityLayoutFixes)
        assertTrue(AdaptiveCardFeatureFlags.useParityImageBehavior)
        assertTrue(AdaptiveCardFeatureFlags.useParityElementStyling)
        assertTrue(AdaptiveCardFeatureFlags.anyVisualParityEnabled)
        // Copilot flag should NOT be affected
        assertFalse(AdaptiveCardFeatureFlags.enableCopilotStreamingExtensions,
            "enableAllVisualParity should not enable copilot flag")
    }

    @Test
    fun `resetAll clears all flags`() {
        // Enable everything
        AdaptiveCardFeatureFlags.enableCopilotStreamingExtensions = true
        AdaptiveCardFeatureFlags.enableAllVisualParity()

        // Verify all enabled
        assertTrue(AdaptiveCardFeatureFlags.enableCopilotStreamingExtensions)
        assertTrue(AdaptiveCardFeatureFlags.anyVisualParityEnabled)

        // Reset
        AdaptiveCardFeatureFlags.resetAll()

        // Verify all reset to false
        assertFalse(AdaptiveCardFeatureFlags.enableCopilotStreamingExtensions)
        assertFalse(AdaptiveCardFeatureFlags.useParityFontMetrics)
        assertFalse(AdaptiveCardFeatureFlags.useParityLayoutFixes)
        assertFalse(AdaptiveCardFeatureFlags.useParityImageBehavior)
        assertFalse(AdaptiveCardFeatureFlags.useParityElementStyling)
        assertFalse(AdaptiveCardFeatureFlags.anyVisualParityEnabled)
    }

    // endregion

    // region Flag Independence Tests

    @Test
    fun `flags are independent of each other`() {
        // Enable only one flag at a time and verify others are unaffected
        AdaptiveCardFeatureFlags.useParityFontMetrics = true
        assertTrue(AdaptiveCardFeatureFlags.useParityFontMetrics)
        assertFalse(AdaptiveCardFeatureFlags.useParityLayoutFixes)
        assertFalse(AdaptiveCardFeatureFlags.useParityImageBehavior)
        assertFalse(AdaptiveCardFeatureFlags.useParityElementStyling)
        assertFalse(AdaptiveCardFeatureFlags.enableCopilotStreamingExtensions)

        AdaptiveCardFeatureFlags.resetAll()
        AdaptiveCardFeatureFlags.enableCopilotStreamingExtensions = true
        assertTrue(AdaptiveCardFeatureFlags.enableCopilotStreamingExtensions)
        assertFalse(AdaptiveCardFeatureFlags.useParityFontMetrics)
        assertFalse(AdaptiveCardFeatureFlags.useParityLayoutFixes)
        assertFalse(AdaptiveCardFeatureFlags.useParityImageBehavior)
        assertFalse(AdaptiveCardFeatureFlags.useParityElementStyling)
    }

    // endregion

    // region Multiple Visual Parity Combinations

    @Test
    fun `anyVisualParityEnabled with multiple flags`() {
        AdaptiveCardFeatureFlags.useParityFontMetrics = true
        AdaptiveCardFeatureFlags.useParityLayoutFixes = true
        assertTrue(AdaptiveCardFeatureFlags.anyVisualParityEnabled)

        // Disable one, should still be true
        AdaptiveCardFeatureFlags.useParityFontMetrics = false
        assertTrue(AdaptiveCardFeatureFlags.anyVisualParityEnabled,
            "Should still be true with layout fixes enabled")

        // Disable all
        AdaptiveCardFeatureFlags.useParityLayoutFixes = false
        assertFalse(AdaptiveCardFeatureFlags.anyVisualParityEnabled,
            "Should be false when all parity flags are off")
    }

    // endregion

    // region JVM Static Annotation Tests

    @Test
    fun `flags are accessible via JvmStatic`() {
        // This test verifies that the @JvmStatic annotation works correctly
        // by accessing the flags through the companion-style access pattern
        AdaptiveCardFeatureFlags.enableCopilotStreamingExtensions = true
        val value = AdaptiveCardFeatureFlags.enableCopilotStreamingExtensions
        assertTrue(value, "JvmStatic property should be readable")
    }

    // endregion
}
