import XCTest
@testable import ACCore
@testable import ACCharts

final class ChartsTests: XCTestCase {

    func testDonutChartDecoding() throws {
        let json = """
        {
            "type": "DonutChart",
            "id": "chart1",
            "title": "Sales",
            "size": "medium",
            "showLegend": true,
            "innerRadiusRatio": 0.5,
            "data": [
                {"label": "A", "value": 10},
                {"label": "B", "value": 20}
            ]
        }
        """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let element = try decoder.decode(CardElement.self, from: data)

        if case .donutChart(let chart) = element {
            XCTAssertEqual(chart.id, "chart1")
            XCTAssertEqual(chart.title, "Sales")
            XCTAssertEqual(chart.size, "medium")
            XCTAssertEqual(chart.showLegend, true)
            XCTAssertEqual(chart.innerRadiusRatio, 0.5)
            XCTAssertEqual(chart.data.count, 2)
            XCTAssertEqual(chart.data[0].label, "A")
            XCTAssertEqual(chart.data[0].value, 10)
        } else {
            XCTFail("Failed to decode DonutChart")
        }
    }

    func testBarChartDecoding() throws {
        let json = """
        {
            "type": "BarChart",
            "id": "chart2",
            "title": "Revenue",
            "orientation": "vertical",
            "showValues": true,
            "data": [
                {"label": "Jan", "value": 100},
                {"label": "Feb", "value": 200}
            ]
        }
        """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let element = try decoder.decode(CardElement.self, from: data)

        if case .barChart(let chart) = element {
            XCTAssertEqual(chart.id, "chart2")
            XCTAssertEqual(chart.title, "Revenue")
            XCTAssertEqual(chart.orientation, "vertical")
            XCTAssertEqual(chart.showValues, true)
            XCTAssertEqual(chart.data.count, 2)
        } else {
            XCTFail("Failed to decode BarChart")
        }
    }

    func testLineChartDecoding() throws {
        let json = """
        {
            "type": "LineChart",
            "id": "chart3",
            "smooth": true,
            "showDataPoints": true,
            "data": [
                {"label": "Mon", "value": 50},
                {"label": "Tue", "value": 75}
            ]
        }
        """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let element = try decoder.decode(CardElement.self, from: data)

        if case .lineChart(let chart) = element {
            XCTAssertEqual(chart.id, "chart3")
            XCTAssertEqual(chart.smooth, true)
            XCTAssertEqual(chart.showDataPoints, true)
            XCTAssertEqual(chart.data.count, 2)
        } else {
            XCTFail("Failed to decode LineChart")
        }
    }

    func testPieChartDecoding() throws {
        let json = """
        {
            "type": "PieChart",
            "id": "chart4",
            "showPercentages": true,
            "data": [
                {"label": "A", "value": 30},
                {"label": "B", "value": 70}
            ]
        }
        """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let element = try decoder.decode(CardElement.self, from: data)

        if case .pieChart(let chart) = element {
            XCTAssertEqual(chart.id, "chart4")
            XCTAssertEqual(chart.showPercentages, true)
            XCTAssertEqual(chart.data.count, 2)
        } else {
            XCTFail("Failed to decode PieChart")
        }
    }

    func testChartWithCustomColors() throws {
        let json = """
        {
            "type": "DonutChart",
            "colors": ["#FF0000", "#00FF00", "#0000FF"],
            "data": [
                {"label": "Red", "value": 10},
                {"label": "Green", "value": 20},
                {"label": "Blue", "value": 30}
            ]
        }
        """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let element = try decoder.decode(CardElement.self, from: data)

        if case .donutChart(let chart) = element {
            XCTAssertEqual(chart.colors?.count, 3)
            XCTAssertEqual(chart.colors?[0], "#FF0000")
        } else {
            XCTFail("Failed to decode chart with custom colors")
        }
    }
}
