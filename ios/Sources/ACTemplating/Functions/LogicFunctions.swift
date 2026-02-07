import Foundation

/// Logic and comparison functions for template expressions
public struct LogicFunctions {
    public static func register(into functions: inout [String: ExpressionFunction]) {
        functions["if"] = If()
        functions["equals"] = Equals()
        functions["not"] = Not()
        functions["and"] = And()
        functions["or"] = Or()
        functions["greaterThan"] = GreaterThan()
        functions["lessThan"] = LessThan()
        functions["exists"] = Exists()
        functions["empty"] = Empty()
        functions["isMatch"] = IsMatch()
    }
    
    // MARK: - Function Implementations
    
    struct If: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 3 else {
                throw EvaluationError.invalidArgumentCount(expected: 3, actual: arguments.count)
            }
            
            let condition = toBool(arguments[0])
            return condition ? arguments[1] : arguments[2]
        }
    }
    
    struct Equals: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 2, actual: arguments.count)
            }
            
            return isEqual(arguments[0], arguments[1])
        }
    }
    
    struct Not: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 1 else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }
            
            return !toBool(arguments[0])
        }
    }
    
    struct And: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count >= 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 2, actual: arguments.count)
            }
            
            return arguments.allSatisfy { toBool($0) }
        }
    }
    
    struct Or: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count >= 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 2, actual: arguments.count)
            }
            
            return arguments.contains { toBool($0) }
        }
    }
    
    struct GreaterThan: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 2, actual: arguments.count)
            }
            
            let left = toNumber(arguments[0])
            let right = toNumber(arguments[1])
            return left > right
        }
    }
    
    struct LessThan: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 2, actual: arguments.count)
            }
            
            let left = toNumber(arguments[0])
            let right = toNumber(arguments[1])
            return left < right
        }
    }
    
    struct Exists: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 1 else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }
            
            return arguments[0] != nil
        }
    }
    
    struct Empty: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 1 else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }
            
            if arguments[0] == nil {
                return true
            }
            
            if let str = arguments[0] as? String {
                return str.isEmpty
            }
            
            if let array = arguments[0] as? [Any] {
                return array.isEmpty
            }
            
            if let dict = arguments[0] as? [String: Any] {
                return dict.isEmpty
            }
            
            return false
        }
    }
    
    struct IsMatch: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 2, actual: arguments.count)
            }
            
            guard let str = arguments[0] as? String,
                  let pattern = arguments[1] as? String else {
                return false
            }
            
            do {
                let regex = try NSRegularExpression(pattern: pattern)
                let range = NSRange(str.startIndex..., in: str)
                return regex.firstMatch(in: str, range: range) != nil
            } catch {
                return false
            }
        }
    }
    
    // MARK: - Helpers
    
    private static func toBool(_ value: Any?) -> Bool {
        if let bool = value as? Bool {
            return bool
        } else if let num = value as? Double {
            return num != 0
        } else if let num = value as? Int {
            return num != 0
        } else if let str = value as? String {
            return !str.isEmpty
        } else if value == nil {
            return false
        } else if let array = value as? [Any] {
            return !array.isEmpty
        } else if let dict = value as? [String: Any] {
            return !dict.isEmpty
        }
        return true
    }
    
    private static func toNumber(_ value: Any?) -> Double {
        if let num = value as? Double {
            return num
        } else if let num = value as? Int {
            return Double(num)
        } else if let str = value as? String, let num = Double(str) {
            return num
        } else if let bool = value as? Bool {
            return bool ? 1.0 : 0.0
        }
        return 0.0
    }
    
    private static func isEqual(_ left: Any?, _ right: Any?) -> Bool {
        if left == nil && right == nil {
            return true
        }
        if left == nil || right == nil {
            return false
        }
        
        if let l = left as? Double, let r = right as? Double {
            return l == r
        }
        if let l = left as? Int, let r = right as? Int {
            return l == r
        }
        if let l = left as? String, let r = right as? String {
            return l == r
        }
        if let l = left as? Bool, let r = right as? Bool {
            return l == r
        }
        
        return String(describing: left!) == String(describing: right!)
    }
}
