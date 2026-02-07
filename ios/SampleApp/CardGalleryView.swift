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
        // In a real implementation, this would load from Bundle.main
        // For now, return placeholder JSON
        return """
        {
          "type": "AdaptiveCard",
          "version": "1.5",
          "body": [
            {
              "type": "TextBlock",
              "text": "\(filename)",
              "size": "large",
              "weight": "bolder"
            }
          ]
        }
        """
    }
}
