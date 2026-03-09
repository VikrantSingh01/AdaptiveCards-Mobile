#if canImport(UIKit)
import XCTest
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
@testable import ACCore
@testable import ACRendering

// MARK: - Performance Metrics

/// Stores performance measurements for a single card
public struct CardPerformanceMetrics {
    public let cardName: String
    public let fileSize: Int
    public let elementCount: Int
    public let parseTime: TimeInterval
    public let renderTime: TimeInterval
    public let peakMemoryDelta: Int64
    public let passed: Bool
    public let failureReason: String?

    /// Human-readable summary
    public var summary: String {
        let status = passed ? "PASS" : "FAIL"
        var text = """
        [\(status)] \(cardName)
          File size:      \(ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file))
          Elements:       \(elementCount)
          Parse time:     \(String(format: "%.3f ms", parseTime * 1000))
          Render time:    \(String(format: "%.3f ms", renderTime * 1000))
          Memory delta:   \(ByteCountFormatter.string(fromByteCount: peakMemoryDelta, countStyle: .memory))
        """
        if let reason = failureReason {
            text += "\n  Failure:        \(reason)"
        }
        return text
    }
}

// MARK: - Performance Thresholds

/// Configurable thresholds for pass/fail determination
public struct PerformanceThresholds {
    /// Maximum acceptable parse time in seconds
    public let maxParseTime: TimeInterval
    /// Maximum acceptable render time in seconds
    public let maxRenderTime: TimeInterval
    /// Maximum acceptable memory increase in bytes
    public let maxMemoryDelta: Int64
    /// Maximum acceptable total time (parse + render) in seconds
    public let maxTotalTime: TimeInterval

    public init(
        maxParseTime: TimeInterval = 0.1,      // 100ms
        maxRenderTime: TimeInterval = 0.5,      // 500ms
        maxMemoryDelta: Int64 = 50_000_000,     // 50MB
        maxTotalTime: TimeInterval = 0.6        // 600ms
    ) {
        self.maxParseTime = maxParseTime
        self.maxRenderTime = maxRenderTime
        self.maxMemoryDelta = maxMemoryDelta
        self.maxTotalTime = maxTotalTime
    }

    public static let `default` = PerformanceThresholds()

    /// Relaxed thresholds for complex cards
    public static let complex = PerformanceThresholds(
        maxParseTime: 0.25,
        maxRenderTime: 1.0,
        maxMemoryDelta: 100_000_000,
        maxTotalTime: 1.25
    )

    /// Strict thresholds for simple cards
    public static let strict = PerformanceThresholds(
        maxParseTime: 0.05,
        maxRenderTime: 0.2,
        maxMemoryDelta: 20_000_000,
        maxTotalTime: 0.25
    )
}

// MARK: - Performance Test Runner

/// Executes performance measurements for Adaptive Cards
public class CardPerformanceRunner {

    private let parser = CardParser()
    private let thresholds: PerformanceThresholds

    public init(thresholds: PerformanceThresholds = .default) {
        self.thresholds = thresholds
    }

