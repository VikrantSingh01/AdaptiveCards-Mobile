import Foundation

// MARK: - Container

public struct Container: Codable, Equatable {
    public let type: String = "Container"
    public var id: String?
    public var items: [CardElement]?  // Optional to support empty containers
    public var selectAction: CardAction?
    public var style: ContainerStyle?
    public var verticalContentAlignment: VerticalAlignment?
    public var bleed: Bool?
    public var backgroundImage: BackgroundImage?
    public var minHeight: String?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?
    public var targetWidth: String?
    public var fallback: CardElement?

    public init(
        id: String? = nil,
        items: [CardElement]? = nil,
        selectAction: CardAction? = nil,
        style: ContainerStyle? = nil,
        verticalContentAlignment: VerticalAlignment? = nil,
        bleed: Bool? = nil,
        backgroundImage: BackgroundImage? = nil,
        minHeight: String? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil,
        targetWidth: String? = nil,
        fallback: CardElement? = nil
    ) {
        self.id = id
        self.items = items
        self.selectAction = selectAction
        self.style = style
        self.verticalContentAlignment = verticalContentAlignment
        self.bleed = bleed
        self.backgroundImage = backgroundImage
        self.minHeight = minHeight
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.requires = requires
        self.targetWidth = targetWidth
        self.fallback = fallback
    }
}

// MARK: - ColumnSet

public struct ColumnSet: Codable, Equatable {
    public let type: String = "ColumnSet"
    public var id: String?
    public var columns: [Column]
    public var selectAction: CardAction?
    public var style: ContainerStyle?
    public var bleed: Bool?
    public var minHeight: String?
    public var horizontalAlignment: HorizontalAlignment?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?
    public var fallback: CardElement?

    public init(
        id: String? = nil,
        columns: [Column],
        selectAction: CardAction? = nil,
        style: ContainerStyle? = nil,
        bleed: Bool? = nil,
        minHeight: String? = nil,
        horizontalAlignment: HorizontalAlignment? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil,
        fallback: CardElement? = nil
    ) {
        self.id = id
        self.columns = columns
        self.selectAction = selectAction
        self.style = style
        self.bleed = bleed
        self.minHeight = minHeight
        self.horizontalAlignment = horizontalAlignment
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.requires = requires
        self.fallback = fallback
    }
}

// MARK: - Column

public struct Column: Codable, Equatable, Identifiable {
    public let type: String = "Column"
    public var id: String?
    public var items: [CardElement]?  // Optional to support empty columns
    public var width: ColumnWidth?
    public var style: ContainerStyle?
    public var verticalContentAlignment: VerticalAlignment?
    public var bleed: Bool?
    public var backgroundImage: BackgroundImage?
    public var minHeight: String?
    public var separator: Bool?
    public var spacing: Spacing?
    public var selectAction: CardAction?
    public var isVisible: Bool?
    public var requires: [String: String]?

    // Stable identifier using id property or combined items IDs as fallback
    public var stableId: String {
        if let id = id, !id.isEmpty {
            return id
        }
        guard let items = items else {
            return "column_empty_\(type)"
        }
        let itemsId = items.map { $0.id }.joined(separator: "_")
        return itemsId.isEmpty ? "column_empty_\(type)" : itemsId
    }

    public init(
        id: String? = nil,
        items: [CardElement]? = nil,
        width: ColumnWidth? = nil,
        style: ContainerStyle? = nil,
        verticalContentAlignment: VerticalAlignment? = nil,
        bleed: Bool? = nil,
        backgroundImage: BackgroundImage? = nil,
        minHeight: String? = nil,
        separator: Bool? = nil,
        spacing: Spacing? = nil,
        selectAction: CardAction? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil
    ) {
        self.id = id
        self.items = items
        self.width = width
        self.style = style
        self.verticalContentAlignment = verticalContentAlignment
        self.bleed = bleed
        self.backgroundImage = backgroundImage
        self.minHeight = minHeight
        self.separator = separator
        self.spacing = spacing
        self.selectAction = selectAction
        self.isVisible = isVisible
        self.requires = requires
    }
}

public enum ColumnWidth: Codable, Equatable {
    case auto
    case stretch
    case weighted(Double)
    case pixels(String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let stringValue = try? container.decode(String.self) {
            switch stringValue.lowercased() {
            case "auto":
                self = .auto
            case "stretch":
                self = .stretch
            default:
                // Per AC spec, numeric strings like "1", "2" are weighted values.
                // Only strings containing non-numeric chars (e.g. "50px") are pixel values.
                if let numericValue = Double(stringValue) {
                    self = .weighted(numericValue)
                } else {
                    self = .pixels(stringValue)
                }
            }
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .weighted(doubleValue)
        } else {
            self = .auto
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .auto:
            try container.encode("auto")
        case .stretch:
            try container.encode("stretch")
        case .weighted(let value):
            try container.encode(value)
        case .pixels(let value):
            try container.encode(value)
        }
    }
}

