import XCTest
@testable import ACTemplating

final class ACTemplatingTests: XCTestCase {
    
    var engine: TemplateEngine!
    
    override func setUp() {
        super.setUp()
        engine = TemplateEngine()
    }
    
    // MARK: - String Expansion Tests
    
    func testSimpleStringExpansion() throws {
        let template = "Hello, ${name}!"
        let data = ["name": "World"]
        let result = try engine.expand(template: template, data: data)
        XCTAssertEqual(result, "Hello, World!")
    }
    
    func testMultipleExpressions() throws {
        let template = "${greeting}, ${name}! You are ${age} years old."
        let data = ["greeting": "Hello", "name": "Alice", "age": 30]
        let result = try engine.expand(template: template, data: data)
        XCTAssertEqual(result, "Hello, Alice! You are 30 years old.")
    }
    
    func testNestedPropertyAccess() throws {
        let template = "User: ${user.name}, Email: ${user.email}"
        let data: [String: Any] = [
            "user": [
                "name": "Bob",
                "email": "bob@example.com"
            ]
        ]
        let result = try engine.expand(template: template, data: data)
        XCTAssertEqual(result, "User: Bob, Email: bob@example.com")
    }
    
    // MARK: - Expression Parser Tests
    
    func testParseNumericLiteral() throws {
        let parser = ExpressionParser()
        let expr = try parser.parse("42")
        if case .literal(let value) = expr,
           let num = value as? Double {
            XCTAssertEqual(num, 42.0)
        } else {
            XCTFail("Expected numeric literal")
        }
    }
    
    func testParseStringLiteral() throws {
        let parser = ExpressionParser()
        let expr = try parser.parse("'hello'")
        if case .literal(let value) = expr,
           let str = value as? String {
            XCTAssertEqual(str, "hello")
        } else {
            XCTFail("Expected string literal")
        }
    }
    
    func testParseBinaryOperation() throws {
        let parser = ExpressionParser()
        let expr = try parser.parse("1 + 2")
        if case .binaryOp(let op, _, _) = expr {
            XCTAssertEqual(op, "+")
        } else {
            XCTFail("Expected binary operation")
        }
    }
    
    func testParseFunctionCall() throws {
        let parser = ExpressionParser()
        let expr = try parser.parse("toUpper(name)")
        if case .functionCall(let name, let args) = expr {
            XCTAssertEqual(name, "toUpper")
            XCTAssertEqual(args.count, 1)
        } else {
            XCTFail("Expected function call")
        }
    }
    
    // MARK: - Expression Evaluator Tests
    
    func testEvaluateArithmetic() throws {
        let parser = ExpressionParser()
        let context = DataContext(data: [:])
        let evaluator = ExpressionEvaluator(context: context)
        
        let expr = try parser.parse("10 + 5 * 2")
        let result = try evaluator.evaluate(expr)
        
        if let num = result as? Double {
            XCTAssertEqual(num, 20.0)
        } else {
            XCTFail("Expected numeric result")
        }
    }
    
    func testEvaluateComparison() throws {
        let parser = ExpressionParser()
        let context = DataContext(data: ["age": 25])
        let evaluator = ExpressionEvaluator(context: context)
        
        let expr = try parser.parse("age > 18")
        let result = try evaluator.evaluate(expr)
        
        if let bool = result as? Bool {
            XCTAssertTrue(bool)
        } else {
            XCTFail("Expected boolean result")
        }
    }
    
    func testEvaluateTernary() throws {
        let parser = ExpressionParser()
        let context = DataContext(data: ["age": 25])
        let evaluator = ExpressionEvaluator(context: context)
        
        let expr = try parser.parse("age >= 18 ? 'adult' : 'minor'")
        let result = try evaluator.evaluate(expr)
        
        if let str = result as? String {
            XCTAssertEqual(str, "adult")
        } else {
            XCTFail("Expected string result")
        }
    }
    
    // MARK: - String Function Tests
    
    func testToUpperFunction() throws {
        let template = "${toUpper(text)}"
        let data = ["text": "hello"]
        let result = try engine.expand(template: template, data: data)
        XCTAssertEqual(result, "HELLO")
    }
    
    func testSubstringFunction() throws {
        let template = "${substring(text, 0, 5)}"
        let data = ["text": "Hello, World!"]
        let result = try engine.expand(template: template, data: data)
        XCTAssertEqual(result, "Hello")
    }
    
    func testLengthFunction() throws {
        let template = "${length(text)}"
        let data = ["text": "Hello"]
        let result = try engine.expand(template: template, data: data)
        XCTAssertEqual(result, "5")
    }
    
    func testTrimFunction() throws {
        let template = "${trim(text)}"
        let data = ["text": "  Hello  "]
        let result = try engine.expand(template: template, data: data)
        XCTAssertEqual(result, "Hello")
    }
    
    // MARK: - Math Function Tests
    
    func testAddFunction() throws {
        let template = "${add(10, 5)}"
        let data: [String: Any] = [:]
        let result = try engine.expand(template: template, data: data)
        XCTAssertEqual(result, "15")
    }
    
    func testMaxFunction() throws {
        let template = "${max(10, 20, 5)}"
        let data: [String: Any] = [:]
        let result = try engine.expand(template: template, data: data)
        XCTAssertEqual(result, "20")
    }
    
