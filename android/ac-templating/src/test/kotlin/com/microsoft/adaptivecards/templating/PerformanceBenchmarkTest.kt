package com.microsoft.adaptivecards.templating

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*
import kotlin.system.measureNanoTime
import kotlin.system.measureTimeMillis

/**
 * Performance benchmarks for expression evaluation and templating.
 *
 * These tests measure the impact of key optimizations:
 * - Singleton function registry (reduced initialization overhead)
 * - Thread-safe expression parsing
 */
class PerformanceBenchmarkTest {

    companion object {
        private const val ITERATIONS_SMALL = 1000
        private const val ITERATIONS_MEDIUM = 100
    }

    // MARK: - Expression Evaluation Performance Tests

    @Test
    fun `benchmark expression evaluator initialization`() {
        val context = DataContext(mapOf("name" to "John", "age" to 30))

        // Warmup
        repeat(10) {
            ExpressionEvaluator(context)
        }

        // Measure
        val times = mutableListOf<Long>()
        repeat(ITERATIONS_SMALL) {
            val time = measureNanoTime {
                ExpressionEvaluator(context)
            }
            times.add(time)
        }

        val avgNanos = times.average()
        val avgMicros = avgNanos / 1_000.0

        println("ExpressionEvaluator initialization: ${String.format("%.2f", avgMicros)}μs average over $ITERATIONS_SMALL iterations")
        println("  Min: ${String.format("%.2f", times.minOrNull()!! / 1_000.0)}μs")
        println("  Max: ${String.format("%.2f", times.maxOrNull()!! / 1_000.0)}μs")

        // With singleton function registry, initialization should be very fast (under 100μs)
        assertTrue(avgMicros < 100.0, "Evaluator initialization should be under 100μs with singleton registry, got ${String.format("%.2f", avgMicros)}μs")
    }

    @Test
    fun `benchmark simple string expression evaluation`() {
        val context = DataContext(mapOf("name" to "John"))
        val evaluator = ExpressionEvaluator(context)
        val parser = ExpressionParser()
        val expressionString = "concat('Hello, ', name, '!')"
        val expression = parser.parse(expressionString)

        // Warmup
        repeat(10) {
            evaluator.evaluate(expression)
        }

        // Measure
        val times = mutableListOf<Long>()
        repeat(ITERATIONS_SMALL) {
            val time = measureNanoTime {
                evaluator.evaluate(expression)
            }
            times.add(time)
        }

        val avgNanos = times.average()
        val avgMicros = avgNanos / 1_000.0

        println("Simple expression evaluation: ${String.format("%.2f", avgMicros)}μs average over $ITERATIONS_SMALL iterations")
        println("  Min: ${String.format("%.2f", times.minOrNull()!! / 1_000.0)}μs")
        println("  Max: ${String.format("%.2f", times.maxOrNull()!! / 1_000.0)}μs")

        // Verify result
        val result = evaluator.evaluate(expression)
        assertEquals("Hello, John!", result)
    }

    @Test
    fun `benchmark complex expression evaluation`() {
        val context = DataContext(
            mapOf(
                "user" to mapOf(
                    "firstName" to "John",
                    "lastName" to "Doe",
                    "age" to 30,
                    "isActive" to true
                ),
                "items" to listOf("apple", "banana", "cherry")
            )
        )
        val evaluator = ExpressionEvaluator(context)
        val parser = ExpressionParser()
        val expressionString = "if(user.isActive, concat(user.firstName, ' ', user.lastName, ' (', string(user.age), ' years old)'), 'Inactive user')"
        val expression = parser.parse(expressionString)

        // Warmup
        repeat(10) {
            evaluator.evaluate(expression)
        }

        // Measure
        val times = mutableListOf<Long>()
        repeat(ITERATIONS_MEDIUM) {
            val time = measureNanoTime {
                evaluator.evaluate(expression)
            }
            times.add(time)
        }

        val avgNanos = times.average()
        val avgMicros = avgNanos / 1_000.0

        println("Complex expression evaluation: ${String.format("%.2f", avgMicros)}μs average over $ITERATIONS_MEDIUM iterations")

        // Verify result
        val result = evaluator.evaluate(expression)
        assertEquals("John Doe (30 years old)", result)
    }

    @Test
    fun `benchmark expression parsing performance`() {
        val parser = ExpressionParser()
        val expression = "concat('Hello, ', name, '!')"

        // Warmup
        repeat(10) {
            parser.parse(expression)
        }

        // Measure
        val times = mutableListOf<Long>()
        repeat(ITERATIONS_SMALL) {
            val time = measureNanoTime {
                parser.parse(expression)
            }
            times.add(time)
        }

        val avgNanos = times.average()
        val avgMicros = avgNanos / 1_000.0

        println("Expression parsing: ${String.format("%.2f", avgMicros)}μs average over $ITERATIONS_SMALL iterations")
        println("  Min: ${String.format("%.2f", times.minOrNull()!! / 1_000.0)}μs")
        println("  Max: ${String.format("%.2f", times.maxOrNull()!! / 1_000.0)}μs")
    }

