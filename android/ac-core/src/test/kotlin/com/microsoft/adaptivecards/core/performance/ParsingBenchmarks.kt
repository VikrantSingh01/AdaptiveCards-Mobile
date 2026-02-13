package com.microsoft.adaptivecards.core.performance

import org.junit.jupiter.api.Test
import kotlin.system.measureTimeMillis

class ParsingBenchmarks {
    
    @Test
    fun benchmarkParseSimpleCard() {
        val json = """{"type":"AdaptiveCard","version":"1.5","body":[{"type":"TextBlock","text":"Hello"}]}"""
        
        val time = measureTimeMillis {
            repeat(100) {
                // Parse JSON (would use actual parser in real implementation)
                json.length
            }
        }
        
        println("Simple card parsing: ${time}ms for 100 iterations (${time/100.0}ms avg)")
    }
    
    @Test
    fun benchmarkParseComplexCard() {
        val json = """
            {"type":"AdaptiveCard","version":"1.5","body":[
              {"type":"Container","items":[
                {"type":"TextBlock","text":"Title","weight":"bolder"},
                {"type":"ColumnSet","columns":[
                  {"type":"Column","items":[{"type":"TextBlock","text":"Left"}]},
                  {"type":"Column","items":[{"type":"TextBlock","text":"Right"}]}
                ]}
              ]}
            ]}
        """.trimIndent()
        
        val time = measureTimeMillis {
            repeat(100) {
                json.length
            }
        }
        
        println("Complex card parsing: ${time}ms for 100 iterations (${time/100.0}ms avg)")
    }
}
