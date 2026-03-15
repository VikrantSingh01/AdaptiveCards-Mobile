// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import Foundation
import SwiftUI

/// Consolidated configuration for rendering an Adaptive Card.
/// Bundles host config, image provider, renderer overrides, and feature flags
/// into a single value type.
///
/// ```swift
/// // Minimal
/// let config = CardConfiguration.default
///
/// // Production (Teams)
/// var config = CardConfiguration.teams(theme: .dark)
/// config.imageProvider = TeamsImageProvider(authService: authService)
///
/// // Full control
/// var config = CardConfiguration(hostConfig: myHostConfig)
/// config.imageProvider = myImageProvider
/// config.featureFlags.register(name: "myFeature", version: "1.0")
/// ```
public struct CardConfiguration {
    /// Host configuration controlling theming, spacing, and layout
    public var hostConfig: HostConfig

    /// Custom image loader. When nil, the SDK uses URLSession with built-in caching.
    public var imageProvider: (any ImageProvider)?

    /// Custom element/action renderers that override built-in views
    public var rendererOverrides: RendererOverrides

    /// Feature flags for conditional card content
    public var featureFlags: FeatureFlags

    /// Performance guardrails (element count cap, nesting depth, image throttling)
    public var guardrails: PerformanceGuardrails

    /// Cache instance. Uses `CardCache.shared` by default. Set to nil to disable caching.
    public var cache: CardCache?

    /// Provider for dynamic typeahead choices (Data.Query).
    /// When set, ChoiceSet inputs with `choices.data` will call this provider
    /// to fetch choices dynamically as the user types.
    public var dataQueryProvider: (any DataQueryProvider)?

    /// When true, shows a floating diagnostics overlay on the card with
    /// performance metrics, element counts, and rendering details.
    public var diagnosticsEnabled: Bool

    /// Default configuration using Teams light host config
    public static var `default`: CardConfiguration {
        CardConfiguration(hostConfig: TeamsHostConfig.create())
    }

    /// Creates a Teams-themed configuration
    public static func teams(theme: TeamsTheme) -> CardConfiguration {
        let hostConfig: HostConfig
        switch theme {
        case .light:
            hostConfig = TeamsHostConfig.createLight()
        case .dark:
            hostConfig = TeamsHostConfig.createDark()
        }
        return CardConfiguration(hostConfig: hostConfig)
    }

    public init(
        hostConfig: HostConfig = TeamsHostConfig.create(),
        imageProvider: (any ImageProvider)? = nil,
        rendererOverrides: RendererOverrides = RendererOverrides(),
        featureFlags: FeatureFlags = FeatureFlags(),
        guardrails: PerformanceGuardrails = .default,
        cache: CardCache? = CardCache.shared,
        dataQueryProvider: (any DataQueryProvider)? = nil,
        diagnosticsEnabled: Bool = false
    ) {
        self.hostConfig = hostConfig
        self.imageProvider = imageProvider
        self.rendererOverrides = rendererOverrides
        self.featureFlags = featureFlags
        self.guardrails = guardrails
        self.cache = cache
        self.dataQueryProvider = dataQueryProvider
        self.diagnosticsEnabled = diagnosticsEnabled
    }
}

/// Theme options for Teams configuration
public enum TeamsTheme {
    case light
    case dark
}

/// Per-card renderer overrides. Replaces the singleton `ElementRendererRegistry.shared` pattern.
/// Overrides set here take precedence over the global registry.
public struct RendererOverrides {
    private var elementRenderers: [String: (CardElement) -> AnyView] = [:]
    private var actionRenderers: [String: (CardAction) -> AnyView] = [:]

    public init() {}

    /// Register a custom element renderer
    public mutating func registerElement<V: View>(
        _ type: String,
        renderer: @escaping (CardElement) -> V
    ) {
        elementRenderers[type] = { AnyView(renderer($0)) }
    }

    /// Register a custom action renderer
    public mutating func registerAction<V: View>(
        _ type: String,
        renderer: @escaping (CardAction) -> V
    ) {
        actionRenderers[type] = { AnyView(renderer($0)) }
    }

    /// Get a custom element renderer, if registered
    public func getElementRenderer(for type: String) -> ((CardElement) -> AnyView)? {
        elementRenderers[type]
    }

    /// Get a custom action renderer, if registered
    public func getActionRenderer(for type: String) -> ((CardAction) -> AnyView)? {
        actionRenderers[type]
    }
}