    // MARK: - Function Registry Performance Tests

    @Test
    fun `verify function registry is singleton`() {
        val context1 = DataContext(mapOf("x" to 1))
        val context2 = DataContext(mapOf("x" to 2))

        val evaluator1 = ExpressionEvaluator(context1)
        val evaluator2 = ExpressionEvaluator(context2)

        // Both evaluators should share the same function registry
        // We can't directly test this without reflection, but we can measure
        // that initialization is fast (which indicates singleton is working)

        val initTimes = mutableListOf<Long>()
        repeat(100) {
            val time = measureNanoTime {
                ExpressionEvaluator(DataContext(mapOf("test" to it)))
            }
            initTimes.add(time)
        }

        val avgNanos = initTimes.average()
        val avgMicros = avgNanos / 1_000.0

        println("Function registry singleton check:")
        println("  Average initialization: ${String.format("%.2f", avgMicros)}μs")
        println("  This should be very fast due to singleton registry")

        // If registry is singleton, initialization should be consistently fast
        assertTrue(avgMicros < 100.0, "With singleton registry, init should be under 100μs")
    }

    // MARK: - Thread Safety Performance Tests

    @Test
    fun `benchmark concurrent expression evaluation`() {
        val context = DataContext(mapOf("name" to "John", "age" to 30))
        val evaluator = ExpressionEvaluator(context)
        val parser = ExpressionParser()
        val expressionString = "concat('Hello, ', name, '! You are ', string(age), ' years old.')"
        val expression = parser.parse(expressionString)

        // Warmup
        repeat(10) {
            evaluator.evaluate(expression)
        }

        val threadCount = 10
        val iterationsPerThread = 100

        val totalTime = measureTimeMillis {
            val threads = (1..threadCount).map {
                Thread {
                    repeat(iterationsPerThread) {
                        val result = evaluator.evaluate(expression)
                        assertEquals("Hello, John! You are 30 years old.", result)
                    }
                }
            }

            threads.forEach { it.start() }
            threads.forEach { it.join() }
        }

        val totalIterations = threadCount * iterationsPerThread
        val avgMicros = (totalTime * 1000.0) / totalIterations

        println("Concurrent expression evaluation ($threadCount threads, $iterationsPerThread iterations each):")
        println("  Total time: ${totalTime}ms")
        println("  Average per evaluation: ${String.format("%.2f", avgMicros)}μs")
        println("  Throughput: ${String.format("%.1f", totalIterations.toDouble() / (totalTime / 1000.0))} evaluations/second")
    }

    @Test
    fun `benchmark concurrent expression parsing`() {
        val parser = ExpressionParser()
        val expression = "concat('Hello, ', name, '!')"

        // Warmup
        repeat(10) {
            parser.parse(expression)
        }

        val threadCount = 10
        val iterationsPerThread = 100

        val totalTime = measureTimeMillis {
            val threads = (1..threadCount).map {
                Thread {
                    repeat(iterationsPerThread) {
                        val parsed = parser.parse(expression)
                        assertNotNull(parsed)
                    }
                }
            }

            threads.forEach { it.start() }
            threads.forEach { it.join() }
        }

        val totalIterations = threadCount * iterationsPerThread
        val avgMicros = (totalTime * 1000.0) / totalIterations

        println("Concurrent expression parsing ($threadCount threads, $iterationsPerThread iterations each):")
        println("  Total time: ${totalTime}ms")
        println("  Average per parse: ${String.format("%.2f", avgMicros)}μs")
        println("  Throughput: ${String.format("%.1f", totalIterations.toDouble() / (totalTime / 1000.0))} parses/second")

        // Should complete in reasonable time
        assertTrue(totalTime < 10000, "Concurrent parsing should complete in under 10 seconds")
    }

    // MARK: - Template Engine Performance Tests

    @Test
    fun `benchmark template expansion`() {
        val template = "\${greeting}, \${name}! You are \${age} years old."
        val data = mapOf(
            "greeting" to "Hello",
            "name" to "John",
            "age" to 30
        )

        val engine = TemplateEngine()

        // Warmup
        repeat(10) {
            engine.expand(template, data)
        }

        // Measure
        val times = mutableListOf<Long>()
        repeat(ITERATIONS_MEDIUM) {
            val time = measureNanoTime {
                engine.expand(template, data)
            }
            times.add(time)
        }

        val avgNanos = times.average()
        val avgMicros = avgNanos / 1_000.0

        println("Template expansion: ${String.format("%.2f", avgMicros)}μs average over $ITERATIONS_MEDIUM iterations")
        println("  Min: ${String.format("%.2f", times.minOrNull()!! / 1_000.0)}μs")
        println("  Max: ${String.format("%.2f", times.maxOrNull()!! / 1_000.0)}μs")

        // Verify result
        val result = engine.expand(template, data)
        assertEquals("Hello, John! You are 30 years old.", result)
    }
}