    /// Measures performance for a single card
    public func measure(cardName: String, json: String) -> CardPerformanceMetrics {
        let fileSize = json.utf8.count
        var elementCount = 0
        var parseTime: TimeInterval = 0
        var renderTime: TimeInterval = 0
        var memoryDelta: Int64 = 0

        // Measure parse time (average of 5 runs)
        var card: AdaptiveCard?
        var parseTimes: [TimeInterval] = []

        for _ in 0..<5 {
            let start = CFAbsoluteTimeGetCurrent()
            card = try? parser.parse(json)
            let end = CFAbsoluteTimeGetCurrent()
            parseTimes.append(end - start)
        }
        parseTime = parseTimes.sorted().dropFirst().dropLast().reduce(0, +) / Double(max(parseTimes.count - 2, 1))

        guard let parsedCard = card else {
            return CardPerformanceMetrics(
                cardName: cardName,
                fileSize: fileSize,
                elementCount: 0,
                parseTime: parseTime,
                renderTime: 0,
                peakMemoryDelta: 0,
                passed: false,
                failureReason: "Failed to parse card"
            )
        }

        // Count elements
        elementCount = countElements(in: parsedCard)

        // Measure render time
        let memoryBefore = currentMemoryUsage()
        var renderTimes: [TimeInterval] = []

        for _ in 0..<3 {
            let start = CFAbsoluteTimeGetCurrent()
            _ = renderCard(json: json)
            let end = CFAbsoluteTimeGetCurrent()
            renderTimes.append(end - start)
        }
        renderTime = renderTimes.sorted().dropFirst().dropLast().isEmpty
            ? (renderTimes.first ?? 0)
            : renderTimes.sorted().dropFirst().dropLast().reduce(0, +) / Double(max(renderTimes.count - 2, 1))

        let memoryAfter = currentMemoryUsage()
        memoryDelta = memoryAfter - memoryBefore

        // Evaluate against thresholds
        var failures: [String] = []

        if parseTime > thresholds.maxParseTime {
            failures.append("Parse time \(String(format: "%.1fms", parseTime * 1000)) exceeds \(String(format: "%.1fms", thresholds.maxParseTime * 1000))")
        }
        if renderTime > thresholds.maxRenderTime {
            failures.append("Render time \(String(format: "%.1fms", renderTime * 1000)) exceeds \(String(format: "%.1fms", thresholds.maxRenderTime * 1000))")
        }
        if memoryDelta > thresholds.maxMemoryDelta {
            failures.append("Memory delta \(ByteCountFormatter.string(fromByteCount: memoryDelta, countStyle: .memory)) exceeds \(ByteCountFormatter.string(fromByteCount: thresholds.maxMemoryDelta, countStyle: .memory))")
        }
        let totalTime = parseTime + renderTime
        if totalTime > thresholds.maxTotalTime {
            failures.append("Total time \(String(format: "%.1fms", totalTime * 1000)) exceeds \(String(format: "%.1fms", thresholds.maxTotalTime * 1000))")
        }

        return CardPerformanceMetrics(
            cardName: cardName,
            fileSize: fileSize,
            elementCount: elementCount,
            parseTime: parseTime,
            renderTime: renderTime,
            peakMemoryDelta: memoryDelta,
            passed: failures.isEmpty,
            failureReason: failures.isEmpty ? nil : failures.joined(separator: "; ")
        )
    }

    /// Renders a card view and returns a UIImage
    private func renderCard(json: String) -> UIImage? {
        let view = AdaptiveCardView(cardJson: json)
        let hostingController = UIHostingController(rootView: view)
        let size = CGSize(width: 393, height: 852)

        hostingController.view.frame = CGRect(origin: .zero, size: size)
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            hostingController.view.drawHierarchy(in: CGRect(origin: .zero, size: size), afterScreenUpdates: true)
        }
    }

    /// Counts total elements in a card recursively
    private func countElements(in card: AdaptiveCard) -> Int {
        var count = 0
        if let body = card.body {
            for element in body {
                count += countElementsRecursive(element)
            }
        }
        if let actions = card.actions {
            count += actions.count
        }
        return count
    }

    private func countElementsRecursive(_ element: CardElement) -> Int {
        var count = 1
        switch element {
        case .container(let container):
            for item in container.items ?? [] {
                count += countElementsRecursive(item)
            }
        case .columnSet(let columnSet):
            for column in columnSet.columns {
                for item in column.items ?? [] {
                    count += countElementsRecursive(item)
                }
            }
        default:
            break
        }
        return count
    }

    /// Returns current memory usage in bytes
    private func currentMemoryUsage() -> Int64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        return result == KERN_SUCCESS ? Int64(info.resident_size) : 0
    }
}

// MARK: - Performance Report Generator

/// Generates formatted performance reports
public class PerformanceReportGenerator {

    private var metrics: [CardPerformanceMetrics] = []

    public init() {}

    public func add(_ metric: CardPerformanceMetrics) {
        metrics.append(metric)
    }

    public func addAll(_ newMetrics: [CardPerformanceMetrics]) {
        metrics.append(contentsOf: newMetrics)
    }

