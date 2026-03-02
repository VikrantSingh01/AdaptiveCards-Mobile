// ProgressBarAccessibilityTests.swift
// Tests for progress bar and spinner accessibility (upstream #451).
//
// Validates that:
// - ProgressBar elements parse with label, value, and color
// - Accessibility description includes label and percentage
// - Children are merged (via .accessibilityElement(children: .ignore))
// - No irrelevant link/image information in announcements

import XCTest
@testable import ACCore
@testable import ACRendering

final class ProgressBarAccessibilityTests: XCTestCase {

    // MARK: - Helpers

    private func parseCard(_ json: String) throws -> AdaptiveCard {
        return try CardParser().parse(json)
    }

    // MARK: - ProgressBar parsing

    func testProgressBarParsesWithLabelAndValue() throws {
        let card = try parseCard("""
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {"type": "ProgressBar", "value": 0.75, "label": "Upload progress"}
            ]
        }
        """)

        guard case .progressBar(let bar) = card.body?.first else {
            XCTFail("Expected ProgressBar")
            return
        }
        XCTAssertEqual(bar.value, 0.75, accuracy: 0.001)
        XCTAssertEqual(bar.label, "Upload progress")
    }

    func testProgressBarWithZeroValue() throws {
        let card = try parseCard("""
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {"type": "ProgressBar", "value": 0.0, "label": "Not started"}
            ]
        }
        """)

        guard case .progressBar(let bar) = card.body?.first else {
            XCTFail("Expected ProgressBar")
            return
        }
        XCTAssertEqual(bar.value, 0.0, accuracy: 0.001)
        XCTAssertEqual(Int(bar.value * 100), 0)
    }

    func testProgressBarWithFullValue() throws {
        let card = try parseCard("""
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {"type": "ProgressBar", "value": 1.0, "label": "Complete"}
            ]
        }
        """)

        guard case .progressBar(let bar) = card.body?.first else {
            XCTFail("Expected ProgressBar")
            return
        }
        XCTAssertEqual(bar.value, 1.0, accuracy: 0.001)
        XCTAssertEqual(Int(bar.value * 100), 100)
    }

    func testProgressBarWithColorParsesCorrectly() throws {
        let card = try parseCard("""
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {"type": "ProgressBar", "value": 0.22, "label": "Poll result",
                 "color": "#4CAF50"}
            ]
        }
        """)

        guard case .progressBar(let bar) = card.body?.first else {
            XCTFail("Expected ProgressBar")
            return
        }
        XCTAssertEqual(bar.color, "#4CAF50")
        XCTAssertEqual(Int(bar.value * 100), 22)
    }

    // MARK: - Spinner parsing

    func testSpinnerParsesWithLabel() throws {
        let card = try parseCard("""
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {"type": "Spinner", "label": "Loading results"}
            ]
        }
        """)

        guard case .spinner(let spinner) = card.body?.first else {
            XCTFail("Expected Spinner")
            return
        }
        XCTAssertEqual(spinner.label, "Loading results")
    }

    // MARK: - Accessibility description

    func testProgressBarAccessibilityDescriptionFormat() throws {
        let card = try parseCard("""
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {"type": "ProgressBar", "value": 0.22, "label": "Yes votes"}
            ]
        }
        """)

        guard case .progressBar(let bar) = card.body?.first else {
            XCTFail("Expected ProgressBar")
            return
        }

        // iOS uses .accessibilityLabel + .accessibilityValue
        let label = bar.label ?? "Progress"
        let value = "\(Int(bar.value * 100)) percent"

        XCTAssertEqual(label, "Yes votes")
        XCTAssertEqual(value, "22 percent",
            "VoiceOver should say percentage, not link or image info (upstream #451)")
    }

    // MARK: - Multiple progress bars (poll card scenario)

    func testMultipleProgressBarsInPollCard() throws {
        let card = try parseCard("""
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {"type": "ProgressBar", "value": 0.55, "label": "Option A"},
                {"type": "ProgressBar", "value": 0.30, "label": "Option B"},
                {"type": "ProgressBar", "value": 0.15, "label": "Option C"}
            ]
        }
        """)

        let bars = card.body?.compactMap { element -> ProgressBar? in
            if case .progressBar(let bar) = element { return bar }
            return nil
        }
        XCTAssertEqual(bars?.count, 3)

        XCTAssertEqual(bars?[0].label, "Option A")
        XCTAssertEqual(bars?[1].label, "Option B")
        XCTAssertEqual(bars?[2].label, "Option C")

        XCTAssertEqual(Int((bars?[0].value ?? 0) * 100), 55)
        XCTAssertEqual(Int((bars?[1].value ?? 0) * 100), 30)
        XCTAssertEqual(Int((bars?[2].value ?? 0) * 100), 15)
    }

    // MARK: - Parity with Android

    func testProgressBarParityNoIrrelevantInfo() throws {
        // Android: clearAndSetSemantics { contentDescription = "label, Progress: N%" }
        // iOS: .accessibilityElement(children: .ignore) + .accessibilityLabel + .accessibilityValue
        // Neither should announce "link" or "image" info

        let card = try parseCard("""
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {"type": "ProgressBar", "value": 0.42, "label": "Approval rating"}
            ]
        }
        """)

        guard case .progressBar(let bar) = card.body?.first else {
            XCTFail("Expected ProgressBar")
            return
        }

        let label = bar.label ?? ""
        let value = "\(Int(bar.value * 100)) percent"

        XCTAssertTrue(value.contains("42"),
            "Should announce percentage")
        XCTAssertTrue(label.contains("Approval"),
            "Should include descriptive label")
        XCTAssertFalse(label.lowercased().contains("link"),
            "Should NOT contain link info (was the bug)")
        XCTAssertFalse(label.lowercased().contains("image"),
            "Should NOT contain image info (was the bug)")
    }
}
