import XCTest
@testable import ACCore

final class AdvancedElementsParserTests: XCTestCase {
    var parser: CardParser!
    
    override func setUp() {
        super.setUp()
        parser = CardParser()
    }
    
    func testParseCarouselElement() throws {
        let json = """
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
        """
        
        let card = try parser.parse(json)
        
        XCTAssertEqual(card.body?.count, 1)
        
        if case .carousel(let carousel) = card.body?.first {
            XCTAssertEqual(carousel.id, "carousel1")
            XCTAssertEqual(carousel.timer, 5000)
            XCTAssertEqual(carousel.initialPage, 0)
            XCTAssertEqual(carousel.pages.count, 2)
            
            let firstPage = carousel.pages[0]
            XCTAssertEqual(firstPage.items.count, 1)
            
            if case .textBlock(let textBlock) = firstPage.items[0] {
                XCTAssertEqual(textBlock.text, "Page 1")
            } else {
                XCTFail("Expected TextBlock in first page")
            }
        } else {
            XCTFail("Expected Carousel element")
        }
    }
    
    func testParseCarouselFromFile() throws {
        let json = try loadTestCard(named: "carousel")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        
        if case .carousel(let carousel) = card.body?.last {
            XCTAssertEqual(carousel.id, "carousel1")
            XCTAssertEqual(carousel.timer, 5000)
            XCTAssertEqual(carousel.initialPage, 0)
            XCTAssertEqual(carousel.pages.count, 3)
        } else {
            XCTFail("Expected Carousel element")
        }
    }
    
    func testParseAccordionElement() throws {
        let json = """
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
        """
        
        let card = try parser.parse(json)
        
        XCTAssertEqual(card.body?.count, 1)
        
        if case .accordion(let accordion) = card.body?.first {
            XCTAssertEqual(accordion.id, "accordion1")
            XCTAssertEqual(accordion.expandMode, .single)
            XCTAssertEqual(accordion.panels.count, 2)
            
            let firstPanel = accordion.panels[0]
            XCTAssertEqual(firstPanel.title, "Panel 1")
            XCTAssertEqual(firstPanel.isExpanded, true)
            XCTAssertEqual(firstPanel.content.count, 1)
        } else {
            XCTFail("Expected Accordion element")
        }
    }
    
    func testParseAccordionFromFile() throws {
        let json = try loadTestCard(named: "accordion")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        
        if case .accordion(let accordion) = card.body?.last {
            XCTAssertEqual(accordion.id, "accordion1")
            XCTAssertEqual(accordion.expandMode, .single)
            XCTAssertEqual(accordion.panels.count, 3)
        } else {
            XCTFail("Expected Accordion element")
        }
    }
    
