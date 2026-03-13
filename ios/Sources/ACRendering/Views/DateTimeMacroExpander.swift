// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import Foundation

/// Expands Adaptive Cards `{{DATE(...)}}` and `{{TIME(...)}}` macros in text strings.
///
/// These are Adaptive Cards built-in functions (not template expressions) that format
/// ISO 8601 date strings into localized date/time displays.
///
/// Formats:
/// - `{{DATE(iso-date, SHORT)}}` → "May 3, 2019"
/// - `{{DATE(iso-date, LONG)}}` → "Friday, May 3, 2019"
/// - `{{DATE(iso-date, COMPACT)}}` → "5/3/2019"
/// - `{{TIME(iso-date)}}` → "8:00 PM"
enum DateTimeMacroExpander {

    /// Expand all `{{DATE(...)}}` and `{{TIME(...)}}` macros in the given string.
    static func expand(_ text: String) -> String {
        guard text.contains("{{") else { return text }

        var result = text

        // Expand {{DATE(...)}} macros
        result = expandPattern(result, prefix: "{{DATE(", suffix: ")}}") { content in
            expandDateMacro(content)
        }

        // Expand {{TIME(...)}} macros
        result = expandPattern(result, prefix: "{{TIME(", suffix: ")}}") { content in
            expandTimeMacro(content)
        }

        return result
    }

    // MARK: - Private

    private static func expandPattern(
        _ text: String,
        prefix: String,
        suffix: String,
        handler: (String) -> String?
    ) -> String {
        var result = text
        var searchStart = result.startIndex

        while searchStart < result.endIndex {
            guard let prefixRange = result.range(of: prefix, range: searchStart..<result.endIndex) else {
                break
            }

            let contentStart = prefixRange.upperBound
            guard let suffixRange = result.range(of: suffix, range: contentStart..<result.endIndex) else {
                break
            }

            let content = String(result[contentStart..<suffixRange.lowerBound])

            if let replacement = handler(content) {
                let fullRange = prefixRange.lowerBound..<suffixRange.upperBound
                result.replaceSubrange(fullRange, with: replacement)
                searchStart = result.index(prefixRange.lowerBound, offsetBy: replacement.count)
            } else {
                searchStart = suffixRange.upperBound
            }
        }

        return result
    }

    /// Expand a DATE macro content like "2019-05-03T20:00:00+0000, SHORT"
    private static func expandDateMacro(_ content: String) -> String? {
        let parts = content.split(separator: ",", maxSplits: 1).map {
            $0.trimmingCharacters(in: .whitespaces)
        }

        guard let dateString = parts.first, !dateString.isEmpty else { return nil }
        guard let date = parseISO8601(dateString) else { return nil }

        let style = parts.count > 1 ? parts[1].uppercased() : "COMPACT"

        let formatter = DateFormatter()
        formatter.locale = Locale.current

        switch style {
        case "LONG":
            formatter.dateStyle = .full
        case "SHORT":
            formatter.dateStyle = .medium
        default: // COMPACT
            formatter.dateStyle = .short
        }

        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    /// Expand a TIME macro content like "2019-05-03T20:00:00+0000"
    private static func expandTimeMacro(_ content: String) -> String? {
        let dateString = content.trimmingCharacters(in: .whitespaces)
        guard !dateString.isEmpty, let date = parseISO8601(dateString) else { return nil }

        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// Parse an ISO 8601 date string with multiple format fallbacks.
    private static func parseISO8601(_ string: String) -> Date? {
        // Try ISO8601DateFormatter first (handles Z and timezone offsets)
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: string) { return date }

        iso.formatOptions = [.withInternetDateTime]
        if let date = iso.date(from: string) { return date }

        // Try common date format patterns
        let patterns = [
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ssXXXXX",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd"
        ]

        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        for pattern in patterns {
            df.dateFormat = pattern
            if let date = df.date(from: string) { return date }
        }

        return nil
    }
}
