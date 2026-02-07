import Foundation

/// String manipulation functions for template expressions
public struct StringFunctions {
    public static func register(into functions: inout [String: ExpressionFunction]) {
        functions["toLower"] = ToLower()
        functions["toUpper"] = ToUpper()
        functions["substring"] = Substring()
        functions["indexOf"] = IndexOf()
        functions["length"] = Length()
        functions["replace"] = Replace()
        functions["split"] = Split()
        functions["join"] = Join()
        functions["trim"] = Trim()
        functions["startsWith"] = StartsWith()
        functions["endsWith"] = EndsWith()
        functions["contains"] = Contains()
        functions["format"] = Format()
    }
    
    // MARK: - Function Implementations
    
    struct ToLower: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 1 else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }
            guard let str = arguments[0] as? String else {
                return arguments[0]
            }
            return str.lowercased()
        }
    }
    
    struct ToUpper: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 1 else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }
            guard let str = arguments[0] as? String else {
                return arguments[0]
            }
            return str.uppercased()
        }
    }
    
    struct Substring: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count >= 2 && arguments.count <= 3 else {
                throw EvaluationError.invalidArgumentCount(expected: 2, actual: arguments.count)
            }
            
            guard let str = arguments[0] as? String else {
                return arguments[0]
            }
            
            let start = try coerceToInt(arguments[1])
            guard start >= 0 && start < str.count else {
                return str
            }
            
            if arguments.count == 3 {
                let length = try coerceToInt(arguments[2])
                let startIndex = str.index(str.startIndex, offsetBy: start)
                let endIndex = str.index(startIndex, offsetBy: min(length, str.count - start))
                return String(str[startIndex..<endIndex])
            } else {
                let startIndex = str.index(str.startIndex, offsetBy: start)
                return String(str[startIndex...])
            }
        }
    }
    
    struct IndexOf: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 2, actual: arguments.count)
            }
            
            guard let str = arguments[0] as? String,
                  let search = arguments[1] as? String else {
                return -1
            }
            
            if let range = str.range(of: search) {
                return str.distance(from: str.startIndex, to: range.lowerBound)
            }
            return -1
        }
    }
    
    struct Length: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 1 else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }
            
            if let str = arguments[0] as? String {
                return str.count
            } else if let array = arguments[0] as? [Any] {
                return array.count
            } else if let dict = arguments[0] as? [String: Any] {
                return dict.count
            }
            
            return 0
        }
    }
    
    struct Replace: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 3 else {
                throw EvaluationError.invalidArgumentCount(expected: 3, actual: arguments.count)
            }
            
            guard let str = arguments[0] as? String,
                  let search = arguments[1] as? String,
                  let replacement = arguments[2] as? String else {
                return arguments[0]
            }
            
            return str.replacingOccurrences(of: search, with: replacement)
        }
    }
    
    struct Split: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 2, actual: arguments.count)
            }
            
            guard let str = arguments[0] as? String,
                  let delimiter = arguments[1] as? String else {
                return [arguments[0]]
            }
            
            return str.components(separatedBy: delimiter)
        }
    }
    
    struct Join: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 2, actual: arguments.count)
            }
            
            guard let array = arguments[0] as? [Any],
                  let delimiter = arguments[1] as? String else {
                return ""
            }
            
            return array.map { String(describing: $0) }.joined(separator: delimiter)
        }
    }
    
    struct Trim: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 1 else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }
            
            guard let str = arguments[0] as? String else {
                return arguments[0]
            }
            
            return str.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    struct StartsWith: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 2, actual: arguments.count)
            }
            
            guard let str = arguments[0] as? String,
                  let prefix = arguments[1] as? String else {
                return false
            }
            
            return str.hasPrefix(prefix)
        }
    }
    
    struct EndsWith: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 2, actual: arguments.count)
            }
            
            guard let str = arguments[0] as? String,
                  let suffix = arguments[1] as? String else {
                return false
            }
            
            return str.hasSuffix(suffix)
        }
    }
    
    struct Contains: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 2, actual: arguments.count)
            }
            
            if let str = arguments[0] as? String,
               let search = arguments[1] as? String {
                return str.contains(search)
            } else if let array = arguments[0] as? [Any] {
                // Check if array contains the element
                return array.contains { element in
                    String(describing: element) == String(describing: arguments[1] ?? "")
                }
            }
            
            return false
        }
    }
    
    struct Format: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count >= 1 else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }
            
            guard let format = arguments[0] as? String else {
                return arguments[0]
            }
            
            var result = format
            for (index, arg) in arguments.dropFirst().enumerated() {
                let placeholder = "{\(index)}"
                result = result.replacingOccurrences(of: placeholder, with: String(describing: arg ?? ""))
            }
            
            return result
        }
    }
    
    // MARK: - Helper
    
    private static func coerceToInt(_ value: Any?) throws -> Int {
        if let int = value as? Int {
            return int
        } else if let double = value as? Double {
            return Int(double)
        } else if let str = value as? String, let int = Int(str) {
            return int
        }
        throw EvaluationError.typeCoercionFailed(value, "integer")
    }
}
