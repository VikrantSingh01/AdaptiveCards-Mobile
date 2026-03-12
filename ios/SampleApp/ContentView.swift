import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var deepLink: DeepLinkRouter
    @EnvironmentObject var editorState: EditorState
    @State private var moreNavigationPath = NavigationPath()

    var body: some View {
        TabView(selection: $editorState.selectedTab) {
            CardGalleryView()
                .tabItem {
                    Label("Gallery", systemImage: "square.grid.2x2.fill")
                }
                .tag(0)

            CardEditorView()
                .tabItem {
                    Label("Editor", systemImage: "chevron.left.forwardslash.chevron.right")
                }
                .tag(1)

            TeamsSimulatorView()
                .tabItem {
                    Label("Teams", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(2)

            NavigationStack(path: $moreNavigationPath) {
                MoreMenuView()
                    .navigationDestination(for: String.self) { screen in
                        switch screen {
                        case "performance":
                            PerformanceDashboardView()
                        case "bookmarks":
                            BookmarksView()
                        case "settings":
                            SettingsView()
                        default:
                            EmptyView()
                        }
                    }
            }
            .tabItem {
                Label("More", systemImage: "ellipsis.circle.fill")
            }
            .tag(3)
        }
        .tint(Color(red: 0.0, green: 0.47, blue: 0.83))
        .preferredColorScheme(colorScheme)
        .fullScreenCover(item: $deepLink.activeCard) { card in
            NavigationStack {
                CardDetailView(card: card)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Close") { deepLink.dismiss() }
                        }
                    }
            }
        }
        .onChange(of: deepLink.pendingScreen) { _, screen in
            guard let screen else { return }
            deepLink.pendingScreen = nil
            switch screen {
            case "gallery":
                editorState.selectedTab = 0
                moreNavigationPath = NavigationPath()
            case "editor":
                editorState.selectedTab = 1
            case "performance":
                editorState.selectedTab = 3
                moreNavigationPath = NavigationPath()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    moreNavigationPath.append("performance")
                }
            case "bookmarks":
                editorState.selectedTab = 3
                moreNavigationPath = NavigationPath()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    moreNavigationPath.append("bookmarks")
                }
            case "settings":
                editorState.selectedTab = 3
                moreNavigationPath = NavigationPath()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    moreNavigationPath.append("settings")
                }
            case "more":
                editorState.selectedTab = 3
                moreNavigationPath = NavigationPath()
            default:
                break
            }
        }
    }

    private var colorScheme: ColorScheme? {
        switch settings.theme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

// MARK: - More Menu

struct MoreMenuView: View {
    @EnvironmentObject var bookmarks: BookmarkStore

    var body: some View {
        List {
            // Quick access
            Section {
                NavigationLink {
                    BookmarksView()
                } label: {
                    MoreMenuItem(
                        icon: "bookmark.fill",
                        iconColor: .orange,
                        title: "Bookmarks",
                        subtitle: "\(bookmarks.bookmarkedFilenames.count) saved cards"
                    )
                }
            }

            // Developer tools
            Section("Developer Tools") {
                NavigationLink {
                    ActionLogView()
                } label: {
                    MoreMenuItem(
                        icon: "list.bullet.clipboard",
                        iconColor: .blue,
                        title: "Action Log",
                        subtitle: "View dispatched card actions"
                    )
                }

                NavigationLink {
                    PerformanceDashboardView()
                } label: {
                    MoreMenuItem(
                        icon: "gauge.with.dots.needle.33percent",
                        iconColor: .green,
                        title: "Performance",
                        subtitle: "Parse & render metrics"
                    )
                }

                NavigationLink {
                    SettingsView()
                } label: {
                    MoreMenuItem(
                        icon: "gearshape.fill",
                        iconColor: .gray,
                        title: "Settings",
                        subtitle: "Theme, accessibility, developer"
                    )
                }
            }

            // About
            Section {
                VStack(spacing: 6) {
                    HStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.0, green: 0.47, blue: 0.83), Color(red: 0.2, green: 0.6, blue: 1.0)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(systemName: "rectangle.stack.fill")
                                    .font(.callout)
                                    .foregroundColor(.white)
                            )

                        VStack(alignment: .leading, spacing: 1) {
                            Text("Adaptive Cards Mobile SDK")
                                .font(.footnote)
                                .fontWeight(.semibold)
                            Text("v1.0.0 (Build 1) \u{00B7} Schema v1.6")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
                .listRowBackground(Color.clear)
            }

            // Footnote
            Section {
                HStack {
                    Spacer()
                    Text("New Mobile AC Visualizer - Built with ❤️ by ")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    + Text("[Vikrant Singh](https://github.com/VikrantSingh01/)")
                        .font(.caption2)
                        .foregroundColor(Color(red: 0.0, green: 0.47, blue: 0.83))
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("More")
    }
}

struct MoreMenuItem: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.gradient)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
