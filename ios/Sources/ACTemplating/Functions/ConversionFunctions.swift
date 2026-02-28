import Foundation

/// Type conversion functions for the expression engine
/// Ported from production Teams-AdaptiveCards-Mobile SDK
public struct ConversionFunctions {
    public static func register(into functions: inout [String: ExpressionFunction]) {
        functions["parseInt"] = ParseIntFunction()
        functions["parseFloat"] = ParseFloatFunction()
        functions["toString"] = ToStringFunction()
        functions["toNumber"] = ToNumberFunction()
        functions["toBool"] = ToBoolFunction()
        functions["float"] = ParseFloatFunction()    // alias
        functions["int"] = ParseIntFunction()        // alias
        functions["string"] = ToStringFunction()     // alias
    }
}

// MARK: - parseInt

/// Converts a value to an integer
/// Usage: parseInt('42') -> 42, parseInt(3.7) -> 3
private struct ParseIntFunction: ExpressionFunction {
    func call(_ arguments: [Any?]) throws -> Any? {
        guard arguments.count == 1 else {
            throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
        }

        let value = arguments[0]

        if let num = value as? Double {
            return Double(Int(num))
        } else if let num = value as? Int {
            return Double(num)
        } else if let str = value as? String {
            // Try integer first, then double -> int
            if let intVal = Int(str) {
                return Double(intVal)
            } else if let doubleVal = Double(str) {
                return Double(Int(doubleVal))
            }
            throw EvaluationError.invalidArgument("Cannot parse '\(str)' as integer")
        } else if let bool = value as? Bool {
            return bool ? 1.0 : 0.0
        } else if value == nil {
            return 0.0
        }

        throw EvaluationError.typeCoercionFailed(value, "integer")
    }
}

// MARK: - parseFloat

/// Converts a value to a floating-point number
/// Usage: parseFloat('3.14') -> 3.14
private struct ParseFloatFunction: ExpressionFunction {
    func call(_ arguments: [Any?]) throws -> Any? {
        guard arguments.count == 1 else {
            throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
        }

        let value = arguments[0]

        if let num = value as? Double {
            return num
        } else if let num = value as? Int {
            return Double(num)
        } else if let str = value as? String {
            if let doubleVal = Double(str) {
                return doubleVal
            }
            throw EvaluationError.invalidArgument("Cannot parse '\(str)' as float")
        } else if let bool = value as? Bool {
            return bool ? 1.0 : 0.0
        } else if value == nil {
            return 0.0
        }

        throw EvaluationError.typeCoercionFailed(value, "float")
    }
}

// MARK: - toString

/// Converts a value to its string representation
/// Usage: toString(42) -> '42', toString(true) -> 'true'
private struct ToStringFunction: ExpressionFunction {
    func call(_ arguments: [Any?]) throws -> Any? {
        guard arguments.count == 1 else {
            throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
        }

        let value = arguments[0]

        if let str = value as? String {
            return str
        } else if let num = value as? Double {
            // Format integers without decimal point
            if num == num.rounded() && !num.isInfinite {
                return String(Int(num))
            }
            return String(num)
        } else if let num = value as? Int {
            return String(num)
        } else if let bool = value as? Bool {
            return bool ? "true" : "false"
        } else if value == nil {
            return ""
        }

        return String(describing: value!)
    }
}

// MARK: - toNumber

/// Converts a value to a number
/// Usage: toNumber('3.14') -> 3.14, toNumber(true) -> 1
private struct ToNumberFunction: ExpressionFunction {
    func call(_ arguments: [Any?]) throws -> Any? {
        guard arguments.count == 1 else {
            throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
        }

        let value = arguments[0]

        if let num = value as? Double {
            return num
        } else if let num = value as? Int {
            return Double(num)
        } else if let str = value as? String {
            if let doubleVal = Double(str) {
                return doubleVal
            }
            throw EvaluationError.invalidArgument("Cannot convert '\(str)' to number")
        } else if let bool = value as? Bool {
            return bool ? 1.0 : 0.0
        } else if value == nil {
            return 0.0
        }

        throw EvaluationError.typeCoercionFailed(value, "number")
    }
}

// MARK: - toBool

/// Converts a value to a boolean
/// Usage: toBool(1) -> true, toBool('') -> false
private struct ToBoolFunction: ExpressionFunction {
    func call(_ arguments: [Any?]) throws -> Any? {
        guard arguments.count == 1 else {
            throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
        }

        let value = arguments[0]

        if let bool = value as? Bool {
            return bool
        } else if let num = value as? Double {
            return num != 0
        } else if let num = value as? Int {
            return num != 0
        } else if let str = value as? String {
            let lower = str.lowercased()
            if lower == "true" || lower == "1" || lower == "yes" { return true }
            if lower == "false" || lower == "0" || lower == "no" || lower.isEmpty { return false }
            return !str.isEmpty
        } else if value == nil {
            return false
        } else if let array = value as? [Any] {
            return !array.isEmpty
        }

        return true // Non-null objects are truthy
    }
}
