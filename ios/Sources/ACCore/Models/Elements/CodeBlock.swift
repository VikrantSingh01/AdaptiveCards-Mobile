import Foundation

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
