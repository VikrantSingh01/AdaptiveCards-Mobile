import XCTest
@testable import ACCore

final class AdvancedElementsParserTests: XCTestCase {
    var parser: CardParser!
    
    override func setUp() {
        super.setUp()
        parser = CardParser()
    }
    
    // MARK: - Carousel Tests
    
    func testParseCarousel() throws {
        let json = try loadTestCard(named: "carousel")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        XCTAssertEqual(card.body?.count, 2)
        
        if case .carousel(let carousel) = card.body?[1] {
            XCTAssertEqual(carousel.id, "photoCarousel")
            XCTAssertEqual(carousel.timer, 5000)
            XCTAssertEqual(carousel.initialPage, 0)
            XCTAssertEqual(carousel.pages.count, 3)
            
            let firstPage = carousel.pages[0]
            XCTAssertEqual(firstPage.items.count, 3)
        } else {
            XCTFail("Expected Carousel element")
        }
    }
    
    func testCarouselRoundTrip() throws {
        let carousel = Carousel(
            id: "test",
            pages: [
                CarouselPage(items: [
                    .textBlock(TextBlock(text: "Page 1"))
                ])
            ],
            timer: 3000,
            initialPage: 0
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(carousel)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Carousel.self, from: data)
        
        XCTAssertEqual(decoded.id, carousel.id)
        XCTAssertEqual(decoded.timer, carousel.timer)
        XCTAssertEqual(decoded.pages.count, carousel.pages.count)
    }
    
    // MARK: - Accordion Tests
    
    func testParseAccordion() throws {
        let json = try loadTestCard(named: "accordion")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        XCTAssertEqual(card.body?.count, 2)
        
        if case .accordion(let accordion) = card.body?[1] {
            XCTAssertEqual(accordion.id, "faqAccordion")
            XCTAssertEqual(accordion.expandMode, .single)
            XCTAssertEqual(accordion.panels.count, 4)
            
            let firstPanel = accordion.panels[0]
            XCTAssertEqual(firstPanel.title, "What is Adaptive Cards?")
            XCTAssertEqual(firstPanel.isExpanded, true)
            XCTAssertGreaterThan(firstPanel.content.count, 0)
        } else {
            XCTFail("Expected Accordion element")
        }
    }
    
    func testAccordionRoundTrip() throws {
        let accordion = Accordion(
            id: "test",
            panels: [
                AccordionPanel(
                    title: "Panel 1",
                    content: [.textBlock(TextBlock(text: "Content"))],
                    isExpanded: true
                )
            ],
            expandMode: .multiple
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(accordion)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Accordion.self, from: data)
        
        XCTAssertEqual(decoded.id, accordion.id)
        XCTAssertEqual(decoded.expandMode, accordion.expandMode)
        XCTAssertEqual(decoded.panels.count, accordion.panels.count)
    }
    
    // MARK: - CodeBlock Tests
    
    func testParseCodeBlock() throws {
        let json = try loadTestCard(named: "code-block")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        XCTAssertGreaterThan(card.body?.count ?? 0, 0)
        
        var codeBlockCount = 0
        for element in card.body ?? [] {
            if case .codeBlock(let codeBlock) = element {
                codeBlockCount += 1
                XCTAssertFalse(codeBlock.code.isEmpty)
            }
        }
        
        XCTAssertEqual(codeBlockCount, 3)
    }
    
    func testCodeBlockRoundTrip() throws {
        let codeBlock = CodeBlock(
            id: "test",
            code: "func hello() {\n    print(\"Hello\")\n}",
            language: "swift",
            startLineNumber: 1
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(codeBlock)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CodeBlock.self, from: data)
        
        XCTAssertEqual(decoded.id, codeBlock.id)
        XCTAssertEqual(decoded.code, codeBlock.code)
        XCTAssertEqual(decoded.language, codeBlock.language)
        XCTAssertEqual(decoded.startLineNumber, codeBlock.startLineNumber)
    }
    
    // MARK: - Rating Tests
    
    func testParseRatingDisplay() throws {
        let json = try loadTestCard(named: "rating")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        
        var ratingDisplayCount = 0
        var ratingInputCount = 0
        
        for element in card.body ?? [] {
            if case .ratingDisplay(let rating) = element {
                ratingDisplayCount += 1
                XCTAssertGreaterThan(rating.value, 0)
            } else if case .ratingInput(let input) = element {
                ratingInputCount += 1
                XCTAssertFalse(input.id.isEmpty)
            }
        }
        
        XCTAssertGreaterThan(ratingDisplayCount, 0)
        XCTAssertGreaterThan(ratingInputCount, 0)
    }
    