// MARK: - ImageSet

public struct ImageSet: Codable, Equatable {
    public let type: String = "ImageSet"
    public var id: String?
    public var images: [Image]
    public var imageSize: ImageSize?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?
    public var fallback: CardElement?

    public init(
        id: String? = nil,
        images: [Image],
        imageSize: ImageSize? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil,
        fallback: CardElement? = nil
    ) {
        self.id = id
        self.images = images
        self.imageSize = imageSize
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.requires = requires
        self.fallback = fallback
    }
}

// MARK: - FactSet

public struct FactSet: Codable, Equatable {
    public let type: String = "FactSet"
    public var id: String?
    public var facts: [Fact]
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?
    public var fallback: CardElement?

    public init(
        id: String? = nil,
        facts: [Fact],
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil,
        fallback: CardElement? = nil
    ) {
        self.id = id
        self.facts = facts
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.requires = requires
        self.fallback = fallback
    }

    public struct Fact: Codable, Equatable, Identifiable {
        public var title: String
        public var value: String

        public var id: String { title }

        public init(title: String, value: String) {
            self.title = title
            self.value = value
        }
    }
}

// MARK: - ActionSet

public struct ActionSet: Codable, Equatable {
    public let type: String = "ActionSet"
    public var id: String?
    public var actions: [CardAction]
    public var mode: ActionSetMode?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?
    public var fallback: CardElement?

    public init(
        id: String? = nil,
        actions: [CardAction],
        mode: ActionSetMode? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil,
        fallback: CardElement? = nil
    ) {
        self.id = id
        self.actions = actions
        self.mode = mode
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.requires = requires
        self.fallback = fallback
    }
}

// MARK: - Table

public struct Table: Codable, Equatable {
    public let type: String = "Table"
    public var id: String?
    public var columns: [TableColumnDefinition]?
    public var rows: [TableRow]
    public var firstRowAsHeaders: Bool?
    public var showGridLines: Bool?
    public var gridStyle: ContainerStyle?
    public var horizontalCellContentAlignment: HorizontalAlignment?
    public var verticalCellContentAlignment: VerticalAlignment?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?
    public var fallback: CardElement?

    public init(
        id: String? = nil,
        columns: [TableColumnDefinition]? = nil,
        rows: [TableRow],
        firstRowAsHeaders: Bool? = nil,
        showGridLines: Bool? = nil,
        gridStyle: ContainerStyle? = nil,
        horizontalCellContentAlignment: HorizontalAlignment? = nil,
        verticalCellContentAlignment: VerticalAlignment? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil,
        fallback: CardElement? = nil
    ) {
        self.id = id
        self.columns = columns
        self.rows = rows
        self.firstRowAsHeaders = firstRowAsHeaders
        self.showGridLines = showGridLines
        self.gridStyle = gridStyle
        self.horizontalCellContentAlignment = horizontalCellContentAlignment
        self.verticalCellContentAlignment = verticalCellContentAlignment
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.requires = requires
        self.fallback = fallback
    }
}

public struct TableRow: Codable, Equatable, Identifiable {
    public let type: String = "TableRow"
    public var cells: [TableCell]
    public var style: ContainerStyle?
    public var horizontalCellContentAlignment: HorizontalAlignment?
    public var verticalCellContentAlignment: VerticalAlignment?

    // Generate stable ID from cells' items IDs
    public var id: String {
        let cellIds = cells.map { cell in
            if let items = cell.items {
                return items.map { $0.id }.joined(separator: "_")
            } else {
                return "empty"
            }
        }.joined(separator: "|")
        return cellIds.isEmpty ? "row_empty" : cellIds
    }

    public init(
        cells: [TableCell],
        style: ContainerStyle? = nil,
        horizontalCellContentAlignment: HorizontalAlignment? = nil,
        verticalCellContentAlignment: VerticalAlignment? = nil
    ) {
        self.cells = cells
        self.style = style
        self.horizontalCellContentAlignment = horizontalCellContentAlignment
        self.verticalCellContentAlignment = verticalCellContentAlignment
    }
}

public struct TableCell: Codable, Equatable, Identifiable {
    public let type: String = "TableCell"
    public var items: [CardElement]?  // Optional to support cells with inline text
    public var style: ContainerStyle?
    public var verticalContentAlignment: VerticalAlignment?
    public var bleed: Bool?
    public var backgroundImage: BackgroundImage?
    public var minHeight: String?
    public var selectAction: CardAction?

    // Generate stable ID from items IDs
    public var id: String {
        guard let items = items else { return "cell_empty" }
        let itemsId = items.map { $0.id }.joined(separator: "_")
        return itemsId.isEmpty ? "cell_empty" : itemsId
    }