    func testRoundFunction() throws {
        let template = "${round(3.7)}"
        let data: [String: Any] = [:]
        let result = try engine.expand(template: template, data: data)
        XCTAssertEqual(result, "4")
    }
    
    // MARK: - Logic Function Tests
    
    func testIfFunction() throws {
        let template = "${if(age >= 18, 'adult', 'minor')}"
        let data = ["age": 25]
        let result = try engine.expand(template: template, data: data)
        XCTAssertEqual(result, "adult")
    }
    
    func testEqualsFunction() throws {
        let template = "${equals(status, 'active')}"
        let data = ["status": "active"]
        let result = try engine.expand(template: template, data: data)
        XCTAssertEqual(result, "true")
    }
    
    // MARK: - Collection Function Tests
    
    func testCountFunction() throws {
        let template = "${count(items)}"
        let data: [String: Any] = ["items": [1, 2, 3, 4, 5]]
        let result = try engine.expand(template: template, data: data)
        XCTAssertEqual(result, "5")
    }
    
    func testFirstFunction() throws {
        let template = "${first(items)}"
        let data: [String: Any] = ["items": [10, 20, 30]]
        let result = try engine.expand(template: template, data: data)
        XCTAssertEqual(result, "10")
    }
    
    // MARK: - JSON Expansion Tests
    
    func testExpandSimpleDictionary() throws {
        let template: [String: Any] = [
            "type": "TextBlock",
            "text": "${message}"
        ]
        let data = ["message": "Hello, World!"]
        let result = try engine.expand(template: template, data: data)
        
        XCTAssertEqual(result["type"] as? String, "TextBlock")
        XCTAssertEqual(result["text"] as? String, "Hello, World!")
    }
    
    func testConditionalRendering() throws {
        let template: [String: Any] = [
            "$when": "${showMessage}",
            "type": "TextBlock",
            "text": "Visible message"
        ]
        
        // Test with condition true
        let dataTrue = ["showMessage": true]
        let resultTrue = try engine.expand(template: template, data: dataTrue)
        XCTAssertEqual(resultTrue["type"] as? String, "TextBlock")
        XCTAssertNil(resultTrue["$when"])
        
        // Test with condition false
        let dataFalse = ["showMessage": false]
        let resultFalse = try engine.expand(template: template, data: dataFalse)
        XCTAssertTrue(resultFalse.isEmpty)
    }
    
    func testDataIteration() throws {
        let template: [String: Any] = [
            "type": "AdaptiveCard",
            "body": [
                [
                    "$data": "${items}",
                    "type": "TextBlock",
                    "text": "${name}"
                ]
            ]
        ]
        
        let data: [String: Any] = [
            "items": [
                ["name": "Item 1"],
                ["name": "Item 2"],
                ["name": "Item 3"]
            ]
        ]
        
        let result = try engine.expand(template: template, data: data)
        
        if let body = result["body"] as? [[String: Any]] {
            XCTAssertEqual(body.count, 3)
            XCTAssertEqual(body[0]["text"] as? String, "Item 1")
            XCTAssertEqual(body[1]["text"] as? String, "Item 2")
            XCTAssertEqual(body[2]["text"] as? String, "Item 3")
        } else {
            XCTFail("Expected array of dictionaries in body")
        }
    }
    
    // MARK: - Data Context Tests
    
    func testRootDataAccess() throws {
        let template = "${$root.title}"
        let data = ["title": "Main Title"]
        let result = try engine.expand(template: template, data: data)
        XCTAssertEqual(result, "Main Title")
    }
    
    func testIndexAccess() throws {
        let template: [String: Any] = [
            "body": [
                [
                    "$data": "${items}",
                    "text": "Item ${$index}"
                ]
            ]
        ]
        
        let data: [String: Any] = [
            "items": ["A", "B", "C"]
        ]
        
        let result = try engine.expand(template: template, data: data)
        
        if let body = result["body"] as? [[String: Any]] {
            XCTAssertEqual(body.count, 3)
            XCTAssertEqual(body[0]["text"] as? String, "Item 0")
            XCTAssertEqual(body[1]["text"] as? String, "Item 1")
            XCTAssertEqual(body[2]["text"] as? String, "Item 2")
        } else {
            XCTFail("Expected array of dictionaries in body")
        }
    }
    
    // MARK: - Edge Cases
    
    func testEmptyTemplate() throws {
        let template = ""
        let data: [String: Any] = [:]
        let result = try engine.expand(template: template, data: data)
        XCTAssertEqual(result, "")
    }
    
    func testNoExpressions() throws {
        let template = "Just plain text"
        let data: [String: Any] = [:]
        let result = try engine.expand(template: template, data: data)
        XCTAssertEqual(result, "Just plain text")
    }
    
    func testMissingProperty() throws {
        let template = "${missing}"
        let data: [String: Any] = [:]
        let result = try engine.expand(template: template, data: data)
        XCTAssertEqual(result, "")
    }
    
    func testNestedExpressions() throws {
        let template = "${toUpper(toLower(text))}"
        let data = ["text": "MiXeD CaSe"]
        let result = try engine.expand(template: template, data: data)
        XCTAssertEqual(result, "MIXED CASE")
    }
    
    func testComplexExpression() throws {
        let template = "${if(age >= 18 && status == 'active', 'Eligible', 'Not eligible')}"
        let data = ["age": 25, "status": "active"]
        let result = try engine.expand(template: template, data: data)
        XCTAssertEqual(result, "Eligible")
    }
}
