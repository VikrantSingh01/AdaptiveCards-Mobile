// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import Foundation

/// Warning generated during card parsing (non-fatal issues like unknown element types)
public struct ParseWarning: Sendable, Equatable {
    /// The type of warning
    public let code: Code
    /// Human-readable description
    public let message: String
    /// The JSON path where the warning occurred, if available
    public let path: String?

    public enum Code: String, Sendable {
        case unknownElementType
        case unknownActionType
        case missingInputId
        case fallbackUsed
    }

    public init(code: Code, message: String, path: String? = nil) {
        self.code = code
        self.message = message
        self.path = path
    }
}

/// Error types for card parsing failures
public enum ParseError: Error, Sendable, LocalizedError {
    case invalidJSON(String)
    case decodingFailed(String)
    case timeout
    case empty

    public var errorDescription: String? {
        switch self {
        case .invalidJSON(let message):
            return "Invalid JSON: \(message)"
        case .decodingFailed(let message):
            return "Decoding failed: \(message)"
        case .timeout:
            return "Parse operation timed out"
        case .empty:
            return "Empty JSON string"
        }
    }
}

/// Result of parsing an Adaptive Card JSON string.
/// Contains the parsed card (if successful), any warnings, and any error.
public struct ParseResult: Sendable {
    /// The parsed card, or nil if parsing failed
    public let card: AdaptiveCard?
    /// Non-fatal warnings encountered during parsing
    public let warnings: [ParseWarning]
    /// The error if parsing failed, nil on success
    public let error: ParseError?
    /// Time taken to parse in milliseconds (0 if served from cache)
    public let parseTimeMs: Double
    /// Whether the result was served from cache
    public let cacheHit: Bool

    /// Whether parsing succeeded (card is non-nil)
    public var isValid: Bool { card != nil }

    public init(
        card: AdaptiveCard? = nil,
        warnings: [ParseWarning] = [],
        error: ParseError? = nil,
        parseTimeMs: Double = 0,
        cacheHit: Bool = false
    ) {
        self.card = card
        self.warnings = warnings
        self.error = error
        self.parseTimeMs = parseTimeMs
        self.cacheHit = cacheHit
    }
}