    /// Generates a console-friendly performance report
    public func printReport() {
        let divider = String(repeating: "=", count: 80)
        let passed = metrics.filter(\.passed).count
        let failed = metrics.count - passed

        print("""

        \(divider)
        PERFORMANCE TEST REPORT
        \(divider)
        Total cards tested: \(metrics.count)
        Passed:             \(passed)
        Failed:             \(failed)
        \(divider)

        """)

        // Print per-card results
        for metric in metrics.sorted(by: { $0.parseTime + $0.renderTime > $1.parseTime + $1.renderTime }) {
            print(metric.summary)
            print("")
        }

        // Print aggregate stats
        if !metrics.isEmpty {
            let parseTimes = metrics.map(\.parseTime)
            let renderTimes = metrics.map(\.renderTime)
            let totalTimes = metrics.map { $0.parseTime + $0.renderTime }

            print("""
            \(divider)
            AGGREGATE STATISTICS
            \(divider)
            Parse time  - avg: \(String(format: "%.3f ms", (parseTimes.reduce(0, +) / Double(parseTimes.count)) * 1000)), \
            min: \(String(format: "%.3f ms", (parseTimes.min() ?? 0) * 1000)), \
            max: \(String(format: "%.3f ms", (parseTimes.max() ?? 0) * 1000))
            Render time - avg: \(String(format: "%.3f ms", (renderTimes.reduce(0, +) / Double(renderTimes.count)) * 1000)), \
            min: \(String(format: "%.3f ms", (renderTimes.min() ?? 0) * 1000)), \
            max: \(String(format: "%.3f ms", (renderTimes.max() ?? 0) * 1000))
            Total time  - avg: \(String(format: "%.3f ms", (totalTimes.reduce(0, +) / Double(totalTimes.count)) * 1000)), \
            min: \(String(format: "%.3f ms", (totalTimes.min() ?? 0) * 1000)), \
            max: \(String(format: "%.3f ms", (totalTimes.max() ?? 0) * 1000))
            \(divider)
            """)
        }
    }

    /// Generates a JSON performance report
    public func generateJSONReport(to path: String) {
        let report: [String: Any] = [
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "totalCards": metrics.count,
            "passed": metrics.filter(\.passed).count,
            "failed": metrics.count - metrics.filter(\.passed).count,
            "cards": metrics.map { metric -> [String: Any] in
                [
                    "name": metric.cardName,
                    "fileSize": metric.fileSize,
                    "elementCount": metric.elementCount,
                    "parseTimeMs": metric.parseTime * 1000,
                    "renderTimeMs": metric.renderTime * 1000,
                    "totalTimeMs": (metric.parseTime + metric.renderTime) * 1000,
                    "memoryDeltaBytes": metric.peakMemoryDelta,
                    "passed": metric.passed,
                    "failureReason": metric.failureReason ?? ""
                ]
            },
            "aggregate": computeAggregateStats()
        ]

        if let data = try? JSONSerialization.data(withJSONObject: report, options: .prettyPrinted) {
            let url = URL(fileURLWithPath: path)
            try? FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try? data.write(to: url)
        }
    }

    private func computeAggregateStats() -> [String: Any] {
        guard !metrics.isEmpty else { return [:] }

        let parseTimes = metrics.map(\.parseTime)
        let renderTimes = metrics.map(\.renderTime)
        let totalTimes = metrics.map { $0.parseTime + $0.renderTime }
        let fileSizes = metrics.map(\.fileSize)
        let elementCounts = metrics.map(\.elementCount)

        return [
            "avgParseTimeMs": (parseTimes.reduce(0, +) / Double(parseTimes.count)) * 1000,
            "maxParseTimeMs": (parseTimes.max() ?? 0) * 1000,
            "minParseTimeMs": (parseTimes.min() ?? 0) * 1000,
            "avgRenderTimeMs": (renderTimes.reduce(0, +) / Double(renderTimes.count)) * 1000,
            "maxRenderTimeMs": (renderTimes.max() ?? 0) * 1000,
            "minRenderTimeMs": (renderTimes.min() ?? 0) * 1000,
            "avgTotalTimeMs": (totalTimes.reduce(0, +) / Double(totalTimes.count)) * 1000,
            "maxTotalTimeMs": (totalTimes.max() ?? 0) * 1000,
            "avgFileSize": fileSizes.reduce(0, +) / fileSizes.count,
            "avgElementCount": elementCounts.reduce(0, +) / elementCounts.count,
            "totalElements": elementCounts.reduce(0, +)
        ]
    }
}
#endif // canImport(UIKit)
