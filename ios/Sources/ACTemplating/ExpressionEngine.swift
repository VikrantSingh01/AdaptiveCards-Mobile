import Foundation

/// Protocol for expression engine implementations
/// Ported from production Teams-AdaptiveCards-Mobile SDK's protocol-oriented architecture.
/// Enables dependency injection and testability.
public protocol ExpressionEvaluating {
    /// Evaluate an expression string against a data context
    /// - Parameters:
    ///   - expression: The expression string (e.g., "name.first")
    ///   - context: The data context to evaluate against
    /// - Returns: The evaluated result
    func evaluate(expression: String, context: DataContext) throws -> Any?
}

/// Protocol for template engine implementations
public protocol TemplateProcessing {
    /// Process a template JSON string with data
    /// - Parameters:
    ///   - template: The template JSON string
    ///   - data: The data to bind into the template
    /// - Returns: The processed JSON string
    func process(template: String, with data: [String: Any]) throws -> String
}

/// Protocol for registering custom functions
public protocol FunctionRegistering {
    /// Register a custom function
    /// - Parameters:
    ///   - name: The function name
    ///   - function: The function implementation
    func registerFunction(name: String, function: ExpressionFunction)

    /// Check if a function is registered
    func hasFunction(name: String) -> Bool
}

/// Default implementation that ties together parser, evaluator, and cache
public final class ExpressionEngine: ExpressionEvaluating {
    private let parser: ExpressionParser
    private let cache: ExpressionCache?
    private var customFunctions: [String: ExpressionFunction] = [:]

    /// Create an expression engine with optional caching
    /// - Parameter cache: Expression cache (nil to disable caching)
    public init(cache: ExpressionCache? = ExpressionCache()) {
        self.parser = ExpressionParser()
        self.cache = cache
    }

    /// Evaluate an expression string against a data context
    public func evaluate(expression: String, context: DataContext) throws -> Any? {
        let parsed: Expression
        if let cache = cache {
            parsed = try cache.getOrParse(expression, using: parser)
        } else {
            parsed = try parser.parse(expression)
        }

        let evaluator = ExpressionEvaluator(context: context)
        return try evaluator.evaluate(parsed)
    }

    /// Cache statistics (nil if caching is disabled)
    public var cacheStats: (hits: Int, misses: Int, hitRate: Double, count: Int)? {
        guard let cache = cache else { return nil }
        return (cache.hits, cache.misses, cache.hitRate, cache.count)
    }

    /// Clear the expression cache
    public func clearCache() {
        cache?.clear()
    }
}

extension ExpressionEngine: FunctionRegistering {
    public func registerFunction(name: String, function: ExpressionFunction) {
        customFunctions[name] = function
    }

    public func hasFunction(name: String) -> Bool {
        customFunctions[name] != nil
    }
}
