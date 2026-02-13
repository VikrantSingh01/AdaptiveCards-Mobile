import Foundation

/// Represents an expression in the template syntax
public indirect enum Expression: Equatable {
    case literal(Any)
    case propertyAccess(String)
    case functionCall(name: String, arguments: [Expression])
    case binaryOp(operator: String, left: Expression, right: Expression)
    case unaryOp(operator: String, operand: Expression)
    case ternary(condition: Expression, trueValue: Expression, falseValue: Expression)
    
    public static func == (lhs: Expression, rhs: Expression) -> Bool {
        switch (lhs, rhs) {
        case let (.literal(l), .literal(r)):
            return String(describing: l) == String(describing: r)
        case let (.propertyAccess(l), .propertyAccess(r)):
            return l == r
        case let (.functionCall(ln, la), .functionCall(rn, ra)):
            return ln == rn && la == ra
        case let (.binaryOp(lo, ll, lr), .binaryOp(ro, rl, rr)):
            return lo == ro && ll == rl && lr == rr
        case let (.unaryOp(lo, lop), .unaryOp(ro, rop)):
            return lo == ro && lop == rop
        case let (.ternary(lc, lt, lf), .ternary(rc, rt, rf)):
            return lc == rc && lt == rt && lf == rf
        default:
            return false
        }
    }
}

/// Token types for expression parsing
public enum Token: Equatable {
    case string(String)
    case number(Double)
    case boolean(Bool)
    case identifier(String)
    case `operator`(String)
    case leftParen
    case rightParen
    case leftBracket
    case rightBracket
    case comma
    case dot
    case question
    case colon
    case eof
}

/// Parses template expressions into an AST with thread-safe parsing
public final class ExpressionParser {
    private var tokens: [Token] = []
    private var position = 0
    private let lock = NSLock()

    public init() {}

    /// Parse an expression string into an AST
    /// - Parameter expression: The expression string
    /// - Returns: The parsed expression
    /// - Throws: ParsingError if the expression is invalid
    public func parse(_ expression: String) throws -> Expression {
        lock.lock()
        defer { lock.unlock() }

        tokens = try tokenize(expression)
        position = 0
        return try parseExpression()
    }
    
    // MARK: - Tokenization
    
    private func tokenize(_ input: String) throws -> [Token] {
        var tokens: [Token] = []
        var index = input.startIndex
        
        while index < input.endIndex {
            let char = input[index]
            
            // Skip whitespace
            if char.isWhitespace {
                index = input.index(after: index)
                continue
            }
            
            // String literals
            if char == "'" || char == "\"" {
                let quote = char
                var value = ""
                index = input.index(after: index)
                
                while index < input.endIndex && input[index] != quote {
                    if input[index] == "\\" && input.index(after: index) < input.endIndex {
                        index = input.index(after: index)
                        let escaped = input[index]
                        value.append(escaped == "n" ? "\n" : escaped == "t" ? "\t" : escaped)
                    } else {
                        value.append(input[index])
                    }
                    index = input.index(after: index)
                }
                
                guard index < input.endIndex else {
                    throw ParsingError.unterminatedString
                }
                
                tokens.append(.string(value))
                index = input.index(after: index)
                continue
            }
            
            // Numbers
            if char.isNumber || (char == "-" && index < input.index(before: input.endIndex) && input[input.index(after: index)].isNumber) {
                var numStr = String(char)
                index = input.index(after: index)
                
                while index < input.endIndex && (input[index].isNumber || input[index] == ".") {
                    numStr.append(input[index])
                    index = input.index(after: index)
                }
                
                if let num = Double(numStr) {
                    tokens.append(.number(num))
                }
                continue
            }
            
            // Identifiers and keywords
            if char.isLetter || char == "$" || char == "_" {
                var identifier = String(char)
                index = input.index(after: index)
                
                while index < input.endIndex && (input[index].isLetter || input[index].isNumber || input[index] == "_") {
                    identifier.append(input[index])
                    index = input.index(after: index)
                }
                
                // Check for boolean keywords
                if identifier == "true" {
                    tokens.append(.boolean(true))
                } else if identifier == "false" {
                    tokens.append(.boolean(false))
                } else {
                    tokens.append(.identifier(identifier))
                }
                continue
            }
            
            // Operators and symbols
            switch char {
            case "(":
                tokens.append(.leftParen)
            case ")":
                tokens.append(.rightParen)
            case "[":
                tokens.append(.leftBracket)
            case "]":
                tokens.append(.rightBracket)
            case ",":
                tokens.append(.comma)
            case ".":
                tokens.append(.dot)
            case "?":
                tokens.append(.question)
            case ":":
                tokens.append(.colon)
            case "+", "-", "*", "/", "%", "=", "!", "<", ">", "&", "|":
                var op = String(char)
                index = input.index(after: index)
                
                // Handle two-character operators
                if index < input.endIndex {
                    let nextChar = input[index]
                    if (char == "=" && nextChar == "=") ||
                       (char == "!" && nextChar == "=") ||
                       (char == "<" && nextChar == "=") ||
                       (char == ">" && nextChar == "=") ||
                       (char == "&" && nextChar == "&") ||
                       (char == "|" && nextChar == "|") {
                        op.append(nextChar)
                        index = input.index(after: index)
                    }
                }
                
                tokens.append(.operator(op))
                continue
            default:
                throw ParsingError.unexpectedCharacter(char)
            }
            
            index = input.index(after: index)
        }
        
        tokens.append(.eof)
        return tokens
    }
    
    // MARK: - Parsing
    
