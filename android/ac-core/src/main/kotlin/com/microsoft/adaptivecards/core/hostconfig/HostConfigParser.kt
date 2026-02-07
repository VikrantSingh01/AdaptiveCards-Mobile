package com.microsoft.adaptivecards.core.hostconfig

import kotlinx.serialization.json.Json

/**
 * Parser for HostConfig JSON
 */
object HostConfigParser {
    private val json = Json {
        ignoreUnknownKeys = true
        isLenient = true
        prettyPrint = true
    }

    /**
     * Parse a JSON string into a HostConfig
     */
    fun parse(jsonString: String): HostConfig {
        return json.decodeFromString(HostConfig.serializer(), jsonString)
    }

    /**
     * Serialize a HostConfig to JSON string
     */
    fun serialize(config: HostConfig): String {
        return json.encodeToString(HostConfig.serializer(), config)
    }

    /**
     * Get default HostConfig
     */
    fun default(): HostConfig = HostConfig()

    /**
     * Get Teams HostConfig
     */
    fun teams(): HostConfig = TeamsHostConfig.create()
}
