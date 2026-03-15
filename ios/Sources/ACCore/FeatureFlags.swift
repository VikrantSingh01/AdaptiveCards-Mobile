// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import Foundation

/// Feature flags for controlling SDK behavior.
/// Hosts register features (name + version) to enable conditional card content.
///
/// ```swift
/// var flags = FeatureFlags()
/// flags.register(name: "myFeature", version: "1.0")
/// config.featureFlags = flags
/// ```
public struct FeatureFlags: Sendable {
    private var features: [String: String] = [:]

    public init() {}

    /// Register a feature with a version string.
    public mutating func register(name: String, version: String) {
        features[name] = version
    }

    /// Unregister a feature.
    public mutating func unregister(name: String) {
        features.removeValue(forKey: name)
    }

    /// Check if a feature is registered.
    public func isRegistered(name: String) -> Bool {
        features[name] != nil
    }

    /// Get the version of a registered feature, if any.
    public func version(for name: String) -> String? {
        features[name]
    }

    /// All registered features.
    public var allFeatures: [String: String] {
        features
    }

    /// Check if host capabilities meet the given requirements.
    /// Per Adaptive Cards spec: `"*"` means any version of the feature must be registered;
    /// a specific version string means exact match. ALL requirements must be met.
    /// Returns `true` if `requires` is nil or empty.
    public func meetsRequirements(_ requires: [String: String]?) -> Bool {
        guard let requires = requires, !requires.isEmpty else { return true }
        for (name, requiredVersion) in requires {
            guard let registeredVersion = features[name] else { return false }
            if requiredVersion != "*" && registeredVersion != requiredVersion {
                return false
            }
        }
        return true
    }
}
