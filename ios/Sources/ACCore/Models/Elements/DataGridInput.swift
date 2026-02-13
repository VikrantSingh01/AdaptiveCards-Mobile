import Foundation
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
