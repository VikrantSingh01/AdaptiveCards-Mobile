import XCTest
@testable import ACCore

/// Unit tests for `AdaptiveCardFeatureFlags` singleton.
///
/// Validates that the feature flag registry works correctly:
/// - All flags default to `false`
/// - Individual flags can be toggled independently
/// - Convenience methods (`enableAllVisualParity`, `resetAll`) work correctly
/// - `anyVisualParityEnabled` computed property is accurate
/// - Thread-safety: singleton reference is stable
final class FeatureFlagTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Reset all flags to defaults before each test
        AdaptiveCardFeatureFlags.shared.resetAll()
    }

    override func tearDown() {
        // Clean up after each test
        AdaptiveCardFeatureFlags.shared.resetAll()
        super.tearDown()
    }

    // MARK: - Default State Tests

    func testAllFlagsDefaultToFalse() {
        let flags = AdaptiveCardFeatureFlags.shared
        XCTAssertFalse(flags.enableCopilotStreamingExtensions,
                       "enableCopilotStreamingExtensions should default to false")
        XCTAssertFalse(flags.useParityFontMetrics,
                       "useParityFontMetrics should default to false")
        XCTAssertFalse(flags.useParityLayoutFixes,
                       "useParityLayoutFixes should default to false")
        XCTAssertFalse(flags.useParityImageBehavior,
                       "useParityImageBehavior should default to false")
        XCTAssertFalse(flags.useParityElementStyling,
                       "useParityElementStyling should default to false")
    }

    func testAnyVisualParityEnabledDefaultsFalse() {
        XCTAssertFalse(AdaptiveCardFeatureFlags.shared.anyVisualParityEnabled,
                       "anyVisualParityEnabled should be false when no flags set")
    }

    // MARK: - Individual Flag Toggle Tests

    func testEnableCopilotStreamingExtensions() {
        let flags = AdaptiveCardFeatureFlags.shared
        flags.enableCopilotStreamingExtensions = true
        XCTAssertTrue(flags.enableCopilotStreamingExtensions)
        // Copilot flag should not affect visual parity
        XCTAssertFalse(flags.anyVisualParityEnabled,
                       "Copilot flag should not affect anyVisualParityEnabled")
    }

    func testEnableParityFontMetrics() {
        let flags = AdaptiveCardFeatureFlags.shared
        flags.useParityFontMetrics = true
        XCTAssertTrue(flags.useParityFontMetrics)
        XCTAssertTrue(flags.anyVisualParityEnabled,
                      "anyVisualParityEnabled should be true when font metrics enabled")
        // Other flags should remain false
        XCTAssertFalse(flags.useParityLayoutFixes)
        XCTAssertFalse(flags.useParityImageBehavior)
        XCTAssertFalse(flags.useParityElementStyling)
    }

    func testEnableParityLayoutFixes() {
        let flags = AdaptiveCardFeatureFlags.shared
        flags.useParityLayoutFixes = true
        XCTAssertTrue(flags.useParityLayoutFixes)
        XCTAssertTrue(flags.anyVisualParityEnabled)
    }

    func testEnableParityImageBehavior() {
        let flags = AdaptiveCardFeatureFlags.shared
        flags.useParityImageBehavior = true
        XCTAssertTrue(flags.useParityImageBehavior)
        XCTAssertTrue(flags.anyVisualParityEnabled)
    }

    func testEnableParityElementStyling() {
        let flags = AdaptiveCardFeatureFlags.shared
        flags.useParityElementStyling = true
        XCTAssertTrue(flags.useParityElementStyling)
        XCTAssertTrue(flags.anyVisualParityEnabled)
    }

    // MARK: - Convenience Method Tests

    func testEnableAllVisualParity() {
        let flags = AdaptiveCardFeatureFlags.shared
        flags.enableAllVisualParity()

        XCTAssertTrue(flags.useParityFontMetrics)
        XCTAssertTrue(flags.useParityLayoutFixes)
        XCTAssertTrue(flags.useParityImageBehavior)
        XCTAssertTrue(flags.useParityElementStyling)
        XCTAssertTrue(flags.anyVisualParityEnabled)
        // Copilot flag should NOT be affected by enableAllVisualParity
        XCTAssertFalse(flags.enableCopilotStreamingExtensions,
                       "enableAllVisualParity should not enable copilot flag")
    }

    func testResetAll() {
        let flags = AdaptiveCardFeatureFlags.shared
        // Enable everything
        flags.enableCopilotStreamingExtensions = true
        flags.enableAllVisualParity()

        // Verify all enabled
        XCTAssertTrue(flags.enableCopilotStreamingExtensions)
        XCTAssertTrue(flags.anyVisualParityEnabled)

        // Reset
        flags.resetAll()

        // Verify all reset to false
        XCTAssertFalse(flags.enableCopilotStreamingExtensions)
        XCTAssertFalse(flags.useParityFontMetrics)
        XCTAssertFalse(flags.useParityLayoutFixes)
        XCTAssertFalse(flags.useParityImageBehavior)
        XCTAssertFalse(flags.useParityElementStyling)
        XCTAssertFalse(flags.anyVisualParityEnabled)
    }

    // MARK: - Singleton Tests

    func testSingletonIdentity() {
        let a = AdaptiveCardFeatureFlags.shared
        let b = AdaptiveCardFeatureFlags.shared
        XCTAssertTrue(a === b, "shared should return the same instance")
    }

    func testSingletonStatePersistsAcrossReferences() {
        AdaptiveCardFeatureFlags.shared.useParityFontMetrics = true
        // Access through a different reference
        let flags = AdaptiveCardFeatureFlags.shared
        XCTAssertTrue(flags.useParityFontMetrics,
                      "State should persist across singleton references")
    }

    // MARK: - Flag Independence Tests

    func testFlagsAreIndependent() {
        let flags = AdaptiveCardFeatureFlags.shared

        // Enable only one flag at a time and verify others are unaffected
        flags.useParityFontMetrics = true
        XCTAssertTrue(flags.useParityFontMetrics)
        XCTAssertFalse(flags.useParityLayoutFixes)
        XCTAssertFalse(flags.useParityImageBehavior)
        XCTAssertFalse(flags.useParityElementStyling)
        XCTAssertFalse(flags.enableCopilotStreamingExtensions)

        flags.resetAll()
        flags.enableCopilotStreamingExtensions = true
        XCTAssertTrue(flags.enableCopilotStreamingExtensions)
        XCTAssertFalse(flags.useParityFontMetrics)
        XCTAssertFalse(flags.useParityLayoutFixes)
        XCTAssertFalse(flags.useParityImageBehavior)
        XCTAssertFalse(flags.useParityElementStyling)
    }

    // MARK: - Multiple Visual Parity Combinations

    func testAnyVisualParityWithMultipleFlags() {
        let flags = AdaptiveCardFeatureFlags.shared

        flags.useParityFontMetrics = true
        flags.useParityLayoutFixes = true
        XCTAssertTrue(flags.anyVisualParityEnabled)

        // Disable one, should still be true
        flags.useParityFontMetrics = false
        XCTAssertTrue(flags.anyVisualParityEnabled,
                      "Should still be true with layout fixes enabled")

        // Disable all
        flags.useParityLayoutFixes = false
        XCTAssertFalse(flags.anyVisualParityEnabled,
                       "Should be false when all parity flags are off")
    }
}
