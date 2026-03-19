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
            let pathParts = url.pathComponents.dropFirst()
            let filename = pathParts.joined(separator: "/")
            guard !filename.isEmpty else { return }
            let allCards = TestCardLoader.loadAllCards()
            let baseName = filename.hasSuffix(".json")
                ? String(filename.dropLast(5))
                : filename
            // Exact and extension-based matching
            var card = allCards.first {
                let fn = $0.filename
                return fn == filename ||
                    fn == "\(filename).json" ||
                    fn.strippingSuffix(".json") == filename ||
                    fn.strippingSuffix(".template.json") == baseName
            }
            // Slug-based fallback: normalize both sides (strip extensions, lowercase)
            // to handle minor path variations from deep links
            if card == nil {
                let slug = baseName.replacingOccurrences(of: ".template", with: "").lowercased()
                card = allCards.first {
                    let cardSlug = $0.filename
                        .replacingOccurrences(of: ".json", with: "")
                        .replacingOccurrences(of: ".template", with: "")
                        .lowercased()
                    return cardSlug == slug
                }
            }
            // Hyphenated single-segment fallback: "element-samples-carousel-styles"
            // maps to "element-samples/carousel-styles.json"
            if card == nil && !filename.contains("/") {
                let knownDirs = ["teams-official-samples", "element-samples", "official-samples", "templates"]
                for dir in knownDirs.sorted(by: { $0.count > $1.count }) {
                    if filename.hasPrefix("\(dir)-") {
                        let cardName = String(filename.dropFirst(dir.count + 1))
                        let resolved = "\(dir)/\(cardName)"
                        card = allCards.first {
                            $0.filename == "\(resolved).json" ||
                            $0.filename.strippingSuffix(".json") == resolved
                        }
                        if card != nil { break }
                    }
                }
                // Handle "versioned-v1.5-CardName" → "versioned/v1.5/CardName"
                if card == nil && filename.hasPrefix("versioned-") {
                    let rest = String(filename.dropFirst("versioned-".count))
                    if let range = rest.range(of: #"^v\d+\.\d+-"#, options: .regularExpression) {
                        let version = String(rest[rest.startIndex..<rest.index(before: range.upperBound)])
                        let cardName = String(rest[range.upperBound...])
                        let resolved = "versioned/\(version)/\(cardName)"
                        card = allCards.first {
                            $0.filename == "\(resolved).json" ||
                            $0.filename.strippingSuffix(".json") == resolved
                        }
                    }
                }
            }
            // Last resort: load from filesystem directly
            if card == nil {
                let candidates = [filename, "\(filename).json", "\(baseName).json", "\(baseName).template.json"]
                for candidate in candidates {
                    if TestCardLoader.loadCardJSON(candidate) != nil {
                        let name = candidate.split(separator: "/").last
                            .map(String.init)?
                            .replacingOccurrences(of: ".json", with: "")
                            .replacingOccurrences(of: ".template", with: "") ?? filename
                        card = TestCard(
                            title: name,
                            description: "Loaded from: \(candidate)",
                            filename: candidate,
                            category: .advanced,
                            isAdvanced: false
                        )
                        break
                    }
                }
            }
            if card != nil {
                pendingScreen = "gallery"
                // Delay setting activeCard so the tab switch to Gallery completes
                // before NavigationStack processes the card navigation push.
                // Without this delay, the navigation can silently fail when
                // switching from another tab (Editor, More, etc.).
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                    self.activeCard = card
                }
            } else {
                activeCard = nil
            }
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

// MARK: - String helpers

extension String {
    /// Returns the string with the given suffix removed, or the original string if it does not end with the suffix.
    func strippingSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        return String(dropLast(suffix.count))
    }
}
