package com.microsoft.adaptivecards.templating

/**
 * Represents an expression in the template syntax
 */
sealed class Expression {
    data class Literal(val value: Any?) : Expression()
    data class PropertyAccess(val path: String) : Expression()
    data class FunctionCall(val name: String, val arguments: List<Expression>) : Expression()
    data class BinaryOp(val operator: String, val left: Expression, val right: Expression) : Expression()
    data class UnaryOp(val operator: String, val operand: Expression) : Expression()
    data class Ternary(val condition: Expression, val trueValue: Expression, val falseValue: Expression) : Expression()
}

/**
 * Token types for expression parsing
 */
sealed class Token {
    data class StringToken(val value: String) : Token()
    data class NumberToken(val value: Double) : Token()
    data class BooleanToken(val value: Boolean) : Token()
    data class IdentifierToken(val name: String) : Token()
    data class OperatorToken(val op: String) : Token()
    object LeftParen : Token()
    object RightParen : Token()
    object LeftBracket : Token()
    object RightBracket : Token()
    object Comma : Token()
    object Dot : Token()
    object Question : Token()
    object Colon : Token()
    object EOF : Token()
}

/**
 * Parses template expressions into an AST with thread-safe parsing
 */
class ExpressionParser {
    private var tokens: List<Token> = emptyList()
    private var position = 0

    /**
     * Parse an expression string into an AST
     * Thread-safe: uses synchronized access to prevent data races
     * @param expression The expression string
     * @return The parsed expression
     * @throws ParsingException if the expression is invalid
     */
    @Synchronized
    fun parse(expression: String): Expression {
        tokens = tokenize(expression)
        position = 0
        return parseExpression()
    }

    // MARK: - Tokenization

    private fun tokenize(input: String): List<Token> {
        val tokens = mutableListOf<Token>()
        var index = 0

        while (index < input.length) {
            val char = input[index]

            // Skip whitespace
            if (char.isWhitespace()) {
                index++
                continue
            }

            // String literals
            if (char == '\'' || char == '"') {
                val quote = char
                val value = StringBuilder()
                index++

                while (index < input.length && input[index] != quote) {
                    if (input[index] == '\\' && index + 1 < input.length) {
                        index++
                        val escaped = input[index]
                        value.append(when (escaped) {
                            'n' -> '\n'
                            't' -> '\t'
                            else -> escaped
                        })
                    } else {
                        value.append(input[index])
                    }
                    index++
                }

                if (index >= input.length) {
                    throw ParsingException("Unterminated string literal")
                }

                tokens.add(Token.StringToken(value.toString()))
                index++
                continue
            }

            // Numbers
            if (char.isDigit()) {
                val numStr = StringBuilder()
                numStr.append(char)
                index++

                while (index < input.length && (input[index].isDigit() || input[index] == '.')) {
                    numStr.append(input[index])
                    index++
                }

                val num = numStr.toString().toDoubleOrNull()
                if (num != null) {
                    tokens.add(Token.NumberToken(num))
                }
                continue
            }

            // Identifiers and keywords
            if (char.isLetter() || char == '$' || char == '_') {
                val identifier = StringBuilder()
                identifier.append(char)
                index++

                while (index < input.length && (input[index].isLetterOrDigit() || input[index] == '_')) {
                    identifier.append(input[index])
                    index++
                }

                val identifierStr = identifier.toString()
                when (identifierStr) {
                    "true" -> tokens.add(Token.BooleanToken(true))
                    "false" -> tokens.add(Token.BooleanToken(false))
                    "in" -> tokens.add(Token.OperatorToken("in"))
                    else -> tokens.add(Token.IdentifierToken(identifierStr))
                }
                continue
            }

            // Operators and symbols
            when (char) {
                '(' -> tokens.add(Token.LeftParen)
                ')' -> tokens.add(Token.RightParen)
                '[' -> tokens.add(Token.LeftBracket)
                ']' -> tokens.add(Token.RightBracket)
                ',' -> tokens.add(Token.Comma)
                '.' -> tokens.add(Token.Dot)
                '?' -> tokens.add(Token.Question)
                ':' -> tokens.add(Token.Colon)
                '+', '-', '*', '/', '%', '=', '!', '<', '>', '&', '|' -> {
                    var op = char.toString()
                    index++

                    // Handle two-character operators
                    if (index < input.length) {
                        val nextChar = input[index]
                        if ((char == '=' && nextChar == '=') ||
                            (char == '!' && nextChar == '=') ||
                            (char == '<' && nextChar == '=') ||
                            (char == '>' && nextChar == '=') ||
                            (char == '&' && nextChar == '&') ||
                            (char == '|' && nextChar == '|')) {
                            op += nextChar
                            index++
                        }
                    }

                    tokens.add(Token.OperatorToken(op))
                    continue
                }
                else -> throw ParsingException("Unexpected character: '$char'")
            }

            index++
        }

        tokens.add(Token.EOF)
        return tokens
    }

    // MARK: - Parsing

    private fun currentToken(): Token {
        return if (position < tokens.size) tokens[position] else Token.EOF
    }

    private fun advance() {
        position++
    }

    private fun parseExpression(): Expression {
        return parseTernary()
    }

