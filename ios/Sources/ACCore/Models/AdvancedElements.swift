import Foundation

// MARK: - Carousel

public struct Carousel: Codable, Equatable {
    public let type: String = "Carousel"
    public var id: String?
    public var pages: [CarouselPage]
    public var timer: Int?
    public var initialPage: Int?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?
    
    public init(
        id: String? = nil,
        pages: [CarouselPage],
        timer: Int? = nil,
        initialPage: Int? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil
    ) {
        self.id = id
        self.pages = pages
        self.timer = timer
        self.initialPage = initialPage
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.requires = requires
    }
}

public struct CarouselPage: Codable, Equatable {
    public var items: [CardElement]
    public var selectAction: CardAction?
    
    public init(
        items: [CardElement],
        selectAction: CardAction? = nil
    ) {
        self.items = items
        self.selectAction = selectAction
    }
}

// MARK: - Accordion

public struct Accordion: Codable, Equatable {
    public let type: String = "Accordion"
    public var id: String?
    public var panels: [AccordionPanel]
    public var expandMode: ExpandMode?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?
    
    public init(
        id: String? = nil,
        panels: [AccordionPanel],
        expandMode: ExpandMode? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil
    ) {
        self.id = id
        self.panels = panels
        self.expandMode = expandMode
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.requires = requires
    }
}

public struct AccordionPanel: Codable, Equatable {
    public var title: String
    public var content: [CardElement]
    public var isExpanded: Bool?
    
    public init(
        title: String,
        content: [CardElement],
        isExpanded: Bool? = nil
    ) {
        self.title = title
        self.content = content
        self.isExpanded = isExpanded
    }
}

// MARK: - CodeBlock

public struct CodeBlock: Codable, Equatable {
    public let type: String = "CodeBlock"
    public var id: String?
    public var code: String
    public var language: String?
    public var startLineNumber: Int?
    public var wrap: Bool?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?
    
    public init(
        id: String? = nil,
        code: String,
        language: String? = nil,
        startLineNumber: Int? = nil,
        wrap: Bool? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil
    ) {
        self.id = id
        self.code = code
        self.language = language
        self.startLineNumber = startLineNumber
        self.wrap = wrap
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.requires = requires
    }
}

// MARK: - Rating Display

public struct RatingDisplay: Codable, Equatable {
    public let type: String = "Rating"
    public var id: String?
    public var value: Double
    public var count: Int?
    public var max: Int?
    public var size: RatingSize?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?
    
    public init(
        id: String? = nil,
        value: Double,
        count: Int? = nil,
        max: Int? = nil,
        size: RatingSize? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil
    ) {
        self.id = id
        self.value = value
        self.count = count
        self.max = max
        self.size = size
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.requires = requires
    }
}

// MARK: - Rating Input

public struct RatingInput: Codable, Equatable {
    public let type: String = "Input.Rating"
    public var id: String
    public var max: Int?
    public var value: Double?
    public var label: String?
    public var isRequired: Bool?
    public var errorMessage: String?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    
    public init(
        id: String,
        max: Int? = nil,
        value: Double? = nil,
        label: String? = nil,
        isRequired: Bool? = nil,
        errorMessage: String? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil
    ) {
        self.id = id
        self.max = max
        self.value = value
        self.label = label
        self.isRequired = isRequired
        self.errorMessage = errorMessage
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
    }
}

// MARK: - ProgressBar

public struct ProgressBar: Codable, Equatable {
    public let type: String = "ProgressBar"
    public var id: String?
    public var value: Double
    public var label: String?
    public var color: String?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?
    
    public init(
        id: String? = nil,
        value: Double,
        label: String? = nil,
        color: String? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil
    ) {
        self.id = id
        self.value = value
        self.label = label
        self.color = color
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.requires = requires
    }
}

// MARK: - Spinner

public struct Spinner: Codable, Equatable {
    public let type: String = "Spinner"
    public var id: String?
    public var size: SpinnerSize?
    public var label: String?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?
    
    public init(
        id: String? = nil,
        size: SpinnerSize? = nil,
        label: String? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil
    ) {
        self.id = id
        self.size = size
        self.label = label
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.requires = requires
    }
}

// MARK: - TabSet

public struct TabSet: Codable, Equatable {
    public let type: String = "TabSet"
    public var id: String?
    public var tabs: [Tab]
    public var selectedTabId: String?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?
    
    public init(
        id: String? = nil,
        tabs: [Tab],
        selectedTabId: String? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil
    ) {
        self.id = id
        self.tabs = tabs
        self.selectedTabId = selectedTabId
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.requires = requires
    }
}

public struct Tab: Codable, Equatable {
    public var id: String
    public var title: String
    public var icon: String?
    public var items: [CardElement]
    
    public init(
        id: String,
        title: String,
        icon: String? = nil,
        items: [CardElement]
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.items = items
    }
}

// MARK: - List

public struct ListElement: Codable, Equatable {
    public let type: String = "List"
    public var id: String?
    public var items: [CardElement]
    public var maxHeight: String?
    public var style: String?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    public var requires: [String: String]?
    
    public init(
        id: String? = nil,
        items: [CardElement],
        maxHeight: String? = nil,
        style: String? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil,
        requires: [String: String]? = nil
    ) {
        self.id = id
        self.items = items
        self.maxHeight = maxHeight
        self.style = style
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
        self.requires = requires
    }
}

// MARK: - DataGrid Input

public struct DataGridInput: Codable, Equatable {
    public let type: String = "Input.DataGrid"
    public var id: String
    public var label: String?
    public var columns: [DataGridColumn]
    public var rows: [[DataGridCellValue]]?
    public var maxRows: Int?
    public var isRequired: Bool?
    public var errorMessage: String?
    public var spacing: Spacing?
    public var separator: Bool?
    public var height: BlockElementHeight?
    public var isVisible: Bool?
    
    public init(
        id: String,
        label: String? = nil,
        columns: [DataGridColumn],
        rows: [[DataGridCellValue]]? = nil,
        maxRows: Int? = nil,
        isRequired: Bool? = nil,
        errorMessage: String? = nil,
        spacing: Spacing? = nil,
        separator: Bool? = nil,
        height: BlockElementHeight? = nil,
        isVisible: Bool? = nil
    ) {
        self.id = id
        self.label = label
        self.columns = columns
        self.rows = rows
        self.maxRows = maxRows
        self.isRequired = isRequired
        self.errorMessage = errorMessage
        self.spacing = spacing
        self.separator = separator
        self.height = height
        self.isVisible = isVisible
    }
}

public struct DataGridColumn: Codable, Equatable {
    public var id: String
    public var title: String
    public var type: String
    public var width: String?
    public var isEditable: Bool?
    public var isSortable: Bool?
    
    public init(
        id: String,
        title: String,
        type: String,
        width: String? = nil,
        isEditable: Bool? = nil,
        isSortable: Bool? = nil
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.width = width
        self.isEditable = isEditable
        self.isSortable = isSortable
    }
}

public enum DataGridCellValue: Codable, Equatable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case null
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .number(doubleValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else {
            self = .null
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
}
