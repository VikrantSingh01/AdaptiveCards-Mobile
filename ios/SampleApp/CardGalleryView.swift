import SwiftUI

struct CardGalleryView: View {
    @State private var searchText = ""
    @State private var selectedCategory: CardCategory = .all
    @State private var showGrouped = true

    private let cards: [TestCard] = TestCardLoader.loadAllCards()

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

    /// Groups cards by their section for sectioned display
    private var groupedCards: [(section: CardSection, cards: [TestCard])] {
        let sections = CardSection.allCases
        return sections.compactMap { section in
            let sectionCards = filteredCards.filter { section.matches($0.category) }
            if sectionCards.isEmpty { return nil }
            return (section: section, cards: sectionCards)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                // Summary header
                if searchText.isEmpty && selectedCategory == .all {
                    Section {
                        cardCountSummaryView
                    }
                }

                if showGrouped {
                    ForEach(groupedCards, id: \.section) { group in
                        Section {
                            ForEach(group.cards) { card in
                                cardRow(card)
                            }
                        } header: {
                            sectionHeader(group.section, count: group.cards.count)
                        }
                    }
                } else {
                    ForEach(filteredCards) { card in
                        cardRow(card)
                    }
                }
            }
            .navigationTitle("Card Gallery")
            .searchable(text: $searchText, prompt: "Search \(cards.count) cards...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button(action: { showGrouped.toggle() }) {
                            Image(systemName: showGrouped ? "list.bullet.indent" : "list.bullet")
                        }
                        Menu {
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(CardCategory.allCases) { category in
                                    HStack {
                                        Text(category.rawValue)
                                        Spacer()
                                        Text("(\(cards.filter { $0.category == category || category == .all }.count))")
                                    }.tag(category)
                                }
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Subviews

    private func cardRow(_ card: TestCard) -> some View {
        NavigationLink(destination: CardDetailView(card: card)) {
            VStack(alignment: .leading, spacing: 4) {
                Text(card.title)
                    .font(.headline)
                Text(card.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                HStack(spacing: 6) {
                    categoryBadge(card.category)
                    if card.isAdvanced {
                        Text("Advanced")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.purple.opacity(0.2))
                            .cornerRadius(4)
                    }
                    if card.dataJsonString != nil {
                        Text("Templated")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.teal.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var cardCountSummaryView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(cards.count) Total Cards")
                .font(.title2)
                .fontWeight(.bold)
            HStack(spacing: 12) {
                summaryPill("Built-in", count: cards.filter { [.basic, .inputs, .actions, .containers, .advanced, .teams, .templating].contains($0.category) }.count, color: .blue)
                summaryPill("Official", count: cards.filter { $0.category == .officialSamples }.count, color: .mint)
                summaryPill("Elements", count: cards.filter { $0.category == .elementSamples }.count, color: .cyan)
                summaryPill("Teams", count: cards.filter { $0.category == .teamsSamples }.count, color: .pink)
                summaryPill("T. Official", count: cards.filter { $0.category == .teamsOfficialSamples }.count, color: .indigo)
                summaryPill("Edge", count: cards.filter { $0.category == .edgeCases }.count, color: .orange)
            }
        }
        .padding(.vertical, 4)
    }

    private func summaryPill(_ title: String, count: Int, color: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(color)
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    private func sectionHeader(_ section: CardSection, count: Int) -> some View {
        HStack {
            Image(systemName: section.icon)
                .foregroundColor(section.color)
            Text(section.title)
                .font(.headline)
            Spacer()
            Text("\(count)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(8)
        }
    }

    private func categoryBadge(_ category: CardCategory) -> some View {
        Text(category.rawValue)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(category.color.opacity(0.2))
            .cornerRadius(4)
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

    var title: String { rawValue }

    var icon: String {
        switch self {
        case .builtIn: return "square.grid.2x2"
        case .officialSamples: return "star.fill"
        case .elementSamples: return "cube"
        case .teamsSamples: return "person.2.fill"
        case .teamsOfficialSamples: return "person.3.fill"
        case .edgeCases: return "exclamationmark.triangle"
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

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .all: return .gray
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
        }
    }
}

struct TestCard: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let filename: String
    let category: CardCategory
    let isAdvanced: Bool
    let jsonString: String
    /// Optional data JSON for templated cards (teams-samples)
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
    /// Directory path to shared test cards resolved at load time
    private static let testCardsDirectory: String? = {
        // Resolve the path to the shared/test-cards directory relative to the app bundle or source tree
        // Strategy 1: Check if cards are bundled as app resources
        if let bundlePath = Bundle.main.resourcePath {
            let bundledDir = (bundlePath as NSString).appendingPathComponent("test-cards")
            if FileManager.default.fileExists(atPath: bundledDir) {
                return bundledDir
            }
        }

        // Strategy 2: Walk up from the app bundle to find the repo root (development builds)
        // The app binary lives somewhere under .../Build/Products/Debug-iphonesimulator/...
        // or the source tree itself at .../ios/SampleApp
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

        // Strategy 3: Use the known relative path from the source file during development
        // __FILE__ equivalent: #file resolves to the source location at compile time
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

    static func loadAllCards() -> [TestCard] {
        let cardDefinitions: [(String, String, CardCategory, Bool)] = [
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
            ("themed-images.json", "Themed Images", .advanced, false),
            ("compound-buttons.json", "Compound Buttons", .actions, false),
            ("split-buttons.json", "Split Buttons", .actions, false),
            ("popover-action.json", "Popover Action", .actions, false),
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
            // Edge case cards
            ("edge-all-unknown-types.json", "Edge: Unknown Types", .edgeCases, false),
            ("edge-deeply-nested.json", "Edge: Deeply Nested", .edgeCases, false),
            ("edge-empty-card.json", "Edge: Empty Card", .edgeCases, false),
            ("edge-empty-containers.json", "Edge: Empty Containers", .edgeCases, false),
            ("edge-long-text.json", "Edge: Long Text", .edgeCases, false),
            ("edge-max-actions.json", "Edge: Max Actions", .edgeCases, false),
            ("edge-mixed-inputs.json", "Edge: Mixed Inputs", .edgeCases, false),
            ("edge-rtl-content.json", "Edge: RTL Content", .edgeCases, false),
            // Additional catalog/metadata cards
            ("sample-catalog.json", "Sample Catalog", .basic, false),
        ]

        var cards = cardDefinitions.compactMap { (filename, title, category, isAdvanced) -> TestCard? in
            guard let jsonString = loadCardJSON(filename) else { return nil }

            return TestCard(
                title: title,
                description: "Test card: \(title)",
                filename: filename,
                category: category,
                isAdvanced: isAdvanced,
                jsonString: jsonString
            )
        }

        // Load official samples from shared/test-cards/official-samples/
        cards.append(contentsOf: loadCardsFromSubdirectory("official-samples", category: .officialSamples))

        // Load element samples from shared/test-cards/element-samples/
        cards.append(contentsOf: loadCardsFromSubdirectory("element-samples", category: .elementSamples))

        // Load teams templated samples from shared/test-cards/teams-samples/
        cards.append(contentsOf: loadTeamsSamples())

        // Load teams official samples from shared/test-cards/teams-official-samples/
        cards.append(contentsOf: loadCardsFromSubdirectory("teams-official-samples", category: .teamsOfficialSamples))

        return cards
    }

    /// Loads all JSON cards from a subdirectory of the test-cards folder
    private static func loadCardsFromSubdirectory(_ subdirectory: String, category: CardCategory) -> [TestCard] {
        guard let directory = testCardsDirectory else { return [] }
        let subdir = (directory as NSString).appendingPathComponent(subdirectory)

        guard let files = try? FileManager.default.contentsOfDirectory(atPath: subdir) else {
            print("Warning: Could not read subdirectory: \(subdir)")
            return []
        }

        return files
            .filter { $0.hasSuffix(".json") }
            .sorted()
            .compactMap { filename -> TestCard? in
                let filePath = (subdir as NSString).appendingPathComponent(filename)
                guard let data = FileManager.default.contents(atPath: filePath),
                      let jsonString = String(data: data, encoding: .utf8) else {
                    return nil
                }

                let name = filename.replacingOccurrences(of: ".json", with: "")
                let title = name
                    .replacingOccurrences(of: "-", with: " ")
                    .split(separator: " ")
                    .map { $0.prefix(1).uppercased() + $0.dropFirst() }
                    .joined(separator: " ")

                return TestCard(
                    title: title,
                    description: "\(category.rawValue) sample: \(title)",
                    filename: "\(subdirectory)/\(filename)",
                    category: category,
                    isAdvanced: false,
                    jsonString: jsonString
                )
            }
    }

    /// Loads teams-samples as template+data pairs, merging data into templates
    private static func loadTeamsSamples() -> [TestCard] {
        guard let directory = testCardsDirectory else { return [] }
        let subdir = (directory as NSString).appendingPathComponent("teams-samples")

        guard let files = try? FileManager.default.contentsOfDirectory(atPath: subdir) else {
            print("Warning: Could not read subdirectory: \(subdir)")
            return []
        }

        let templateFiles = files.filter { $0.hasSuffix("-template.json") }.sorted()

        return templateFiles.compactMap { templateFilename -> TestCard? in
            let baseName = templateFilename
                .replacingOccurrences(of: "-template.json", with: "")
            let dataFilename = "\(baseName)-data.json"

            let templatePath = (subdir as NSString).appendingPathComponent(templateFilename)
            let dataPath = (subdir as NSString).appendingPathComponent(dataFilename)

            guard let templateData = FileManager.default.contents(atPath: templatePath),
                  let templateJson = String(data: templateData, encoding: .utf8) else {
                return nil
            }

            var dataJson: String? = nil
            if let dataData = FileManager.default.contents(atPath: dataPath),
               let dataStr = String(data: dataData, encoding: .utf8) {
                dataJson = dataStr
            }

            let title = baseName
                .replacingOccurrences(of: "-", with: " ")
                .split(separator: " ")
                .map { $0.prefix(1).uppercased() + $0.dropFirst() }
                .joined(separator: " ")

            return TestCard(
                title: title,
                description: "Teams templated sample: \(title)",
                filename: "teams-samples/\(templateFilename)",
                category: .teamsSamples,
                isAdvanced: false,
                jsonString: templateJson,
                dataJsonString: dataJson
            )
        }
    }

    static func loadCardJSON(_ filename: String) -> String? {
        // Try to load the real card JSON from the shared test-cards directory
        if let directory = testCardsDirectory {
            let filePath = (directory as NSString).appendingPathComponent(filename)
            if let data = FileManager.default.contents(atPath: filePath),
               let jsonString = String(data: data, encoding: .utf8) {
                return jsonString
            }
        }

        // Try loading from the app bundle directly (e.g. if cards were added as bundle resources)
        let resourceName = (filename as NSString).deletingPathExtension
        if let url = Bundle.main.url(forResource: resourceName, withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }

        // Fallback: return nil so the card is filtered out by compactMap
        // This avoids showing identical placeholder cards
        print("Warning: Could not load test card file: \(filename)")
        return nil
    }
}
