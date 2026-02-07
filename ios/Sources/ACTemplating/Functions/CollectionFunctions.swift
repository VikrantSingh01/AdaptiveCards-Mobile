import Foundation

/// Collection manipulation functions for template expressions
public struct CollectionFunctions {
    public static func register(into functions: inout [String: ExpressionFunction]) {
        functions["count"] = Count()
        functions["first"] = First()
        functions["last"] = Last()
        functions["filter"] = Filter()
        functions["sort"] = Sort()
        functions["flatten"] = Flatten()
        functions["union"] = Union()
        functions["intersection"] = Intersection()
    }
    
    // MARK: - Function Implementations
    
    struct Count: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 1 else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }
            
            if let array = arguments[0] as? [Any] {
                return array.count
            } else if let dict = arguments[0] as? [String: Any] {
                return dict.count
            } else if let str = arguments[0] as? String {
                return str.count
            }
            return 0
        }
    }
    
    struct First: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 1 else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }
            
            if let array = arguments[0] as? [Any], !array.isEmpty {
                return array.first
            }
            return nil
        }
    }
    
    struct Last: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 1 else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }
            
            if let array = arguments[0] as? [Any], !array.isEmpty {
                return array.last
            }
            return nil
        }
    }
    
    struct Filter: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count >= 1 else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }
            
            guard let array = arguments[0] as? [Any] else {
                return []
            }
            
            // Simple filter: keep non-nil, non-empty elements
            return array.filter { element in
                if element == nil {
                    return false
                }
                if let str = element as? String {
                    return !str.isEmpty
                }
                return true
            }
        }
    }
    
    struct Sort: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 1 else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }
            
            guard let array = arguments[0] as? [Any] else {
                return []
            }
            
            return array.sorted { left, right in
                if let l = left as? Double, let r = right as? Double {
                    return l < r
                } else if let l = left as? Int, let r = right as? Int {
                    return l < r
                } else if let l = left as? String, let r = right as? String {
                    return l < r
                }
                return String(describing: left) < String(describing: right)
            }
        }
    }
    
    struct Flatten: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 1 else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }
            
            guard let array = arguments[0] as? [Any] else {
                return []
            }
            
            var result: [Any] = []
            for element in array {
                if let nested = element as? [Any] {
                    result.append(contentsOf: nested)
                } else {
                    result.append(element)
                }
            }
            
            return result
        }
    }
    
    struct Union: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 2, actual: arguments.count)
            }
            
            guard let array1 = arguments[0] as? [Any],
                  let array2 = arguments[1] as? [Any] else {
                return []
            }
            
            var result = array1
            for element in array2 {
                let elementStr = String(describing: element)
                if !result.contains(where: { String(describing: $0) == elementStr }) {
                    result.append(element)
                }
            }
            
            return result
        }
    }
    
    struct Intersection: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 2, actual: arguments.count)
            }
            
            guard let array1 = arguments[0] as? [Any],
                  let array2 = arguments[1] as? [Any] else {
                return []
            }
            
            let array2Strings = array2.map { String(describing: $0) }
            return array1.filter { element in
                let elementStr = String(describing: element)
                return array2Strings.contains(elementStr)
            }
        }
    }
}