    func testRatingDisplayRoundTrip() throws {
        let rating = RatingDisplay(
            id: "test",
            value: 4.5,
            count: 100,
            max: 5,
            size: .medium
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(rating)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(RatingDisplay.self, from: data)
        
        XCTAssertEqual(decoded.id, rating.id)
        XCTAssertEqual(decoded.value, rating.value)
        XCTAssertEqual(decoded.count, rating.count)
        XCTAssertEqual(decoded.max, rating.max)
    }
    
    func testRatingInputRoundTrip() throws {
        let input = RatingInput(
            id: "ratingInput",
            max: 5,
            value: 0,
            label: "Rate this",
            isRequired: true
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(input)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(RatingInput.self, from: data)
        
        XCTAssertEqual(decoded.id, input.id)
        XCTAssertEqual(decoded.max, input.max)
        XCTAssertEqual(decoded.label, input.label)
        XCTAssertEqual(decoded.isRequired, input.isRequired)
    }
    
    // MARK: - Progress Indicators Tests
    
    func testParseProgressIndicators() throws {
        let json = try loadTestCard(named: "progress-indicators")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        
        var progressBarCount = 0
        var spinnerCount = 0
        
        func countElements(_ elements: [CardElement]) {
            for element in elements {
                switch element {
                case .progressBar:
                    progressBarCount += 1
                case .spinner:
                    spinnerCount += 1
                case .container(let container):
                    countElements(container.items)
                default:
                    break
                }
            }
        }
        
        countElements(card.body ?? [])
        
        XCTAssertGreaterThan(progressBarCount, 0)
        XCTAssertGreaterThan(spinnerCount, 0)
    }
    
    func testProgressBarRoundTrip() throws {
        let progressBar = ProgressBar(
            id: "test",
            value: 0.75,
            label: "Loading",
            color: "#0078D4"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(progressBar)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ProgressBar.self, from: data)
        
        XCTAssertEqual(decoded.id, progressBar.id)
        XCTAssertEqual(decoded.value, progressBar.value)
        XCTAssertEqual(decoded.label, progressBar.label)
        XCTAssertEqual(decoded.color, progressBar.color)
    }
    
    func testSpinnerRoundTrip() throws {
        let spinner = Spinner(
            id: "test",
            size: .large,
            label: "Please wait"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(spinner)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Spinner.self, from: data)
        
        XCTAssertEqual(decoded.id, spinner.id)
        XCTAssertEqual(decoded.size, spinner.size)
        XCTAssertEqual(decoded.label, spinner.label)
    }
    
    // MARK: - TabSet Tests
    
    func testParseTabSet() throws {
        let json = try loadTestCard(named: "tab-set")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        XCTAssertEqual(card.body?.count, 2)
        
        if case .tabSet(let tabSet) = card.body?[1] {
            XCTAssertEqual(tabSet.id, "projectTabs")
            XCTAssertEqual(tabSet.selectedTabId, "overview")
            XCTAssertEqual(tabSet.tabs.count, 4)
            
            let firstTab = tabSet.tabs[0]
            XCTAssertEqual(firstTab.id, "overview")
            XCTAssertEqual(firstTab.title, "Overview")
            XCTAssertGreaterThan(firstTab.items.count, 0)
        } else {
            XCTFail("Expected TabSet element")
        }
    }
    
    func testTabSetRoundTrip() throws {
        let tabSet = TabSet(
            id: "test",
            tabs: [
                Tab(
                    id: "tab1",
                    title: "Tab 1",
                    items: [.textBlock(TextBlock(text: "Content"))]
                )
            ],
            selectedTabId: "tab1"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(tabSet)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(TabSet.self, from: data)
        
        XCTAssertEqual(decoded.id, tabSet.id)
        XCTAssertEqual(decoded.selectedTabId, tabSet.selectedTabId)
        XCTAssertEqual(decoded.tabs.count, tabSet.tabs.count)
    }
    
    // MARK: - Advanced Combined Tests
    
    func testParseAdvancedCombined() throws {
        let json = try loadTestCard(named: "advanced-combined")
        let card = try parser.parse(json)
        
        XCTAssertNotNil(card.body)
        XCTAssertGreaterThan(card.body?.count ?? 0, 0)
        
        // Should contain TabSet with multiple tabs
        var hasTabSet = false
        for element in card.body ?? [] {
            if case .tabSet(let tabSet) = element {
                hasTabSet = true
                XCTAssertGreaterThan(tabSet.tabs.count, 0)
            }
        }
        
        XCTAssertTrue(hasTabSet)
    }
    
    // MARK: - Element Type String Tests
    
    func testElementTypeStrings() {
        let carousel = CardElement.carousel(Carousel(pages: []))
        XCTAssertEqual(carousel.typeString, "Carousel")
        
        let accordion = CardElement.accordion(Accordion(panels: []))
        XCTAssertEqual(accordion.typeString, "Accordion")
        
        let codeBlock = CardElement.codeBlock(CodeBlock(code: "test"))
        XCTAssertEqual(codeBlock.typeString, "CodeBlock")
        
        let rating = CardElement.ratingDisplay(RatingDisplay(value: 4.5))
        XCTAssertEqual(rating.typeString, "Rating")
        
        let ratingInput = CardElement.ratingInput(RatingInput(id: "test"))
        XCTAssertEqual(ratingInput.typeString, "Input.Rating")
        
        let progressBar = CardElement.progressBar(ProgressBar(value: 0.5))
        XCTAssertEqual(progressBar.typeString, "ProgressBar")
        
        let spinner = CardElement.spinner(Spinner())
        XCTAssertEqual(spinner.typeString, "Spinner")
        
        let tabSet = CardElement.tabSet(TabSet(tabs: []))
        XCTAssertEqual(tabSet.typeString, "TabSet")
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
