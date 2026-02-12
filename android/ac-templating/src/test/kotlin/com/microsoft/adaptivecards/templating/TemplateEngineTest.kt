package com.microsoft.adaptivecards.templating

import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test

class TemplateEngineTest {
    private lateinit var engine: TemplateEngine

    @BeforeEach
    fun setUp() {
        engine = TemplateEngine()
    }

    // MARK: - String Expansion Tests

    @Test
    fun `testSimpleStringExpansion`() {
        val template = "Hello, \${name}!"
        val data = mapOf("name" to "World")
        val result = engine.expand(template, data)
        assertEquals("Hello, World!", result)
    }

    @Test
    fun `testMultipleExpressions`() {
        val template = "\${greeting}, \${name}! You are \${age} years old."
        val data = mapOf("greeting" to "Hello", "name" to "Alice", "age" to 30)
        val result = engine.expand(template, data)
        assertEquals("Hello, Alice! You are 30 years old.", result)
    }

    @Test
    fun `testNestedPropertyAccess`() {
        val template = "User: \${user.name}, Email: \${user.email}"
        val data = mapOf(
            "user" to mapOf(
                "name" to "Bob",
                "email" to "bob@example.com"
            )
        )
        val result = engine.expand(template, data)
        assertEquals("User: Bob, Email: bob@example.com", result)
    }

    // MARK: - Expression Parser Tests

    @Test
    fun `testParseNumericLiteral`() {
        val parser = ExpressionParser()
        val expr = parser.parse("42")
        assertTrue(expr is Expression.Literal)
        val value = (expr as Expression.Literal).value
        assertEquals(42.0, (value as Double), 0.001)
    }

    @Test
    fun `testParseStringLiteral`() {
        val parser = ExpressionParser()
        val expr = parser.parse("'hello'")
        assertTrue(expr is Expression.Literal)
        val value = (expr as Expression.Literal).value
        assertEquals("hello", value)
    }

    @Test
    fun `testParseBinaryOperation`() {
        val parser = ExpressionParser()
        val expr = parser.parse("1 + 2")
        assertTrue(expr is Expression.BinaryOp)
        assertEquals("+", (expr as Expression.BinaryOp).operator)
    }

    @Test
    fun `testParseFunctionCall`() {
        val parser = ExpressionParser()
        val expr = parser.parse("toUpper(name)")
        assertTrue(expr is Expression.FunctionCall)
        val funcCall = expr as Expression.FunctionCall
        assertEquals("toUpper", funcCall.name)
        assertEquals(1, funcCall.arguments.size)
    }

    // MARK: - Expression Evaluator Tests

    @Test
    fun `testEvaluateArithmetic`() {
        val parser = ExpressionParser()
        val context = DataContext(data = emptyMap<String, Any>())
        val evaluator = ExpressionEvaluator(context)

        val expr = parser.parse("10 + 5 * 2")
        val result = evaluator.evaluate(expr)

        assertEquals(20.0, (result as Double), 0.001)
    }

    @Test
    fun `testEvaluateComparison`() {
        val parser = ExpressionParser()
        val context = DataContext(data = mapOf("age" to 25))
        val evaluator = ExpressionEvaluator(context)

        val expr = parser.parse("age > 18")
        val result = evaluator.evaluate(expr)

        assertTrue(result as Boolean)
    }

    @Test
    fun `testEvaluateTernary`() {
        val parser = ExpressionParser()
        val context = DataContext(data = mapOf("age" to 25))
        val evaluator = ExpressionEvaluator(context)

        val expr = parser.parse("age >= 18 ? 'adult' : 'minor'")
        val result = evaluator.evaluate(expr)

        assertEquals("adult", result)
    }

    // MARK: - String Function Tests

    @Test
    fun `testToUpperFunction`() {
        val template = "\${toUpper(text)}"
        val data = mapOf("text" to "hello")
        val result = engine.expand(template, data)
        assertEquals("HELLO", result)
    }

    @Test
    fun `testToLowerFunction`() {
        val template = "\${toLower(text)}"
        val data = mapOf("text" to "HELLO")
        val result = engine.expand(template, data)
        assertEquals("hello", result)
    }

