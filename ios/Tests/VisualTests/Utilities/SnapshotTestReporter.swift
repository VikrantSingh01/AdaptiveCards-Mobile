#if canImport(UIKit)
import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Generates HTML and JSON reports from snapshot test results
public class SnapshotTestReporter {

    /// Collected results across test runs
    private var results: [TestRunResult] = []

    public struct TestRunResult {
        public let cardName: String
        public let configurationName: String
        public let passed: Bool
        public let diffPercentage: Double
        public let baselinePath: String?
        public let actualPath: String?
        public let diffPath: String?
        public let duration: TimeInterval
    }

    public init() {}

    /// Records a snapshot diff result along with metadata
    public func record(
        cardName: String,
        configuration: String,
        result: SnapshotDiffResult,
        duration: TimeInterval = 0
    ) {
        results.append(TestRunResult(
            cardName: cardName,
            configurationName: configuration,
            passed: result.passed,
            diffPercentage: result.diffPercentage,
            baselinePath: result.baselinePath,
            actualPath: result.actualPath,
            diffPath: result.diffPath,
            duration: duration
        ))
    }

    /// Generates a summary dictionary of the test run
    public func summary() -> [String: Any] {
        let total = results.count
        let passed = results.filter(\.passed).count
        let failed = total - passed

        let failedCards = results
            .filter { !$0.passed }
            .map { "\($0.cardName) (\($0.configurationName)): \(String(format: "%.2f%%", $0.diffPercentage * 100)) diff" }

        let avgDiff = results.isEmpty ? 0 :
            results.map(\.diffPercentage).reduce(0, +) / Double(results.count)

        let totalDuration = results.map(\.duration).reduce(0, +)

        return [
            "total": total,
            "passed": passed,
            "failed": failed,
            "passRate": total > 0 ? String(format: "%.1f%%", Double(passed) / Double(total) * 100) : "N/A",
            "averageDiff": String(format: "%.4f%%", avgDiff * 100),
            "totalDuration": String(format: "%.2fs", totalDuration),
            "failedCards": failedCards
        ]
    }

