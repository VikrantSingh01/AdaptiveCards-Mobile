import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: $settings.theme) {
                    ForEach(AppSettings.Theme.allCases, id: \.self) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Font Scale")
                        Spacer()
                        Text(String(format: "%.0f%%", settings.fontScale * 100))
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $settings.fontScale, in: 0.8...1.5, step: 0.1)
                }
            }
            
            Section("Accessibility") {
                Toggle("Enhanced Accessibility", isOn: $settings.enableAccessibility)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Voice Over Support")
                    Text("Enables enhanced screen reader support")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Developer") {
                Toggle("Performance Metrics", isOn: $settings.enablePerformanceMetrics)
                
                NavigationLink("Performance Dashboard") {
                    PerformanceDashboardView()
                }
                
                NavigationLink("Action Log") {
                    ActionLogView()
                }
            }
            
            Section("About") {
                LabeledContent("SDK Version", value: "1.0.0")
                LabeledContent("Build", value: "1")
                
                Button("View Documentation") {
                    openDocumentation()
                }
                
                Button("Report Issue") {
                    reportIssue()
                }
            }
            
            Section {
                Button("Reset to Defaults") {
                    resetSettings()
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Settings")
    }
    
    private func resetSettings() {
        settings.theme = .system
        settings.fontScale = 1.0
        settings.enableAccessibility = true
        settings.enablePerformanceMetrics = false
    }
    
    private func openDocumentation() {
        // Open documentation URL
        print("Opening documentation...")
    }
    
    private func reportIssue() {
        // Open issue reporting
        print("Reporting issue...")
    }
}
