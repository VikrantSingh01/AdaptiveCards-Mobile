package com.microsoft.adaptivecards.rendering.registry

import androidx.compose.material3.Text
import androidx.compose.ui.Modifier
import com.microsoft.adaptivecards.core.models.*
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*

class RegistryTest {
    
    @Test
    fun `register and retrieve custom element renderer`() {
        val registry = ElementRendererRegistry.createDefault()
        
        // Register custom renderer
        registry.register("CustomElement") { element, modifier ->
            Text("Custom: ${element.type}", modifier = modifier)
        }
        
        assertTrue(registry.hasRenderer("CustomElement"))
        assertNotNull(registry.getRenderer("CustomElement"))
    }
    
    @Test
    fun `unregister element renderer`() {
        val registry = ElementRendererRegistry.createDefault()
        
        registry.register("CustomElement") { element, modifier ->
            Text("Custom", modifier = modifier)
        }
        
        assertTrue(registry.hasRenderer("CustomElement"))
        
        registry.unregister("CustomElement")
        
        assertFalse(registry.hasRenderer("CustomElement"))
    }
    
    @Test
    fun `get registered types`() {
        val registry = ElementRendererRegistry.createDefault()
        
        registry.register("Type1") { element, modifier -> }
        registry.register("Type2") { element, modifier -> }
        
        val types = registry.getRegisteredTypes()
        
        assertEquals(2, types.size)
        assertTrue(types.contains("Type1"))
        assertTrue(types.contains("Type2"))
    }
    
    @Test
    fun `clear all renderers`() {
        val registry = ElementRendererRegistry.createDefault()
        
        registry.register("Type1") { element, modifier -> }
        registry.register("Type2") { element, modifier -> }
        
        assertEquals(2, registry.getRegisteredTypes().size)
        
        registry.clear()
        
        assertEquals(0, registry.getRegisteredTypes().size)
    }
    
    @Test
    fun `register and retrieve custom action renderer`() {
        val registry = ActionRendererRegistry.createDefault()
        
        registry.register("Action.Custom") { action, modifier ->
            Text("Custom Action", modifier = modifier)
        }
        
        assertTrue(registry.hasRenderer("Action.Custom"))
        assertNotNull(registry.getRenderer("Action.Custom"))
    }
}
