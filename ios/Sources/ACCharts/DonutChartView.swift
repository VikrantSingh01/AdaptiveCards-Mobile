import SwiftUI
import ACCore

public struct DonutChartView: View {
    let chart: DonutChart
    @State private var selectedIndex: Int?
    @State private var animationProgress: CGFloat = 0

    public init(chart: DonutChart) {
        self.chart = chart
    }

    private var chartSize: ChartSize {
        ChartSize.from(chart.size)
    }

    private var colors: [Color] {
        ChartColors.colors(from: chart.colors)
    }

    private var total: Double {
        chart.data.reduce(0) { $0 + $1.value }
    }

    private var innerRadiusRatio: CGFloat {
        CGFloat(chart.innerRadiusRatio ?? 0.5)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title = chart.title {
                Text(title)
                    .font(.headline)
            }

            HStack(alignment: .center, spacing: 20) {
                donutChart
                    .frame(height: chartSize.height)

                if chart.showLegend ?? true {
                    legend
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                animationProgress = 1.0
            }
        }
    }

    private var donutChart: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let radius = size / 2
            let lineWidth = radius * (1 - innerRadiusRatio)

            Canvas { context, canvasSize in
                var startAngle = Angle.degrees(-90)

                for (index, dataPoint) in chart.data.enumerated() {
                    let percentage = dataPoint.value / total
                    let sweepAngle = Angle.degrees(360 * percentage * Double(animationProgress))

                    let color = dataPoint.color.map { Color(hex: $0) } ?? colors[index % colors.count]

                    var path = Path()
                    path.addArc(
                        center: CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2),
                        radius: radius - lineWidth / 2,
                        startAngle: startAngle,
                        endAngle: startAngle + sweepAngle,
                        clockwise: false
                    )

                    context.stroke(
                        path,
                        with: .color(selectedIndex == index ? color.opacity(0.7) : color),
                        lineWidth: lineWidth
                    )

                    startAngle += sweepAngle
                }
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .contentShape(Rectangle())
            .onTapGesture { location in
                selectedIndex = indexForTap(at: location, in: geometry, radius: radius)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var legend: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(chart.data.enumerated()), id: \.element.id) { index, dataPoint in
                HStack(spacing: 8) {
                    let color = dataPoint.color.map { Color(hex: $0) } ?? colors[index % colors.count]
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: 16, height: 16)

                    Text(dataPoint.label)
                        .font(.caption)

                    Spacer()

                    Text(String(format: "%.0f%%", (dataPoint.value / total) * 100))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .opacity(selectedIndex == nil || selectedIndex == index ? 1.0 : 0.5)
                .onTapGesture {
                    selectedIndex = selectedIndex == index ? nil : index
                }
            }
        }
    }

    private func indexForTap(at location: CGPoint, in geometry: GeometryProxy, radius: CGFloat) -> Int? {
        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
        let dx = location.x - center.x
        let dy = location.y - center.y
        let distance = sqrt(dx * dx + dy * dy)

        guard distance <= radius && distance >= radius * innerRadiusRatio else { return nil }

        var angle = atan2(dy, dx) + .pi / 2
        if angle < 0 { angle += 2 * .pi }

        var startAngle: Double = 0
        for (index, dataPoint) in chart.data.enumerated() {
            let percentage = dataPoint.value / total
            let sweepAngle = 2 * .pi * percentage

            if angle >= startAngle && angle < startAngle + sweepAngle {
                return index
            }
            startAngle += sweepAngle
        }

        return nil
    }

    private var accessibilityDescription: String {
        var description = "Donut chart"
        if let title = chart.title {
            description += " titled \(title)"
        }
        description += ". \(chart.data.count) segments: "

        let segments = chart.data.map { dataPoint in
            let percentage = (dataPoint.value / total) * 100
            return "\(dataPoint.label) \(String(format: "%.0f%%", percentage))"
        }.joined(separator: ", ")

        description += segments
        return description
    }
}