    /// Generates a JSON report and writes it to disk
    public func generateJSONReport(to path: String) {
        let report: [String: Any] = [
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "summary": summary(),
            "results": results.map { result -> [String: Any] in
                [
                    "cardName": result.cardName,
                    "configuration": result.configurationName,
                    "passed": result.passed,
                    "diffPercentage": result.diffPercentage,
                    "duration": result.duration,
                    "baselinePath": result.baselinePath ?? "",
                    "actualPath": result.actualPath ?? "",
                    "diffPath": result.diffPath ?? ""
                ]
            }
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

    /// Generates an HTML report with visual diff previews
    public func generateHTMLReport(to path: String) {
        let summaryInfo = summary()
        let total = summaryInfo["total"] as? Int ?? 0
        let passed = summaryInfo["passed"] as? Int ?? 0
        let failed = summaryInfo["failed"] as? Int ?? 0

        var html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Adaptive Cards Visual Regression Report</title>
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f5f5f5; padding: 20px; }
                .header { background: #1a1a2e; color: white; padding: 30px; border-radius: 12px; margin-bottom: 20px; }
                .header h1 { font-size: 24px; margin-bottom: 10px; }
                .stats { display: flex; gap: 20px; margin-top: 15px; }
                .stat { background: rgba(255,255,255,0.1); padding: 15px 20px; border-radius: 8px; text-align: center; }
                .stat .number { font-size: 28px; font-weight: bold; }
                .stat .label { font-size: 12px; opacity: 0.8; margin-top: 4px; }
                .stat.pass .number { color: #4ade80; }
                .stat.fail .number { color: #f87171; }
                .filters { background: white; padding: 15px 20px; border-radius: 8px; margin-bottom: 20px; display: flex; gap: 10px; }
                .filters button { padding: 8px 16px; border: 1px solid #ddd; border-radius: 6px; background: white; cursor: pointer; font-size: 14px; }
                .filters button.active { background: #1a1a2e; color: white; border-color: #1a1a2e; }
                .card-grid { display: grid; gap: 16px; }
                .result-card { background: white; border-radius: 8px; padding: 20px; border-left: 4px solid; }
                .result-card.passed { border-color: #4ade80; }
                .result-card.failed { border-color: #f87171; }
                .result-card .title { font-size: 16px; font-weight: 600; margin-bottom: 8px; }
                .result-card .meta { font-size: 13px; color: #666; display: flex; gap: 15px; }
                .result-card .badge { display: inline-block; padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: 600; }
                .badge.pass { background: #dcfce7; color: #166534; }
                .badge.fail { background: #fee2e2; color: #991b1b; }
                .image-row { display: flex; gap: 10px; margin-top: 12px; overflow-x: auto; }
                .image-row img { max-height: 200px; border: 1px solid #eee; border-radius: 4px; }
                .image-label { font-size: 11px; color: #999; text-align: center; margin-top: 4px; }
            </style>
        </head>
        <body>
            <div class="header">
                <h1>Adaptive Cards Visual Regression Report</h1>
                <p>Generated: \(DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .medium))</p>
                <div class="stats">
                    <div class="stat"><div class="number">\(total)</div><div class="label">Total Tests</div></div>
                    <div class="stat pass"><div class="number">\(passed)</div><div class="label">Passed</div></div>
                    <div class="stat fail"><div class="number">\(failed)</div><div class="label">Failed</div></div>
                    <div class="stat"><div class="number">\(summaryInfo["passRate"] as? String ?? "N/A")</div><div class="label">Pass Rate</div></div>
                    <div class="stat"><div class="number">\(summaryInfo["totalDuration"] as? String ?? "N/A")</div><div class="label">Duration</div></div>
                </div>
            </div>
            <div class="filters">
                <button class="active" onclick="filterResults('all')">All (\(total))</button>
                <button onclick="filterResults('passed')">Passed (\(passed))</button>
                <button onclick="filterResults('failed')">Failed (\(failed))</button>
            </div>
            <div class="card-grid">
        """

        for result in results {
            let statusClass = result.passed ? "passed" : "failed"
            let badgeClass = result.passed ? "pass" : "fail"
            let badgeText = result.passed ? "PASS" : "FAIL"

            html += """
                <div class="result-card \(statusClass)" data-status="\(statusClass)">
                    <div class="title">\(result.cardName) <span class="badge \(badgeClass)">\(badgeText)</span></div>
                    <div class="meta">
                        <span>Config: \(result.configurationName)</span>
                        <span>Diff: \(String(format: "%.4f%%", result.diffPercentage * 100))</span>
                        <span>Duration: \(String(format: "%.3fs", result.duration))</span>
                    </div>
            """

            if !result.passed {
                html += """
                    <div class="image-row">
                """
                if let baselinePath = result.baselinePath {
                    html += """
                        <div><img src="file://\(baselinePath)" alt="Baseline"><div class="image-label">Baseline</div></div>
                    """
                }
                if let actualPath = result.actualPath {
                    html += """
                        <div><img src="file://\(actualPath)" alt="Actual"><div class="image-label">Actual</div></div>
                    """
                }
                if let diffPath = result.diffPath {
                    html += """
                        <div><img src="file://\(diffPath)" alt="Diff"><div class="image-label">Diff</div></div>
                    """
                }
                html += """
                    </div>
                """
            }

            html += """
                </div>
            """
        }

        html += """
            </div>
            <script>
                function filterResults(status) {
                    document.querySelectorAll('.filters button').forEach(b => b.classList.remove('active'));
                    event.target.classList.add('active');
                    document.querySelectorAll('.result-card').forEach(card => {
                        if (status === 'all' || card.dataset.status === status) {
                            card.style.display = '';
                        } else {
                            card.style.display = 'none';
                        }
                    });
                }
            </script>
        </body>
        </html>
        """

        let url = URL(fileURLWithPath: path)
        try? FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try? html.write(to: url, atomically: true, encoding: .utf8)
    }

    /// Prints a console-friendly summary
    public func printSummary() {
        let s = summary()
        let divider = String(repeating: "=", count: 60)

        print("""

        \(divider)
        VISUAL REGRESSION TEST REPORT
        \(divider)
        Total:     \(s["total"] ?? 0)
        Passed:    \(s["passed"] ?? 0)
        Failed:    \(s["failed"] ?? 0)
        Pass Rate: \(s["passRate"] ?? "N/A")
        Avg Diff:  \(s["averageDiff"] ?? "N/A")
        Duration:  \(s["totalDuration"] ?? "N/A")
        \(divider)
        """)

        if let failedCards = s["failedCards"] as? [String], !failedCards.isEmpty {
            print("FAILURES:")
            for card in failedCards {
                print("  - \(card)")
            }
            print(divider)
        }
    }
}
#endif // canImport(UIKit)
