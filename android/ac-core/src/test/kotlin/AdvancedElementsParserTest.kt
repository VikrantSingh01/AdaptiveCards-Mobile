package com.microsoft.adaptivecards.core.parsing

import com.microsoft.adaptivecards.core.models.*
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*

class AdvancedElementsParserTest {
    
    @Test
    fun `parse Carousel element`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {
                        "type": "Carousel",
                        "id": "carousel1",
                        "timer": 5000,
                        "initialPage": 0,
                        "pages": [
                            {
                                "items": [
                                    {
                                        "type": "TextBlock",
                                        "text": "Page 1"
                                    }
                                ],
                                "selectAction": null
                            },
                            {
                                "items": [
                                    {
                                        "type": "TextBlock",
                                        "text": "Page 2"
                                    }
                                ]
                            }
                        ]
                    }
                ]
            }
        """.trimIndent()
        
        val card = CardParser.parse(json)
        
        assertEquals(1, card.body?.size)
        val carousel = card.body?.first() as Carousel
        
        assertEquals("carousel1", carousel.id)
        assertEquals(5000, carousel.timer)
        assertEquals(0, carousel.initialPage)
        assertEquals(2, carousel.pages.size)
        
        val firstPage = carousel.pages[0]
        assertEquals(1, firstPage.items.size)
        assertTrue(firstPage.items[0] is TextBlock)
    }
    
    @Test
    fun `parse Accordion element`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {
                        "type": "Accordion",
                        "id": "accordion1",
                        "expandMode": "single",
                        "panels": [
                            {
                                "title": "Panel 1",
                                "isExpanded": true,
                                "content": [
                                    {
                                        "type": "TextBlock",
                                        "text": "Content 1"
                                    }
                                ]
                            },
                            {
                                "title": "Panel 2",
                                "content": [
                                    {
                                        "type": "TextBlock",
                                        "text": "Content 2"
                                    }
                                ]
                            }
                        ]
                    }
                ]
            }
        """.trimIndent()
        
        val card = CardParser.parse(json)
        
        assertEquals(1, card.body?.size)
        val accordion = card.body?.first() as Accordion
        
        assertEquals("accordion1", accordion.id)
        assertEquals(ExpandMode.SINGLE, accordion.expandMode)
        assertEquals(2, accordion.panels.size)
        
        val firstPanel = accordion.panels[0]
        assertEquals("Panel 1", firstPanel.title)
        assertTrue(firstPanel.isExpanded == true)
        assertEquals(1, firstPanel.content.size)
    }
    
    @Test
    fun `parse CodeBlock element`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {
                        "type": "CodeBlock",
                        "id": "code1",
                        "code": "function hello() {\n  console.log('Hello');\n}",
                        "language": "javascript",
                        "startLineNumber": 1,
                        "wrap": false
                    }
                ]
            }
        """.trimIndent()
        
        val card = CardParser.parse(json)
        
        assertEquals(1, card.body?.size)
        val codeBlock = card.body?.first() as CodeBlock
        
        assertEquals("code1", codeBlock.id)
        assertEquals("javascript", codeBlock.language)
        assertEquals(1, codeBlock.startLineNumber)
        assertEquals(false, codeBlock.wrap)
        assertTrue(codeBlock.code.contains("function hello()"))
    }
    
    @Test
    fun `parse RatingDisplay element`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {
                        "type": "Rating",
                        "id": "rating1",
                        "value": 4.5,
                        "max": 5,
                        "count": 127,
                        "size": "medium"
                    }
                ]
            }
        """.trimIndent()
        
        val card = CardParser.parse(json)
        
        assertEquals(1, card.body?.size)
        val rating = card.body?.first() as RatingDisplay
        
        assertEquals("rating1", rating.id)
        assertEquals(4.5, rating.value)
        assertEquals(5, rating.max)
        assertEquals(127, rating.count)
        assertEquals(RatingSize.MEDIUM, rating.size)
    }
    
    @Test
    fun `parse RatingInput element`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {
                        "type": "Input.Rating",
                        "id": "ratingInput1",
                        "label": "Rate this product",
                        "max": 5,
                        "value": 0,
                        "isRequired": true,
                        "errorMessage": "Please provide a rating"
                    }
                ]
            }
        """.trimIndent()
        
        val card = CardParser.parse(json)
        
        assertEquals(1, card.body?.size)
        val ratingInput = card.body?.first() as RatingInput
        
        assertEquals("ratingInput1", ratingInput.id)
        assertEquals("Rate this product", ratingInput.label)
        assertEquals(5, ratingInput.max)
        assertEquals(0.0, ratingInput.value)
        assertTrue(ratingInput.isRequired)
        assertEquals("Please provide a rating", ratingInput.errorMessage)
    }
    
    @Test
    fun `parse ProgressBar element`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {
                        "type": "ProgressBar",
                        "id": "progress1",
                        "label": "Download Progress",
                        "value": 0.75,
                        "color": "#0078D4"
                    }
                ]
            }
        """.trimIndent()
        
        val card = CardParser.parse(json)
        
        assertEquals(1, card.body?.size)
        val progressBar = card.body?.first() as ProgressBar
        
        assertEquals("progress1", progressBar.id)
        assertEquals("Download Progress", progressBar.label)
        assertEquals(0.75, progressBar.value)
        assertEquals("#0078D4", progressBar.color)
    }
    
    @Test
    fun `parse Spinner element`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {
                        "type": "Spinner",
                        "id": "spinner1",
                        "size": "medium",
                        "label": "Loading..."
                    }
                ]
            }
        """.trimIndent()
        
        val card = CardParser.parse(json)
        
        assertEquals(1, card.body?.size)
        val spinner = card.body?.first() as Spinner
        
        assertEquals("spinner1", spinner.id)
        assertEquals(SpinnerSize.MEDIUM, spinner.size)
        assertEquals("Loading...", spinner.label)
    }
    
    @Test
    fun `parse TabSet element`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {
                        "type": "TabSet",
                        "id": "tabSet1",
                        "selectedTabId": "tab1",
                        "tabs": [
                            {
                                "id": "tab1",
                                "title": "Tab 1",
                                "icon": "📋",
                                "items": [
                                    {
                                        "type": "TextBlock",
                                        "text": "Tab 1 content"
                                    }
                                ]
                            },
                            {
                                "id": "tab2",
                                "title": "Tab 2",
                                "items": [
                                    {
                                        "type": "TextBlock",
                                        "text": "Tab 2 content"
                                    }
                                ]
                            }
                        ]
                    }
                ]
            }
        """.trimIndent()
        
        val card = CardParser.parse(json)
        
        assertEquals(1, card.body?.size)
        val tabSet = card.body?.first() as TabSet
        
        assertEquals("tabSet1", tabSet.id)
        assertEquals("tab1", tabSet.selectedTabId)
        assertEquals(2, tabSet.tabs.size)
        
        val firstTab = tabSet.tabs[0]
        assertEquals("tab1", firstTab.id)
        assertEquals("Tab 1", firstTab.title)
        assertEquals("📋", firstTab.icon)
        assertEquals(1, firstTab.items.size)
    }
    
    @Test
    fun `serialize and deserialize Carousel`() {
        val originalCard = AdaptiveCard(
            version = "1.6",
            body = listOf(
                Carousel(
                    id = "carousel1",
                    timer = 3000,
                    initialPage = 0,
                    pages = listOf(
                        CarouselPage(
                            items = listOf(
                                TextBlock(text = "Page 1")
                            )
                        ),
                        CarouselPage(
                            items = listOf(
                                TextBlock(text = "Page 2")
                            )
                        )
                    )
                )
            )
        )
        
        val json = CardParser.serialize(originalCard)
        val parsedCard = CardParser.parse(json)
        
        assertEquals(1, parsedCard.body?.size)
        val carousel = parsedCard.body?.first() as Carousel
        assertEquals("carousel1", carousel.id)
        assertEquals(3000, carousel.timer)
        assertEquals(2, carousel.pages.size)
    }
    
    @Test
    fun `serialize and deserialize TabSet`() {
        val originalCard = AdaptiveCard(
            version = "1.6",
            body = listOf(
                TabSet(
                    id = "tabs1",
                    selectedTabId = "tab1",
                    tabs = listOf(
                        Tab(
                            id = "tab1",
                            title = "Overview",
                            icon = "📋",
                            items = listOf(
                                TextBlock(text = "Overview content")
                            )
                        )
                    )
                )
            )
        )
        
        val json = CardParser.serialize(originalCard)
        val parsedCard = CardParser.parse(json)
        
        assertEquals(1, parsedCard.body?.size)
        val tabSet = parsedCard.body?.first() as TabSet
        assertEquals("tabs1", tabSet.id)
        assertEquals("tab1", tabSet.selectedTabId)
        assertEquals(1, tabSet.tabs.size)
    }
    
    @Test
    fun `parse List element`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {
                        "type": "List",
                        "id": "list1",
                        "style": "bulleted",
                        "items": [
                            {
                                "type": "TextBlock",
                                "text": "Item 1"
                            },
                            {
                                "type": "TextBlock",
                                "text": "Item 2"
                            },
                            {
                                "type": "TextBlock",
                                "text": "Item 3"
                            }
                        ]
                    }
                ]
            }
        """.trimIndent()
        
        val card = CardParser.parse(json)
        
        assertEquals(1, card.body?.size)
        val list = card.body?.first() as ListElement
        
        assertEquals("list1", list.id)
        assertEquals("bulleted", list.style)
        assertEquals(3, list.items.size)
        assertTrue(list.items[0] is TextBlock)
    }
    
    @Test
    fun `parse List with maxHeight`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {
                        "type": "List",
                        "id": "scrollableList",
                        "style": "numbered",
                        "maxHeight": "200px",
                        "items": [
                            {
                                "type": "TextBlock",
                                "text": "Item 1"
                            },
                            {
                                "type": "TextBlock",
                                "text": "Item 2"
                            }
                        ]
                    }
                ]
            }
        """.trimIndent()
        
        val card = CardParser.parse(json)
        
        assertEquals(1, card.body?.size)
        val list = card.body?.first() as ListElement
        
        assertEquals("scrollableList", list.id)
        assertEquals("numbered", list.style)
        assertEquals("200px", list.maxHeight)
        assertEquals(2, list.items.size)
    }
    
    @Test
    fun `parse List with empty items`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {
                        "type": "List",
                        "id": "emptyList",
                        "items": []
                    }
                ]
            }
        """.trimIndent()
        
        val card = CardParser.parse(json)
        
        assertEquals(1, card.body?.size)
        val list = card.body?.first() as ListElement
        
        assertEquals("emptyList", list.id)
        assertEquals(0, list.items.size)
        assertNull(list.maxHeight)
        assertNull(list.style)
    }
    
    @Test
    fun `serialize and deserialize List`() {
        val originalCard = AdaptiveCard(
            version = "1.6",
            body = listOf(
                ListElement(
                    id = "list1",
                    style = "bulleted",
                    maxHeight = "300px",
                    items = listOf(
                        TextBlock(text = "Item 1"),
                        TextBlock(text = "Item 2")
                    )
                )
            )
        )
        
        val json = CardParser.serialize(originalCard)
        val parsedCard = CardParser.parse(json)
        
        assertEquals(1, parsedCard.body?.size)
        val list = parsedCard.body?.first() as ListElement
        assertEquals("list1", list.id)
        assertEquals("bulleted", list.style)
        assertEquals("300px", list.maxHeight)
        assertEquals(2, list.items.size)
    }
    
    @Test
    fun `parse CompoundButton element`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {
                        "type": "CompoundButton",
                        "id": "btn1",
                        "title": "Approve Request",
                        "subtitle": "Review and approve the pending request",
                        "icon": "checkmark.circle.fill",
                        "iconPosition": "leading",
                        "style": "positive",
                        "action": {
                            "type": "Action.Submit",
                            "title": "Approve",
                            "data": {
                                "action": "approve"
                            }
                        }
                    }
                ]
            }
        """.trimIndent()
        
        val card = CardParser.parse(json)
        
        assertEquals(1, card.body?.size)
        val button = card.body?.first() as CompoundButton
        
        assertEquals("btn1", button.id)
        assertEquals("Approve Request", button.title)
        assertEquals("Review and approve the pending request", button.subtitle)
        assertEquals("checkmark.circle.fill", button.icon)
        assertEquals("leading", button.iconPosition)
        assertEquals("positive", button.style)
        assertNotNull(button.action)
    }
    
    @Test
    fun `parse CompoundButton with emphasis style`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {
                        "type": "CompoundButton",
                        "id": "btn_emphasis",
                        "title": "Primary Action",
                        "subtitle": "With accent color",
                        "icon": "star.fill",
                        "style": "emphasis",
                        "action": {
                            "type": "Action.Submit",
                            "title": "Submit"
                        }
                    }
                ]
            }
        """.trimIndent()
        
        val card = CardParser.parse(json)
        val button = card.body?.first() as CompoundButton
        
        assertEquals("emphasis", button.style)
        assertEquals("Primary Action", button.title)
    }
    
    @Test
    fun `parse CompoundButton with destructive style`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {
                        "type": "CompoundButton",
                        "id": "btn_delete",
                        "title": "Delete Item",
                        "subtitle": "This action cannot be undone",
                        "icon": "trash",
                        "style": "destructive",
                        "action": {
                            "type": "Action.Submit",
                            "title": "Delete",
                            "data": {
                                "action": "delete"
                            }
                        }
                    }
                ]
            }
        """.trimIndent()
        
        val card = CardParser.parse(json)
        val button = card.body?.first() as CompoundButton
        
        assertEquals("destructive", button.style)
        assertEquals("Delete Item", button.title)
    }
    
    @Test
    fun `parse CompoundButton with trailing icon`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {
                        "type": "CompoundButton",
                        "id": "btn_trailing",
                        "title": "Navigate",
                        "subtitle": "Open external link",
                        "icon": "arrow.right.circle",
                        "iconPosition": "trailing",
                        "action": {
                            "type": "Action.OpenUrl",
                            "url": "https://example.com"
                        }
                    }
                ]
            }
        """.trimIndent()
        
        val card = CardParser.parse(json)
        val button = card.body?.first() as CompoundButton
        
        assertEquals("trailing", button.iconPosition)
        assertNotNull(button.icon)
    }
    
    @Test
    fun `parse CompoundButton without icon`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {
                        "type": "CompoundButton",
                        "id": "btn_no_icon",
                        "title": "Submit Form",
                        "subtitle": "Send your response",
                        "action": {
                            "type": "Action.Submit"
                        }
                    }
                ]
            }
        """.trimIndent()
        
        val card = CardParser.parse(json)
        val button = card.body?.first() as CompoundButton
        
        assertNull(button.icon)
        assertNotNull(button.subtitle)
    }
    
    @Test
    fun `parse CompoundButton without subtitle`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {
                        "type": "CompoundButton",
                        "id": "btn_no_subtitle",
                        "title": "Quick Action",
                        "icon": "bolt.fill",
                        "action": {
                            "type": "Action.Submit"
                        }
                    }
                ]
            }
        """.trimIndent()
        
        val card = CardParser.parse(json)
        val button = card.body?.first() as CompoundButton
        
        assertNull(button.subtitle)
        assertNotNull(button.icon)
    }
    
    @Test
    fun `parse CompoundButton without action`() {
        val json = """
            {
                "type": "AdaptiveCard",
                "version": "1.6",
                "body": [
                    {
                        "type": "CompoundButton",
                        "id": "btn_disabled",
                        "title": "Disabled Button",
                        "subtitle": "No action associated"
                    }
                ]
            }
        """.trimIndent()
        
        val card = CardParser.parse(json)
        val button = card.body?.first() as CompoundButton
        
        assertNull(button.action)
    }
    
    @Test
    fun `serialize and deserialize CompoundButton`() {
        val originalCard = AdaptiveCard(
            version = "1.6",
            body = listOf(
                CompoundButton(
                    id = "btn1",
                    title = "Test Button",
                    subtitle = "Test subtitle",
                    icon = "star.fill",
                    iconPosition = "leading",
                    style = "emphasis",
                    action = ActionSubmit(
                        title = "Submit",
                        data = mapOf("action" to "test")
                    )
                )
            )
        )
        
        val json = CardParser.serialize(originalCard)
        val parsedCard = CardParser.parse(json)
        
        assertEquals(1, parsedCard.body?.size)
        val button = parsedCard.body?.first() as CompoundButton
        assertEquals("btn1", button.id)
        assertEquals("Test Button", button.title)
        assertEquals("Test subtitle", button.subtitle)
        assertEquals("star.fill", button.icon)
        assertEquals("leading", button.iconPosition)
        assertEquals("emphasis", button.style)
        assertNotNull(button.action)
    }
}
