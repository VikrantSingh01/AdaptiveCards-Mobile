import Foundation

public struct Citation: Codable, Equatable, Identifiable {
    public var id: String
    public var title: String
    public var url: String?
    public var snippet: String?
    public var index: Int

    public init(id: String, title: String, url: String? = nil, snippet: String? = nil, index: Int) {
        self.id = id
        self.title = title
        self.url = url
        self.snippet = snippet
        self.index = index
    }
}

public struct Reference: Codable, Equatable, Identifiable {
    public var id: String
    public var title: String
    public var url: String?
    public var snippet: String?
    public var iconUrl: String?
    public var type: ReferenceType

    public init(id: String, title: String, url: String? = nil, snippet: String? = nil, iconUrl: String? = nil, type: ReferenceType) {
        self.id = id
        self.title = title
        self.url = url
        self.snippet = snippet
        self.iconUrl = iconUrl
        self.type = type
    }

    public enum ReferenceType: String, Codable {
        case file
        case url
        case document
    }
}

public enum StreamingState {
    case idle
    case streaming
    case complete
    case error(Error)
}
