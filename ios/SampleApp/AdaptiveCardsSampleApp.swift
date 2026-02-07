import SwiftUI

@main
struct AdaptiveCardsSampleApp: App {
    @StateObject private var actionLog = ActionLogStore()
    @StateObject private var settings = AppSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(actionLog)
                .environmentObject(settings)
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
