// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
import ACCore

public struct PieChartView: View {
    let chart: PieChart
    @State private var selectedIndex: Int?
    @State private var animationProgress: CGFloat = 0

    public init(chart: PieChart) {
        self.chart = chart
    }

    private var chartSize: ChartSize {
        ChartSize.from(chart.size)
    }

    private var colors: [Color] {
        ChartColors.colors(from: chart.colors)
    }

    private var total: Double {
        let sum = chart.data.reduce(0) { $0 + $1.value }
        return sum == 0 ? 1 : sum  // Avoid division by zero when data is empty or all zeros
    }

    private var showLegend: Bool {
        chart.showLegend ?? true
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title = chart.title {
                Text(title)
                    .font(.headline)
            }

            GeometryReader { geometry in
                let chartDiameter = showLegend
                    ? min(geometry.size.width * 0.45, geometry.size.height)
                    : min(geometry.size.width * 0.8, geometry.size.height)

                HStack(alignment: .center, spacing: 20) {
                    pieSlices(diameter: chartDiameter)
                        .frame(width: chartDiameter, height: chartDiameter)

                    if showLegend {
                        legend
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .frame(height: chartSize.height)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                animationProgress = 1.0
            }
        }
    }

    private func pieSlices(diameter: CGFloat) -> some View {
        ZStack {
            ForEach(Array(chart.data.enumerated()), id: \.element.id) { index, dataPoint in
                let percentage = dataPoint.value / total
                let startAngle = chart.data.prefix(index).reduce(0) { $0 + $1.value / total } * 360 - 90
                let sweepAngle = percentage * 360 * animationProgress
                let color = dataPoint.color.map { Color(hex: $0) } ?? colors[index % colors.count]

                PieWedge(startAngle: .degrees(startAngle), endAngle: .degrees(startAngle + sweepAngle))
                    .fill(selectedIndex == index ? color.opacity(0.7) : color)
            }

            // Percentage labels overlay
            if chart.showPercentages ?? false, animationProgress > 0.9 {
                ForEach(Array(chart.data.enumerated()), id: \.element.id) { index, dataPoint in
                    let percentage = dataPoint.value / total
                    let startFraction = chart.data.prefix(index).reduce(0) { $0 + $1.value / total }
                    let midAngle = 2 * .pi * (startFraction + percentage / 2) - .pi / 2
                    let labelRadius = diameter / 2 * 0.65

                    Text(String(format: "%.0f%%", percentage * 100))
                        .font(.caption)
                        .bold()
                        .foregroundColor(.white)
                        .position(
                            x: diameter / 2 + labelRadius * cos(midAngle),
                            y: diameter / 2 + labelRadius * sin(midAngle)
                        )
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { location in
            let center = CGPoint(x: diameter / 2, y: diameter / 2)
            let radius = diameter / 2
            let dx = location.x - center.x
            let dy = location.y - center.y
            let distance = sqrt(dx * dx + dy * dy)
            guard distance <= radius else {
                selectedIndex = nil
                return
            }
            var angle = atan2(dy, dx) + .pi / 2
            if angle < 0 { angle += 2 * .pi }
            var startAngle: Double = 0
            for (index, dataPoint) in chart.data.enumerated() {
                let percentage = dataPoint.value / total
                let sweepAngle = 2 * .pi * percentage
                if angle >= startAngle && angle < startAngle + sweepAngle {
                    selectedIndex = selectedIndex == index ? nil : index
                    return
                }
                startAngle += sweepAngle
            }
            selectedIndex = nil
        }
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

    private var accessibilityDescription: String {
        var description = "Pie chart"
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

/// A filled pie wedge from startAngle to endAngle, drawn from the center.
private struct PieWedge: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        var path = Path()
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}
