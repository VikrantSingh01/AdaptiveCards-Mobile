package com.microsoft.adaptivecards.templating

import com.microsoft.adaptivecards.templating.functions.*

/**
 * Interface for evaluating expressions.
 * Provides abstraction for testability and swappable implementations.
 */
interface ExpressionEvaluating {
    /**
     * Evaluate an expression string against a data context.
     * @param expression The expression string
     * @param context The data context
     * @return The evaluated result
     */
    fun evaluate(expression: String, context: DataContext): Any?
}

/**
 * Interface for processing templates with data binding.
 */
interface TemplateProcessing {
    /**
     * Process a template string, replacing `${...}` expressions with evaluated values.
     * @param template The template string
     * @param context The data context
     * @return The processed string
     */
    fun processTemplate(template: String, context: DataContext): String
}

/**
 * Interface for registering custom functions.
 */
interface FunctionRegistering {
    /**
     * Register a custom function.
     * @param name Function name
     * @param function Function implementation
     */
    fun registerFunction(name: String, function: ExpressionFunction)
}

/**
 * Unified expression engine that ties together parsing, evaluation, and caching.
 *
 * Ported from production Teams-AdaptiveCards-Mobile SDK's protocol-oriented architecture.
 * Provides a single entry point for expression evaluation with optional caching.
 *
 * @param cache Optional expression cache for performance optimization
 */
class ExpressionEngine(
    private val cache: ExpressionCache? = ExpressionCache()
) : ExpressionEvaluating, TemplateProcessing, FunctionRegistering {

    private val parser = ExpressionParser()
    private val customFunctions = mutableMapOf<String, ExpressionFunction>()

    override fun evaluate(expression: String, context: DataContext): Any? {
        val parsed = if (cache != null) {
            cache.getOrParse(expression, parser)
        } else {
            parser.parse(expression)
        }

        val evaluator = ExpressionEvaluator(context)
        return evaluator.evaluate(parsed)
    }

    override fun processTemplate(template: String, context: DataContext): String {
        val regex = Regex("""\$\{(.+?)\}""")
        return regex.replace(template) { match ->
            val expr = match.groupValues[1]
            try {
                val result = evaluate(expr, context)
                result?.toString() ?: ""
            } catch (_: Exception) {
                match.value // Return original on error
            }
        }
    }

    override fun registerFunction(name: String, function: ExpressionFunction) {
        customFunctions[name] = function
    }

    /** Clear the expression cache */
    fun clearCache() {
        cache?.clear()
    }

    /** Get cache statistics */
    fun cacheStats(): CacheStats? {
        val c = cache ?: return null
        return CacheStats(
            entries = c.count,
            hits = c.hits,
            misses = c.misses,
            hitRate = c.hitRate
        )
    }

    data class CacheStats(
        val entries: Int,
        val hits: Int,
        val misses: Int,
        val hitRate: Double
    )
}
