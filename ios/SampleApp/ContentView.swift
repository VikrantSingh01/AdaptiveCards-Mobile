import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        TabView {
            CardGalleryView()
                .tabItem {
                    Label("Gallery", systemImage: "square.grid.2x2")
                }

            CardEditorView()
                .tabItem {
                    Label("Editor", systemImage: "pencil")
                }

            TeamsSimulatorView()
                .tabItem {
                    Label("Teams", systemImage: "message")
                }

            NavigationStack {
                List {
                    Section {
                        NavigationLink("Action Log") {
                            ActionLogView()
                        }
                        NavigationLink("Performance") {
                            PerformanceDashboardView()
                        }
                        NavigationLink("Settings") {
                            SettingsView()
                        }
                    }
                }
                .navigationTitle("More")
            }
            .tabItem {
                Label("More", systemImage: "ellipsis.circle")
            }
        }
        .preferredColorScheme(colorScheme)
    }

    private var colorScheme: ColorScheme? {
        switch settings.theme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}
