import Foundation

// MARK: - Carousel Element

public struct Carousel: Codable, Equatable {
    public let type: String
    public var id: String?
    public var isVisible: Bool?
    public var separator: Bool?
    public var spacing: Spacing?
    public var height: BlockElementHeight?
    public var pages: [CarouselPage]
    public var timer: Int?
    public var initialPage: Int?
    
    public init(
        type: String = "Carousel",
        id: String? = nil,
        isVisible: Bool? = nil,
        separator: Bool? = nil,
        spacing: Spacing? = nil,
        height: BlockElementHeight? = nil,
        pages: [CarouselPage],
        timer: Int? = nil,
        initialPage: Int? = nil
    ) {
        self.type = type
        self.id = id
        self.isVisible = isVisible
        self.separator = separator
        self.spacing = spacing
        self.height = height
        self.pages = pages
        self.timer = timer
        self.initialPage = initialPage
    }
}

public struct CarouselPage: Codable, Equatable {
    public var items: [CardElement]
    public var selectAction: CardAction?
    
    public init(items: [CardElement], selectAction: CardAction? = nil) {
        self.items = items
        self.selectAction = selectAction
    }
}

// MARK: - Accordion Element

public struct Accordion: Codable, Equatable {
    public let type: String
    public var id: String?
    public var isVisible: Bool?
    public var separator: Bool?
    public var spacing: Spacing?
    public var height: BlockElementHeight?
    public var panels: [AccordionPanel]
    public var expandMode: ExpandMode
    
    public init(
        type: String = "Accordion",
        id: String? = nil,
        isVisible: Bool? = nil,
        separator: Bool? = nil,
        spacing: Spacing? = nil,
        height: BlockElementHeight? = nil,
        panels: [AccordionPanel],
        expandMode: ExpandMode = .single
    ) {
        self.type = type
        self.id = id
        self.isVisible = isVisible
        self.separator = separator
        self.spacing = spacing
        self.height = height
        self.panels = panels
        self.expandMode = expandMode
    }
}

public struct AccordionPanel: Codable, Equatable {
    public var title: String
    public var content: [CardElement]
    public var isExpanded: Bool?
    
    public init(title: String, content: [CardElement], isExpanded: Bool? = nil) {
        self.title = title
        self.content = content
        self.isExpanded = isExpanded
    }
}

public enum ExpandMode: String, Codable {
    case single = "single"
    case multiple = "multiple"
}

// MARK: - CodeBlock Element

public struct CodeBlock: Codable, Equatable {
    public let type: String
    public var id: String?
    public var isVisible: Bool?
    public var separator: Bool?
    public var spacing: Spacing?
    public var height: BlockElementHeight?
    public var code: String
    public var language: String?
    public var startLineNumber: Int?
    public var wrap: Bool?
    
    public init(
        type: String = "CodeBlock",
        id: String? = nil,
        isVisible: Bool? = nil,
        separator: Bool? = nil,
        spacing: Spacing? = nil,
        height: BlockElementHeight? = nil,
        code: String,
        language: String? = nil,
        startLineNumber: Int? = nil,
        wrap: Bool? = nil
    ) {
        self.type = type
        self.id = id
        self.isVisible = isVisible
        self.separator = separator
        self.spacing = spacing
        self.height = height
        self.code = code
        self.language = language
        self.startLineNumber = startLineNumber
        self.wrap = wrap
    }
}

// MARK: - Rating Display Element

public struct RatingDisplay: Codable, Equatable {
    public let type: String
    public var id: String?
    public var isVisible: Bool?
    public var separator: Bool?
    public var spacing: Spacing?
    public var height: BlockElementHeight?
    public var value: Double
    public var count: Int?
    public var max: Int?
    public var size: RatingSize?
    
    public init(
        type: String = "Rating",
        id: String? = nil,
        isVisible: Bool? = nil,
        separator: Bool? = nil,
        spacing: Spacing? = nil,
        height: BlockElementHeight? = nil,
        value: Double,
        count: Int? = nil,
        max: Int? = nil,
        size: RatingSize? = nil
    ) {
        self.type = type
        self.id = id
        self.isVisible = isVisible
        self.separator = separator
        self.spacing = spacing
        self.height = height
        self.value = value
        self.count = count
        self.max = max
        self.size = size
    }
}

