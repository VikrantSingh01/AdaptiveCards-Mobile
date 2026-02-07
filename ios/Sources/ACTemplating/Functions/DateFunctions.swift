import Foundation

/// Date and time functions for template expressions
public struct DateFunctions {
    public static func register(into functions: inout [String: ExpressionFunction]) {
        functions["formatDateTime"] = FormatDateTime()
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
            
            let formatter = DateFormatter()
            formatter.dateFormat = formatString ?? "yyyy-MM-dd"
            return formatter.string(from: date)
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
            
            // Try standard formats
            let dateFormatter = DateFormatter()
            let formats = ["yyyy-MM-dd", "yyyy-MM-dd'T'HH:mm:ss", "MM/dd/yyyy"]
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
}
