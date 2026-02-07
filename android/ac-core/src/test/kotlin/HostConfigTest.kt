package com.microsoft.adaptivecards.core.hostconfig

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*

class HostConfigTest {
    
    @Test
    fun `create default host config`() {
        val config = HostConfigParser.default()
        
        assertNotNull(config)
        assertTrue(config.supportsInteractivity)
        assertEquals(8, config.spacing.default)
        assertEquals(5, config.actions.maxActions)
    }
    
    @Test
    fun `create Teams host config`() {
        val config = HostConfigParser.teams()
        
        assertNotNull(config)
        assertTrue(config.supportsInteractivity)
        assertEquals("#E1DFDD", config.separator.lineColor)
        assertEquals("#6264A7", config.containerStyles.default.foregroundColors.accent.default)
    }
    
    @Test
    fun `parse host config from JSON`() {
        val json = """
            {
                "spacing": {
                    "small": 2,
                    "default": 4,
                    "medium": 8,
                    "large": 16,
                    "extraLarge": 32,
                    "padding": 12
                },
                "supportsInteractivity": true,
                "actions": {
                    "maxActions": 3
                }
            }
        """.trimIndent()
        
        val config = HostConfigParser.parse(json)
        
        assertEquals(2, config.spacing.small)
        assertEquals(4, config.spacing.default)
        assertEquals(3, config.actions.maxActions)
        assertTrue(config.supportsInteractivity)
    }
    
    @Test
    fun `serialize host config to JSON`() {
        val config = HostConfig(
            spacing = SpacingConfig(small = 2, default = 4),
            supportsInteractivity = false
        )
        
        val json = HostConfigParser.serialize(config)
        
        assertNotNull(json)
        assertTrue(json.contains("\"small\": 2") || json.contains("\"small\":2"))
        assertTrue(json.contains("\"supportsInteractivity\": false") || json.contains("\"supportsInteractivity\":false"))
    }
}