    private fun parseTernary(): Expression {
        var expr = parseLogicalOr()

        if (currentToken() is Token.Question) {
            advance() // consume '?'
            val trueValue = parseExpression()

            if (currentToken() !is Token.Colon) {
                throw ParsingException("Expected ':' in ternary expression")
            }
            advance() // consume ':'

            val falseValue = parseExpression()
            expr = Expression.Ternary(expr, trueValue, falseValue)
        }

        return expr
    }

    private fun parseLogicalOr(): Expression {
        var left = parseLogicalAnd()

        while (currentToken() is Token.OperatorToken && (currentToken() as Token.OperatorToken).op == "||") {
            advance()
            val right = parseLogicalAnd()
            left = Expression.BinaryOp("||", left, right)
        }

        return left
    }

    private fun parseLogicalAnd(): Expression {
        var left = parseEquality()

        while (currentToken() is Token.OperatorToken && (currentToken() as Token.OperatorToken).op == "&&") {
            advance()
            val right = parseEquality()
            left = Expression.BinaryOp("&&", left, right)
        }

        return left
    }

    private fun parseEquality(): Expression {
        var left = parseComparison()

        while (currentToken() is Token.OperatorToken) {
            val op = (currentToken() as Token.OperatorToken).op
            if (op == "==" || op == "!=" || op == "in") {
                advance()
                val right = parseComparison()
                left = Expression.BinaryOp(op, left, right)
            } else {
                break
            }
        }

        return left
    }

    private fun parseComparison(): Expression {
        var left = parseAdditive()

        while (currentToken() is Token.OperatorToken) {
            val op = (currentToken() as Token.OperatorToken).op
            if (op == "<" || op == ">" || op == "<=" || op == ">=") {
                advance()
                val right = parseAdditive()
                left = Expression.BinaryOp(op, left, right)
            } else {
                break
            }
        }

        return left
    }

    private fun parseAdditive(): Expression {
        var left = parseMultiplicative()

        while (currentToken() is Token.OperatorToken) {
            val op = (currentToken() as Token.OperatorToken).op
            if (op == "+" || op == "-") {
                advance()
                val right = parseMultiplicative()
                left = Expression.BinaryOp(op, left, right)
            } else {
                break
            }
        }

        return left
    }

    private fun parseMultiplicative(): Expression {
        var left = parseUnary()

        while (currentToken() is Token.OperatorToken) {
            val op = (currentToken() as Token.OperatorToken).op
            if (op == "*" || op == "/" || op == "%") {
                advance()
                val right = parseUnary()
                left = Expression.BinaryOp(op, left, right)
            } else {
                break
            }
        }

        return left
    }

    private fun parseUnary(): Expression {
        if (currentToken() is Token.OperatorToken) {
            val op = (currentToken() as Token.OperatorToken).op
            if (op == "!" || op == "-") {
                advance()
                val operand = parseUnary()
                return Expression.UnaryOp(op, operand)
            }
        }

        return parsePostfix()
    }

    private fun parsePostfix(): Expression {
        var expr = parsePrimary()

        while (true) {
            when (currentToken()) {
                is Token.Dot -> {
                    advance() // consume '.'
                    val token = currentToken()
                    if (token !is Token.IdentifierToken) {
                        throw ParsingException("Expected identifier after '.'")
                    }
                    val property = token.name
                    advance()

                    // Convert to property access
                    if (expr is Expression.PropertyAccess) {
                        expr = Expression.PropertyAccess("${expr.path}.$property")
                    } else {
                        throw ParsingException("Invalid property access")
                    }
                }
                is Token.LeftParen -> {
                    // Function call
                    if (expr !is Expression.PropertyAccess) {
                        throw ParsingException("Expected function name")
                    }
                    val funcName = expr.path
                    advance() // consume '('

                    val args = mutableListOf<Expression>()
                    if (currentToken() !is Token.RightParen) {
                        args.add(parseExpression())
                        while (currentToken() is Token.Comma) {
                            advance() // consume ','
                            args.add(parseExpression())
                        }
                    }

                    if (currentToken() !is Token.RightParen) {
                        throw ParsingException("Expected ')'")
                    }
                    advance() // consume ')'

                    expr = Expression.FunctionCall(funcName, args)
                }
                else -> break
            }
        }

        return expr
    }

    private fun parsePrimary(): Expression {
        return when (val token = currentToken()) {
            is Token.StringToken -> {
                advance()
                Expression.Literal(token.value)
            }
            is Token.NumberToken -> {
                advance()
                Expression.Literal(token.value)
            }
            is Token.BooleanToken -> {
                advance()
                Expression.Literal(token.value)
            }
            is Token.IdentifierToken -> {
                advance()
                Expression.PropertyAccess(token.name)
            }
            is Token.LeftParen -> {
                advance() // consume '('
                val expr = parseExpression()
                if (currentToken() !is Token.RightParen) {
                    throw ParsingException("Expected ')'")
                }
                advance() // consume ')'
                expr
            }
            else -> throw ParsingException("Unexpected token: $token")
        }
    }
}

/**
 * Exception thrown when expression parsing fails
 */
class ParsingException(message: String) : Exception(message)
