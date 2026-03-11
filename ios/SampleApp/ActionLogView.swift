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
        Group {
            if actionLog.actions.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "list.bullet.clipboard")
                        .font(.system(size: 48))
                        .foregroundStyle(.tertiary)
                    Text("No Actions Yet")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Actions dispatched from adaptive cards\nwill appear here.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                List {
                    ForEach(filteredActions) { action in
                        Button(action: { selectedAction = action }) {
                            ActionListRow(action: action)
                        }
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                }
            }
        }
        .navigationTitle("Action Log")
        .searchable(text: $filterText, prompt: "Filter actions...")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        actionLog.clear()
                    } label: {
                        Label("Clear All", systemImage: "trash")
                    }
                    Button {
                        exportLog()
                    } label: {
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
        print("Exporting action log...")
    }
}

struct ActionListRow: View {
    let action: ActionLogEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(action.actionType)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    Text(formatTime(action.timestamp))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.quaternary)
            }

            if !action.data.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "cube.box")
                        .font(.caption2)
                    Text("\(action.data.count) properties")
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color(.tertiarySystemFill))
                .clipShape(Capsule())
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
        )
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
                        .font(.body)
                        .fontWeight(.medium)
                }

                Section("Timestamp") {
                    Text(formatTime(action.timestamp))
                }

                if !action.data.isEmpty {
                    Section("Data") {
                        ForEach(Array(action.data.keys.sorted()), id: \.self) { key in
                            VStack(alignment: .leading, spacing: 3) {
                                Text(key)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(action.data[key] ?? "nil")")
                                    .font(.body)
                            }
                        }
                    }
                }

                Section {
                    Button {
                        copyJSON()
                    } label: {
                        Label("Copy JSON", systemImage: "doc.on.doc")
                    }
                }
            }
            .navigationTitle("Action Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.medium)
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