    public init(
        items: [CardElement]? = nil,
        style: ContainerStyle? = nil,
        verticalContentAlignment: VerticalAlignment? = nil,
        bleed: Bool? = nil,
        backgroundImage: BackgroundImage? = nil,
        minHeight: String? = nil,
        selectAction: CardAction? = nil
    ) {
        self.items = items
        self.style = style
        self.verticalContentAlignment = verticalContentAlignment
        self.bleed = bleed
        self.backgroundImage = backgroundImage
        self.minHeight = minHeight
        self.selectAction = selectAction
    }
}

public struct TableColumnDefinition: Codable, Equatable {
    public var width: ColumnWidth?
    public var horizontalCellContentAlignment: HorizontalAlignment?
    public var verticalCellContentAlignment: VerticalAlignment?

    public init(
        width: ColumnWidth? = nil,
        horizontalCellContentAlignment: HorizontalAlignment? = nil,
        verticalCellContentAlignment: VerticalAlignment? = nil
    ) {
        self.width = width
        self.horizontalCellContentAlignment = horizontalCellContentAlignment
        self.verticalCellContentAlignment = verticalCellContentAlignment
    }
}

// MARK: - BackgroundImage

public struct BackgroundImage: Codable, Equatable {
    public var url: String
    public var fillMode: FillMode?
    public var horizontalAlignment: HorizontalAlignment?
    public var verticalAlignment: VerticalAlignment?

    enum CodingKeys: String, CodingKey {
        case url
        case fillMode
        case horizontalAlignment
        case verticalAlignment
    }

    public init(
        url: String,
        fillMode: FillMode? = nil,
        horizontalAlignment: HorizontalAlignment? = nil,
        verticalAlignment: VerticalAlignment? = nil
    ) {
        self.url = url
        self.fillMode = fillMode
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
    }

    // Custom decoder to support both string URL and object form
    public init(from decoder: Decoder) throws {
        // Try decoding as a string first (shorthand form)
        if let container = try? decoder.singleValueContainer(),
           let urlString = try? container.decode(String.self) {
            self.url = urlString
            self.fillMode = nil
            self.horizontalAlignment = nil
            self.verticalAlignment = nil
        } else {
            // Fall back to object form
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.url = try container.decode(String.self, forKey: .url)
            self.fillMode = try container.decodeIfPresent(FillMode.self, forKey: .fillMode)
            self.horizontalAlignment = try container.decodeIfPresent(HorizontalAlignment.self, forKey: .horizontalAlignment)
            self.verticalAlignment = try container.decodeIfPresent(VerticalAlignment.self, forKey: .verticalAlignment)
        }
    }

    public enum FillMode: String, Codable {
        case cover = "cover"
        case repeatHorizontally = "repeatHorizontally"
        case repeatVertically = "repeatVertically"
        case `repeat` = "repeat"

        // Support legacy PascalCase values for backward compatibility
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)

            switch value.lowercased() {
            case "cover":
                self = .cover
            case "repeathorizontally":
                self = .repeatHorizontally
            case "repeatvertically":
                self = .repeatVertically
            case "repeat":
                self = .repeat
            default:
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Unknown fill mode: \(value)"
                )
            }
        }
    }
}

// MARK: - Image (defined here to avoid circular dependency)

public struct Image: Codable, Equatable, Identifiable {
    public let type: String = "Image"
    public var id: String?
    public var url: String
    public var altText: String?
    public var size: ImageSize?
    public var style: ImageStyle?
    public var width: String?
    public var height: String?
    public var horizontalAlignment: HorizontalAlignment?
    public var selectAction: CardAction?
    public var spacing: Spacing?
    public var separator: Bool?
    public var isVisible: Bool?
    public var requires: [String: String]?
    public var targetWidth: String?
    public var themedUrls: [String: String]?
    public var backgroundColor: String?
    public var fallback: CardElement?

    // Stable identifier using id property or url as fallback
    public var stableId: String {
        if let id = id, !id.isEmpty {
            return id
        }
        return url.isEmpty ? "image_no_url" : url
    }

    public init(
        id: String? = nil,
        url: String,
        altText: String? = nil,
        size: ImageSize? = nil,
        style: ImageStyle? = nil,
        width: String? = nil,
        height: String? = nil,
        horizontalAlignment: HorizontalAlignment? = nil,
        selectAction: CardAction? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil,
        targetWidth: String? = nil,
        themedUrls: [String: String]? = nil,
        backgroundColor: String? = nil,
        fallback: CardElement? = nil
    ) {
        self.id = id
        self.url = url
        self.altText = altText
        self.size = size
        self.style = style
        self.width = width
        self.height = height
        self.horizontalAlignment = horizontalAlignment
        self.selectAction = selectAction
        self.spacing = spacing
        self.separator = separator
        self.isVisible = isVisible
        self.requires = requires
        self.targetWidth = targetWidth
        self.themedUrls = themedUrls
        self.backgroundColor = backgroundColor
        self.fallback = fallback
    }
}
