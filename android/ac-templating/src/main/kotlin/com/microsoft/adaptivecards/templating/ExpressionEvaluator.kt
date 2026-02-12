package com.microsoft.adaptivecards.templating

import com.microsoft.adaptivecards.templating.functions.*

/**
 * Expression function interface
 */
interface ExpressionFunction {
    fun call(arguments: List<Any?>): Any?
}

/**
 * Evaluates parsed expressions against a data context
 */
class ExpressionEvaluator(private val context: DataContext) {
    private val functions: Map<String, ExpressionFunction>

    init {
        val functionsMap = mutableMapOf<String, ExpressionFunction>()

        // Register all built-in functions
        StringFunctions.register(functionsMap)
        DateFunctions.register(functionsMap)
        CollectionFunctions.register(functionsMap)
        LogicFunctions.register(functionsMap)
        MathFunctions.register(functionsMap)

        functions = functionsMap
    }

    /**
     * Evaluate an expression
     * @param expression The parsed expression
     * @return The evaluated result
     * @throws EvaluationException if evaluation fails
     */
    fun evaluate(expression: Expression): Any? {
        return when (expression) {
            is Expression.Literal -> expression.value

            is Expression.PropertyAccess -> context.resolve(expression.path)

            is Expression.FunctionCall -> {
                val function = functions[expression.name]
                    ?: throw EvaluationException("Unknown function: ${expression.name}")

                val evaluatedArgs = expression.arguments.map { evaluate(it) }
                try {
                    function.call(evaluatedArgs)
                } catch (e: Exception) {
                    throw EvaluationException("Function ${expression.name} failed: ${e.message}", e)
                }
            }

            is Expression.BinaryOp -> evaluateBinaryOp(expression.operator, expression.left, expression.right)

            is Expression.UnaryOp -> evaluateUnaryOp(expression.operator, expression.operand)

            is Expression.Ternary -> {
                val condResult = evaluate(expression.condition)
                val boolResult = coerceToBool(condResult)
                evaluate(if (boolResult) expression.trueValue else expression.falseValue)
            }
        }
    }

    // MARK: - Binary Operations

    private fun evaluateBinaryOp(op: String, left: Expression, right: Expression): Any? {
        val leftValue = evaluate(left)
        val rightValue = evaluate(right)

        return when (op) {
            "+" -> {
                // String concatenation or numeric addition
                if (leftValue is String || rightValue is String) {
                    stringValue(leftValue) + stringValue(rightValue)
                } else {
                    coerceToNumber(leftValue) + coerceToNumber(rightValue)
                }
            }
            "-" -> coerceToNumber(leftValue) - coerceToNumber(rightValue)
            "*" -> coerceToNumber(leftValue) * coerceToNumber(rightValue)
            "/" -> {
                val divisor = coerceToNumber(rightValue)
                if (divisor == 0.0) {
                    throw EvaluationException("Division by zero")
                }
                coerceToNumber(leftValue) / divisor
            }
            "%" -> {
                val divisor = coerceToNumber(rightValue)
                if (divisor == 0.0) {
                    throw EvaluationException("Division by zero")
                }
                coerceToNumber(leftValue) % divisor
            }
            "==" -> isEqual(leftValue, rightValue)
            "!=" -> !isEqual(leftValue, rightValue)
            "<" -> coerceToNumber(leftValue) < coerceToNumber(rightValue)
            ">" -> coerceToNumber(leftValue) > coerceToNumber(rightValue)
            "<=" -> coerceToNumber(leftValue) <= coerceToNumber(rightValue)
            ">=" -> coerceToNumber(leftValue) >= coerceToNumber(rightValue)
            "&&" -> coerceToBool(leftValue) && coerceToBool(rightValue)
            "||" -> coerceToBool(leftValue) || coerceToBool(rightValue)
            else -> throw EvaluationException("Unknown operator: $op")
        }
    }

    private fun evaluateUnaryOp(op: String, operand: Expression): Any? {
        val value = evaluate(operand)

        return when (op) {
            "!" -> !coerceToBool(value)
            "-" -> -coerceToNumber(value)
            else -> throw EvaluationException("Unknown operator: $op")
        }
    }

    // MARK: - Type Coercion

    private fun coerceToNumber(value: Any?): Double {
        return when (value) {
            is Double -> value
            is Int -> value.toDouble()
            is Long -> value.toDouble()
            is Float -> value.toDouble()
            is String -> value.toDoubleOrNull() ?: 0.0
            is Boolean -> if (value) 1.0 else 0.0
            null -> 0.0
            else -> throw EvaluationException("Cannot convert $value to number")
        }
    }

    private fun coerceToBool(value: Any?): Boolean {
        return when (value) {
            is Boolean -> value
            is Double -> value != 0.0
            is Int -> value != 0
            is Long -> value != 0L
            is Float -> value != 0.0f
            is String -> value.isNotEmpty()
            null -> false
            is List<*> -> value.isNotEmpty()
            is Map<*, *> -> value.isNotEmpty()
            else -> true // Non-null objects are truthy
        }
    }

    private fun isEqual(left: Any?, right: Any?): Boolean {
        // Handle nil cases
        if (left == null && right == null) return true
        if (left == null || right == null) return false

        // Try numeric comparison
        if (left is Number && right is Number) {
            return left.toDouble() == right.toDouble()
        }

        // Try string comparison
        if (left is String && right is String) {
            return left == right
        }

        // Try boolean comparison
        if (left is Boolean && right is Boolean) {
            return left == right
        }

        // Fallback to string representation
        return left.toString() == right.toString()
    }

    private fun stringValue(value: Any?): String {
        return when (value) {
            is String -> value
            is Double -> {
                // Format numbers without unnecessary decimal places
                if (value % 1.0 == 0.0) {
                    value.toInt().toString()
                } else {
                    value.toString()
                }
            }
            is Int -> value.toString()
            is Boolean -> value.toString()
            null -> ""
            else -> value.toString()
        }
    }
}

/**
 * Exception thrown when expression evaluation fails
 */
class EvaluationException(message: String, cause: Throwable? = null) : Exception(message, cause)
