// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.core.hostconfig

/**
 * Pre-configured HostConfig for Microsoft Teams loaded from bundled JSON files.
 * JSON source of truth lives in shared/host-configs/android/.
 *
 * Light and dark themes are loaded lazily and cached as singletons.
 */
object TeamsHostConfig {

    /** Creates the standard Teams light-theme HostConfig (cached singleton). */
    fun create(): HostConfig = lightInstance

    /** Teams light theme — white card surface (cached singleton). */
    fun createLight(): HostConfig = lightInstance

    /** Teams dark theme — dark card surface (cached singleton). */
    fun createDark(): HostConfig = darkInstance

    private val lightInstance: HostConfig by lazy {
        loadConfig("host-configs/microsoft-teams-light.json")
    }

    private val darkInstance: HostConfig by lazy {
        loadConfig("host-configs/microsoft-teams-dark.json")
    }

    private fun loadConfig(resourcePath: String): HostConfig {
        return try {
            val json = this::class.java.classLoader
                ?.getResourceAsStream(resourcePath)
                ?.bufferedReader()
                ?.readText()
            if (json != null) {
                HostConfigParser.parse(json)
            } else {
                println("TeamsHostConfig: Missing resource $resourcePath, using defaults")
                HostConfig()
            }
        } catch (e: Exception) {
            println("TeamsHostConfig: Failed to parse $resourcePath — ${e.message}")
            HostConfig()
        }
    }
}
