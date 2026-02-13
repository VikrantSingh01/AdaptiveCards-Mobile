import Foundation
// MARK: - Charts

public struct ChartDataPoint: Codable, Equatable, Identifiable {
    public let id: String
    public var label: String
    public var value: Double
    public var color: String?

    // Use label as stable ID (with value to make it unique if needed)
    public var id: String {
        "\(label)_\(value)"
    }

    
    public init(
        label: String,
        value: Double,
        color: String? = nil,
        id: String = UUID().uuidString
    ) {
        self.id = id
        self.label = label
        self.value = value
        self.color = color
    }
    
    private enum CodingKeys: String, CodingKey {
        case label
        case value
        case color
    }
}

public struct DonutChart: Codable, Equatable {
    public let type: String = "DonutChart"
    public var id: String?
    public var title: String?
    public var data: [ChartDataPoint]
    public var colors: [String]?
    public var size: String?
    public var showLegend: Bool?
    public var innerRadiusRatio: Double?
    public var isVisible: Bool?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var requires: [String: String]?

    public init(
        id: String? = nil,
        title: String? = nil,
        data: [ChartDataPoint],
        colors: [String]? = nil,
        size: String? = nil,
        showLegend: Bool? = nil,
        innerRadiusRatio: Double? = nil,
        isVisible: Bool? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        requires: [String: String]? = nil
    ) {
        self.id = id
        self.title = title
        self.data = data
        self.colors = colors
        self.size = size
        self.showLegend = showLegend
        self.innerRadiusRatio = innerRadiusRatio
        self.isVisible = isVisible
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.requires = requires
    }
}

public struct BarChart: Codable, Equatable {
    public let type: String = "BarChart"
    public var id: String?
    public var title: String?
    public var data: [ChartDataPoint]
    public var colors: [String]?
    public var size: String?
    public var showLegend: Bool?
    public var orientation: String?
    public var showValues: Bool?
    public var isVisible: Bool?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var requires: [String: String]?

    public init(
        id: String? = nil,
        title: String? = nil,
        data: [ChartDataPoint],
        colors: [String]? = nil,
        size: String? = nil,
        showLegend: Bool? = nil,
        orientation: String? = nil,
        showValues: Bool? = nil,
        isVisible: Bool? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        requires: [String: String]? = nil
    ) {
        self.id = id
        self.title = title
        self.data = data
        self.colors = colors
        self.size = size
        self.showLegend = showLegend
        self.orientation = orientation
        self.showValues = showValues
        self.isVisible = isVisible
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.requires = requires
    }
}

public struct LineChart: Codable, Equatable {
    public let type: String = "LineChart"
    public var id: String?
    public var title: String?
    public var data: [ChartDataPoint]
    public var colors: [String]?
    public var size: String?
    public var showLegend: Bool?
    public var showDataPoints: Bool?
    public var smooth: Bool?
    public var isVisible: Bool?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var requires: [String: String]?

    public init(
        id: String? = nil,
        title: String? = nil,
        data: [ChartDataPoint],
        colors: [String]? = nil,
        size: String? = nil,
        showLegend: Bool? = nil,
        showDataPoints: Bool? = nil,
        smooth: Bool? = nil,
        isVisible: Bool? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        requires: [String: String]? = nil
    ) {
        self.id = id
        self.title = title
        self.data = data
        self.colors = colors
        self.size = size
        self.showLegend = showLegend
        self.showDataPoints = showDataPoints
        self.smooth = smooth
        self.isVisible = isVisible
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.requires = requires
    }
}

public struct PieChart: Codable, Equatable {
    public let type: String = "PieChart"
    public var id: String?
    public var title: String?
    public var data: [ChartDataPoint]
    public var colors: [String]?
    public var size: String?
    public var showLegend: Bool?
    public var showPercentages: Bool?
    public var isVisible: Bool?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var requires: [String: String]?

    public init(
        id: String? = nil,
        title: String? = nil,
        data: [ChartDataPoint],
        colors: [String]? = nil,
        size: String? = nil,
        showLegend: Bool? = nil,
        showPercentages: Bool? = nil,
        isVisible: Bool? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        requires: [String: String]? = nil
    ) {
        self.id = id
        self.title = title
        self.data = data
        self.colors = colors
        self.size = size
        self.showLegend = showLegend
        self.showPercentages = showPercentages
        self.isVisible = isVisible
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.requires = requires
    }
}
