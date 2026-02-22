import Foundation

public struct Citation: Codable, Equatable, Identifiable {
    public var id: String
    public var title: String
    public var url: String?
    public var snippet: String?
    public var index: Int
    /// File type for icon display (e.g., "pdf", "docx", "xlsx")
    public var fileType: String?
    /// Source application name
    public var sourceName: String?

    public init(
        id: String,
        title: String,
        url: String? = nil,
        snippet: String? = nil,
        index: Int,
        fileType: String? = nil,
        sourceName: String? = nil
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.snippet = snippet
        self.index = index
        self.fileType = fileType
        self.sourceName = sourceName
    }
}

public struct Reference: Codable, Equatable, Identifiable {
    public var id: String
    public var title: String
    public var url: String?
    public var snippet: String?
    public var iconUrl: String?
    public var type: ReferenceType
    /// Preview image URL
    public var thumbnailUrl: String?
    /// Sensitivity label (e.g., "Confidential")
    public var sensitivityLabel: String?

    public init(
        id: String,
        title: String,
        url: String? = nil,
        snippet: String? = nil,
        iconUrl: String? = nil,
        type: ReferenceType,
        thumbnailUrl: String? = nil,
        sensitivityLabel: String? = nil
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.snippet = snippet
        self.iconUrl = iconUrl
        self.type = type
        self.thumbnailUrl = thumbnailUrl
        self.sensitivityLabel = sensitivityLabel
    }

    public enum ReferenceType: String, Codable {
        case file
        case url
        case document
        case email
        case meeting
        case person
        case message
    }
}

public enum StreamingState: Equatable {
    case idle
    case streaming
    case complete
    case error(String)

    public static func == (lhs: StreamingState, rhs: StreamingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.streaming, .streaming), (.complete, .complete):
            return true
        case let (.error(l), .error(r)):
            return l == r
        default:
            return false
        }
    }
}

/// Represents a Copilot response that may contain streaming, CoT, citations, and references
public struct CopilotResponse: Equatable {
    public var streamingState: StreamingState
    public var streamingContent: StreamingContent?
    public var chainOfThought: ChainOfThoughtData?
    public var citations: [Citation]
    public var references: [Reference]

    public init(
        streamingState: StreamingState = .idle,
        streamingContent: StreamingContent? = nil,
        chainOfThought: ChainOfThoughtData? = nil,
        citations: [Citation] = [],
        references: [Reference] = []
    ) {
        self.streamingState = streamingState
        self.streamingContent = streamingContent
        self.chainOfThought = chainOfThought
        self.citations = citations
        self.references = references
    }
}