    @Test
    fun `testSubstringFunction`() {
        val template = "\${substring(text, 0, 5)}"
        val data = mapOf("text" to "Hello, World!")
        val result = engine.expand(template, data)
        assertEquals("Hello", result)
    }

    @Test
    fun `testLengthFunction`() {
        val template = "\${length(text)}"
        val data = mapOf("text" to "Hello")
        val result = engine.expand(template, data)
        assertEquals("5", result)
    }

    @Test
    fun `testTrimFunction`() {
        val template = "\${trim(text)}"
        val data = mapOf("text" to "  Hello  ")
        val result = engine.expand(template, data)
        assertEquals("Hello", result)
    }

    @Test
    fun `testReplaceFunction`() {
        val template = "\${replace(text, 'World', 'Universe')}"
        val data = mapOf("text" to "Hello, World!")
        val result = engine.expand(template, data)
        assertEquals("Hello, Universe!", result)
    }

    @Test
    fun `testSplitFunction`() {
        val template = "\${length(split(text, ','))}"
        val data = mapOf("text" to "a,b,c")
        val result = engine.expand(template, data)
        assertEquals("3", result)
    }

    @Test
    fun `testStartsWithFunction`() {
        val template = "\${startsWith(text, 'Hello')}"
        val data = mapOf("text" to "Hello, World!")
        val result = engine.expand(template, data)
        assertEquals("true", result)
    }

    @Test
    fun `testEndsWithFunction`() {
        val template = "\${endsWith(text, '!')}"
        val data = mapOf("text" to "Hello, World!")
        val result = engine.expand(template, data)
        assertEquals("true", result)
    }

    @Test
    fun `testContainsFunction`() {
        val template = "\${contains(text, 'World')}"
        val data = mapOf("text" to "Hello, World!")
        val result = engine.expand(template, data)
        assertEquals("true", result)
    }

    @Test
    fun `testFormatFunction`() {
        val template = "\${format('Hello, {0}! You are {1} years old.', name, age)}"
        val data = mapOf("name" to "Alice", "age" to 30)
        val result = engine.expand(template, data)
        assertEquals("Hello, Alice! You are 30 years old.", result)
    }

    // MARK: - Math Function Tests

    @Test
    fun `testAddFunction`() {
        val template = "\${add(10, 5)}"
        val data = emptyMap<String, Any>()
        val result = engine.expand(template, data)
        assertEquals("15", result)
    }

    @Test
    fun `testSubFunction`() {
        val template = "\${sub(10, 5)}"
        val data = emptyMap<String, Any>()
        val result = engine.expand(template, data)
        assertEquals("5", result)
    }

    @Test
    fun `testMulFunction`() {
        val template = "\${mul(10, 5)}"
        val data = emptyMap<String, Any>()
        val result = engine.expand(template, data)
        assertEquals("50", result)
    }

    @Test
    fun `testDivFunction`() {
        val template = "\${div(10, 2)}"
        val data = emptyMap<String, Any>()
        val result = engine.expand(template, data)
        assertEquals("5", result)
    }

    @Test
    fun `testModFunction`() {
        val template = "\${mod(10, 3)}"
        val data = emptyMap<String, Any>()
        val result = engine.expand(template, data)
        assertEquals("1", result)
    }

    @Test
    fun `testMinFunction`() {
        val template = "\${min(10, 20, 5)}"
        val data = emptyMap<String, Any>()
        val result = engine.expand(template, data)
        assertEquals("5", result)
    }

    @Test
    fun `testMaxFunction`() {
        val template = "\${max(10, 20, 5)}"
        val data = emptyMap<String, Any>()
        val result = engine.expand(template, data)
        assertEquals("20", result)
    }

    @Test
    fun `testRoundFunction`() {
        val template = "\${round(3.7)}"
        val data = emptyMap<String, Any>()
        val result = engine.expand(template, data)
        assertEquals("4", result)
    }

    @Test
    fun `testFloorFunction`() {
        val template = "\${floor(3.7)}"
        val data = emptyMap<String, Any>()
        val result = engine.expand(template, data)
        assertEquals("3", result)
    }