    private func currentToken() -> Token {
        guard position < tokens.count else { return .eof }
        return tokens[position]
    }
    
    private func advance() {
        position += 1
    }
    
    private func parseExpression() throws -> Expression {
        return try parseTernary()
    }
    
    private func parseTernary() throws -> Expression {
        var expr = try parseLogicalOr()
        
        if case .question = currentToken() {
            advance() // consume '?'
            let trueValue = try parseExpression()
            
            guard case .colon = currentToken() else {
                throw ParsingError.expectedColon
            }
            advance() // consume ':'
            
            let falseValue = try parseExpression()
            expr = .ternary(condition: expr, trueValue: trueValue, falseValue: falseValue)
        }
        
        return expr
    }
    
    private func parseLogicalOr() throws -> Expression {
        var left = try parseLogicalAnd()
        
        while case .operator("||") = currentToken() {
            let op = "||"
            advance()
            let right = try parseLogicalAnd()
            left = .binaryOp(operator: op, left: left, right: right)
        }
        
        return left
    }
    
    private func parseLogicalAnd() throws -> Expression {
        var left = try parseEquality()
        
        while case .operator("&&") = currentToken() {
            let op = "&&"
            advance()
            let right = try parseEquality()
            left = .binaryOp(operator: op, left: left, right: right)
        }
        
        return left
    }
    
    private func parseEquality() throws -> Expression {
        var left = try parseComparison()
        
        while case .operator(let op) = currentToken(), op == "==" || op == "!=" {
            advance()
            let right = try parseComparison()
            left = .binaryOp(operator: op, left: left, right: right)
        }
        
        return left
    }
    
    private func parseComparison() throws -> Expression {
        var left = try parseAdditive()
        
        while case .operator(let op) = currentToken(), op == "<" || op == ">" || op == "<=" || op == ">=" {
            advance()
            let right = try parseAdditive()
            left = .binaryOp(operator: op, left: left, right: right)
        }
        
        return left
    }
    
    private func parseAdditive() throws -> Expression {
        var left = try parseMultiplicative()
        
        while case .operator(let op) = currentToken(), op == "+" || op == "-" {
            advance()
            let right = try parseMultiplicative()
            left = .binaryOp(operator: op, left: left, right: right)
        }
        
        return left
    }
    
    private func parseMultiplicative() throws -> Expression {
        var left = try parseUnary()
        
        while case .operator(let op) = currentToken(), op == "*" || op == "/" || op == "%" {
            advance()
            let right = try parseUnary()
            left = .binaryOp(operator: op, left: left, right: right)
        }
        
        return left
    }
    
    private func parseUnary() throws -> Expression {
        if case .operator(let op) = currentToken(), op == "!" || op == "-" {
            advance()
            let operand = try parseUnary()
            return .unaryOp(operator: op, operand: operand)
        }
        
        return try parsePostfix()
    }
    
    private func parsePostfix() throws -> Expression {
        var expr = try parsePrimary()
        
        while true {
            if case .dot = currentToken() {
                advance() // consume '.'
                guard case .identifier(let property) = currentToken() else {
                    throw ParsingError.expectedIdentifier
                }
                advance()
                
                // Convert to property access
                if case .propertyAccess(let path) = expr {
                    expr = .propertyAccess("\(path).\(property)")
                } else {
                    throw ParsingError.invalidPropertyAccess
                }
            } else if case .leftParen = currentToken() {
                // Function call
                guard case .propertyAccess(let funcName) = expr else {
                    throw ParsingError.expectedIdentifier
                }
                advance() // consume '('
                
                var args: [Expression] = []
                if case .rightParen = currentToken() {
                    // No arguments
                } else {
                    args.append(try parseExpression())
                    while case .comma = currentToken() {
                        advance() // consume ','
                        args.append(try parseExpression())
                    }
                }
                
                guard case .rightParen = currentToken() else {
                    throw ParsingError.expectedRightParen
                }
                advance() // consume ')'
                
                expr = .functionCall(name: funcName, arguments: args)
            } else {
                break
            }
        }
        
        return expr
    }
    
    private func parsePrimary() throws -> Expression {
        switch currentToken() {
        case .string(let value):
            advance()
            return .literal(value)
            
        case .number(let value):
            advance()
            return .literal(value)
            
        case .boolean(let value):
            advance()
            return .literal(value)
            
        case .identifier(let name):
            advance()
            return .propertyAccess(name)
            
        case .leftParen:
            advance() // consume '('
            let expr = try parseExpression()
            guard case .rightParen = currentToken() else {
                throw ParsingError.expectedRightParen
            }
            advance() // consume ')'
            return expr
            
        default:
            throw ParsingError.unexpectedToken(currentToken())
        }
    }
}

// MARK: - Errors

public enum ParsingError: Error, LocalizedError {
    case unterminatedString
    case unexpectedCharacter(Character)
    case unexpectedToken(Token)
    case expectedIdentifier
    case expectedRightParen
    case expectedColon
    case invalidPropertyAccess
    
    public var errorDescription: String? {
        switch self {
        case .unterminatedString:
            return "Unterminated string literal"
        case .unexpectedCharacter(let char):
            return "Unexpected character: '\(char)'"
        case .unexpectedToken(let token):
            return "Unexpected token: \(token)"
        case .expectedIdentifier:
            return "Expected identifier"
        case .expectedRightParen:
            return "Expected ')'"
        case .expectedColon:
            return "Expected ':' in ternary expression"
        case .invalidPropertyAccess:
            return "Invalid property access"
        }
    }
}
