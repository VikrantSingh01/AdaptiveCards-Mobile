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
        chart.data.map { $0.value }.max() ?? 1.0
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
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(chart.data) { dataPoint in
                    VStack(spacing: 4) {
                        if chart.showValues ?? false {
                            Text(String(format: "%.0f", dataPoint.value))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        let index = chart.data.firstIndex(where: { $0.id == dataPoint.id }) ?? 0
                        let color = dataPoint.color.map { Color(hex: $0) } ?? colors[index % colors.count]
                        let height = (dataPoint.value / maxValue) * (geometry.size.height - 40) * animationProgress
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(selectedIndex == index ? color.opacity(0.7) : color)
                            .frame(height: height)
                            .onTapGesture {
                                selectedIndex = selectedIndex == index ? nil : index
                            }
                        
                        Text(dataPoint.label)
                            .font(.caption2)
                            .lineLimit(1)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 8)
        }
    }
    
    private var horizontalBars: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(chart.data) { dataPoint in
                    HStack(spacing: 8) {
                        Text(dataPoint.label)
                            .font(.caption)
                            .frame(width: 80, alignment: .trailing)
                        
                        GeometryReader { geometry in
                            let index = chart.data.firstIndex(where: { $0.id == dataPoint.id }) ?? 0
                            let color = dataPoint.color.map { Color(hex: $0) } ?? colors[index % colors.count]
                            let width = (dataPoint.value / maxValue) * geometry.size.width * animationProgress
                            
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
                        let index = chart.data.firstIndex(where: { $0.id == dataPoint.id }) ?? 0
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
                ForEach(chart.data) { dataPoint in
                    HStack(spacing: 4) {
                        let index = chart.data.firstIndex(where: { $0.id == dataPoint.id }) ?? 0
                        let color = dataPoint.color.map { Color(hex: $0) } ?? colors[index % colors.count]
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