public enum RatingSize: String, Codable {
    case small = "small"
    case medium = "medium"
    case large = "large"
}

// MARK: - Rating Input Element

public struct RatingInput: Codable, Equatable {
    public let type: String
    public var id: String
    public var isVisible: Bool?
    public var separator: Bool?
    public var spacing: Spacing?
    public var height: BlockElementHeight?
    public var label: String?
    public var isRequired: Bool?
    public var errorMessage: String?
    public var max: Int?
    public var value: Double?
    
    public init(
        type: String = "Input.Rating",
        id: String,
        isVisible: Bool? = nil,
        separator: Bool? = nil,
        spacing: Spacing? = nil,
        height: BlockElementHeight? = nil,
        label: String? = nil,
        isRequired: Bool? = nil,
        errorMessage: String? = nil,
        max: Int? = nil,
        value: Double? = nil
    ) {
        self.type = type
        self.id = id
        self.isVisible = isVisible
        self.separator = separator
        self.spacing = spacing
        self.height = height
        self.label = label
        self.isRequired = isRequired
        self.errorMessage = errorMessage
        self.max = max
        self.value = value
    }
}

// MARK: - ProgressBar Element

public struct ProgressBar: Codable, Equatable {
    public let type: String
    public var id: String?
    public var isVisible: Bool?
    public var separator: Bool?
    public var spacing: Spacing?
    public var height: BlockElementHeight?
    public var value: Double
    public var label: String?
    public var color: String?
    
    public init(
        type: String = "ProgressBar",
        id: String? = nil,
        isVisible: Bool? = nil,
        separator: Bool? = nil,
        spacing: Spacing? = nil,
        height: BlockElementHeight? = nil,
        value: Double,
        label: String? = nil,
        color: String? = nil
    ) {
        self.type = type
        self.id = id
        self.isVisible = isVisible
        self.separator = separator
        self.spacing = spacing
        self.height = height
        self.value = value
        self.label = label
        self.color = color
    }
}

// MARK: - Spinner Element

public struct Spinner: Codable, Equatable {
    public let type: String
    public var id: String?
    public var isVisible: Bool?
    public var separator: Bool?
    public var spacing: Spacing?
    public var height: BlockElementHeight?
    public var size: SpinnerSize?
    public var label: String?
    
    public init(
        type: String = "Spinner",
        id: String? = nil,
        isVisible: Bool? = nil,
        separator: Bool? = nil,
        spacing: Spacing? = nil,
        height: BlockElementHeight? = nil,
        size: SpinnerSize? = nil,
        label: String? = nil
    ) {
        self.type = type
        self.id = id
        self.isVisible = isVisible
        self.separator = separator
        self.spacing = spacing
        self.height = height
        self.size = size
        self.label = label
    }
}

public enum SpinnerSize: String, Codable {
    case small = "small"
    case medium = "medium"
    case large = "large"
}

// MARK: - TabSet Element

public struct TabSet: Codable, Equatable {
    public let type: String
    public var id: String?
    public var isVisible: Bool?
    public var separator: Bool?
    public var spacing: Spacing?
    public var height: BlockElementHeight?
    public var tabs: [Tab]
    public var selectedTabId: String?
    
    public init(
        type: String = "TabSet",
        id: String? = nil,
        isVisible: Bool? = nil,
        separator: Bool? = nil,
        spacing: Spacing? = nil,
        height: BlockElementHeight? = nil,
        tabs: [Tab],
        selectedTabId: String? = nil
    ) {
        self.type = type
        self.id = id
        self.isVisible = isVisible
        self.separator = separator
        self.spacing = spacing
        self.height = height
        self.tabs = tabs
        self.selectedTabId = selectedTabId
    }
}

public struct Tab: Codable, Equatable {
    public var id: String
    public var title: String
    public var icon: String?
    public var items: [CardElement]
    
    public init(id: String, title: String, icon: String? = nil, items: [CardElement]) {
        self.id = id
        self.title = title
        self.icon = icon
        self.items = items
    }
}
