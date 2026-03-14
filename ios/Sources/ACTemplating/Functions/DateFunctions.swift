// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import Foundation

/// Date and time functions for template expressions
public struct DateFunctions {
    public static func register(into functions: inout [String: ExpressionFunction]) {
        functions["formatDateTime"] = FormatDateTime()
        functions["formatTicks"] = FormatTicks()
        functions["formatEpoch"] = FormatEpoch()
        functions["addDays"] = AddDays()
        functions["addHours"] = AddHours()
        functions["getYear"] = GetYear()
        functions["getMonth"] = GetMonth()
        functions["getDay"] = GetDay()
        functions["dateDiff"] = DateDiff()
        functions["utcNow"] = UtcNow()
    }

    // MARK: - Function Implementations

    struct FormatDateTime: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count >= 1 && arguments.count <= 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }

            let date = try parseDate(arguments[0])
            let formatString = arguments.count > 1 ? (arguments[1] as? String) : "yyyy-MM-dd"

            // Quote unrecognized letters (e.g., literal 'T' in ISO date formats)
            // to avoid undefined behavior in DateFormatter
            let safeFormat = sanitizeFormat(formatString ?? "yyyy-MM-dd")
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = safeFormat
            return formatter.string(from: date)
        }
    }

    /// Converts .NET ticks (100-nanosecond intervals since 0001-01-01) to a formatted date string.
    /// Usage: formatTicks(ticksValue, 'yyyy-MM-dd')
    struct FormatTicks: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count >= 1 && arguments.count <= 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }

            let ticks: Int64
            if let intVal = arguments[0] as? Int {
                ticks = Int64(intVal)
            } else if let doubleVal = arguments[0] as? Double {
                ticks = Int64(doubleVal)
            } else if let strVal = arguments[0] as? String, let parsed = Int64(strVal) {
                ticks = parsed
            } else {
                throw EvaluationError.invalidArgument("formatTicks requires a numeric ticks value")
            }

            // .NET epoch: 0001-01-01T00:00:00Z
            // Unix epoch: 1970-01-01T00:00:00Z
            // Difference: 621355968000000000 ticks
            let unixEpochTicks: Int64 = 621_355_968_000_000_000
            let ticksPerSecond: Int64 = 10_000_000
            let unixSeconds = Double(ticks - unixEpochTicks) / Double(ticksPerSecond)
            let date = Date(timeIntervalSince1970: unixSeconds)

            let formatString = arguments.count > 1 ? (arguments[1] as? String) : "yyyy-MM-dd"
            let formatter = DateFormatter()
            formatter.dateFormat = formatString ?? "yyyy-MM-dd"
            return formatter.string(from: date)
        }
    }

    /// Converts Unix epoch seconds to a formatted date string.
    /// Usage: formatEpoch(1556913600, 'yyyy-MM-ddTHH:mm:ssZ') → "2019-05-03T20:00:00+0000"
    struct FormatEpoch: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count >= 1 && arguments.count <= 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }

            let epochSeconds: Double
            if let num = arguments[0] as? Double {
                epochSeconds = num
            } else if let num = arguments[0] as? Int {
                epochSeconds = Double(num)
            } else if let str = arguments[0] as? String, let num = Double(str) {
                epochSeconds = num
            } else {
                throw EvaluationError.invalidArgument("formatEpoch requires a numeric epoch value")
            }

            let date = Date(timeIntervalSince1970: epochSeconds)

            // Always use ISO8601DateFormatter for reliable UTC output that the
            // DateTimeMacroExpander can parse (produces +00:00 or Z format).
            // This avoids issues with DateFormatter's Z pattern producing +0000
            // which ISO8601DateFormatter cannot parse back.
            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withInternetDateTime]
            iso.timeZone = TimeZone(identifier: "UTC")
            return iso.string(from: date)
        }
    }

    struct AddDays: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 2, actual: arguments.count)
            }

            let date = try parseDate(arguments[0])
            guard let days = arguments[1] as? Double ?? (arguments[1] as? Int).map(Double.init) else {
                throw EvaluationError.invalidArgument("days must be a number")
            }

            guard let newDate = Calendar.current.date(byAdding: .day, value: Int(days), to: date) else {
                return date
            }
            return ISO8601DateFormatter().string(from: newDate)
        }
    }

    struct AddHours: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 2, actual: arguments.count)
            }

            let date = try parseDate(arguments[0])
            guard let hours = arguments[1] as? Double ?? (arguments[1] as? Int).map(Double.init) else {
                throw EvaluationError.invalidArgument("hours must be a number")
            }

            guard let newDate = Calendar.current.date(byAdding: .hour, value: Int(hours), to: date) else {
                return date
            }
            return ISO8601DateFormatter().string(from: newDate)
        }
    }

    struct GetYear: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 1 else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }

            let date = try parseDate(arguments[0])
            return Calendar.current.component(.year, from: date)
        }
    }

    struct GetMonth: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 1 else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }

            let date = try parseDate(arguments[0])
            return Calendar.current.component(.month, from: date)
        }
    }

    struct GetDay: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 1 else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }

            let date = try parseDate(arguments[0])
            return Calendar.current.component(.day, from: date)
        }
    }

    struct DateDiff: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 2, actual: arguments.count)
            }

            let date1 = try parseDate(arguments[0])
            let date2 = try parseDate(arguments[1])

            let diff = Calendar.current.dateComponents([.day], from: date1, to: date2)
            return diff.day ?? 0
        }
    }

    struct UtcNow: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.isEmpty else {
                throw EvaluationError.invalidArgumentCount(expected: 0, actual: arguments.count)
            }

            return ISO8601DateFormatter().string(from: Date())
        }
    }

    // MARK: - Helpers

    private static func parseDate(_ value: Any?) throws -> Date {
        if let date = value as? Date {
            return date
        } else if let str = value as? String {
            let formatter = ISO8601DateFormatter()
            if let date = formatter.date(from: str) {
                return date
            }

            // Try ISO 8601 with timezone offset (+0000 / +00:00)
            let tzFormatter = DateFormatter()
            tzFormatter.locale = Locale(identifier: "en_US_POSIX")
            tzFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let date = tzFormatter.date(from: str) {
                return date
            }

            // Try standard formats
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            let formats = ["yyyy-MM-dd", "yyyy-MM-dd'T'HH:mm:ss", "MM/dd/yyyy HH:mm:ss", "MM/dd/yyyy"]
            for format in formats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: str) {
                    return date
                }
            }
        }

        // Default to current date if parsing fails
        return Date()
    }

    /// Quote unrecognized letters in a date format string so DateFormatter
    /// doesn't produce undefined behavior. Recognized pattern letters follow
    /// Unicode TR35 (used by NSDateFormatter / DateFormatter).
    private static func sanitizeFormat(_ format: String) -> String {
        // .NET/AC day-name shortcuts → DateFormatter equivalents
        switch format {
        case "dddd": return "EEEE"
        case "ddd": return "EEE"
        default: break
        }

        let recognized: Set<Character> = Set("GyYuUrQqMLlwWdDFgEecahHKkjJmsSAzZOvVXx")
        var result = ""
        var inQuote = false
        for ch in format {
            if ch == "'" {
                result.append(ch)
                inQuote = !inQuote
            } else if !inQuote && ch.isLetter && !recognized.contains(ch) {
                result.append("'")
                result.append(ch)
                result.append("'")
            } else {
                result.append(ch)
            }
        }
        return result
    }
}
