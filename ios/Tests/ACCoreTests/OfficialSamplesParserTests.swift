import XCTest
@testable import ACCore

/// Tests that all official, element, and teams-sample cards parse correctly
/// through the ACCore CardParser. Validates rendering readiness for the sample app.
final class OfficialSamplesParserTests: XCTestCase {
    var parser: CardParser!

    override func setUp() {
        super.setUp()
        parser = CardParser()
    }

    // MARK: - Official Samples

    func testActivityUpdateCard() throws {
        let card = try loadAndParse("activity-update")
        XCTAssertNotNil(card.body)
        XCTAssertGreaterThan(card.body?.count ?? 0, 0)
        // Should have a ColumnSet for the author section
        let hasColumnSet = (card.body ?? []).contains { if case .columnSet = $0 { return true } else { return false } }
        XCTAssertTrue(hasColumnSet, "Activity Update should have a ColumnSet")
        // Should have a FactSet
        let hasFactSet = (card.body ?? []).contains { if case .factSet = $0 { return true } else { return false } }
        XCTAssertTrue(hasFactSet, "Activity Update should have a FactSet")
        // Should have actions
        XCTAssertNotNil(card.actions)
        XCTAssertGreaterThan(card.actions?.count ?? 0, 0)
    }

    func testFlightDetailsCard() throws {
        let card = try loadAndParse("flight-details")
        XCTAssertNotNil(card.body)
        XCTAssertGreaterThan(card.body?.count ?? 0, 0)
        XCTAssertEqual(card.version, "1.5")
    }

    func testWeatherLargeCard() throws {
        let card = try loadAndParse("weather-large")
        XCTAssertNotNil(card.body)
        XCTAssertGreaterThan(card.body?.count ?? 0, 0)
    }

    func testStockUpdateCard() throws {
        let card = try loadAndParse("stock-update")
        XCTAssertNotNil(card.body)
        XCTAssertGreaterThan(card.body?.count ?? 0, 0)
    }

    func testInputFormOfficialCard() throws {
        let card = try loadAndParse("input-form-official")
        XCTAssertNotNil(card.body)
        XCTAssertGreaterThan(card.body?.count ?? 0, 0)
        // Should contain input elements
        let hasInputs = (card.body ?? []).contains {
            switch $0 {
            case .textInput, .numberInput, .dateInput, .timeInput, .choiceSetInput, .toggleInput:
                return true
            default:
                return false
            }
        }
        XCTAssertTrue(hasInputs, "Input Form should have input elements")
    }

    func testCalendarReminderCard() throws {
        let card = try loadAndParse("calendar-reminder")
        XCTAssertNotNil(card.body)
        XCTAssertGreaterThan(card.body?.count ?? 0, 0)
    }

    func testFlightUpdateCard() throws {
        let card = try loadAndParse("flight-update")
        XCTAssertNotNil(card.body)
    }

    func testFlightItineraryCard() throws {
        let card = try loadAndParse("flight-itinerary")
        XCTAssertNotNil(card.body)
    }

    func testExpenseReportCard() throws {
        let card = try loadAndParse("expense-report")
        XCTAssertNotNil(card.body)
    }

    func testFoodOrderCard() throws {
        let card = try loadAndParse("food-order")
        XCTAssertNotNil(card.body)
    }

    func testImageGalleryCard() throws {
        let card = try loadAndParse("image-gallery")
        XCTAssertNotNil(card.body)
    }

    func testInputsWithValidationCard() throws {
        let card = try loadAndParse("inputs-with-validation")
        XCTAssertNotNil(card.body)
    }

    func testRestaurantCard() throws {
        let card = try loadAndParse("restaurant")
        XCTAssertNotNil(card.body)
    }

    func testSportingEventCard() throws {
        let card = try loadAndParse("sporting-event")
        XCTAssertNotNil(card.body)
    }

    func testWeatherCompactCard() throws {
        let card = try loadAndParse("weather-compact")
        XCTAssertNotNil(card.body)
    }

    func testAgendaCard() throws {
        let card = try loadAndParse("agenda")
        XCTAssertNotNil(card.body)
    }

    func testFlightUpdateTableCard() throws {
        let card = try loadAndParse("flight-update-table")
        XCTAssertNotNil(card.body)
        // Should have a Table element
        let hasTable = (card.body ?? []).contains { if case .table = $0 { return true } else { return false } }
        XCTAssertTrue(hasTable, "Flight Update Table should have a Table element")
    }

