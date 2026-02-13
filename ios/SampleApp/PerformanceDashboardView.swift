import SwiftUI

struct PerformanceDashboardView: View {
    @State private var metrics: PerformanceMetrics = .sample
    @State private var isRecording: Bool = false

    var body: some View {
        List {
            Section("Parse Performance") {
                MetricRow(title: "Average Parse Time", value: String(format: "%.2fms", metrics.avgParseTime * 1000), trend: .stable)
                MetricRow(title: "Min Parse Time", value: String(format: "%.2fms", metrics.minParseTime * 1000), trend: .down)
                MetricRow(title: "Max Parse Time", value: String(format: "%.2fms", metrics.maxParseTime * 1000), trend: .up)
                MetricRow(title: "Cards Parsed", value: "\(metrics.cardsParsed)", trend: .stable)
            }

            Section("Render Performance") {
                MetricRow(title: "Average Render Time", value: String(format: "%.2fms", metrics.avgRenderTime * 1000), trend: .stable)
                MetricRow(title: "Min Render Time", value: String(format: "%.2fms", metrics.minRenderTime * 1000), trend: .down)
                MetricRow(title: "Max Render Time", value: String(format: "%.2fms", metrics.maxRenderTime * 1000), trend: .up)
                MetricRow(title: "Cards Rendered", value: "\(metrics.cardsRendered)", trend: .stable)
            }

            Section("Memory Usage") {
                MetricRow(title: "Current Usage", value: String(format: "%.1f MB", metrics.currentMemoryMB), trend: .stable)
                MetricRow(title: "Peak Usage", value: String(format: "%.1f MB", metrics.peakMemoryMB), trend: .up)
                MetricRow(title: "Average Usage", value: String(format: "%.1f MB", metrics.avgMemoryMB), trend: .stable)
            }

            Section("Actions") {
                MetricRow(title: "Total Actions", value: "\(metrics.totalActions)", trend: .up)
                MetricRow(title: "Action Success Rate", value: String(format: "%.1f%%", metrics.actionSuccessRate * 100), trend: .stable)
            }

            Section {
                Button(action: {
                    isRecording.toggle()
                }) {
                    HStack {
                        Image(systemName: isRecording ? "stop.circle.fill" : "record.circle")
                        Text(isRecording ? "Stop Recording" : "Start Recording")
                    }
                    .foregroundColor(isRecording ? .red : .blue)
                }

                Button("Reset Metrics") {
                    resetMetrics()
                }

                Button("Export Report") {
                    exportReport()
                }
            }
        }
        .navigationTitle("Performance")
        .onAppear {
            loadMetrics()
        }
    }

    private func loadMetrics() {
        // Load real metrics in production
        metrics = .sample
    }

    private func resetMetrics() {
        metrics = PerformanceMetrics(
            avgParseTime: 0,
            minParseTime: 0,
            maxParseTime: 0,
            avgRenderTime: 0,
            minRenderTime: 0,
            maxRenderTime: 0,
            cardsParsed: 0,
            cardsRendered: 0,
            totalActions: 0,
            actionSuccessRate: 0,
            currentMemoryMB: 0,
            peakMemoryMB: 0,
            avgMemoryMB: 0
        )
    }

    private func exportReport() {
        print("Exporting performance report...")
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
            case .stable: return .gray
            }
        }
    }

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            HStack(spacing: 8) {
                Text(value)
                    .fontWeight(.semibold)
                Image(systemName: trend.icon)
                    .font(.caption)
                    .foregroundColor(trend.color)
            }
        }
    }
}

struct PerformanceMetrics {
    var avgParseTime: TimeInterval
    var minParseTime: TimeInterval
    var maxParseTime: TimeInterval
    var avgRenderTime: TimeInterval
    var minRenderTime: TimeInterval
    var maxRenderTime: TimeInterval
    var cardsParsed: Int
    var cardsRendered: Int
    var totalActions: Int
    var actionSuccessRate: Double
    var currentMemoryMB: Double
    var peakMemoryMB: Double
    var avgMemoryMB: Double

    static let sample = PerformanceMetrics(
        avgParseTime: 0.0023,
        minParseTime: 0.0012,
        maxParseTime: 0.0045,
        avgRenderTime: 0.0087,
        minRenderTime: 0.0034,
        maxRenderTime: 0.0156,
        cardsParsed: 127,
        cardsRendered: 127,
        totalActions: 45,
        actionSuccessRate: 0.978,
        currentMemoryMB: 18.5,
        peakMemoryMB: 24.3,
        avgMemoryMB: 16.8
    )
}
