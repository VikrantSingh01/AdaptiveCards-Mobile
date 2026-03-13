// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI

@main
struct ACVisualizer: App {
    @StateObject private var actionLog = ActionLogStore()
    @StateObject private var settings = AppSettings()
    @StateObject private var bookmarks = BookmarkStore()
    @StateObject private var deepLink = DeepLinkRouter()
    @StateObject private var editorState = EditorState()
    @StateObject private var perfStore = PerformanceStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(actionLog)
                .environmentObject(settings)
                .environmentObject(bookmarks)
                .environmentObject(deepLink)
                .environmentObject(editorState)
                .environmentObject(perfStore)
                .onOpenURL { url in
                    deepLink.handle(url)
                }
        }
    }
}

/// Deep link handler for automated demo & test scripts.
///
/// Supported routes:
///   adaptivecards://card/{category}/{name}  — open card detail
///   adaptivecards://gallery                 — return to gallery tab
///   adaptivecards://gallery/{filter}         — gallery with category filter (e.g. teams-official)
///   adaptivecards://editor                  — switch to editor tab
///   adaptivecards://performance             — open performance dashboard
///   adaptivecards://bookmarks               — open bookmarks screen
///   adaptivecards://settings                — open settings screen
///   adaptivecards://tap-action/{title}       — programmatically trigger action by title
class DeepLinkRouter: ObservableObject {
    @Published var activeCard: TestCard?
    /// Set by deep link to request a screen navigation
    @Published var pendingScreen: String?
    /// Set by deep link to request a gallery filter (e.g. "teams-official")
    @Published var pendingFilter: String?
    /// Set by deep link to trigger an action by title on the currently displayed card
    @Published var pendingActionTitle: String?
    /// Signals CardGalleryView to pop its navigation stack to root
    @Published var pendingGalleryPopToRoot = false

    func handle(_ url: URL) {
        guard url.scheme == "adaptivecards" else { return }
        switch url.host {
        case "card":
            let filename = url.pathComponents.dropFirst().joined(separator: "/")
            guard !filename.isEmpty else { return }
            let allCards = TestCardLoader.loadAllCards()
            let card = allCards.first {
                $0.filename == filename ||
                $0.filename == "\(filename).json" ||
                $0.filename.replacingOccurrences(of: ".json", with: "") == filename
            }
            if card != nil {
                pendingScreen = "gallery"
            }
            activeCard = card
        case "gallery":
            activeCard = nil
            pendingGalleryPopToRoot = true
            // Check for filter path: adaptivecards://gallery/{filter}
            let filter = url.pathComponents.dropFirst().first
            pendingFilter = filter
            pendingScreen = "gallery"
        case "editor":
            activeCard = nil
            pendingScreen = "editor"
        case "performance":
            activeCard = nil
            pendingScreen = "performance"
        case "bookmarks":
            activeCard = nil
            pendingScreen = "bookmarks"
        case "settings":
            activeCard = nil
            pendingScreen = "settings"
        case "more":
            activeCard = nil
            pendingScreen = "more"
        case "tap-action":
            // adaptivecards://tap-action/{title} — trigger action on the current card
            let title = url.pathComponents.dropFirst().joined(separator: "/")
                .removingPercentEncoding ?? ""
            if !title.isEmpty {
                pendingActionTitle = title
            }
        default:
            break
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

class EditorState: ObservableObject {
    @Published var pendingJson: String?
    @Published var selectedTab: Int = 0

    func openInEditor(json: String) {
        pendingJson = json
        selectedTab = 1 // Switch to Editor tab
    }
}

// MARK: - Performance Store (persisted via UserDefaults)

class PerformanceStore: ObservableObject {
    private static let key = "perf_store_v1"

    @Published private(set) var parseTimes: [Double] = []   // seconds
    @Published private(set) var renderTimes: [Double] = []   // seconds
    @Published private(set) var peakMemoryMB: Double = 0

    init() { load() }

    // MARK: - Recording

    func recordParse(_ duration: TimeInterval) {
        parseTimes.append(duration)
        save()
    }

    func recordRender(_ duration: TimeInterval) {
        renderTimes.append(duration)
        updateMemory()
        save()
    }

    func reset() {
        parseTimes = []
        renderTimes = []
        peakMemoryMB = 0
        save()
    }

    // MARK: - Computed metrics

    var cardsParsed: Int { parseTimes.count }
    var cardsRendered: Int { renderTimes.count }

    var avgParseTime: TimeInterval { parseTimes.isEmpty ? 0 : parseTimes.reduce(0, +) / Double(parseTimes.count) }
    var minParseTime: TimeInterval { parseTimes.min() ?? 0 }
    var maxParseTime: TimeInterval { parseTimes.max() ?? 0 }

    var avgRenderTime: TimeInterval { renderTimes.isEmpty ? 0 : renderTimes.reduce(0, +) / Double(renderTimes.count) }
    var minRenderTime: TimeInterval { renderTimes.min() ?? 0 }
    var maxRenderTime: TimeInterval { renderTimes.max() ?? 0 }

    var currentMemoryMB: Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return 0 }
        return Double(info.resident_size) / (1024 * 1024)
    }

    // MARK: - Persistence

    private func updateMemory() {
        let mem = currentMemoryMB
        if mem > peakMemoryMB { peakMemoryMB = mem }
    }

    private func save() {
        let dict: [String: Any] = [
            "parseTimes": parseTimes,
            "renderTimes": renderTimes,
            "peakMemoryMB": peakMemoryMB
        ]
        UserDefaults.standard.set(dict, forKey: Self.key)
    }

    private func load() {
        guard let dict = UserDefaults.standard.dictionary(forKey: Self.key) else { return }
        parseTimes = dict["parseTimes"] as? [Double] ?? []
        renderTimes = dict["renderTimes"] as? [Double] ?? []
        peakMemoryMB = dict["peakMemoryMB"] as? Double ?? 0
    }
}
