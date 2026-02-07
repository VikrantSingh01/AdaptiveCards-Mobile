import SwiftUI

struct CardDetailView: View {
    let card: TestCard
    @State private var showJSON = false
    @State private var parseTime: TimeInterval = 0
    @State private var renderTime: TimeInterval = 0
    @EnvironmentObject var actionLog: ActionLogStore
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Card Preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preview")
                        .font(.headline)
                    
                    CardPreviewPlaceholder(json: card.jsonString)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                // Performance Metrics
                HStack(spacing: 20) {
                    MetricView(title: "Parse", value: String(format: "%.2fms", parseTime * 1000))
                    MetricView(title: "Render", value: String(format: "%.2fms", renderTime * 1000))
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                // JSON Toggle
                Toggle("Show JSON", isOn: $showJSON)
                    .padding(.horizontal)
                
                if showJSON {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("JSON Payload")
                                .font(.headline)
                            Spacer()
                            Button(action: copyJSON) {
                                Label("Copy", systemImage: "doc.on.doc")
                                    .font(.caption)
                            }
                        }
                        
                        ScrollView(.horizontal, showsIndicators: true) {
                            Text(card.jsonString)
                                .font(.system(.caption, design: .monospaced))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                
                // Recent Actions
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Actions")
                        .font(.headline)
                    
                    if actionLog.actions.isEmpty {
                        Text("No actions yet")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(actionLog.actions.prefix(5)) { action in
                            ActionRowView(action: action)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(card.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: reloadCard) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            measurePerformance()
        }
    }
    
    private func measurePerformance() {
        let start = Date()
        // Simulate parsing
        Thread.sleep(forTimeInterval: 0.001)
        parseTime = Date().timeIntervalSince(start)
        
        let renderStart = Date()
        // Simulate rendering
        Thread.sleep(forTimeInterval: 0.003)
        renderTime = Date().timeIntervalSince(renderStart)
    }
    
    private func reloadCard() {
        measurePerformance()
    }
    
    private func copyJSON() {
        #if os(iOS)
        UIPasteboard.general.string = card.jsonString
        #endif
    }
}

struct CardPreviewPlaceholder: View {
    let json: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Adaptive Card Preview")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Card rendering would appear here")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Placeholder representation
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.blue.opacity(0.3))
                    .frame(height: 20)
                    .frame(maxWidth: 200)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 16)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 16)
                    .frame(maxWidth: 250)
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct MetricView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
    }
}

struct ActionRowView: View {
    let action: ActionLogEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(action.actionType)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(formatTime(action.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            if !action.data.isEmpty {
                Text(formatData(action.data))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatData(_ data: [String: Any]) -> String {
        data.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
    }
}
