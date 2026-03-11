import SwiftUI

@main
struct AdaptiveCardsSampleApp: App {
    @StateObject private var actionLog = ActionLogStore()
    @StateObject private var settings = AppSettings()
    @StateObject private var bookmarks = BookmarkStore()
    @StateObject private var deepLink = DeepLinkRouter()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(actionLog)
                .environmentObject(settings)
                .environmentObject(bookmarks)
                .environmentObject(deepLink)
                .onOpenURL { url in
                    deepLink.handle(url)
                }
        }
    }
}

/// Deep link handler: adaptivecards://card/{filename}
/// Enables automated test scripts to navigate directly to any card.
class DeepLinkRouter: ObservableObject {
    @Published var activeCard: TestCard?

    func handle(_ url: URL) {
        guard url.scheme == "adaptivecards", url.host == "card" else { return }
        let filename = url.pathComponents.dropFirst().joined(separator: "/")
        guard !filename.isEmpty else { return }
        let allCards = TestCardLoader.loadAllCards()
        // Match with or without .json extension
        activeCard = allCards.first {
            $0.filename == filename ||
            $0.filename == "\(filename).json" ||
            $0.filename.replacingOccurrences(of: ".json", with: "") == filename
        }
    }

    func dismiss() {
        activeCard = nil
    }
}

class ActionLogStore: ObservableObject {
    @Published var actions: [ActionLogEntry] = []

    func log(_ actionType: String, data: [String: Any]) {
        let entry = ActionLogEntry(
            timestamp: Date(),
            actionType: actionType,
            data: data
        )
        DispatchQueue.main.async {
            self.actions.insert(entry, at: 0)
        }
    }

    func clear() {
        actions.removeAll()
    }
}

struct ActionLogEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let actionType: String
    let data: [String: Any]
}

class BookmarkStore: ObservableObject {
    private static let storageKey = "bookmarkedCardFilenames"

    @Published var bookmarkedFilenames: Set<String> {
        didSet { save() }
    }

    init() {
        let saved = UserDefaults.standard.stringArray(forKey: Self.storageKey) ?? []
        bookmarkedFilenames = Set(saved)
    }

    func toggle(_ filename: String) {
        if bookmarkedFilenames.contains(filename) {
            bookmarkedFilenames.remove(filename)
        } else {
            bookmarkedFilenames.insert(filename)
        }
    }

    func isBookmarked(_ filename: String) -> Bool {
        bookmarkedFilenames.contains(filename)
    }

    private func save() {
        UserDefaults.standard.set(Array(bookmarkedFilenames), forKey: Self.storageKey)
    }
}

class AppSettings: ObservableObject {
    @Published var theme: Theme = .system
    @Published var fontScale: Double = 1.0
    @Published var enableAccessibility: Bool = true
    @Published var enablePerformanceMetrics: Bool = false

    enum Theme: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"
    }
}
