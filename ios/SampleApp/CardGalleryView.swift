import SwiftUI

struct CardGalleryView: View {
    @State private var searchText = ""
    @State private var selectedCategory: CardCategory = .all
    
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
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredCards) { card in
                    NavigationLink(destination: CardDetailView(card: card)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(card.title)
                                .font(.headline)
                            Text(card.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack {
                                categoryBadge(card.category)
                                if card.isAdvanced {
                                    Text("Advanced")
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.purple.opacity(0.2))
                                        .cornerRadius(4)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Card Gallery")
            .searchable(text: $searchText, prompt: "Search cards...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(CardCategory.allCases) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
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

enum CardCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case basic = "Basic"
    case inputs = "Inputs"
    case actions = "Actions"
    case containers = "Containers"
    case advanced = "Advanced"
    case teams = "Teams"
    case templating = "Templating"
    
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
        ]

        return cardDefinitions.compactMap { (filename, title, category, isAdvanced) in
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
    }

    private static func loadCardJSON(_ filename: String) -> String? {
        // Try to load the real card JSON from the shared test-cards directory
        if let directory = testCardsDirectory {
            let filePath = (directory as NSString).appendingPathComponent(filename)
            if let data = FileManager.default.contents(atPath: filePath),
               let jsonString = String(data: data, encoding: .utf8) {
                return jsonString
            }
        }

        // Try loading from the app bundle directly (e.g. if cards were added as bundle resources)
        if let url = Bundle.main.url(forResource: filename.replacingOccurrences(of: ".json", with: ""), withExtension: "json"),
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
