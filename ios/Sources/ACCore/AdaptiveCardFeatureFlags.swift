import Foundation

// MARK: - AdaptiveCardFeatureFlags

/// Central feature flag registry for the AdaptiveCards Mobile SDK.
///
/// All flags default to `false` — new behavior is opt-in.
/// Set flags before rendering any cards, typically during app initialization.
///
/// ```swift
/// // Enable copilot streaming extensions
/// AdaptiveCardFeatureFlags.shared.enableCopilotStreamingExtensions = true
///
/// // Enable visual parity fixes
/// AdaptiveCardFeatureFlags.shared.useParityFontMetrics = true
/// ```
///
/// These flags gate changes from the proxy/integration branch:
/// - Copilot extensions: PR #37 (ChainOfThought + Streaming)
/// - Visual parity: PR #39 delta (font metrics, layout, image, element styling)
public final class AdaptiveCardFeatureFlags {

    /// Shared singleton instance.
    public static let shared = AdaptiveCardFeatureFlags()

    private init() {}

    // MARK: - Copilot Streaming Extensions (PR #37)

    /// When `true`, enables ChainOfThought and Streaming text views and models.
    /// These are new Copilot-specific card extensions for reasoning visualization
    /// and progressive text rendering.
    ///
    /// **Affected types**: `ChainOfThoughtView`, `ChainOfThoughtModels`,
    /// `StreamingTextView`, `StreamingModels`, `CopilotExtensionTypes` (new registrations)
    public var enableCopilotStreamingExtensions: Bool = false

    // MARK: - Visual Parity Flags (PR #39 delta over #38)

    /// When `true`, applies updated font metrics for text rendering parity with
    /// the web/desktop SDK. Affects line-height calculations and font size mapping.
    ///
    /// **Affected views**: `TextBlockView`, `RichTextBlockView`
    public var useParityFontMetrics: Bool = false

    /// When `true`, applies corrected padding, spacing, and alignment behavior
    /// for container-based layouts to match web/desktop SDK rendering.
    ///
    /// **Affected views**: `ContainerView`, `ColumnView`, `ColumnSetView`
    public var useParityLayoutFixes: Bool = false

    /// When `true`, applies updated image sizing and aspect-ratio behavior
    /// to match web/desktop SDK rendering.
    ///
    /// **Affected views**: `ImageView`
    public var useParityImageBehavior: Bool = false

    /// When `true`, applies visual styling corrections for miscellaneous elements
    /// including fact sets, tables, action buttons, and rich text blocks.
    ///
    /// **Affected views**: `FactSetView`, `TableView`, `ActionButton`, `RichTextBlockView`
    public var useParityElementStyling: Bool = false

    // MARK: - Convenience

    /// Returns `true` if any visual parity flag is enabled.
    public var anyVisualParityEnabled: Bool {
        useParityFontMetrics || useParityLayoutFixes ||
        useParityImageBehavior || useParityElementStyling
    }

    /// Enables all visual parity flags at once.
    public func enableAllVisualParity() {
        useParityFontMetrics = true
        useParityLayoutFixes = true
        useParityImageBehavior = true
        useParityElementStyling = true
    }

    /// Resets all flags to their defaults (`false`).
    public func resetAll() {
        enableCopilotStreamingExtensions = false
        useParityFontMetrics = false
        useParityLayoutFixes = false
        useParityImageBehavior = false
        useParityElementStyling = false
    }
}
