import Foundation

/// Evaluates parsed expressions against a data context
public final class ExpressionEvaluator {
    private let context: DataContext
    private let functions: [String: ExpressionFunction]
    
    public init(context: DataContext) {
        self.context = context
        
        // Register all built-in functions
        var functions: [String: ExpressionFunction] = [:]
        
        // String functions
        StringFunctions.register(into: &functions)
        
        // Date functions
        DateFunctions.register(into: &functions)
        
        // Collection functions
        CollectionFunctions.register(into: &functions)
        
        // Logic functions
        LogicFunctions.register(into: &functions)
        
        // Math functions
        MathFunctions.register(into: &functions)
        
        self.functions = functions
    }
    
    /// Evaluate an expression
    /// - Parameter expression: The parsed expression
    /// - Returns: The evaluated result
    /// - Throws: EvaluationError if evaluation fails
    public func evaluate(_ expression: Expression) throws -> Any? {
        switch expression {
        case .literal(let value):
            return value
            
        case .propertyAccess(let path):
            return context.resolve(path: path)
            
        case .functionCall(let name, let arguments):
            guard let function = functions[name] else {
                throw EvaluationError.unknownFunction(name)
            }
            
            let evaluatedArgs = try arguments.map { try evaluate($0) }
            return try function.call(evaluatedArgs)
            
        case .binaryOp(let op, let left, let right):
            return try evaluateBinaryOp(op: op, left: left, right: right)
            
        case .unaryOp(let op, let operand):
            return try evaluateUnaryOp(op: op, operand: operand)
            
        case .ternary(let condition, let trueValue, let falseValue):
            let condResult = try evaluate(condition)
            let boolResult = try coerceToBool(condResult)
            return try evaluate(boolResult ? trueValue : falseValue)
        }
    }
    
    // MARK: - Binary Operations
    
    private func evaluateBinaryOp(op: String, left: Expression, right: Expression) throws -> Any? {
        let leftValue = try evaluate(left)
        let rightValue = try evaluate(right)
        
        switch op {
        case "+":
            // String concatenation or numeric addition
            if let l = leftValue as? String, let r = rightValue as? String {
                return l + r
            } else if let l = leftValue as? String {
                return l + String(describing: rightValue ?? "")
            } else if let r = rightValue as? String {
                return String(describing: leftValue ?? "") + r
            }
            let left = try coerceToNumber(leftValue)
            let right = try coerceToNumber(rightValue)
            return left + right

        case "-":
            let left = try coerceToNumber(leftValue)
            let right = try coerceToNumber(rightValue)
            return left - right

        case "*":
            let left = try coerceToNumber(leftValue)
            let right = try coerceToNumber(rightValue)
            return left * right
            
        case "/":
            let divisor = try coerceToNumber(rightValue)
            guard divisor != 0 else {
                throw EvaluationError.divisionByZero
            }
            return try coerceToNumber(leftValue) / divisor
            
        case "%":
            let divisor = try coerceToNumber(rightValue)
            guard divisor != 0 else {
                throw EvaluationError.divisionByZero
            }
            return try coerceToNumber(leftValue).truncatingRemainder(dividingBy: divisor)
            
        case "==":
            return isEqual(leftValue, rightValue)
            
        case "!=":
            return !isEqual(leftValue, rightValue)
            
        case "<":
            let left = try coerceToNumber(leftValue)
            let right = try coerceToNumber(rightValue)
            return left < right

        case ">":
            let left = try coerceToNumber(leftValue)
            let right = try coerceToNumber(rightValue)
            return left > right

        case "<=":
            let left = try coerceToNumber(leftValue)
            let right = try coerceToNumber(rightValue)
            return left <= right

        case ">=":
            let left = try coerceToNumber(leftValue)
            let right = try coerceToNumber(rightValue)
            return left >= right

        case "&&":
            let left = try coerceToBool(leftValue)
            let right = try coerceToBool(rightValue)
            return left && right

        case "||":
            let left = try coerceToBool(leftValue)
            let right = try coerceToBool(rightValue)
            return left || right
            
        default:
            throw EvaluationError.unknownOperator(op)
        }
    }
    
    private func evaluateUnaryOp(op: String, operand: Expression) throws -> Any? {
        let value = try evaluate(operand)
        
        switch op {
        case "!":
            return try !coerceToBool(value)
            
        case "-":
            return try -coerceToNumber(value)
            
        default:
            throw EvaluationError.unknownOperator(op)
        }
    }
    
    // MARK: - Type Coercion
    
    private func coerceToNumber(_ value: Any?) throws -> Double {
        if let num = value as? Double {
            return num
        } else if let num = value as? Int {
            return Double(num)
        } else if let num = value as? Float {
            return Double(num)
        } else if let str = value as? String, let num = Double(str) {
            return num
        } else if let bool = value as? Bool {
            return bool ? 1.0 : 0.0
        } else if value == nil {
            return 0.0
        }
        
        throw EvaluationError.typeCoercionFailed(value, "number")
    }
    
    private func coerceToBool(_ value: Any?) throws -> Bool {
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
        
        return true // Non-null objects are truthy
    }
    
    private func isEqual(_ left: Any?, _ right: Any?) -> Bool {
        // Handle nil cases
        if left == nil && right == nil {
            return true
        }
        if left == nil || right == nil {
            return false
        }
        
        // Try numeric comparison
        if let l = left as? Double, let r = right as? Double {
            return l == r
        }
        if let l = left as? Int, let r = right as? Int {
            return l == r
        }
        
        // Try string comparison
        if let l = left as? String, let r = right as? String {
            return l == r
        }
        
        // Try boolean comparison
        if let l = left as? Bool, let r = right as? Bool {
            return l == r
        }
        
        // Fallback to string representation
        return String(describing: left!) == String(describing: right!)
    }
}

// MARK: - Expression Function Protocol

public protocol ExpressionFunction {
    func call(_ arguments: [Any?]) throws -> Any?
}

// MARK: - Errors

public enum EvaluationError: Error, LocalizedError {
    case unknownFunction(String)
    case unknownOperator(String)
    case typeCoercionFailed(Any?, String)
    case divisionByZero
    case invalidArgumentCount(expected: Int, actual: Int)
    case invalidArgument(String)
    
    public var errorDescription: String? {
        switch self {
        case .unknownFunction(let name):
            return "Unknown function: \(name)"
        case .unknownOperator(let op):
            return "Unknown operator: \(op)"
        case .typeCoercionFailed(let value, let type):
            return "Cannot convert \(String(describing: value)) to \(type)"
        case .divisionByZero:
            return "Division by zero"
        case .invalidArgumentCount(let expected, let actual):
            return "Invalid argument count: expected \(expected), got \(actual)"
        case .invalidArgument(let message):
            return "Invalid argument: \(message)"
        }
    }
}
