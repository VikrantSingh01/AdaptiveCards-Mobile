// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI

struct CardGalleryView: View {
    @EnvironmentObject var bookmarks: BookmarkStore
    @EnvironmentObject var deepLink: DeepLinkRouter
    @State private var searchText = ""
    @State private var selectedCategory: CardCategory = .all
    @State private var showGrouped = true
    @State private var navigationPath = NavigationPath()

    private let cards: [TestCard] = TestCardLoader.loadAllCards()

    /// Maps deep link filter slugs to CardCategory values
    private static let filterMap: [String: CardCategory] = [
        "all": .all, "basic": .basic, "inputs": .inputs, "actions": .actions,
        "containers": .containers, "advanced": .advanced, "teams": .teams,
        "templating": .templating, "official": .officialSamples,
        "elements": .elementSamples, "teams-templated": .teamsSamples,
        "teams-official": .teamsOfficialSamples, "edge-cases": .edgeCases
    ]

    var filteredCards: [TestCard] {
        var result = cards

        if selectedCategory != .all {
            result = result.filter { $0.category == selectedCategory }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    private var groupedCards: [(section: CardSection, cards: [TestCard])] {
        let sections = CardSection.allCases
        return sections.compactMap { section in
            let sectionCards = filteredCards.filter { section.matches($0.category) }
            if sectionCards.isEmpty { return nil }
            return (section: section, cards: sectionCards)
        }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero header
                    if searchText.isEmpty && selectedCategory == .all {
                        heroHeader
                    }

                    // Category chips
                    categoryChipBar

                    // Results count
                    if selectedCategory != .all || !searchText.isEmpty {
                        HStack {
                            Text("\(filteredCards.count) results")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }

                    // Card list
                    LazyVStack(spacing: 0) {
                        if showGrouped && searchText.isEmpty {
                            ForEach(groupedCards, id: \.section) { group in
                                sectionHeader(group.section, count: group.cards.count)
                                    .padding(.top, 20)
                                ForEach(group.cards) { card in
                                    cardRow(card)
                                }
                            }
                        } else {
                            ForEach(filteredCards) { card in
                                cardRow(card)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search \(cards.count) cards...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { withAnimation(.easeInOut(duration: 0.2)) { showGrouped.toggle() } }) {
                        Image(systemName: showGrouped ? "list.bullet.indent" : "list.bullet")
                            .font(.body)
                    }
                }
            }
            .onChange(of: deepLink.pendingFilter) { _, filter in
                guard let filter else { return }
                deepLink.pendingFilter = nil
                if let category = Self.filterMap[filter] {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCategory = category
                    }
                }
            }
            .navigationDestination(for: TestCard.self) { card in
                CardDetailView(card: card)
            }
            .onChange(of: deepLink.activeCard) { _, card in
                guard let card else { return }
                deepLink.activeCard = nil
                navigationPath = NavigationPath()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    navigationPath.append(card)
                }
            }
            .onChange(of: deepLink.pendingGalleryPopToRoot) { _, shouldPop in
                guard shouldPop else { return }
                deepLink.pendingGalleryPopToRoot = false
                navigationPath = NavigationPath()
            }
        }
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        VStack(spacing: 16) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.0, green: 0.47, blue: 0.83), Color(red: 0.2, green: 0.6, blue: 1.0)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: "rectangle.stack.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    )
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, y: 4)

                VStack(alignment: .leading, spacing: 2) {
                    Text("AC Visualizer")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("v1.6 Mobile SDK")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            HStack(spacing: 0) {
                statBadge(value: "\(cards.count)", label: "Cards", color: .blue)
                Spacer()
                statBadge(value: "\(Set(cards.map { $0.category }).count - 1)", label: "Categories", color: .purple)
                Spacer()
                statBadge(value: "\(cards.filter { $0.isAdvanced }.count)", label: "Advanced", color: .orange)
                Spacer()
                statBadge(value: "\(bookmarks.bookmarkedFilenames.count)", label: "Saved", color: .pink)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func statBadge(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Category Chips

    private var categoryChipBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CardCategory.allCases) { category in
                    let count = category == .all ? cards.count : cards.filter { $0.category == category }.count
                    if count > 0 || category == .all {
                        categoryChip(category, count: count)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private func categoryChip(_ category: CardCategory, count: Int) -> some View {
        let isSelected = selectedCategory == category
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCategory = category
            }
        }) {
            HStack(spacing: 5) {
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                if category != .all {
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.white.opacity(0.3) : category.color.opacity(0.15))
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? category.color : Color(.tertiarySystemFill))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Card Row

    private func cardRow(_ card: TestCard) -> some View {
        NavigationLink(value: card) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(card.category.color.gradient)
                    .frame(width: 4, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(card.title)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .lineLimit(1)

                        if card.isAdvanced {
                            Label("Advanced", systemImage: "sparkles")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.purple)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.purple.opacity(0.1))
                                .clipShape(Capsule())
                        }

                        if card.dataJsonString != nil {
                            Label("Templated", systemImage: "doc.on.doc")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.teal)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.teal.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }

                    Text(card.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if bookmarks.isBookmarked(card.filename) {
                    Image(systemName: "bookmark.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.quaternary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing) {
            Button {
                bookmarks.toggle(card.filename)
            } label: {
                Label(
                    bookmarks.isBookmarked(card.filename) ? "Remove" : "Bookmark",
                    systemImage: bookmarks.isBookmarked(card.filename) ? "bookmark.slash" : "bookmark.fill"
                )
            }
            .tint(.orange)
        }
    }

    // MARK: - Section Header

    private func sectionHeader(_ section: CardSection, count: Int) -> some View {
        HStack(spacing: 8) {
            Image(systemName: section.icon)
                .font(.subheadline)
                .foregroundColor(section.color)
                .frame(width: 24)

            Text(section.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            Rectangle()
                .fill(Color(.separator))
                .frame(height: 0.5)

            Text("\(count)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 4)
    }
}

// MARK: - Card Sections for Grouped Display

enum CardSection: String, CaseIterable, Hashable {
    case builtIn = "Built-in Samples"
    case officialSamples = "Official Samples"
    case elementSamples = "Element Samples"
    case teamsSamples = "Teams Templated Samples"
    case teamsOfficialSamples = "Teams Official Samples"
    case edgeCases = "Edge Cases"
    case versioned = "Versioned Cards"

    var title: String { rawValue }

    var icon: String {
        switch self {
        case .builtIn: return "square.grid.2x2"
        case .officialSamples: return "star.fill"
        case .elementSamples: return "cube"
        case .teamsSamples: return "person.2.fill"
        case .teamsOfficialSamples: return "person.3.fill"
        case .edgeCases: return "exclamationmark.triangle"
        case .versioned: return "clock.arrow.circlepath"
        }
    }

    var color: Color {
        switch self {
        case .builtIn: return .blue
        case .officialSamples: return .mint
        case .elementSamples: return .cyan
        case .teamsSamples: return .pink
        case .teamsOfficialSamples: return .indigo
        case .edgeCases: return .orange
        case .versioned: return .gray
        }
    }

    func matches(_ category: CardCategory) -> Bool {
        switch self {
        case .builtIn:
            return [.basic, .inputs, .actions, .containers, .advanced, .teams, .templating].contains(category)
        case .officialSamples:
            return category == .officialSamples
        case .elementSamples:
            return category == .elementSamples
        case .teamsSamples:
            return category == .teamsSamples
        case .teamsOfficialSamples:
            return category == .teamsOfficialSamples
        case .edgeCases:
            return category == .edgeCases
        case .versioned:
            return category == .versioned
        }
    }
}

enum CardCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case basic = "Basic"
    case inputs = "Inputs"
    case actions = "Actions"
    case containers = "Containers"
    case advanced = "Advanced"
    case teams = "Teams"
    case templating = "Templating"
    case officialSamples = "Official"
    case elementSamples = "Elements"
    case teamsSamples = "Teams Templated"
    case teamsOfficialSamples = "Teams Official"
    case edgeCases = "Edge Cases"
    case versioned = "Versioned"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .all: return .blue
        case .basic: return .blue
        case .inputs: return .green
        case .actions: return .orange
        case .containers: return .purple
        case .advanced: return .red
        case .teams: return .indigo
        case .templating: return .teal
        case .officialSamples: return .mint
        case .elementSamples: return .cyan
        case .teamsSamples: return .pink
        case .teamsOfficialSamples: return .indigo
        case .edgeCases: return .orange
        case .versioned: return .gray
        }
    }
}

struct TestCard: Identifiable, Hashable {
    let id = UUID()

    static func == (lhs: TestCard, rhs: TestCard) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    let title: String
    let description: String
    let filename: String
    let category: CardCategory
    let isAdvanced: Bool
    let jsonString: String
    let dataJsonString: String?

    init(title: String, description: String, filename: String, category: CardCategory, isAdvanced: Bool, jsonString: String, dataJsonString: String? = nil) {
        self.title = title
        self.description = description
        self.filename = filename
        self.category = category
        self.isAdvanced = isAdvanced
        self.jsonString = jsonString
        self.dataJsonString = dataJsonString
    }
}

class TestCardLoader {
    private static let testCardsDirectory: String? = {
        if let bundlePath = Bundle.main.resourcePath {
            let bundledDir = (bundlePath as NSString).appendingPathComponent("test-cards")
            if FileManager.default.fileExists(atPath: bundledDir) {
                return bundledDir
            }
        }

        if let bundlePath = Bundle.main.bundlePath as NSString? {
            var current = bundlePath as String
            for _ in 0..<10 {
                let candidate = (current as NSString).appendingPathComponent("shared/test-cards")
                if FileManager.default.fileExists(atPath: candidate) {
                    return candidate
                }
                current = (current as NSString).deletingLastPathComponent
            }
        }

        let sourceFile = #file
        var dir = (sourceFile as NSString).deletingLastPathComponent
        for _ in 0..<10 {
            let candidate = (dir as NSString).appendingPathComponent("shared/test-cards")
            if FileManager.default.fileExists(atPath: candidate) {
                return candidate
            }
            dir = (dir as NSString).deletingLastPathComponent
        }

        return nil
    }()

    // Maps teams template files to their data files
    private static let templateDataFiles: [String: String] = [
        "templates/ActivityUpdate.template.json": "templates/ActivityUpdate.data.json",
        "templates/WeatherLarge.template.json": "templates/WeatherLarge.data.json",
        "templates/StockUpdate.template.json": "templates/StockUpdate.data.json",
        "templates/FlightDetails.template.json": "templates/FlightDetails.data.json",
        "templates/FlightItinerary.template.json": "templates/FlightItinerary.data.json",
        "templates/FoodOrder.template.json": "templates/FoodOrder.data.json",
        "templates/ExpenseReport.template.json": "templates/ExpenseReport.data.json",
        "templates/CalendarReminder.template.json": "templates/CalendarReminder.data.json",
        "templates/SportingEvent.template.json": "templates/SportingEvent.data.json",
        "templates/Restaurant.template.json": "templates/Restaurant.data.json",
        "templates/InputForm.template.json": "templates/InputForm.data.json",
        "templates/Agenda.template.json": "templates/Agenda.data.json",
        "templates/Solitaire.template.json": "templates/Solitaire.data.json",
        "templates/SimpleFallback.template.json": "templates/SimpleFallback.data.json",
        "templates/CarouselTemplatedPages.template.json": "templates/CarouselTemplatedPages.data.json",
        "templates/CarouselWhenShowCarousel.template.json": "templates/CarouselWhenShowCarousel.data.json",
        "templates/ProductVideo.template.json": "templates/ProductVideo.data.json",
        "templates/ImageGallery.template.json": "templates/ImageGallery.data.json",
        "templates/FlightUpdate.template.json": "templates/FlightUpdate.data.json",
        "templates/OrderConfirmation.template.json": "templates/OrderConfirmation.data.json",
        "templates/RestaurantOrder.template.json": "templates/RestaurantOrder.data.json",
        "templates/WeatherCompact.template.json": "templates/WeatherCompact.data.json",
        "templates/FlightUpdateTable.template.json": "templates/FlightUpdateTable.data.json",
        "templates/OrderDelivery.template.json": "templates/OrderDelivery.data.json",
        "templates/ApplicationLogin.template.json": "templates/ApplicationLogin.data.json",
        "templates/InputFormWithRTL.template.json": "templates/InputFormWithRTL.data.json",
        "templates/InputsWithValidation.template.json": "templates/InputsWithValidation.data.json",
        "templates/ShowCardWizard.template.json": "templates/ShowCardWizard.data.json",
        "templates/Template.Functions.Number.json": "templates/Template.data.json",
        "templates/Template.Functions.String.json": "templates/Template.data.json",
        "templates/Template.Functions.LogicalComparison.json": "templates/Template.data.json",
        "templates/Template.Functions.DateFunctions.json": "templates/Template.data.json",
        "templates/Template.Functions.DataManipulation.json": "templates/Template.data.json",
        "templates/Template.DataBinding.json": "templates/Template.data.json",
        "templates/Template.DataBinding.Inline.json": "templates/Template.data.json",
        "templates/Template.ConditionalLayout.json": "templates/Template.data.json",
        "templates/Template.Keywords.json": "templates/Template.data.json",
        "templates/Template.RepeatingItems.json": "templates/Template.data.json",
        "templating-basic.json": "templating-basic.data.json",
        "templating-conditional.json": "templating-conditional.data.json",
        "templating-expressions.json": "templating-expressions.data.json",
        "templating-iteration.json": "templating-iteration.data.json",
        "templating-nested.json": "templating-nested.data.json",
    ]

    static func loadAllCards() -> [TestCard] {
        // All card definitions with explicit titles matching Android for cross-platform parity
        let cardDefinitions: [(String, String, CardCategory, Bool)] = [
            // Built-in samples
            ("simple-text.json", "Simple Text", .basic, false),
            ("rich-text.json", "Rich Text", .basic, false),
            ("containers.json", "Containers", .containers, false),
            ("all-inputs.json", "All Input Types", .inputs, false),
            ("input-form.json", "Input Form", .inputs, false),
            ("all-actions.json", "All Action Types", .actions, false),
            ("markdown.json", "Markdown", .basic, false),
            ("charts.json", "Charts", .advanced, true),
            ("datagrid.json", "DataGrid", .advanced, true),
            ("list.json", "List", .containers, false),
            ("carousel.json", "Carousel", .containers, false),
            ("accordion.json", "Accordion", .containers, false),
            ("tab-set.json", "Tab Set", .containers, false),
            ("table.json", "Table", .containers, false),
            ("media.json", "Media", .basic, false),
            ("progress-indicators.json", "Progress Indicators", .basic, false),
            ("rating.json", "Rating", .basic, false),
            ("code-block.json", "Code Block", .advanced, false),
            ("fluent-theming.json", "Fluent Theming", .advanced, true),
            ("responsive-layout.json", "Responsive Layout", .advanced, false),
            ("themed-images.json", "Themed Images", .basic, false),
            ("compound-buttons.json", "Compound Buttons", .actions, false),
            ("split-buttons.json", "Split Buttons", .actions, false),
            ("popover-action.json", "Popover Action", .actions, false),
            ("action-overflow.json", "Action Overflow", .actions, false),
            ("teams-connector.json", "Teams Connector", .teams, false),
            ("teams-task-module.json", "Teams Task Module", .teams, false),
            ("copilot-citations.json", "Copilot Citations", .advanced, true),
            ("streaming-card.json", "Streaming Card", .advanced, true),
            ("templating-basic.json", "Basic Templating", .templating, false),
            ("templating-conditional.json", "Conditional Templating", .templating, false),
            ("templating-iteration.json", "Iteration Templating", .templating, false),
            ("templating-expressions.json", "Expression Templating", .templating, false),
            ("templating-nested.json", "Nested Templating", .templating, false),
            ("advanced-combined.json", "Advanced Combined", .advanced, true),
            ("sample-catalog.json", "Sample Catalog", .basic, false),
            // Edge cases
            ("edge-all-unknown-types.json", "Edge: Unknown Types", .edgeCases, false),
            ("edge-deeply-nested.json", "Edge: Deeply Nested", .edgeCases, false),
            ("edge-empty-card.json", "Edge: Empty Card", .edgeCases, false),
            ("edge-empty-containers.json", "Edge: Empty Containers", .edgeCases, false),
            ("edge-long-text.json", "Edge: Long Text", .edgeCases, false),
            ("edge-max-actions.json", "Edge: Max Actions", .edgeCases, false),
            ("edge-action-crashes.json", "Edge: Action Crashes", .edgeCases, false),
            ("edge-mixed-inputs.json", "Edge: Mixed Inputs", .edgeCases, false),
            ("edge-rtl-content.json", "Edge: RTL Content", .edgeCases, false),
            // Official Samples
            ("official-samples/activity-update.json", "Activity Update", .officialSamples, false),
            ("official-samples/agenda.json", "Agenda", .officialSamples, false),
            ("official-samples/application-login.json", "Application Login", .officialSamples, false),
            ("official-samples/calendar-reminder.json", "Calendar Reminder", .officialSamples, false),
            ("official-samples/expense-report.json", "Expense Report", .officialSamples, false),
            ("official-samples/flight-details.json", "Flight Details", .officialSamples, false),
            ("official-samples/flight-itinerary.json", "Flight Itinerary", .officialSamples, false),
            ("official-samples/flight-update.json", "Flight Update", .officialSamples, false),
            ("official-samples/flight-update-table.json", "Flight Update Table", .officialSamples, false),
            ("official-samples/food-order.json", "Food Order", .officialSamples, false),
            ("official-samples/image-gallery.json", "Image Gallery", .officialSamples, false),
            ("official-samples/input-form-official.json", "Input Form (Official)", .officialSamples, false),
            ("official-samples/input-form-rtl.json", "Input Form RTL", .officialSamples, false),
            ("official-samples/inputs-with-validation.json", "Inputs with Validation", .officialSamples, false),
            ("official-samples/order-confirmation.json", "Order Confirmation", .officialSamples, false),
            ("official-samples/order-delivery.json", "Order Delivery", .officialSamples, false),
            ("official-samples/restaurant.json", "Restaurant", .officialSamples, false),
            ("official-samples/restaurant-order.json", "Restaurant Order", .officialSamples, false),
            ("official-samples/show-card-wizard.json", "Show Card Wizard", .officialSamples, false),
            ("official-samples/sporting-event.json", "Sporting Event", .officialSamples, false),
            ("official-samples/stock-update.json", "Stock Update", .officialSamples, false),
            ("official-samples/weather-compact.json", "Weather Compact", .officialSamples, false),
            ("official-samples/weather-large.json", "Weather Large", .officialSamples, false),
            ("official-samples/product-video.json", "Product Video", .officialSamples, false),
            // Element Samples
            ("element-samples/action-execute-is-enabled.json", "Action Execute isEnabled", .elementSamples, false),
            ("element-samples/action-execute-mode.json", "Action Execute Mode", .elementSamples, false),
            ("element-samples/action-execute-tooltip.json", "Action Execute Tooltip", .elementSamples, false),
            ("element-samples/action-openurl-is-enabled.json", "Action OpenUrl isEnabled", .elementSamples, false),
            ("element-samples/action-openurl-mode.json", "Action OpenUrl Mode", .elementSamples, false),
            ("element-samples/action-openurl-tooltip.json", "Action OpenUrl Tooltip", .elementSamples, false),
            ("element-samples/action-showcard-is-enabled.json", "Action ShowCard isEnabled", .elementSamples, false),
            ("element-samples/action-showcard-mode.json", "Action ShowCard Mode", .elementSamples, false),
            ("element-samples/action-showcard-tooltip.json", "Action ShowCard Tooltip", .elementSamples, false),
            ("element-samples/action-submit-is-enabled.json", "Action Submit isEnabled", .elementSamples, false),
            ("element-samples/action-submit-mode.json", "Action Submit Mode", .elementSamples, false),
            ("element-samples/action-submit-tooltip.json", "Action Submit Tooltip", .elementSamples, false),
            ("element-samples/action-role.json", "Action Role", .elementSamples, false),
            ("element-samples/adaptive-card-rtl.json", "Adaptive Card RTL", .elementSamples, false),
            ("element-samples/column-rtl.json", "Column RTL", .elementSamples, false),
            ("element-samples/container-rtl.json", "Container RTL", .elementSamples, false),
            ("element-samples/image-select-action.json", "Image Select Action", .elementSamples, false),
            ("element-samples/image-force-load.json", "Image Force Load", .elementSamples, false),
            ("element-samples/imageset-stacked-style.json", "ImageSet Stacked Style", .elementSamples, false),
            ("element-samples/input-choiceset-filtered.json", "Input ChoiceSet Filtered", .elementSamples, false),
            ("element-samples/input-choiceset-dynamic-typeahead.json", "Input ChoiceSet Dynamic", .elementSamples, false),
            ("element-samples/input-text-password-style.json", "Input Text Password", .elementSamples, false),
            ("element-samples/input-label-position.json", "Input Label Position", .elementSamples, false),
            ("element-samples/input-style.json", "Input Style", .elementSamples, false),
            ("element-samples/input-toggle-consolidated.json", "Input Toggle Consolidated", .elementSamples, false),
            ("element-samples/table-basic.json", "Table Basic", .elementSamples, false),
            ("element-samples/table-first-row-headers.json", "Table First Row Headers", .elementSamples, false),
            ("element-samples/table-grid-style.json", "Table Grid Style", .elementSamples, false),
            ("element-samples/table-horizontal-alignment.json", "Table Horizontal Alignment", .elementSamples, false),
            ("element-samples/table-show-grid-lines.json", "Table Show Grid Lines", .elementSamples, false),
            ("element-samples/table-vertical-alignment.json", "Table Vertical Alignment", .elementSamples, false),
            ("element-samples/textblock-style.json", "TextBlock Style", .elementSamples, false),
            ("element-samples/carousel-basic.json", "Carousel Basic", .elementSamples, false),
            ("element-samples/carousel-header.json", "Carousel Header", .elementSamples, false),
            ("element-samples/carousel-height.json", "Carousel Height", .elementSamples, false),
            ("element-samples/carousel-height-pixels.json", "Carousel Height Pixels", .elementSamples, false),
            ("element-samples/carousel-height-vertical.json", "Carousel Height Vertical", .elementSamples, false),
            ("element-samples/carousel-initial-page.json", "Carousel Initial Page", .elementSamples, false),
            ("element-samples/carousel-loop.json", "Carousel Loop", .elementSamples, false),
            ("element-samples/carousel-scenario-cards.json", "Carousel Scenario Cards", .elementSamples, false),
            ("element-samples/carousel-scenario-timer.json", "Carousel Scenario Timer", .elementSamples, false),
            ("element-samples/carousel-styles.json", "Carousel Styles", .elementSamples, false),
            ("element-samples/carousel-vertical.json", "Carousel Vertical", .elementSamples, false),
            ("element-samples/container-scrollable.json", "Container Scrollable", .elementSamples, false),
            ("element-samples/media-basic.json", "Media Basic", .elementSamples, false),
            ("element-samples/media-sources.json", "Media Sources", .elementSamples, false),
            // Teams Templated Samples
            ("templates/ActivityUpdate.template.json", "Teams: Activity Update", .teamsSamples, false),
            ("templates/WeatherLarge.template.json", "Teams: Weather Large", .teamsSamples, false),
            ("templates/StockUpdate.template.json", "Teams: Stock Update", .teamsSamples, false),
            ("templates/FlightDetails.template.json", "Teams: Flight Details", .teamsSamples, false),
            ("templates/FlightItinerary.template.json", "Teams: Flight Itinerary", .teamsSamples, false),
            ("templates/FoodOrder.template.json", "Teams: Food Order", .teamsSamples, false),
            ("templates/ExpenseReport.template.json", "Teams: Expense Report", .teamsSamples, false),
            ("templates/CalendarReminder.template.json", "Teams: Calendar Reminder", .teamsSamples, false),
            ("templates/SportingEvent.template.json", "Teams: Sporting Event", .teamsSamples, false),
            ("templates/Restaurant.template.json", "Teams: Restaurant", .teamsSamples, false),
            ("templates/InputForm.template.json", "Teams: Input Form", .teamsSamples, false),
            ("templates/Agenda.template.json", "Teams: Agenda", .teamsSamples, false),
            ("templates/Solitaire.template.json", "Teams: Solitaire", .teamsSamples, false),
            ("templates/SimpleFallback.template.json", "Teams: Simple Fallback", .teamsSamples, false),
            ("templates/CarouselTemplatedPages.template.json", "Teams: Carousel Pages", .teamsSamples, false),
            ("templates/CarouselWhenShowCarousel.template.json", "Teams: Carousel When/Show", .teamsSamples, false),
            ("templates/ProductVideo.template.json", "Teams: Product Video", .teamsSamples, false),
            ("templates/ImageGallery.template.json", "Teams: Image Gallery", .teamsSamples, false),
            ("templates/FlightUpdate.template.json", "Teams: Flight Update", .teamsSamples, false),
            ("templates/OrderConfirmation.template.json", "Teams: Order Confirmation", .teamsSamples, false),
            ("templates/RestaurantOrder.template.json", "Teams: Restaurant Order", .teamsSamples, false),
            ("templates/WeatherCompact.template.json", "Teams: Weather Compact", .teamsSamples, false),
            ("templates/FlightUpdateTable.template.json", "Teams: Flight Update Table", .teamsSamples, false),
            ("templates/OrderDelivery.template.json", "Teams: Order Delivery", .teamsSamples, false),
            ("templates/ApplicationLogin.template.json", "Teams: Application Login", .teamsSamples, false),
            ("templates/InputFormWithRTL.template.json", "Teams: Input Form RTL", .teamsSamples, false),
            ("templates/InputsWithValidation.template.json", "Teams: Inputs Validation", .teamsSamples, false),
            ("templates/ShowCardWizard.template.json", "Teams: ShowCard Wizard", .teamsSamples, false),
            // Template Function Tests
            ("templates/Template.Functions.Number.json", "Template: Number Functions", .templating, false),
            ("templates/Template.Functions.String.json", "Template: String Functions", .templating, false),
            ("templates/Template.Functions.LogicalComparison.json", "Template: Logic Functions", .templating, false),
            ("templates/Template.Functions.DateFunctions.json", "Template: Date Functions", .templating, false),
            ("templates/Template.Functions.DataManipulation.json", "Template: Data Manipulation", .templating, false),
            ("templates/Template.DataBinding.json", "Template: Data Binding", .templating, false),
            ("templates/Template.DataBinding.Inline.json", "Template: Inline Binding", .templating, false),
            ("templates/Template.ConditionalLayout.json", "Template: Conditional Layout", .templating, false),
            ("templates/Template.Keywords.json", "Template: Keywords", .templating, false),
            ("templates/Template.RepeatingItems.json", "Template: Repeating Items", .templating, false),
            // Teams Official Samples
            ("teams-official-samples/account.json", "Teams: Account", .teamsOfficialSamples, false),
            ("teams-official-samples/author-highlight-video.json", "Teams: Author Highlight Video", .teamsOfficialSamples, false),
            ("teams-official-samples/book-a-room.json", "Teams: Book a Room", .teamsOfficialSamples, false),
            ("teams-official-samples/cafe-menu.json", "Teams: Cafe Menu", .teamsOfficialSamples, false),
            ("teams-official-samples/communication.json", "Teams: Communication", .teamsOfficialSamples, false),
            ("teams-official-samples/course-video.json", "Teams: Course Video", .teamsOfficialSamples, false),
            ("teams-official-samples/editorial.json", "Teams: Editorial", .teamsOfficialSamples, false),
            ("teams-official-samples/expense-report.json", "Teams: Expense Report", .teamsOfficialSamples, false),
            ("teams-official-samples/insights.json", "Teams: Insights", .teamsOfficialSamples, false),
            ("teams-official-samples/issue.json", "Teams: Issue", .teamsOfficialSamples, false),
            ("teams-official-samples/list.json", "Teams: List", .teamsOfficialSamples, false),
            ("teams-official-samples/project-dashboard.json", "Teams: Project Dashboard", .teamsOfficialSamples, false),
            ("teams-official-samples/recipe.json", "Teams: Recipe", .teamsOfficialSamples, false),
            ("teams-official-samples/simple-event.json", "Teams: Simple Event", .teamsOfficialSamples, false),
            ("teams-official-samples/simple-time-off-request.json", "Teams: Simple Time Off Request", .teamsOfficialSamples, false),
            ("teams-official-samples/standard-video.json", "Teams: Standard Video", .teamsOfficialSamples, false),
            ("teams-official-samples/team-standup-summary.json", "Teams: Team Standup Summary", .teamsOfficialSamples, false),
            ("teams-official-samples/time-off-request.json", "Teams: Time Off Request", .teamsOfficialSamples, false),
            ("teams-official-samples/work-item.json", "Teams: Work Item", .teamsOfficialSamples, false),
        ]

        var cards = cardDefinitions.compactMap { (filename, title, category, isAdvanced) -> TestCard? in
            guard let jsonString = loadCardJSON(filename) else { return nil }

            // Load template data for templated cards
            var dataJsonString: String? = nil
            if let dataFile = templateDataFiles[filename] {
                dataJsonString = loadCardJSON(dataFile)
            }

            let description: String
            switch category {
            case .basic: description = "Basic card demonstrating \(title) rendering"
            case .inputs: description = "Input elements: \(title)"
            case .actions: description = "Action types: \(title)"
            case .containers: description = "Container layout: \(title)"
            case .advanced: description = "Advanced feature: \(title)"
            case .teams: description = "Teams integration: \(title)"
            case .templating: description = "Data binding: \(title)"
            case .officialSamples: description = "Official sample: \(title)"
            case .elementSamples: description = "Element test: \(title)"
            case .teamsSamples: description = "Teams templated: \(title)"
            case .teamsOfficialSamples: description = "Teams official sample: \(title)"
            case .edgeCases: description = "Edge case: \(title)"
            case .versioned: description = "Versioned card: \(title)"
            case .all: description = "Test card: \(title)"
            }

            return TestCard(
                title: title,
                description: description,
                filename: filename,
                category: category,
                isAdvanced: isAdvanced,
                jsonString: jsonString,
                dataJsonString: dataJsonString
            )
        }

        // Dynamically discover versioned cards from filesystem
        cards.append(contentsOf: loadVersionedCards())

        return cards
    }

    static func loadCardJSON(_ filename: String) -> String? {
        if let directory = testCardsDirectory {
            let filePath = (directory as NSString).appendingPathComponent(filename)
            if let data = FileManager.default.contents(atPath: filePath),
               let jsonString = String(data: data, encoding: .utf8) {
                return jsonString
            }
        }

        let resourceName = (filename as NSString).deletingPathExtension
        if let url = Bundle.main.url(forResource: resourceName, withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }

        print("Warning: Could not load test card file: \(filename)")
        return nil
    }

    /// Dynamically discover versioned cards from versioned/ subdirectories
    private static func loadVersionedCards() -> [TestCard] {
        guard let baseDir = testCardsDirectory else { return [] }
        let versionedDir = (baseDir as NSString).appendingPathComponent("versioned")
        guard FileManager.default.fileExists(atPath: versionedDir) else { return [] }

        var cards: [TestCard] = []
        let fm = FileManager.default

        // Scan versioned/{version}/*.json
        guard let versions = try? fm.contentsOfDirectory(atPath: versionedDir) else { return [] }
        for version in versions.sorted() {
            let versionPath = (versionedDir as NSString).appendingPathComponent(version)
            var isDir: ObjCBool = false
            guard fm.fileExists(atPath: versionPath, isDirectory: &isDir), isDir.boolValue else { continue }

            guard let files = try? fm.contentsOfDirectory(atPath: versionPath) else { continue }
            for file in files.sorted() where file.hasSuffix(".json") {
                let relativePath = "versioned/\(version)/\(file)"
                guard let jsonString = loadCardJSON(relativePath) else { continue }
                let name = (file as NSString).deletingPathExtension
                cards.append(TestCard(
                    title: "\(version): \(name)",
                    description: "Versioned card: \(name) (\(version))",
                    filename: relativePath,
                    category: .versioned,
                    isAdvanced: false,
                    jsonString: jsonString
                ))
            }
        }
        return cards
    }
}