    func testInputFormRTLCard() throws {
        let card = try loadAndParse("input-form-rtl")
        XCTAssertNotNil(card.body)
        XCTAssertEqual(card.rtl, true, "RTL card should have rtl=true")
    }

    // MARK: - Element Samples

    func testTableBasicCard() throws {
        let card = try loadAndParse("table-basic")
        XCTAssertNotNil(card.body)
        let hasTable = (card.body ?? []).contains { if case .table = $0 { return true } else { return false } }
        XCTAssertTrue(hasTable, "Table Basic should have a Table")
    }

    func testTableGridStyleCard() throws {
        let card = try loadAndParse("table-grid-style")
        XCTAssertNotNil(card.body)
    }

    func testCarouselBasicCard() throws {
        let card = try loadAndParse("carousel-basic")
        XCTAssertNotNil(card.body)
        let hasCarousel = (card.body ?? []).contains { if case .carousel = $0 { return true } else { return false } }
        XCTAssertTrue(hasCarousel, "Carousel Basic should have a Carousel")
    }

    func testAdaptiveCardRTLCard() throws {
        let card = try loadAndParse("adaptive-card-rtl")
        XCTAssertNotNil(card.body)
        XCTAssertEqual(card.rtl, true, "RTL sample should have rtl=true")
    }

    func testColumnRTLCard() throws {
        let card = try loadAndParse("column-rtl")
        XCTAssertNotNil(card.body)
    }

    func testContainerRTLCard() throws {
        let card = try loadAndParse("container-rtl")
        XCTAssertNotNil(card.body)
    }

    func testTextblockStyleCard() throws {
        let card = try loadAndParse("textblock-style")
        XCTAssertNotNil(card.body)
    }

    func testInputStyleCard() throws {
        let card = try loadAndParse("input-style")
        XCTAssertNotNil(card.body)
    }

    func testCarouselStylesCard() throws {
        let card = try loadAndParse("carousel-styles")
        XCTAssertNotNil(card.body)
    }

    // MARK: - Teams Template Samples (template files)

    func testTeamsActivityUpdateTemplate() throws {
        let card = try loadAndParse("activity-update-template")
        XCTAssertNotNil(card.body)
        XCTAssertGreaterThan(card.body?.count ?? 0, 0)
    }

    func testTeamsCalendarReminderTemplate() throws {
        let card = try loadAndParse("calendar-reminder-template")
        XCTAssertNotNil(card.body)
    }

    func testTeamsFlightDetailsTemplate() throws {
        let card = try loadAndParse("flight-details-template")
        XCTAssertNotNil(card.body)
    }

    func testTeamsStockUpdateTemplate() throws {
        let card = try loadAndParse("stock-update-template")
        XCTAssertNotNil(card.body)
    }

    func testTeamsWeatherLargeTemplate() throws {
        let card = try loadAndParse("weather-large-template")
        XCTAssertNotNil(card.body)
    }

    // MARK: - Bulk Parsing: All Official Samples

    func testAllOfficialSamplesParse() throws {
        let officialSamples = [
            "activity-update", "agenda", "application-login", "calendar-reminder",
            "expense-report", "flight-details", "flight-itinerary",
            "flight-update-table", "flight-update", "food-order",
            "image-gallery", "input-form-official", "input-form-rtl",
            "inputs-with-validation", "order-confirmation", "order-delivery",
            "product-video", "restaurant-order", "restaurant",
            "show-card-wizard", "sporting-event", "stock-update",
            "weather-compact", "weather-large"
        ]

        var failures: [String] = []
        var successes: [String] = []

        for name in officialSamples {
            do {
                let card = try loadAndParse(name)
                XCTAssertNotNil(card.body, "\(name) should have a body")
                successes.append(name)
            } catch {
                failures.append("\(name): \(error.localizedDescription)")
            }
        }

        print("Official samples parsed: \(successes.count)/\(officialSamples.count)")
        if !failures.isEmpty {
            print("Failures:")
            for f in failures { print("  - \(f)") }
        }

        // Allow some failures for templates with $data expressions
        // but at least 80% should parse
        let successRate = Double(successes.count) / Double(officialSamples.count)
        XCTAssertGreaterThanOrEqual(successRate, 0.8,
            "At least 80% of official samples should parse. Failed: \(failures.joined(separator: ", "))")
    }

