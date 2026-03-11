import SwiftUI

@main
struct AdaptiveCardsSampleApp: App {
    @StateObject private var actionLog = ActionLogStore()
    @StateObject private var settings = AppSettings()
    @StateObject private var bookmarks = BookmarkStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(actionLog)
                .environmentObject(settings)
                .environmentObject(bookmarks)
        }
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
