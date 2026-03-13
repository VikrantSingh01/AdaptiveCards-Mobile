// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import Foundation

// MARK: - Layout Protocol

/// A type-erased layout descriptor for containers.
/// Containers can use FlowLayout, AreaGridLayout, or default stack layout.
public enum Layout: Codable, Equatable {
    case flow(FlowLayout)
    case areaGrid(AreaGridLayout)

    private enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type.lowercased() {
        case "layout.flow":
            let flow = try FlowLayout(from: decoder)
            self = .flow(flow)
        case "layout.areagrid":
            let grid = try AreaGridLayout(from: decoder)
            self = .areaGrid(grid)
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unknown layout type: \(type)"
                )
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .flow(let layout):
            try layout.encode(to: encoder)
        case .areaGrid(let layout):
            try layout.encode(to: encoder)
        }
    }
}

// MARK: - FlowLayout

/// A flow layout that wraps items across multiple rows, similar to CSS flexbox wrap.
///
/// Ported from production AdaptiveCards C++ ObjectModel `FlowLayout` class.
/// Used when a Container's `layout` property is set to `"Layout.Flow"`.
///
/// Example JSON:
/// ```json
/// {
///   "type": "Container",
///   "layout": {
///     "type": "Layout.Flow",
///     "itemFit": "Fit",
///     "itemWidth": "100px",
///     "columnSpacing": "Small",
///     "rowSpacing": "Small"
///   },
///   "items": [...]
/// }
/// ```
public struct FlowLayout: Codable, Equatable {
    public let type: String

    /// Responsive target width constraint (e.g., "atLeast:Standard", "Narrow")
    public var targetWidth: String?

    /// How items should be sized: "Fit" (natural size) or "Fill" (stretch to fill row)
    public var itemFit: ItemFit?

    /// Fixed width for items (e.g., "100px", "50%")
    public var itemWidth: String?

    /// Minimum width for items (e.g., "80px")
    public var minItemWidth: String?

    /// Maximum width for items (e.g., "200px")
    public var maxItemWidth: String?

    /// Spacing between columns within a row
    public var columnSpacing: Spacing?

    /// Spacing between rows
    public var rowSpacing: Spacing?

    /// Horizontal alignment of items within the flow container
    public var horizontalAlignment: HorizontalAlignment?

    public init(
        targetWidth: String? = nil,
        itemFit: ItemFit? = nil,
        itemWidth: String? = nil,
        minItemWidth: String? = nil,
        maxItemWidth: String? = nil,
        columnSpacing: Spacing? = nil,
        rowSpacing: Spacing? = nil,
        horizontalAlignment: HorizontalAlignment? = nil
    ) {
        self.type = "Layout.Flow"
        self.targetWidth = targetWidth
        self.itemFit = itemFit
        self.itemWidth = itemWidth
        self.minItemWidth = minItemWidth
        self.maxItemWidth = maxItemWidth
        self.columnSpacing = columnSpacing
        self.rowSpacing = rowSpacing
        self.horizontalAlignment = horizontalAlignment
    }
}

// MARK: - AreaGridLayout

/// A CSS Grid-like layout that places items into named areas.
///
/// Ported from production AdaptiveCards C++ ObjectModel `AreaGridLayout` class.
/// Used when a Container's `layout` property is set to `"Layout.AreaGrid"`.
///
/// Example JSON:
/// ```json
/// {
///   "type": "Container",
///   "layout": {
///     "type": "Layout.AreaGrid",
///     "columns": ["1fr", "2fr", "1fr"],
///     "areas": [
///       { "name": "header", "row": 1, "column": 1, "columnSpan": 3 },
///       { "name": "sidebar", "row": 2, "column": 1 },
///       { "name": "content", "row": 2, "column": 2, "columnSpan": 2 }
///     ],
///     "columnSpacing": "Default",
///     "rowSpacing": "Default"
///   },
///   "items": [...]
/// }
/// ```
public struct AreaGridLayout: Codable, Equatable {
    public let type: String

