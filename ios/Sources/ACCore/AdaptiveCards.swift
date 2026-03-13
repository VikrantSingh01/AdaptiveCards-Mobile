// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import Foundation

/// Primary entry point for the Adaptive Cards SDK.
/// Provides standalone parsing APIs that can be used without a view.
///
/// ```swift
/// // Simple parse
/// let result = AdaptiveCards.parse(jsonString)
/// if let card = result.card {
///     // Use the card
/// }
///
/// // Pre-parse for caching (e.g., in a list prefetch)
/// let results = jsonStrings.map { AdaptiveCards.parse($0) }
/// ```
public enum AdaptiveCards {

    // MARK: - Parsing

    /// Parse an Adaptive Card JSON string into a card model.
    ///
    /// Results are cached via `CardCache.shared`. Calling `parse` with the same JSON
    /// string returns a cached result with `parseTimeMs == 0`.
    ///
    /// - Parameter json: A JSON string representing an Adaptive Card
    /// - Returns: A `ParseResult` containing the card, warnings, and timing info
    public static func parse(_ json: String) -> ParseResult {
        return parse(json, cache: CardCache.shared)
    }

    /// Parse with a specific cache instance.
    public static func parse(_ json: String, cache: CardCache?) -> ParseResult {
        guard !json.isEmpty else {
            return ParseResult(error: .empty)
        }

        // Check cache
        if let cache = cache, let cached = cache.cachedCard(for: json) {
            return ParseResult(
                card: cached.card,
                warnings: cached.warnings,
                parseTimeMs: 0,
                cacheHit: true
            )
        }

        // Parse
        let start = CFAbsoluteTimeGetCurrent()
        let parser = CardParser()

        do {
            let card = try parser.parse(json)
            let parseTimeMs = (CFAbsoluteTimeGetCurrent() - start) * 1000
            let warnings = collectWarnings(for: card)

            // Cache the result
            cache?.cacheCard(card, warnings: warnings, for: json)

            return ParseResult(
                card: card,
                warnings: warnings,
                parseTimeMs: parseTimeMs,
                cacheHit: false
            )
        } catch let error as CardParserError {
            let parseTimeMs = (CFAbsoluteTimeGetCurrent() - start) * 1000
            let parseError: ParseError
            switch error {
            case .invalidJSON(let msg):
                parseError = .invalidJSON(msg)
            case .decodingFailed(let msg):
                parseError = .decodingFailed(msg)
            case .missingRequiredField(let msg):
                parseError = .decodingFailed("Missing required field: \(msg)")
            }
            return ParseResult(error: parseError, parseTimeMs: parseTimeMs)
        } catch {
            let parseTimeMs = (CFAbsoluteTimeGetCurrent() - start) * 1000
            return ParseResult(
                error: .decodingFailed(error.localizedDescription),
                parseTimeMs: parseTimeMs
            )
        }
    }

    /// Clears the shared parse cache. Call when receiving memory warnings.
    public static func clearCache() {
        CardCache.shared.clearAll()
    }

    // MARK: - Private Helpers

    /// Walk the parsed card tree and collect warnings for unknown types, inputs without IDs, etc.
    private static func collectWarnings(for card: AdaptiveCard) -> [ParseWarning] {
        var warnings: [ParseWarning] = []

        func walk(_ elements: [CardElement]?) {
            guard let elements = elements else { return }
            for element in elements {
                switch element {
                case .unknown(let type):
                    warnings.append(ParseWarning(
                        code: .unknownElementType,
                        message: "Unknown element type: \(type)"
                    ))
                case .container(let c):
                    walk(c.items)
                case .columnSet(let cs):
                    for column in cs.columns {
                        walk(column.items)
                    }
                case .carousel(let c):
                    for page in c.pages {
                        walk(page.items)
                    }
                case .tabSet(let ts):
                    for tab in ts.tabs {
                        walk(tab.items)
                    }
                default:
                    break
                }

                // Check inputs missing IDs
                if let id = element.elementId, id.isEmpty {
                    warnings.append(ParseWarning(
                        code: .missingInputId,
                        message: "Input element missing ID"
                    ))
                }
            }
        }

        walk(card.body)
        return warnings
    }
}