    @Test
    fun `testCeilFunction`() {
        val template = "\${ceil(3.2)}"
        val data = emptyMap<String, Any>()
        val result = engine.expand(template, data)
        assertEquals("4", result)
    }

    @Test
    fun `testAbsFunction`() {
        val template = "\${abs(-5)}"
        val data = emptyMap<String, Any>()
        val result = engine.expand(template, data)
        assertEquals("5", result)
    }

    // MARK: - Logic Function Tests

    @Test
    fun `testIfFunction`() {
        val template = "\${if(age >= 18, 'adult', 'minor')}"
        val data = mapOf("age" to 25)
        val result = engine.expand(template, data)
        assertEquals("adult", result)
    }

    @Test
    fun `testEqualsFunction`() {
        val template = "\${equals(status, 'active')}"
        val data = mapOf("status" to "active")
        val result = engine.expand(template, data)
        assertEquals("true", result)
    }

    @Test
    fun `testNotFunction`() {
        val template = "\${not(false)}"
        val data = emptyMap<String, Any>()
        val result = engine.expand(template, data)
        assertEquals("true", result)
    }

    @Test
    fun `testAndFunction`() {
        val template = "\${and(true, true)}"
        val data = emptyMap<String, Any>()
        val result = engine.expand(template, data)
        assertEquals("true", result)
    }

    @Test
    fun `testOrFunction`() {
        val template = "\${or(false, true)}"
        val data = emptyMap<String, Any>()
        val result = engine.expand(template, data)
        assertEquals("true", result)
    }

    @Test
    fun `testGreaterThanFunction`() {
        val template = "\${greaterThan(10, 5)}"
        val data = emptyMap<String, Any>()
        val result = engine.expand(template, data)
        assertEquals("true", result)
    }

    @Test
    fun `testLessThanFunction`() {
        val template = "\${lessThan(5, 10)}"
        val data = emptyMap<String, Any>()
        val result = engine.expand(template, data)
        assertEquals("true", result)
    }

    @Test
    fun `testExistsFunction`() {
        val template = "\${exists(value)}"
        val data = mapOf("value" to "something")
        val result = engine.expand(template, data)
        assertEquals("true", result)
    }

    @Test
    fun `testEmptyFunction`() {
        val template = "\${empty(text)}"
        val data = mapOf("text" to "")
        val result = engine.expand(template, data)
        assertEquals("true", result)
    }

    @Test
    fun `testIsMatchFunction`() {
        val template = "\${isMatch(email, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\\\.[a-zA-Z]{2,}\$')}"
        val data = mapOf("email" to "test@example.com")
        val result = engine.expand(template, data)
        assertEquals("true", result)
    }

    // MARK: - Collection Function Tests

    @Test
    fun `testCountFunction`() {
        val template = "\${count(items)}"
        val data = mapOf("items" to listOf(1, 2, 3, 4, 5))
        val result = engine.expand(template, data)
        assertEquals("5", result)
    }

    @Test
    fun `testFirstFunction`() {
        val template = "\${first(items)}"
        val data = mapOf("items" to listOf(10, 20, 30))
        val result = engine.expand(template, data)
        assertEquals("10", result)
    }

    @Test
    fun `testLastFunction`() {
        val template = "\${last(items)}"
        val data = mapOf("items" to listOf(10, 20, 30))
        val result = engine.expand(template, data)
        assertEquals("30", result)
    }

    // MARK: - JSON Expansion Tests

    @Test
    fun `testExpandSimpleDictionary`() {
        val template = mapOf(
            "type" to "TextBlock",
            "text" to "\${message}"
        )
        val data = mapOf("message" to "Hello, World!")
        val result = engine.expand(template, data)

        assertEquals("TextBlock", result["type"])
        assertEquals("Hello, World!", result["text"])
    }

