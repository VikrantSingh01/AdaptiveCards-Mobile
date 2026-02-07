import Foundation

/// Mathematical functions for template expressions
public struct MathFunctions {
    public static func register(into functions: inout [String: ExpressionFunction]) {
        functions["add"] = Add()
        functions["sub"] = Sub()
        functions["mul"] = Mul()
        functions["div"] = Div()
        functions["mod"] = Mod()
        functions["min"] = Min()
        functions["max"] = Max()
        functions["round"] = Round()
        functions["floor"] = Floor()
        functions["ceil"] = Ceil()
        functions["abs"] = Abs()
    }
    
    // MARK: - Function Implementations
    
    struct Add: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count >= 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 2, actual: arguments.count)
            }
            
            return arguments.reduce(0.0) { result, arg in
                result + toNumber(arg)
            }
        }
    }
    
    struct Sub: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 2, actual: arguments.count)
            }
            
            return toNumber(arguments[0]) - toNumber(arguments[1])
        }
    }
    
    struct Mul: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count >= 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 2, actual: arguments.count)
            }
            
            return arguments.reduce(1.0) { result, arg in
                result * toNumber(arg)
            }
        }
    }
    
    struct Div: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 2, actual: arguments.count)
            }
            
            let divisor = toNumber(arguments[1])
            guard divisor != 0 else {
                throw EvaluationError.divisionByZero
            }
            
            return toNumber(arguments[0]) / divisor
        }
    }
    
    struct Mod: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 2 else {
                throw EvaluationError.invalidArgumentCount(expected: 2, actual: arguments.count)
            }
            
            let divisor = toNumber(arguments[1])
            guard divisor != 0 else {
                throw EvaluationError.divisionByZero
            }
            
            return toNumber(arguments[0]).truncatingRemainder(dividingBy: divisor)
        }
    }
    
    struct Min: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard !arguments.isEmpty else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }
            
            let numbers = arguments.map { toNumber($0) }
            return numbers.min() ?? 0.0
        }
    }
    
    struct Max: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard !arguments.isEmpty else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }
            
            let numbers = arguments.map { toNumber($0) }
            return numbers.max() ?? 0.0
        }
    }
    
    struct Round: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 1 else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }
            
            return Foundation.round(toNumber(arguments[0]))
        }
    }
    
    struct Floor: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 1 else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }
            
            return Foundation.floor(toNumber(arguments[0]))
        }
    }
    
    struct Ceil: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 1 else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }
            
            return Foundation.ceil(toNumber(arguments[0]))
        }
    }
    
    struct Abs: ExpressionFunction {
        func call(_ arguments: [Any?]) throws -> Any? {
            guard arguments.count == 1 else {
                throw EvaluationError.invalidArgumentCount(expected: 1, actual: arguments.count)
            }
            
            return Swift.abs(toNumber(arguments[0]))
        }
    }
    
    // MARK: - Helper
    
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
}