    /// Responsive target width constraint (e.g., "atLeast:Standard", "Narrow")
    public var targetWidth: String?

    /// Column definitions (e.g., ["1fr", "2fr", "auto", "100px"] or [25, 25, 25])
    public var columns: [String]

    /// Named grid areas that define placement regions
    public var areas: [GridArea]

    /// Spacing between columns
    public var columnSpacing: Spacing?

    /// Spacing between rows
    public var rowSpacing: Spacing?

    private enum CodingKeys: String, CodingKey {
        case type, targetWidth, columns, areas, columnSpacing, rowSpacing
    }

    public init(
        targetWidth: String? = nil,
        columns: [String] = [],
        areas: [GridArea] = [],
        columnSpacing: Spacing? = nil,
        rowSpacing: Spacing? = nil
    ) {
        self.type = "Layout.AreaGrid"
        self.targetWidth = targetWidth
        self.columns = columns
        self.areas = areas
        self.columnSpacing = columnSpacing
        self.rowSpacing = rowSpacing
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decodeIfPresent(String.self, forKey: .type) ?? "Layout.AreaGrid"
        self.targetWidth = try container.decodeIfPresent(String.self, forKey: .targetWidth)
        self.areas = try container.decodeIfPresent([GridArea].self, forKey: .areas) ?? []
        self.columnSpacing = try container.decodeIfPresent(Spacing.self, forKey: .columnSpacing)
        self.rowSpacing = try container.decodeIfPresent(Spacing.self, forKey: .rowSpacing)

        // Columns can be strings ("1fr", "auto") or integers (25, 50) in JSON
        if var columnsArray = try? container.nestedUnkeyedContainer(forKey: .columns) {
            var parsed: [String] = []
            while !columnsArray.isAtEnd {
                if let str = try? columnsArray.decode(String.self) {
                    parsed.append(str)
                } else if let num = try? columnsArray.decode(Int.self) {
                    parsed.append(String(num))
                } else if let num = try? columnsArray.decode(Double.self) {
                    parsed.append(String(Int(num)))
                } else {
                    _ = try? columnsArray.decode(LayoutAnyCodable.self)
                }
            }
            self.columns = parsed
        } else {
            self.columns = []
        }
    }
}

/// Type-erased Codable wrapper for skipping unknown JSON values in layout columns
private struct LayoutAnyCodable: Codable {
    init(from decoder: Decoder) throws {
        _ = try? decoder.singleValueContainer()
    }
    func encode(to encoder: Encoder) throws {}
}

// MARK: - GridArea

/// A named area within an AreaGridLayout, specifying row/column placement and span.
///
/// Ported from production AdaptiveCards C++ ObjectModel `GridArea` class.
/// Items placed in a Container with AreaGridLayout reference areas by name
/// via the `layout.targetArea` property on the item.
public struct GridArea: Codable, Equatable {
    /// Name for this area, referenced by items' `layout.targetArea`
    public var name: String

    /// Row position (1-based, defaults to 1)
    public var row: Int

    /// Column position (1-based, defaults to 1)
    public var column: Int

    /// Number of rows this area spans
    public var rowSpan: Int?

    /// Number of columns this area spans
    public var columnSpan: Int?

    private enum CodingKeys: String, CodingKey {
        case name, row, column, rowSpan, columnSpan
    }

    public init(
        name: String,
        row: Int = 1,
        column: Int = 1,
        rowSpan: Int? = nil,
        columnSpan: Int? = nil
    ) {
        self.name = name
        self.row = row
        self.column = column
        self.rowSpan = rowSpan
        self.columnSpan = columnSpan
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.row = try container.decodeIfPresent(Int.self, forKey: .row) ?? 1
        self.column = try container.decodeIfPresent(Int.self, forKey: .column) ?? 1
        self.rowSpan = try container.decodeIfPresent(Int.self, forKey: .rowSpan)
        self.columnSpan = try container.decodeIfPresent(Int.self, forKey: .columnSpan)
    }
}
