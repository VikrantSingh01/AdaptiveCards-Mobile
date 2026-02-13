import Foundation

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

