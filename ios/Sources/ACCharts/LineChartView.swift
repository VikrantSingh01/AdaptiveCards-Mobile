import SwiftUI
import ACCore

public struct LineChartView: View {
    let chart: LineChart
    @State private var selectedIndex: Int?
    @State private var animationProgress: CGFloat = 0

    public init(chart: LineChart) {
        self.chart = chart
    }

    private var chartSize: ChartSize {
        ChartSize.from(chart.size)
    }

    private var colors: [Color] {
        ChartColors.colors(from: chart.colors)
    }

    private var maxValue: Double {
        chart.data.map { $0.value }.max() ?? 1.0
    }

    private var minValue: Double {
        chart.data.map { $0.value }.min() ?? 0.0
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title = chart.title {
                Text(title)
                    .font(.headline)
            }

            lineChart

            if chart.showLegend ?? false {
                legend
            }
        }
        .frame(height: chartSize.height)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                animationProgress = 1.0
            }
        }
    }

    private var lineChart: some View {
        GeometryReader { geometry in
            ZStack {
                // Grid lines
                Canvas { context, size in
                    let gridColor = Color.secondary.opacity(0.2)
                    for i in 0...4 {
                        let y = size.height * CGFloat(i) / 4
                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                        context.stroke(path, with: .color(gridColor), lineWidth: 1)
                    }
                }

                // Line path
                Canvas { context, size in
                    guard chart.data.count > 1 else { return }

                    let padding: CGFloat = 20
                    let availableWidth = size.width - padding * 2
                    let availableHeight = size.height - padding * 2
                    let valueRange = maxValue - minValue

                    let points = chart.data.enumerated().map { index, dataPoint in
                        let x = padding + (availableWidth * CGFloat(index) / CGFloat(chart.data.count - 1))
                        let normalizedValue = (dataPoint.value - minValue) / valueRange
                        let y = size.height - padding - (availableHeight * normalizedValue)
                        return CGPoint(x: x, y: y)
                    }

                    // Draw line
                    var path = Path()
                    if let firstPoint = points.first {
                        path.move(to: firstPoint)

                        if chart.smooth ?? false {
                            // Smooth curve using Catmull-Rom spline
                            for i in 0..<points.count - 1 {
                                let current = points[i]
                                let next = points[i + 1]
                                let controlPoint1 = CGPoint(
                                    x: current.x + (next.x - current.x) * 0.4,
                                    y: current.y
                                )
                                let controlPoint2 = CGPoint(
                                    x: current.x + (next.x - current.x) * 0.6,
                                    y: next.y
                                )
                                path.addCurve(to: next, control1: controlPoint1, control2: controlPoint2)
                            }
                        } else {
                            // Straight lines
                            for point in points.dropFirst() {
                                path.addLine(to: point)
                            }
                        }
                    }

                    let lineColor = colors.first ?? .blue
                    context.stroke(
                        path.trimmedPath(from: 0, to: animationProgress),
                        with: .color(lineColor),
                        lineWidth: 2
                    )

                    // Draw data points if enabled
                    if chart.showDataPoints ?? true {
                        let visibleCount = Int(Double(points.count) * Double(animationProgress))
                        for (index, point) in points.prefix(visibleCount).enumerated() {
                            let dotColor = selectedIndex == index ? lineColor.opacity(0.5) : lineColor
                            context.fill(
                                Circle().path(in: CGRect(x: point.x - 4, y: point.y - 4, width: 8, height: 8)),
                                with: .color(dotColor)
                            )
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        selectedIndex = indexForLocation(value.location, in: geometry)
                    }
                    .onEnded { _ in
                        selectedIndex = nil
                    }
            )
        }
    }

    private var legend: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(chart.data.enumerated()), id: \.offset) { index, dataPoint in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dataPoint.label)
                            .font(.caption2)
                        Text(String(format: "%.1f", dataPoint.value))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .opacity(selectedIndex == nil || selectedIndex == index ? 1.0 : 0.5)
                }
            }
            .padding(.horizontal, 8)
        }
    }

    private func indexForLocation(_ location: CGPoint, in geometry: GeometryProxy) -> Int? {
        let padding: CGFloat = 20
        let availableWidth = geometry.size.width - padding * 2
        guard chart.data.count > 1 else { return nil }

        let relativeX = location.x - padding
        let segmentWidth = availableWidth / CGFloat(chart.data.count - 1)
        let index = Int(round(relativeX / segmentWidth))

        return index >= 0 && index < chart.data.count ? index : nil
    }

    private var accessibilityDescription: String {
        var description = "Line chart"
        if let title = chart.title {
            description += " titled \(title)"
        }
        description += ". \(chart.data.count) data points: "

        let points = chart.data.map { dataPoint in
            "\(dataPoint.label) \(String(format: "%.1f", dataPoint.value))"
        }.joined(separator: ", ")

        description += points
        return description
    }
}
