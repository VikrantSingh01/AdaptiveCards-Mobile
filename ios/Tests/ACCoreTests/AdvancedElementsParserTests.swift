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

    // MARK: - CarouselPage Identifiable Tests

    func testCarouselPageIdentifiable() throws {
        // Test that CarouselPage conforms to Identifiable
        let page1 = CarouselPage(items: [
            .textBlock(TextBlock(id: "tb1", text: "Page 1"))
        ])

        let page2 = CarouselPage(items: [
            .textBlock(TextBlock(id: "tb2", text: "Page 2"))
        ])

        // IDs should be different when inner elements have different IDs
        XCTAssertNotEqual(page1.id, page2.id)
    }

    func testCarouselPageIdentifiableStability() throws {
        // Test that ID is stable for same structure
        let page1 = CarouselPage(items: [
            .textBlock(TextBlock(id: "tb1", text: "Test"))
        ])

        let page2 = CarouselPage(items: [
            .textBlock(TextBlock(id: "tb1", text: "Test"))
        ])

        // Same structure should produce same ID
        XCTAssertEqual(page1.id, page2.id)
    }

    func testCarouselPageIdentifiableWithEmptyItems() throws {
        // Test edge case: empty items array
        let emptyPage = CarouselPage(items: [])

        // Should have a valid ID even with empty items
        XCTAssertEqual(emptyPage.id, "page_empty")
        XCTAssertFalse(emptyPage.id.isEmpty)
    }

    func testCarouselPageIdentifiableWithSelectAction() throws {
        // Test that selectAction affects ID
        let pageWithAction = CarouselPage(
            items: [.textBlock(TextBlock(text: "Test"))],
            selectAction: .openUrl(OpenUrlAction(url: "https://example.com"))
        )

        let pageWithoutAction = CarouselPage(
            items: [.textBlock(TextBlock(text: "Test"))]
        )

        // IDs should differ when selectAction is present
        XCTAssertNotEqual(pageWithAction.id, pageWithoutAction.id)
        XCTAssertTrue(pageWithAction.id.contains("with_action"))
    }

    func testCarouselPageIdentifiableUniqueInArray() throws {
        // Test that multiple pages can be distinguished in a collection when they have different element IDs
        let pages = [
            CarouselPage(items: [.textBlock(TextBlock(id: "p1", text: "Page 1"))]),
            CarouselPage(items: [.textBlock(TextBlock(id: "p2", text: "Page 2"))]),
            CarouselPage(items: [.textBlock(TextBlock(id: "p3", text: "Page 3"))])
        ]

        // All IDs should be unique
        let ids = pages.map { $0.id }
        let uniqueIds = Set(ids)
        XCTAssertEqual(ids.count, uniqueIds.count, "All page IDs should be unique")
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
                    countElements(container.items ?? [])
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

    // MARK: - Edge Case Tests

    func testCarouselWithEmptyPages() throws {
        let carousel = Carousel(pages: [])

        let encoder = JSONEncoder()
        let data = try encoder.encode(carousel)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Carousel.self, from: data)

        XCTAssertEqual(decoded.pages.count, 0)
    }

    func testCarouselWithoutTimer() throws {
        let carousel = Carousel(
            pages: [
                CarouselPage(items: [.textBlock(TextBlock(text: "Test"))])
            ],
            timer: nil
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(carousel)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Carousel.self, from: data)

        XCTAssertNil(decoded.timer)
    }

    func testAccordionMultipleExpandMode() throws {
        let accordion = Accordion(
            panels: [
                AccordionPanel(title: "Panel 1", content: [], isExpanded: true),
                AccordionPanel(title: "Panel 2", content: [], isExpanded: true)
            ],
            expandMode: .multiple
        )

        XCTAssertEqual(accordion.expandMode, .multiple)
        XCTAssertTrue(accordion.panels[0].isExpanded ?? false)
        XCTAssertTrue(accordion.panels[1].isExpanded ?? false)
    }

    func testRatingDisplayBoundaryValues() throws {
        // Test minimum rating
        let minRating = RatingDisplay(value: 0.0, max: 5)
        XCTAssertEqual(minRating.value, 0.0)

        // Test maximum rating
        let maxRating = RatingDisplay(value: 5.0, max: 5)
        XCTAssertEqual(maxRating.value, 5.0)

        // Test half-star value
        let halfRating = RatingDisplay(value: 3.5, max: 5)
        XCTAssertEqual(halfRating.value, 3.5)
    }

    func testRatingInputDefaultValues() throws {
        let input = RatingInput(id: "test")

        XCTAssertNil(input.max)
        XCTAssertNil(input.value)
        XCTAssertNil(input.label)
        XCTAssertNil(input.isRequired)
    }

    func testProgressBarValueClamping() throws {
        // Test values within range
        let normalProgress = ProgressBar(value: 0.5)
        XCTAssertEqual(normalProgress.value, 0.5)

        // Test minimum value
        let minProgress = ProgressBar(value: 0.0)
        XCTAssertEqual(minProgress.value, 0.0)

        // Test maximum value
        let maxProgress = ProgressBar(value: 1.0)
        XCTAssertEqual(maxProgress.value, 1.0)
    }

    func testSpinnerDefaultSize() throws {
        let spinner = Spinner()
        XCTAssertNil(spinner.size)
    }

    func testCodeBlockMultilineContent() throws {
        let multilineCode = "func test() {\n    print(\"line 1\")\n    print(\"line 2\")\n}"
        let codeBlock = CodeBlock(code: multilineCode)

        XCTAssertEqual(codeBlock.code, multilineCode)
        XCTAssertTrue(codeBlock.code.contains("\n"))
    }

    func testTabSetWithoutSelectedTab() throws {
        let tabSet = TabSet(
            tabs: [
                Tab(id: "tab1", title: "Tab 1", items: [])
            ],
            selectedTabId: nil
        )

        XCTAssertNil(tabSet.selectedTabId)
    }

    func testTabWithoutIcon() throws {
        let tab = Tab(id: "test", title: "Test Tab", icon: nil, items: [])
        XCTAssertNil(tab.icon)
    }

    // MARK: - Visibility Tests

    func testAdvancedElementsVisibility() throws {
        let carousel = CardElement.carousel(Carousel(pages: []))
        XCTAssertTrue(carousel.isVisible)

        let accordion = CardElement.accordion(Accordion(panels: []))
        XCTAssertTrue(accordion.isVisible)

        let codeBlock = CardElement.codeBlock(CodeBlock(code: "test"))
        XCTAssertTrue(codeBlock.isVisible)

        let rating = CardElement.ratingDisplay(RatingDisplay(value: 4.5))
        XCTAssertTrue(rating.isVisible)

        let progressBar = CardElement.progressBar(ProgressBar(value: 0.5))
        XCTAssertTrue(progressBar.isVisible)

        let spinner = CardElement.spinner(Spinner())
        XCTAssertTrue(spinner.isVisible)

        let tabSet = CardElement.tabSet(TabSet(tabs: []))
        XCTAssertTrue(tabSet.isVisible)
    }

    func testAdvancedElementsWithIsVisibleFalse() throws {
        let carousel = Carousel(pages: [], isVisible: false)
        let carouselElement = CardElement.carousel(carousel)
        XCTAssertFalse(carouselElement.isVisible)

        let accordion = Accordion(panels: [], isVisible: false)
        let accordionElement = CardElement.accordion(accordion)
        XCTAssertFalse(accordionElement.isVisible)
    }

    // MARK: - ID Tests

    func testAdvancedElementsWithIds() throws {
        let carousel = CardElement.carousel(Carousel(id: "carousel1", pages: []))
        XCTAssertEqual(carousel.id, "carousel1")

        let accordion = CardElement.accordion(Accordion(id: "accordion1", panels: []))
        XCTAssertEqual(accordion.id, "accordion1")

        let codeBlock = CardElement.codeBlock(CodeBlock(id: "code1", code: "test"))
        XCTAssertEqual(codeBlock.id, "code1")

        let rating = CardElement.ratingDisplay(RatingDisplay(id: "rating1", value: 4.5))
        XCTAssertEqual(rating.id, "rating1")

        let progressBar = CardElement.progressBar(ProgressBar(id: "progress1", value: 0.5))
        XCTAssertEqual(progressBar.id, "progress1")

        let spinner = CardElement.spinner(Spinner(id: "spinner1"))
        XCTAssertEqual(spinner.id, "spinner1")

        let tabSet = CardElement.tabSet(TabSet(id: "tabs1", tabs: []))
        XCTAssertEqual(tabSet.id, "tabs1")
    }

    func testAdvancedElementsWithoutIds() throws {
        let carousel = CardElement.carousel(Carousel(pages: []))
        XCTAssertNil(carousel.elementId)

        let accordion = CardElement.accordion(Accordion(panels: []))
        XCTAssertNil(accordion.elementId)

        let codeBlock = CardElement.codeBlock(CodeBlock(code: "test"))
        XCTAssertNil(codeBlock.elementId)
    }

    // MARK: - List Tests

    func testParseList() throws {
        let json = try loadTestCard(named: "list")
        let card = try parser.parse(json)

        XCTAssertNotNil(card.body)

        // Find the basic list
        let basicList = card.body?.first { element in
            if case .list(let list) = element {
                return list.id == "basicList"
            }
            return false
        }

        XCTAssertNotNil(basicList)

        if case .list(let list) = basicList {
            XCTAssertEqual(list.id, "basicList")
            XCTAssertEqual(list.style, "default")
            XCTAssertEqual(list.items.count, 3)
        } else {
            XCTFail("Expected List element")
        }
    }

    func testParseListWithMaxHeight() throws {
        let json = try loadTestCard(named: "list")
        let card = try parser.parse(json)

        // Find the scrollable list
        let scrollableList = card.body?.first { element in
            if case .list(let list) = element {
                return list.id == "scrollableList"
            }
            return false
        }

        if case .list(let list) = scrollableList {
            XCTAssertEqual(list.maxHeight, "150px")
            XCTAssertEqual(list.style, "numbered")
            XCTAssertEqual(list.items.count, 7)
        } else {
            XCTFail("Expected List element with maxHeight")
        }
    }

    func testListRoundTrip() throws {
        let list = ListElement(
            id: "testList",
            items: [
                .textBlock(TextBlock(text: "Item 1")),
                .textBlock(TextBlock(text: "Item 2"))
            ],
            maxHeight: "200px",
            style: "bulleted"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(list)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ListElement.self, from: data)

        XCTAssertEqual(decoded.id, list.id)
        XCTAssertEqual(decoded.maxHeight, list.maxHeight)
        XCTAssertEqual(decoded.style, list.style)
        XCTAssertEqual(decoded.items.count, list.items.count)
    }

    func testListEmptyItems() throws {
        let list = ListElement(
            id: "emptyList",
            items: []
        )

        XCTAssertEqual(list.items.count, 0)
        XCTAssertNil(list.maxHeight)
        XCTAssertNil(list.style)
    }

    // MARK: - CompoundButton Tests

    func testParseCompoundButton() throws {
        let json = try loadTestCard(named: "compound-buttons")
        let card = try parser.parse(json)

        XCTAssertNotNil(card.body)

        // Find the default style button
        let defaultButton = card.body?.first { element in
            if case .compoundButton(let button) = element {
                return button.id == "btn_default"
            }
            return false
        }

        XCTAssertNotNil(defaultButton)

        if case .compoundButton(let button) = defaultButton {
            XCTAssertEqual(button.id, "btn_default")
            XCTAssertEqual(button.title, "Default Style Button")
            XCTAssertEqual(button.subtitle, "Leading icon with default styling")
            XCTAssertEqual(button.icon, "checkmark.circle.fill")
            XCTAssertEqual(button.iconPosition, "leading")
            XCTAssertNotNil(button.action)
        } else {
            XCTFail("Expected CompoundButton element")
        }
    }

    func testParseCompoundButtonEmphasis() throws {
        let json = try loadTestCard(named: "compound-buttons")
        let card = try parser.parse(json)

        // Find the emphasis style button
        let emphasisButton = card.body?.first { element in
            if case .compoundButton(let button) = element {
                return button.id == "btn_emphasis"
            }
            return false
        }

        if case .compoundButton(let button) = emphasisButton {
            XCTAssertEqual(button.style, "emphasis")
            XCTAssertNotNil(button.action)
        } else {
            XCTFail("Expected CompoundButton with emphasis style")
        }
    }

    func testParseCompoundButtonPositive() throws {
        let json = try loadTestCard(named: "compound-buttons")
        let card = try parser.parse(json)

        // Find the positive style button
        let positiveButton = card.body?.first { element in
            if case .compoundButton(let button) = element {
                return button.id == "btn_positive"
            }
            return false
        }

        if case .compoundButton(let button) = positiveButton {
            XCTAssertEqual(button.style, "positive")
            XCTAssertEqual(button.title, "Approve Request")
            XCTAssertNotNil(button.action)
        } else {
            XCTFail("Expected CompoundButton with positive style")
        }
    }

    func testParseCompoundButtonDestructive() throws {
        let json = try loadTestCard(named: "compound-buttons")
        let card = try parser.parse(json)

        // Find the destructive style button
        let destructiveButton = card.body?.first { element in
            if case .compoundButton(let button) = element {
                return button.id == "btn_destructive"
            }
            return false
        }

        if case .compoundButton(let button) = destructiveButton {
            XCTAssertEqual(button.style, "destructive")
            XCTAssertEqual(button.title, "Delete Item")
            XCTAssertNotNil(button.action)
        } else {
            XCTFail("Expected CompoundButton with destructive style")
        }
    }

    func testParseCompoundButtonTrailingIcon() throws {
        let json = try loadTestCard(named: "compound-buttons")
        let card = try parser.parse(json)

        // Find the trailing icon button
        let trailingButton = card.body?.first { element in
            if case .compoundButton(let button) = element {
                return button.id == "btn_trailing_icon"
            }
            return false
        }

        if case .compoundButton(let button) = trailingButton {
            XCTAssertEqual(button.iconPosition, "trailing")
            XCTAssertNotNil(button.icon)
        } else {
            XCTFail("Expected CompoundButton with trailing icon")
        }
    }

    func testParseCompoundButtonNoIcon() throws {
        let json = try loadTestCard(named: "compound-buttons")
        let card = try parser.parse(json)

        // Find the no-icon button
        let noIconButton = card.body?.first { element in
            if case .compoundButton(let button) = element {
                return button.id == "btn_no_icon"
            }
            return false
        }

        if case .compoundButton(let button) = noIconButton {
            XCTAssertNil(button.icon)
            XCTAssertNotNil(button.subtitle)
        } else {
            XCTFail("Expected CompoundButton without icon")
        }
    }

    func testParseCompoundButtonNoSubtitle() throws {
        let json = try loadTestCard(named: "compound-buttons")
        let card = try parser.parse(json)

        // Find the no-subtitle button
        let noSubtitleButton = card.body?.first { element in
            if case .compoundButton(let button) = element {
                return button.id == "btn_no_subtitle"
            }
            return false
        }

        if case .compoundButton(let button) = noSubtitleButton {
            XCTAssertNil(button.subtitle)
            XCTAssertNotNil(button.icon)
            XCTAssertNotNil(button.action)
        } else {
            XCTFail("Expected CompoundButton without subtitle")
        }
    }

    func testParseCompoundButtonNoAction() throws {
        let json = try loadTestCard(named: "compound-buttons")
        let card = try parser.parse(json)

        // Find the disabled button (no action)
        let disabledButton = card.body?.first { element in
            if case .compoundButton(let button) = element {
                return button.id == "btn_disabled"
            }
            return false
        }

        if case .compoundButton(let button) = disabledButton {
            XCTAssertNil(button.action)
        } else {
            XCTFail("Expected CompoundButton without action")
        }
    }

    func testCompoundButtonRoundTrip() throws {
        let button = CompoundButton(
            id: "testButton",
            title: "Test Button",
            subtitle: "Test subtitle",
            icon: "star.fill",
            iconPosition: "leading",
            action: CardAction.submit(SubmitAction(title: "Submit")),
            style: "emphasis"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(button)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CompoundButton.self, from: data)

        XCTAssertEqual(decoded.id, button.id)
        XCTAssertEqual(decoded.title, button.title)
        XCTAssertEqual(decoded.subtitle, button.subtitle)
        XCTAssertEqual(decoded.icon, button.icon)
        XCTAssertEqual(decoded.iconPosition, button.iconPosition)
        XCTAssertEqual(decoded.style, button.style)
    }

    func testCompoundButtonTypeString() {
        let button = CardElement.compoundButton(CompoundButton(title: "Test"))
        XCTAssertEqual(button.typeString, "CompoundButton")
    }

    func testCompoundButtonVisibility() {
        let button = CardElement.compoundButton(CompoundButton(title: "Test"))
        XCTAssertTrue(button.isVisible)

        let hiddenButton = CompoundButton(title: "Test", isVisible: false)
        let hiddenElement = CardElement.compoundButton(hiddenButton)
        XCTAssertFalse(hiddenElement.isVisible)
    }

    func testCompoundButtonId() {
        let button = CardElement.compoundButton(CompoundButton(id: "test123", title: "Test"))
        XCTAssertEqual(button.id, "test123")

        let noIdButton = CardElement.compoundButton(CompoundButton(title: "Test"))
        XCTAssertNil(noIdButton.elementId)
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
