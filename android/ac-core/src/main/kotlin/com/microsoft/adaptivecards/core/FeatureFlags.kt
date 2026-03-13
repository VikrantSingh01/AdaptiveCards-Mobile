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
}
