// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.core

/**
 * Feature flags for controlling SDK behavior.
 * Hosts register features (name + version) to enable conditional card content.
 *
 * ```kotlin
 * val flags = FeatureFlags()
 * flags.register("myFeature", "1.0")
 * config.featureFlags = flags
 * ```
 */
class FeatureFlags {
    private val features = mutableMapOf<String, String>()

    /** Register a feature with a version string. */
    fun register(name: String, version: String) {
        features[name] = version
    }

    /** Unregister a feature. */
    fun unregister(name: String) {
        features.remove(name)
    }

    /** Check if a feature is registered. */
    fun isRegistered(name: String): Boolean = features.containsKey(name)

    /** Get the version of a registered feature, if any. */
    fun version(name: String): String? = features[name]

    /** All registered features. */
    val allFeatures: Map<String, String> get() = features.toMap()

    /**
     * Check if host capabilities meet the given requirements.
     * Per Adaptive Cards spec: `"*"` means any version of the feature must be registered;
     * a specific version string means exact match. ALL requirements must be met.
     * Returns `true` if [requires] is null or empty.
     */
    fun meetsRequirements(requires: Map<String, String>?): Boolean {
        if (requires.isNullOrEmpty()) return true
        for ((name, requiredVersion) in requires) {
            val registeredVersion = features[name] ?: return false
            if (requiredVersion != "*" && registeredVersion != requiredVersion) return false
        }
        return true
    }
}
