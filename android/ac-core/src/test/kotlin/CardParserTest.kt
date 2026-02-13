package com.microsoft.adaptivecards.core.parsing

import com.microsoft.adaptivecards.core.models.*
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*

class CardParserTest {
    
    @Test
    fun `parse simple text block card`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {
                        "type": "TextBlock",
                        "text": "Hello, World!"
                    }
                ]
            }
        """.trimIndent()
        
        val card = CardParser.parse(json)
        
        assertEquals("AdaptiveCard", card.type)
        assertEquals("1.6", card.version)
        assertNotNull(card.body)
        assertEquals(1, card.body?.size)
        
        val element = card.body?.first()
        assertTrue(element is TextBlock)
        assertEquals("Hello, World!", (element as TextBlock).text)
    }
    
    @Test
    fun `parse card with multiple elements`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {
                        "type": "TextBlock",
                        "text": "Title",
                        "weight": "Bolder",
                        "size": "Large"
                    },
                    {
                        "type": "Image",
                        "url": "https://example.com/image.png",
                        "size": "Medium"
                    }
                ]
            }
        """.trimIndent()
        
        val card = CardParser.parse(json)
        
        assertEquals(2, card.body?.size)
        
        val textBlock = card.body?.get(0) as TextBlock
        assertEquals("Title", textBlock.text)
        assertEquals(FontWeight.Bolder, textBlock.weight)
        assertEquals(FontSize.Large, textBlock.size)
        
        val image = card.body?.get(1) as Image
        assertEquals("https://example.com/image.png", image.url)
        assertEquals(ImageSize.Medium, image.size)
    }
    
    @Test
    fun `parse card with container`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {
                        "type": "Container",
                        "style": "Emphasis",
                        "items": [
                            {
                                "type": "TextBlock",
                                "text": "Inside container"
                            }
                        ]
                    }
                ]
            }
        """.trimIndent()
        
        val card = CardParser.parse(json)
        val container = card.body?.first() as Container
        
        assertEquals(ContainerStyle.Emphasis, container.style)
        assertEquals(1, container.items?.size)
        
        val textBlock = container.items?.first() as TextBlock
        assertEquals("Inside container", textBlock.text)
    }
    
    @Test
    fun `parse card with actions`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {
                        "type": "TextBlock",
                        "text": "Click a button"
                    }
                ],
                "actions": [
                    {
                        "type": "Action.Submit",
                        "title": "Submit"
                    },
                    {
                        "type": "Action.OpenUrl",
                        "title": "Open",
                        "url": "https://example.com"
                    }
                ]
            }
        """.trimIndent()
        
        val card = CardParser.parse(json)
        
        assertEquals(2, card.actions?.size)
        
        val submitAction = card.actions?.get(0) as ActionSubmit
        assertEquals("Submit", submitAction.title)
        
        val openUrlAction = card.actions?.get(1) as ActionOpenUrl
        assertEquals("Open", openUrlAction.title)
        assertEquals("https://example.com", openUrlAction.url)
    }
    
    @Test
    fun `parse card with inputs`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {
                        "type": "Input.Text",
                        "id": "name",
                        "label": "Name",
                        "isRequired": true,
                        "placeholder": "Enter your name"
                    },
                    {
                        "type": "Input.Number",
                        "id": "age",
                        "label": "Age",
                        "min": 0,
                        "max": 120
                    }
                ]
            }
        """.trimIndent()
        
        val card = CardParser.parse(json)
        
        val textInput = card.body?.get(0) as InputText
        assertEquals("name", textInput.id)
        assertEquals("Name", textInput.label)
        assertTrue(textInput.isRequired)
        assertEquals("Enter your name", textInput.placeholder)
        
        val numberInput = card.body?.get(1) as InputNumber
        assertEquals("age", numberInput.id)
        assertEquals("Age", numberInput.label)
        assertEquals(0.0, numberInput.min)
        assertEquals(120.0, numberInput.max)
    }
    
    @Test
    fun `serialize and deserialize card`() {
        val originalCard = AdaptiveCard(
            version = "1.6",
            body = listOf(
                TextBlock(
                    text = "Test",
                    weight = FontWeight.Bolder
                )
            )
        )
        
        val json = CardParser.serialize(originalCard)
        val parsedCard = CardParser.parse(json)
        
        assertEquals(originalCard.version, parsedCard.version)
        assertEquals(1, parsedCard.body?.size)
        
        val textBlock = parsedCard.body?.first() as TextBlock
        assertEquals("Test", textBlock.text)
        assertEquals(FontWeight.Bolder, textBlock.weight)
    }
    
    @Test
    fun `parse card with ColumnSet`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {
                        "type": "ColumnSet",
                        "columns": [
                            {
                                "width": "auto",
                                "items": [
                                    {
                                        "type": "TextBlock",
                                        "text": "Column 1"
                                    }
                                ]
                            },
                            {
                                "width": "stretch",
                                "items": [
                                    {
                                        "type": "TextBlock",
                                        "text": "Column 2"
                                    }
                                ]
                            }
                        ]
                    }
                ]
            }
        """.trimIndent()
        
        val card = CardParser.parse(json)
        val columnSet = card.body?.first() as ColumnSet
        
        assertEquals(2, columnSet.columns?.size)
        assertEquals("auto", columnSet.columns?.get(0)?.width)
        assertEquals("stretch", columnSet.columns?.get(1)?.width)
    }
}
