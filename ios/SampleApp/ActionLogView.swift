import SwiftUI

struct ActionLogView: View {
    @EnvironmentObject var actionLog: ActionLogStore
    @State private var filterText: String = ""
    @State private var selectedAction: ActionLogEntry?

    var filteredActions: [ActionLogEntry] {
        if filterText.isEmpty {
            return actionLog.actions
        } else {
            return actionLog.actions.filter {
                $0.actionType.localizedCaseInsensitiveContains(filterText)
            }
        }
    }

    var body: some View {
        List {
            if actionLog.actions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No Actions Yet")
                        .font(.headline)
                    Text("Actions dispatched from adaptive cards will appear here")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .listRowBackground(Color.clear)
            } else {
                ForEach(filteredActions) { action in
                    Button(action: {
                        selectedAction = action
                    }) {
                        ActionListRow(action: action)
                    }
                    .listRowBackground(Color.clear)
                }
            }
        }
        .navigationTitle("Action Log")
        .searchable(text: $filterText, prompt: "Filter actions...")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        actionLog.clear()
                    }) {
                        Label("Clear All", systemImage: "trash")
                    }

                    Button(action: {
                        exportLog()
                    }) {
                        Label("Export Log", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(item: $selectedAction) { action in
            ActionDetailView(action: action)
        }
    }

    private func exportLog() {
        // Export functionality would be implemented here
        print("Exporting action log...")
    }
}

struct ActionListRow: View {
    let action: ActionLogEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(action.actionType)
                        .font(.headline)

                    Text(formatTime(action.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if !action.data.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "cube.box")
                        .font(.caption2)
                    Text("\(action.data.count) properties")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}

struct ActionDetailView: View {
    let action: ActionLogEntry
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Action Type") {
                    Text(action.actionType)
                        .font(.headline)
                }

                Section("Timestamp") {
                    Text(formatTime(action.timestamp))
                }

                if !action.data.isEmpty {
                    Section("Data") {
                        ForEach(Array(action.data.keys.sorted()), id: \.self) { key in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(key)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(action.data[key] ?? "nil")")
                                    .font(.body)
                            }
                        }
                    }
                }

                Section {
                    Button("Copy JSON") {
                        copyJSON()
                    }
                }
            }
            .navigationTitle("Action Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }

    private func copyJSON() {
        if let jsonData = try? JSONSerialization.data(withJSONObject: action.data, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            #if os(iOS)
            UIPasteboard.general.string = jsonString
            #endif
        }
    }
}
