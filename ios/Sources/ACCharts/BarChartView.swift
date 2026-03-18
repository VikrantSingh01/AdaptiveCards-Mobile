// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
import ACCore

public struct BarChartView: View {
    let chart: BarChart
    @State private var selectedIndex: Int?
    @State private var animationProgress: CGFloat = 0

    public init(chart: BarChart) {
        self.chart = chart
    }

    private var chartSize: ChartSize {
        ChartSize.from(chart.size)
    }

    private var colors: [Color] {
        ChartColors.colors(from: chart.colors)
    }

    private var maxValue: Double {
        let val = chart.data.map { $0.value }.max() ?? 1.0
        return val == 0 ? 1.0 : val  // Avoid division by zero when all values are 0
    }

    private var isHorizontal: Bool {
        chart.orientation?.lowercased() == "horizontal"
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title = chart.title {
                Text(title)
                    .font(.headline)
            }

            if isHorizontal {
                horizontalBars
            } else {
                verticalBars
            }

            if chart.showLegend ?? false {
                legend
            }
        }
        .frame(height: chartSize.height)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animationProgress = 1.0
            }
        }
    }

    private var verticalBars: some View {
        GeometryReader { geometry in
            let labelHeight: CGFloat = 16
            let valueHeight: CGFloat = (chart.showValues ?? false) ? 16 : 0
            // Use proportional sizing (matching Android 0.8f fraction) so labels always have room
            let barAreaHeight = max(geometry.size.height * 0.75 - valueHeight, 0)

            VStack(spacing: 0) {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(Array(chart.data.enumerated()), id: \.element.id) { index, dataPoint in
                        VStack(spacing: 2) {
                            if chart.showValues ?? false {
                                Text(String(format: "%.0f", dataPoint.value))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(height: valueHeight)
                            }

                            let color = dataPoint.color.map { Color(hex: $0) } ?? colors[index % colors.count] // safe: data-driven color from card JSON
                            let height = (dataPoint.value / maxValue) * barAreaHeight * animationProgress // safe: maxValue guarded >= 1.0 in computed property

                            RoundedRectangle(cornerRadius: 4)
                                .fill(selectedIndex == index ? color.opacity(0.7) : color)
                                .frame(height: height)
                                .onTapGesture {
                                    selectedIndex = selectedIndex == index ? nil : index
                                }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 8)
                .frame(height: barAreaHeight + valueHeight + 4)

                // X-axis labels — fixed height, never clipped
                HStack(spacing: 8) {
                    ForEach(chart.data, id: \.id) { dataPoint in
                        Text(dataPoint.label)
                            .font(.caption2)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 8)
                .frame(height: labelHeight)
            }
        }
    }

    private var horizontalBars: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(chart.data.enumerated()), id: \.element.id) { index, dataPoint in
                    HStack(spacing: 8) {
                        Text(dataPoint.label)
                            .font(.caption)
                            .frame(width: 80, alignment: .trailing)

                        GeometryReader { geometry in
                            let color = dataPoint.color.map { Color(hex: $0) } ?? colors[index % colors.count] // safe: data-driven color from card JSON
                            let width = (dataPoint.value / maxValue) * geometry.size.width * animationProgress // safe: maxValue guarded >= 1.0 in computed property

                            RoundedRectangle(cornerRadius: 4)
                                .fill(selectedIndex == index ? color.opacity(0.7) : color)
                                .frame(width: width, height: 24)
                        }
                        .frame(height: 24)

                        if chart.showValues ?? false {
                            Text(String(format: "%.0f", dataPoint.value))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 50, alignment: .leading)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedIndex = selectedIndex == index ? nil : index
                    }
                }
            }
            .padding(.horizontal, 8)
        }
    }

    private var legend: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(chart.data.enumerated()), id: \.element.id) { index, dataPoint in
                    HStack(spacing: 4) {
                        let color = dataPoint.color.map { Color(hex: $0) } ?? colors[index % colors.count] // safe: data-driven color from card JSON
                        RoundedRectangle(cornerRadius: 2)
                            .fill(color)
                            .frame(width: 12, height: 12)

                        Text(dataPoint.label)
                            .font(.caption2)
                    }
                    .opacity(selectedIndex == nil || selectedIndex == index ? 1.0 : 0.5)
                }
            }
            .padding(.horizontal, 8)
        }
    }

    private var accessibilityDescription: String {
        var description = "\(isHorizontal ? "Horizontal" : "Vertical") bar chart"
        if let title = chart.title {
            description += " titled \(title)"
        }
        description += ". \(chart.data.count) bars: "

        let bars = chart.data.map { dataPoint in
            "\(dataPoint.label) \(String(format: "%.0f", dataPoint.value))"
        }.joined(separator: ", ")

        description += bars
        return description
    }
}
