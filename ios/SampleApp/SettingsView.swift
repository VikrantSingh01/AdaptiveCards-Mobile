import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var showResetConfirmation = false

    var body: some View {
        Form {
            Section {
                Picker(selection: $settings.theme) {
                    ForEach(AppSettings.Theme.allCases, id: \.self) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                } label: {
                    Label("Theme", systemImage: "paintbrush.fill")
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Font Scale", systemImage: "textformat.size")
                        Spacer()
                        Text(String(format: "%.0f%%", settings.fontScale * 100))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    Slider(value: $settings.fontScale, in: 0.8...1.5, step: 0.1)
                        .tint(.blue)
                }
            } header: {
                Label("Appearance", systemImage: "paintpalette")
                    .textCase(nil)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Section {
                Toggle(isOn: $settings.enableAccessibility) {
                    Label("Enhanced Accessibility", systemImage: "accessibility")
                }

                HStack(spacing: 12) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    Text("Enables enhanced screen reader and VoiceOver support for card content.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Label("Accessibility", systemImage: "figure.arms.open")
                    .textCase(nil)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Section {
                Toggle(isOn: $settings.enablePerformanceMetrics) {
                    Label("Performance Metrics", systemImage: "gauge.with.dots.needle.33percent")
                }

                NavigationLink {
                    PerformanceDashboardView()
                } label: {
                    Label("Performance Dashboard", systemImage: "chart.xyaxis.line")
                }

                NavigationLink {
                    ActionLogView()
                } label: {
                    Label("Action Log", systemImage: "list.bullet.clipboard")
                }
            } header: {
                Label("Developer", systemImage: "wrench.and.screwdriver")
                    .textCase(nil)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Section {
                LabeledContent {
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                } label: {
                    Label("SDK Version", systemImage: "shippingbox")
                }

                LabeledContent {
                    Text("1")
                        .foregroundStyle(.secondary)
                } label: {
                    Label("Build", systemImage: "hammer")
                }

                LabeledContent {
                    Text("1.6")
                        .foregroundStyle(.secondary)
                } label: {
                    Label("Schema", systemImage: "doc.text")
                }
            } header: {
                Label("About", systemImage: "info.circle")
                    .textCase(nil)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Section {
                Button(role: .destructive) {
                    showResetConfirmation = true
                } label: {
                    HStack {
                        Spacer()
                        Label("Reset to Defaults", systemImage: "arrow.counterclockwise")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .confirmationDialog("Reset all settings to defaults?", isPresented: $showResetConfirmation) {
            Button("Reset", role: .destructive) {
                resetSettings()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func resetSettings() {
        settings.theme = .system
        settings.fontScale = 1.0
        settings.enableAccessibility = true
        settings.enablePerformanceMetrics = false
    }
}