    @Test
    fun `testConditionalRendering`() {
        val template = mapOf(
            "\$when" to "\${showMessage}",
            "type" to "TextBlock",
            "text" to "Visible message"
        )

        // Test with condition true
        val dataTrue = mapOf("showMessage" to true)
        val resultTrue = engine.expand(template, dataTrue)
        assertEquals("TextBlock", resultTrue["type"])
        assertNull(resultTrue["\$when"])

        // Test with condition false
        val dataFalse = mapOf("showMessage" to false)
        val resultFalse = engine.expand(template, dataFalse)
        assertTrue(resultFalse.isEmpty())
    }

    @Test
    fun `testDataIteration`() {
        val template = mapOf(
            "type" to "AdaptiveCard",
            "body" to listOf(
                mapOf(
                    "\$data" to "\${items}",
                    "type" to "TextBlock",
                    "text" to "\${name}"
                )
            )
        )

        val data = mapOf(
            "items" to listOf(
                mapOf("name" to "Item 1"),
                mapOf("name" to "Item 2"),
                mapOf("name" to "Item 3")
            )
        )

        val result = engine.expand(template, data)

        @Suppress("UNCHECKED_CAST")
        val body = result["body"] as? List<Map<String, Any?>>
        assertNotNull(body)
        assertEquals(3, body!!.size)
        assertEquals("Item 1", body[0]["text"])
        assertEquals("Item 2", body[1]["text"])
        assertEquals("Item 3", body[2]["text"])
    }

    // MARK: - Data Context Tests

    @Test
    fun `testRootDataAccess`() {
        val template = "\${\$root.title}"
        val data = mapOf("title" to "Main Title")
        val result = engine.expand(template, data)
        assertEquals("Main Title", result)
    }

    @Test
    fun `testIndexAccess`() {
        val template = mapOf(
            "body" to listOf(
                mapOf(
                    "\$data" to "\${items}",
                    "text" to "Item \${\$index}"
                )
            )
        )

        val data = mapOf(
            "items" to listOf("A", "B", "C")
        )

        val result = engine.expand(template, data)

        @Suppress("UNCHECKED_CAST")
        val body = result["body"] as? List<Map<String, Any?>>
        assertNotNull(body)
        assertEquals(3, body!!.size)
        assertEquals("Item 0", body[0]["text"])
        assertEquals("Item 1", body[1]["text"])
        assertEquals("Item 2", body[2]["text"])
    }

    // MARK: - Edge Cases

    @Test
    fun `testEmptyTemplate`() {
        val template = ""
        val data = emptyMap<String, Any>()
        val result = engine.expand(template, data)
        assertEquals("", result)
    }

    @Test
    fun `testNoExpressions`() {
        val template = "Just plain text"
        val data = emptyMap<String, Any>()
        val result = engine.expand(template, data)
        assertEquals("Just plain text", result)
    }

    @Test
    fun `testMissingProperty`() {
        val template = "\${missing}"
        val data = emptyMap<String, Any>()
        val result = engine.expand(template, data)
        assertEquals("", result)
    }

    @Test
    fun `testNestedExpressions`() {
        val template = "\${toUpper(toLower(text))}"
        val data = mapOf("text" to "MiXeD CaSe")
        val result = engine.expand(template, data)
        assertEquals("MIXED CASE", result)
    }

    @Test
    fun `testComplexExpression`() {
        val template = "\${if(age >= 18 && status == 'active', 'Eligible', 'Not eligible')}"
        val data = mapOf("age" to 25, "status" to "active")
        val result = engine.expand(template, data)
        assertEquals("Eligible", result)
    }

    @Test
    fun `testArithmeticExpression`() {
        val template = "\${(10 + 5) * 2}"
        val data = emptyMap<String, Any>()
        val result = engine.expand(template, data)
        assertEquals("30", result)
    }

    @Test
    fun `testLogicalOperators`() {
        val template = "\${age > 18 && age < 65}"
        val data = mapOf("age" to 25)
        val result = engine.expand(template, data)
        assertEquals("true", result)
    }

    @Test
    fun `testStringConcatenation`() {
        val template = "\${firstName + ' ' + lastName}"
        val data = mapOf("firstName" to "John", "lastName" to "Doe")
        val result = engine.expand(template, data)
        assertEquals("John Doe", result)
    }
}
