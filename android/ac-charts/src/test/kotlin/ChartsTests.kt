package com.microsoft.adaptivecards.charts

import com.microsoft.adaptivecards.core.models.*
import kotlinx.serialization.json.Json
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test

class ChartsTests {
    
    private val json = Json {
        ignoreUnknownKeys = true
        isLenient = true
    }
    
    @Test
    fun `test DonutChart deserialization`() {
        val jsonString = """
        {
            "type": "DonutChart",
            "id": "chart1",
            "title": "Sales",
            "size": "medium",
            "showLegend": true,
            "innerRadiusRatio": 0.5,
            "data": [
                {"label": "A", "value": 10.0},
                {"label": "B", "value": 20.0}
            ]
        }
        """
        
        val chart = json.decodeFromString<DonutChart>(jsonString)
        
        assertEquals("chart1", chart.id)
        assertEquals("Sales", chart.title)
        assertEquals("medium", chart.size)
        assertEquals(true, chart.showLegend)
        assertEquals(0.5, chart.innerRadiusRatio)
        assertEquals(2, chart.data.size)
        assertEquals("A", chart.data[0].label)
        assertEquals(10.0, chart.data[0].value)
    }
    
    @Test
    fun `test BarChart deserialization`() {
        val jsonString = """
        {
            "type": "BarChart",
            "id": "chart2",
            "title": "Revenue",
            "orientation": "vertical",
            "showValues": true,
            "data": [
                {"label": "Jan", "value": 100.0},
                {"label": "Feb", "value": 200.0}
            ]
        }
        """
        
        val chart = json.decodeFromString<BarChart>(jsonString)
        
        assertEquals("chart2", chart.id)
        assertEquals("Revenue", chart.title)
        assertEquals("vertical", chart.orientation)
        assertEquals(true, chart.showValues)
        assertEquals(2, chart.data.size)
    }
    
    @Test
    fun `test LineChart deserialization`() {
        val jsonString = """
        {
            "type": "LineChart",
            "id": "chart3",
            "smooth": true,
            "showDataPoints": true,
            "data": [
                {"label": "Mon", "value": 50.0},
                {"label": "Tue", "value": 75.0}
            ]
        }
        """
        
        val chart = json.decodeFromString<LineChart>(jsonString)
        
        assertEquals("chart3", chart.id)
        assertEquals(true, chart.smooth)
        assertEquals(true, chart.showDataPoints)
        assertEquals(2, chart.data.size)
    }
    
    @Test
    fun `test PieChart deserialization`() {
        val jsonString = """
        {
            "type": "PieChart",
            "id": "chart4",
            "showPercentages": true,
            "data": [
                {"label": "A", "value": 30.0},
                {"label": "B", "value": 70.0}
            ]
        }
        """
        
        val chart = json.decodeFromString<PieChart>(jsonString)
        
        assertEquals("chart4", chart.id)
        assertEquals(true, chart.showPercentages)
        assertEquals(2, chart.data.size)
    }
    
    @Test
    fun `test chart with custom colors`() {
        val jsonString = """
        {
            "type": "DonutChart",
            "colors": ["#FF0000", "#00FF00", "#0000FF"],
            "data": [
                {"label": "Red", "value": 10.0},
                {"label": "Green", "value": 20.0},
                {"label": "Blue", "value": 30.0}
            ]
        }
        """
        
        val chart = json.decodeFromString<DonutChart>(jsonString)
        
        assertEquals(3, chart.colors?.size)
        assertEquals("#FF0000", chart.colors?.get(0))
    }
    
    @Test
    fun `test ChartColors default palette`() {
        assertEquals(8, ChartColors.defaultPalette.size)
    }
    
    @Test
    fun `test ChartSize enum`() {
        assertEquals(150, ChartSize.SMALL.heightDp)
        assertEquals(250, ChartSize.MEDIUM.heightDp)
        assertEquals(350, ChartSize.LARGE.heightDp)
        assertEquals(250, ChartSize.AUTO.heightDp)
        
        assertEquals(ChartSize.SMALL, ChartSize.from("small"))
        assertEquals(ChartSize.MEDIUM, ChartSize.from("medium"))
        assertEquals(ChartSize.LARGE, ChartSize.from("large"))
        assertEquals(ChartSize.AUTO, ChartSize.from("auto"))
        assertEquals(ChartSize.AUTO, ChartSize.from(null))
    }
}