    func testParseCodeBlockElement() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "CodeBlock",
                    "id": "code1",
                    "code": "function hello() {\\n  console.log('Hello');\\n}",
                    "language": "javascript",
                    "startLineNumber": 1,
                    "wrap": false
                }
            ]
        }
        """
        
        let card = try parser.parse(json)
        
        XCTAssertEqual(card.body?.count, 1)
        
        if case .codeBlock(let codeBlock) = card.body?.first {
            XCTAssertEqual(codeBlock.id, "code1")
            XCTAssertEqual(codeBlock.language, "javascript")
            XCTAssertEqual(codeBlock.startLineNumber, 1)
            XCTAssertEqual(codeBlock.wrap, false)
            XCTAssertTrue(codeBlock.code.contains("function hello()"))
        } else {
            XCTFail("Expected CodeBlock element")
        }
    }
    
    func testParseCodeBlockFromFile() throws {
        let json = try loadTestCard(named: "code-block")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        
        var codeBlockCount = 0
        for element in card.body ?? [] {
            if case .codeBlock(let codeBlock) = element {
                codeBlockCount += 1
                XCTAssertNotNil(codeBlock.language)
                XCTAssertFalse(codeBlock.code.isEmpty)
            }
        }
        
        XCTAssertEqual(codeBlockCount, 3)
    }
    
    func testParseRatingDisplayElement() throws {
        let json = """
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
        """
        
        let card = try parser.parse(json)
        
        XCTAssertEqual(card.body?.count, 1)
        
        if case .ratingDisplay(let rating) = card.body?.first {
            XCTAssertEqual(rating.id, "rating1")
            XCTAssertEqual(rating.value, 4.5)
            XCTAssertEqual(rating.max, 5)
            XCTAssertEqual(rating.count, 127)
            XCTAssertEqual(rating.size, .medium)
        } else {
            XCTFail("Expected RatingDisplay element")
        }
    }
    
    func testParseRatingInputElement() throws {
        let json = """
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
        """
        
        let card = try parser.parse(json)
        
        XCTAssertEqual(card.body?.count, 1)
        
        if case .ratingInput(let ratingInput) = card.body?.first {
            XCTAssertEqual(ratingInput.id, "ratingInput1")
            XCTAssertEqual(ratingInput.label, "Rate this product")
            XCTAssertEqual(ratingInput.max, 5)
            XCTAssertEqual(ratingInput.value, 0.0)
            XCTAssertEqual(ratingInput.isRequired, true)
            XCTAssertEqual(ratingInput.errorMessage, "Please provide a rating")
        } else {
            XCTFail("Expected RatingInput element")
        }
    }
    
    func testParseRatingFromFile() throws {
        let json = try loadTestCard(named: "rating")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        
        var ratingDisplayCount = 0
        var ratingInputCount = 0
        
        for element in card.body ?? [] {
            if case .ratingDisplay = element {
                ratingDisplayCount += 1
            } else if case .ratingInput = element {
                ratingInputCount += 1
            }
        }
        
        XCTAssertEqual(ratingDisplayCount, 3)
        XCTAssertEqual(ratingInputCount, 2)
    }
    
    func testParseProgressBarElement() throws {
        let json = """
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
        """
        
        let card = try parser.parse(json)
        
        XCTAssertEqual(card.body?.count, 1)
        
        if case .progressBar(let progressBar) = card.body?.first {
            XCTAssertEqual(progressBar.id, "progress1")
            XCTAssertEqual(progressBar.label, "Download Progress")
            XCTAssertEqual(progressBar.value, 0.75)
            XCTAssertEqual(progressBar.color, "#0078D4")
        } else {
            XCTFail("Expected ProgressBar element")
        }
    }
    
    func testParseSpinnerElement() throws {
        let json = """
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
        """
        
        let card = try parser.parse(json)
        
        XCTAssertEqual(card.body?.count, 1)
        
        if case .spinner(let spinner) = card.body?.first {
            XCTAssertEqual(spinner.id, "spinner1")
            XCTAssertEqual(spinner.size, .medium)
            XCTAssertEqual(spinner.label, "Loading...")
        } else {
            XCTFail("Expected Spinner element")
        }
    }
    
    func testParseProgressIndicatorsFromFile() throws {
        let json = try loadTestCard(named: "progress-indicators")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        
        var progressBarCount = 0
        var spinnerCount = 0
        
        for element in card.body ?? [] {
            if case .progressBar = element {
                progressBarCount += 1
            } else if case .spinner = element {
                spinnerCount += 1
            }
        }
        
        XCTAssertEqual(progressBarCount, 3)
        XCTAssertGreaterThanOrEqual(spinnerCount, 1)
    }
    
    func testParseTabSetElement() throws {
        let json = """
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
        """
        
        let card = try parser.parse(json)
        
        XCTAssertEqual(card.body?.count, 1)
        
        if case .tabSet(let tabSet) = card.body?.first {
            XCTAssertEqual(tabSet.id, "tabSet1")
            XCTAssertEqual(tabSet.selectedTabId, "tab1")
            XCTAssertEqual(tabSet.tabs.count, 2)
            
            let firstTab = tabSet.tabs[0]
            XCTAssertEqual(firstTab.id, "tab1")
            XCTAssertEqual(firstTab.title, "Tab 1")
            XCTAssertEqual(firstTab.icon, "📋")
            XCTAssertEqual(firstTab.items.count, 1)
        } else {
            XCTFail("Expected TabSet element")
        }
    }
    
    func testParseTabSetFromFile() throws {
        let json = try loadTestCard(named: "tab-set")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        
        if case .tabSet(let tabSet) = card.body?.last {
            XCTAssertEqual(tabSet.id, "tabSet1")
            XCTAssertEqual(tabSet.selectedTabId, "tab1")
            XCTAssertEqual(tabSet.tabs.count, 4)
        } else {
            XCTFail("Expected TabSet element")
        }
    }
    
    func testSerializeAndDeserializeCarousel() throws {
        let originalCard = AdaptiveCard(
            version: "1.6",
            body: [
                .carousel(Carousel(
                    id: "carousel1",
                    timer: 3000,
                    initialPage: 0,
                    pages: [
                        CarouselPage(items: [
                            .textBlock(TextBlock(text: "Page 1"))
                        ]),
                        CarouselPage(items: [
                            .textBlock(TextBlock(text: "Page 2"))
                        ])
                    ]
                ))
            ]
        )
        
        let json = try parser.encode(originalCard)
        let parsedCard = try parser.parse(json)
        
        XCTAssertEqual(parsedCard.body?.count, 1)
        
        if case .carousel(let carousel) = parsedCard.body?.first {
            XCTAssertEqual(carousel.id, "carousel1")
            XCTAssertEqual(carousel.timer, 3000)
            XCTAssertEqual(carousel.pages.count, 2)
        } else {
            XCTFail("Expected Carousel element")
        }
    }
    
    func testSerializeAndDeserializeTabSet() throws {
        let originalCard = AdaptiveCard(
            version: "1.6",
            body: [
                .tabSet(TabSet(
                    id: "tabs1",
                    selectedTabId: "tab1",
                    tabs: [
                        Tab(
                            id: "tab1",
                            title: "Overview",
                            icon: "📋",
                            items: [
                                .textBlock(TextBlock(text: "Overview content"))
                            ]
                        )
                    ]
                ))
            ]
        )
        
        let json = try parser.encode(originalCard)
        let parsedCard = try parser.parse(json)
        
        XCTAssertEqual(parsedCard.body?.count, 1)
        
        if case .tabSet(let tabSet) = parsedCard.body?.first {
            XCTAssertEqual(tabSet.id, "tabs1")
            XCTAssertEqual(tabSet.selectedTabId, "tab1")
            XCTAssertEqual(tabSet.tabs.count, 1)
        } else {
            XCTFail("Expected TabSet element")
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadTestCard(named name: String) throws -> String {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Resources") else {
            throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test card not found: \(name)"])
        }
        
        let data = try Data(contentsOf: url)
        guard let json = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "TestError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to string"])
        }
        
        return json
    }
}
