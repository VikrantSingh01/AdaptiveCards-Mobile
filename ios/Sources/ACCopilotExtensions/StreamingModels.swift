import Foundation

// MARK: - Streaming Models

/// Represents the different phases of streaming content.
///
/// Ported from production Teams-AdaptiveCards-Mobile SDK's streaming implementation.
public enum StreamingPhase: String, Codable, CaseIterable {
    case start = "start"
    case informative = "informative"
    case streaming = "streaming"
    case final_ = "final"

    public static func from(_ rawValue: String) -> StreamingPhase? {
        switch rawValue.lowercased() {
        case "start": return .start
        case "informative": return .informative
        case "streaming": return .streaming
        case "final": return .final_
        default: return nil
        }
    }
}

/// Model for streaming content and state.
///
/// Contains all the metadata needed to render streaming text with proper
/// typing animations, progress indicators, and stop controls.
public struct StreamingContent: Codable, Equatable {
    /// Unique message identifier for tracking streaming state
    public let messageID: String
    /// Current phase of the streaming process
    public let phase: String
    /// The actual text content being streamed
    public let content: String
    /// Whether the streaming is complete
    public let isComplete: Bool
    /// Reason the stream ended (e.g., "done", "stopped", "error")
    public let streamEndReason: String?
    /// Characters per second for typing animation
    public let typingSpeed: Double?
    /// Whether to show a stop/cancel button
    public let showStopButton: Bool?
    /// Whether to show a progress indicator
    public let showProgressIndicator: Bool?

    /// Parsed streaming phase
    public var streamingPhase: StreamingPhase? {
        StreamingPhase.from(phase)
    }

    public init(
        messageID: String,
        phase: String,
        content: String,
        isComplete: Bool,
        streamEndReason: String? = nil,
        typingSpeed: Double? = nil,
        showStopButton: Bool? = nil,
        showProgressIndicator: Bool? = nil
    ) {
        self.messageID = messageID
        self.phase = phase
        self.content = content
        self.isComplete = isComplete
        self.streamEndReason = streamEndReason
        self.typingSpeed = typingSpeed
        self.showStopButton = showStopButton
        self.showProgressIndicator = showProgressIndicator
    }
}

// MARK: - Streaming Data Parser

/// Helper for parsing streaming data from text content.
///
/// Detects and parses JSON-encoded streaming data embedded in text elements.
/// This allows regular TextBlock elements to carry streaming metadata.
public struct StreamingDataParser {

    /// Attempts to parse streaming data from a text string
    public static func parseStreamingData(from text: String) -> StreamingContent? {
        guard text.hasPrefix("{") && text.hasSuffix("}"),
              let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              json["streamingEnabled"] as? Bool == true,
              let messageID = json["messageID"] as? String,
              let phase = json["phase"] as? String,
              let content = json["content"] as? String else {
            return nil
        }

        return StreamingContent(
            messageID: messageID,
            phase: phase,
            content: content,
            isComplete: json["isComplete"] as? Bool ?? false,
            streamEndReason: json["streamEndReason"] as? String,
            typingSpeed: json["typingSpeed"] as? Double,
            showStopButton: json["showStopButton"] as? Bool,
            showProgressIndicator: json["showProgressIndicator"] as? Bool
        )
    }

    /// Checks if text content contains valid streaming data
    public static func isStreamingContent(_ text: String) -> Bool {
        parseStreamingData(from: text) != nil
    }
}

extension StreamingContent {
    /// Create from text content (JSON string)
    public static func from(textContent: String) -> StreamingContent? {
        StreamingDataParser.parseStreamingData(from: textContent)
    }
}
