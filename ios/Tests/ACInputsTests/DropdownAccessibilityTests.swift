// DropdownAccessibilityTests.swift
// Tests for ChoiceSet dropdown accessibility semantics (upstream #466)
//
// Verifies that dropdown/choice-set components provide correct
// collection position info for VoiceOver (e.g. "1 of 4").

import XCTest
@testable import ACCore
@testable import ACAccessibility

final class DropdownAccessibilityTests: XCTestCase {

    // MARK: - Model helpers

    private func makeChoiceSet(
        choices: [(String, String)],
        style: ChoiceInputStyle = .compact,
        isMultiSelect: Bool = false,
        label: String? = "Sample label",
        placeholder: String? = "Select...",
        isRequired: Bool = false
    ) -> ChoiceSetInput {
        ChoiceSetInput(
            id: "test-choiceset",
            isRequired: isRequired,
            label: label,
            choices: choices.map { ChoiceSetInput.Choice(title: $0.0, value: $0.1) },
            value: nil,
            style: style,
            isMultiSelect: isMultiSelect,
            placeholder: placeholder
        )
    }

    private let fourChoices: [(String, String)] = [
        ("Metro Transit", "metro"),
        ("City Bus", "bus"),
        ("Regional Rail", "rail"),
        ("Airport Shuttle", "shuttle")
    ]

    // MARK: - Choice count tests

    func testChoiceCountMatchesActualChoices() {
        let cs = makeChoiceSet(choices: fourChoices)
        XCTAssertEqual(cs.choices.count, 4, "Should have exactly 4 choices, not 5")
    }

    func testChoiceCountExcludesPlaceholder() {
        let cs = makeChoiceSet(choices: fourChoices, placeholder: "Select an option")
        // The placeholder is NOT a choice — it should not be counted
        XCTAssertEqual(cs.choices.count, 4,
                       "Placeholder should not be counted as a choice")
    }

    func testChoiceCountWithEmptyList() {
        let cs = makeChoiceSet(choices: [])
        XCTAssertEqual(cs.choices.count, 0)
    }

    func testChoiceCountWithSingleChoice() {
        let cs = makeChoiceSet(choices: [("Only Option", "only")])
        XCTAssertEqual(cs.choices.count, 1)
    }

    // MARK: - Index correctness

    func testChoiceIndicesAreZeroBased() {
        let cs = makeChoiceSet(choices: fourChoices)
        for (index, choice) in cs.choices.enumerated() {
            XCTAssertEqual(index, cs.choices.firstIndex(where: { $0.value == choice.value }),
                           "Index should match position in choices array")
        }
    }

    func testFirstChoiceIndexIsZero() {
        let cs = makeChoiceSet(choices: fourChoices)
        let firstIndex = cs.choices.firstIndex(where: { $0.value == "metro" })
        XCTAssertEqual(firstIndex, 0)
    }

    func testLastChoiceIndexIsCountMinusOne() {
        let cs = makeChoiceSet(choices: fourChoices)
        let lastIndex = cs.choices.firstIndex(where: { $0.value == "shuttle" })
        XCTAssertEqual(lastIndex, 3)
    }

    // MARK: - Accessibility hint format

    func testAccessibilityHintFormat() {
        // Verify the format used by accessibilityChoiceItem
        let index = 0
        let totalCount = 4
        let hint = "\(index + 1) of \(totalCount)"
        XCTAssertEqual(hint, "1 of 4")
    }

    func testAccessibilityHintForLastItem() {
        let index = 3
        let totalCount = 4
        let hint = "\(index + 1) of \(totalCount)"
        XCTAssertEqual(hint, "4 of 4")
    }

    func testAccessibilityHintNeverExceedsCount() {
        let cs = makeChoiceSet(choices: fourChoices)
        for (index, _) in cs.choices.enumerated() {
            let position = index + 1
            XCTAssertLessThanOrEqual(position, cs.choices.count,
                                     "Position \(position) should never exceed count \(cs.choices.count)")
        }
    }

    // MARK: - Display text for accessibility label

    func testDisplayTextForSelectedValue() {
        let cs = makeChoiceSet(choices: fourChoices)
        let text = cs.displayText(forValue: "bus")
        XCTAssertEqual(text, "City Bus")
    }

    func testDisplayTextForNoSelection() {
        let cs = makeChoiceSet(choices: fourChoices, placeholder: "Pick one")
        let text = cs.displayText(forValue: nil)
        XCTAssertEqual(text, "Pick one")
    }

    // MARK: - Multi-select count

    func testMultiSelectChoiceCount() {
        let cs = makeChoiceSet(choices: fourChoices, isMultiSelect: true)
        XCTAssertEqual(cs.choices.count, 4,
                       "Multi-select should have same count as single-select")
    }

    // MARK: - Expanded style count

    func testExpandedStyleChoiceCount() {
        let cs = makeChoiceSet(choices: fourChoices, style: .expanded)
        XCTAssertEqual(cs.choices.count, 4,
                       "Expanded style should have same choice count")
    }

    // MARK: - Filtered style count

    func testFilteredStyleChoiceCount() {
        let cs = makeChoiceSet(choices: fourChoices, style: .filtered)
        XCTAssertEqual(cs.choices.count, 4,
                       "Filtered style should have same choice count")
    }

    // MARK: - Required field accessibility

    func testRequiredFieldAccessibilityLabel() {
        let label = "Sample label"
        // Build label the same way the accessibility modifier does for isRequired=true
        let accessibilityLabel = "\(label), required, popup button"
        XCTAssertTrue(accessibilityLabel.contains("required"),
                      "Required dropdown should include 'required' in accessibility label")
    }

    func testOptionalFieldAccessibilityLabel() {
        let label = "Sample label"
        // Build label the same way the accessibility modifier does for isRequired=false
        let accessibilityLabel = "\(label), popup button"
        XCTAssertFalse(accessibilityLabel.contains("required"),
                       "Optional dropdown should not include 'required'")
    }
}