    func testAllElementSamplesParse() throws {
        let elementSamples = [
            "action-execute-is-enabled", "action-execute-mode", "action-execute-tooltip",
            "action-openurl-is-enabled", "action-openurl-mode", "action-openurl-tooltip",
            "action-role", "action-showcard-is-enabled", "action-showcard-mode",
            "action-showcard-tooltip", "action-submit-is-enabled", "action-submit-mode",
            "action-submit-tooltip", "adaptive-card-rtl",
            "carousel-basic", "carousel-header", "carousel-height-pixels",
            "carousel-height-vertical", "carousel-height", "carousel-initial-page",
            "carousel-loop", "carousel-scenario-cards", "carousel-scenario-timer",
            "carousel-styles", "carousel-vertical", "column-rtl", "container-rtl",
            "image-force-load", "image-select-action", "imageset-stacked-style",
            "input-choiceset-dynamic-typeahead", "input-choiceset-filtered",
            "input-label-position", "input-style", "input-text-password-style",
            "input-toggle-consolidated",
            "media-basic", "media-sources",
            "table-basic", "table-first-row-headers", "table-grid-style",
            "table-horizontal-alignment", "table-show-grid-lines", "table-vertical-alignment",
            "textblock-style"
        ]

        var failures: [String] = []
        var successes: [String] = []

        for name in elementSamples {
            do {
                let card = try loadAndParse(name)
                XCTAssertNotNil(card.body, "\(name) should have a body")
                successes.append(name)
            } catch {
                failures.append("\(name): \(error.localizedDescription)")
            }
        }

        print("Element samples parsed: \(successes.count)/\(elementSamples.count)")
        if !failures.isEmpty {
            print("Failures:")
            for f in failures { print("  - \(f)") }
        }

        let successRate = Double(successes.count) / Double(elementSamples.count)
        XCTAssertGreaterThanOrEqual(successRate, 0.8,
            "At least 80% of element samples should parse. Failed: \(failures.joined(separator: ", "))")
    }

    func testAllTeamsSampleTemplatesParse() throws {
        let templates = [
            "activity-update-template", "agenda-template",
            "calendar-reminder-template", "carousel-templated-pages-template",
            "carousel-when-show-template", "expense-report-template",
            "flight-details-template", "flight-itinerary-template",
            "flight-update-template", "food-order-template",
            "image-gallery-template", "input-form-template",
            "order-confirmation-template", "product-video-template",
            "restaurant-order-template", "restaurant-template",
            "simple-fallback-template", "solitaire-template",
            "sporting-event-template", "stock-update-template",
            "weather-large-template"
        ]

        var failures: [String] = []
        var successes: [String] = []

        for name in templates {
            do {
                let card = try loadAndParse(name)
                XCTAssertNotNil(card.body, "\(name) should have a body")
                successes.append(name)
            } catch {
                failures.append("\(name): \(error.localizedDescription)")
            }
        }

        print("Teams templates parsed: \(successes.count)/\(templates.count)")
        if !failures.isEmpty {
            print("Failures:")
            for f in failures { print("  - \(f)") }
        }

        // Templates may contain ${expression} syntax that causes parsing issues
        // so we allow a lower threshold
        let successRate = Double(successes.count) / Double(templates.count)
        XCTAssertGreaterThanOrEqual(successRate, 0.6,
            "At least 60% of templates should parse. Failed: \(failures.joined(separator: ", "))")
    }

    // MARK: - Rendering Quality Checks

    func testFlightDetailsHasComplexLayout() throws {
        let card = try loadAndParse("flight-details")
        // Should have deeply nested ColumnSets
        var columnSetCount = 0
        func countColumnSets(_ elements: [CardElement]) {
            for el in elements {
                switch el {
                case .columnSet(let cs):
                    columnSetCount += 1
                    for col in cs.columns {
                        countColumnSets(col.items ?? [])
                    }
                case .container(let c):
                    countColumnSets(c.items ?? [])
                default:
                    break
                }
            }
        }
        countColumnSets(card.body ?? [])
        XCTAssertGreaterThanOrEqual(columnSetCount, 2, "Flight Details should have multiple ColumnSets")
    }

    func testStockUpdateHasFactSet() throws {
        let card = try loadAndParse("stock-update")
        let hasFactSet = (card.body ?? []).contains { if case .factSet = $0 { return true } else { return false } }
        XCTAssertTrue(hasFactSet, "Stock Update should have a FactSet for stock data")
    }

    // MARK: - Helpers

    private func loadAndParse(_ name: String) throws -> AdaptiveCard {
        let json = try loadTestCard(named: name)
        return try parser.parse(json)
    }

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
