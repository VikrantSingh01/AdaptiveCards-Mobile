import SwiftUI

struct PerformanceDashboardView: View {
    @EnvironmentObject var perfStore: PerformanceStore
    @EnvironmentObject var actionLog: ActionLogStore

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if perfStore.cardsParsed == 0 {
                    emptyState
                } else {
                    // Parse Performance
                    MetricsSectionCard(title: "Parse Performance", icon: "doc.text.magnifyingglass", color: .blue) {
                        MetricRow(title: "Average", value: String(format: "%.2fms", perfStore.avgParseTime * 1000), trend: .stable)
                        MetricRow(title: "Min", value: String(format: "%.2fms", perfStore.minParseTime * 1000), trend: .down)
                        MetricRow(title: "Max", value: String(format: "%.2fms", perfStore.maxParseTime * 1000), trend: .up)
                        MetricRow(title: "Total Parsed", value: "\(perfStore.cardsParsed)", trend: .stable)
                    }

                    // Render Performance
                    MetricsSectionCard(title: "Render Performance", icon: "paintbrush", color: .purple) {
                        MetricRow(title: "Average", value: String(format: "%.2fms", perfStore.avgRenderTime * 1000), trend: .stable)
                        MetricRow(title: "Min", value: String(format: "%.2fms", perfStore.minRenderTime * 1000), trend: .down)
                        MetricRow(title: "Max", value: String(format: "%.2fms", perfStore.maxRenderTime * 1000), trend: .up)
                        MetricRow(title: "Total Rendered", value: "\(perfStore.cardsRendered)", trend: .stable)
                    }

                    // Memory
                    MetricsSectionCard(title: "Memory Usage", icon: "memorychip", color: .orange) {
                        MetricRow(title: "Current", value: String(format: "%.1f MB", perfStore.currentMemoryMB), trend: .stable)
                        MetricRow(title: "Peak", value: String(format: "%.1f MB", perfStore.peakMemoryMB), trend: .up)
                    }

                    // Actions
                    MetricsSectionCard(title: "Actions", icon: "bolt.fill", color: .green) {
                        MetricRow(title: "Total", value: "\(actionLog.actions.count)", trend: .stable)
                    }
                }

                // Reset button
                Button(role: .destructive) {
                    withAnimation { perfStore.reset() }
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Reset All Metrics")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
                .padding(.top, 4)
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Performance")
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("No data yet")
                .font(.headline)
            Text("Browse cards in the gallery to collect real parse and render metrics.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
}

struct MetricsSectionCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .padding(.bottom, 2)

            content
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
        )
    }
}

struct MetricRow: View {
    let title: String
    let value: String
    let trend: Trend

    enum Trend {
        case up, down, stable

        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .stable: return "arrow.right"
            }
        }

        var color: Color {
            switch self {
            case .up: return .red
            case .down: return .green
            case .stable: return .secondary
            }
        }
    }

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            HStack(spacing: 6) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                Image(systemName: trend.icon)
                    .font(.caption2)
                    .foregroundColor(trend.color)
            }
        }
        .padding(.vertical, 3)
    }
}
