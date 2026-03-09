import Foundation

// MARK: - Chain of Thought Models

/// Data models for Chain of Thought (CoT) UX.
///
/// Ported from production Teams-AdaptiveCards-Mobile SDK's SwiftUI ChainOfThought implementation.
/// CoT shows the reasoning steps Copilot goes through while processing a request.
public struct ChainOfThoughtData: Codable, Equatable {
    /// The individual reasoning steps
    public let entries: [ChainOfThoughtEntry]
    /// Display state (e.g., "Thought for 1 min", "Thinking...")
    public let state: String
    /// Whether the chain of thought is complete
    public let isDone: Bool

    public init(entries: [ChainOfThoughtEntry], state: String, isDone: Bool) {
        self.entries = entries
        self.state = state
        self.isDone = isDone
    }
}

public struct ChainOfThoughtEntry: Codable, Equatable, Identifiable {
    public let id: String
    /// The step header/title
    public let header: String
    /// The detailed reasoning content
    public let content: String
    /// Optional app info for tool use steps
    public let appInfo: AppInfo?

    private enum CodingKeys: String, CodingKey {
        case id, header, content, appInfo
    }

    public init(id: String = UUID().uuidString, header: String, content: String, appInfo: AppInfo? = nil) {
        self.id = id
        self.header = header
        self.content = content
        self.appInfo = appInfo
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.header = try container.decode(String.self, forKey: .header)
        self.content = try container.decode(String.self, forKey: .content)
        self.appInfo = try container.decodeIfPresent(AppInfo.self, forKey: .appInfo)
    }
}

public struct AppInfo: Codable, Equatable {
    /// App/tool name
    public let name: String
    /// URL for the app icon
    public let icon: String

    public init(name: String, icon: String) {
        self.name = name
        self.icon = icon
    }
}

/// Parser for extracting Chain of Thought data from text content
extension ChainOfThoughtData {
    /// Attempt to parse Chain of Thought JSON from text content
    public static func from(textContent: String) -> ChainOfThoughtData? {
        let cleaned = textContent
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")

        guard cleaned.hasPrefix("{") && cleaned.hasSuffix("}"),
              let data = cleaned.data(using: .utf8) else { return nil }

        // First attempt: direct decode
        if let result = try? JSONDecoder().decode(ChainOfThoughtData.self, from: data) {
            return result
        }

        // Second attempt: fix smart quotes
        let fixedQuotes = cleaned
            .replacingOccurrences(of: "\u{201C}", with: "\"")
            .replacingOccurrences(of: "\u{201D}", with: "\"")
            .replacingOccurrences(of: "\u{2018}", with: "'")
            .replacingOccurrences(of: "\u{2019}", with: "'")

        guard let retryData = fixedQuotes.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(ChainOfThoughtData.self, from: retryData)
    }
}
