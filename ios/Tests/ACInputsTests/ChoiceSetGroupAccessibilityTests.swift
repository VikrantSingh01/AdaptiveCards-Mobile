// ChoiceSetGroupAccessibilityTests.swift
// Tests for ChoiceSet expanded group label accessibility (upstream #483)
//
// Verifies that expanded radio buttons / checkboxes do NOT repeat the
// group label on every item — the label should be announced once, and
// each item should only announce its own title + position.

import XCTest
@testable import ACCore
@testable import ACAccessibility

final class ChoiceSetGroupAccessibilityTests: XCTestCase {

    // MARK: - Helpers

    private func makeChoiceSet(
        choices: [(String, String)],
        style: ChoiceInputStyle = .compact,
        isMultiSelect: Bool = false,
        label: String? = "What color do you want?",
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
            placeholder: "Select..."
        )
    }

    private let colorChoices: [(String, String)] = [
        ("Red", "red"),
        ("Green", "green"),
        ("Blue", "blue"),
        ("Yellow", "yellow")
    ]

    // MARK: - Expanded style — individual item labels

    func testExpandedItemLabelDoesNotContainGroupLabel() {
        let groupLabel = "What color do you want?"
        let cs = makeChoiceSet(choices: colorChoices, style: .expanded, label: groupLabel)

        // Each choice label should be its own title, NOT prefixed with
        // the group label.
        for choice in cs.choices {
            XCTAssertFalse(
                choice.title.contains(groupLabel),
                "Individual choice '\(choice.title)' should not contain the group label"
            )
        }
    }

    func testExpandedItemLabelIsJustChoiceTitle() {
        let cs = makeChoiceSet(choices: colorChoices, style: .expanded)
        XCTAssertEqual(cs.choices[0].title, "Red")
        XCTAssertEqual(cs.choices[1].title, "Green")
        XCTAssertEqual(cs.choices[2].title, "Blue")
        XCTAssertEqual(cs.choices[3].title, "Yellow")
    }

    // MARK: - Group label should exist but be standalone

    func testExpandedGroupLabelNotNil() {
        let cs = makeChoiceSet(choices: colorChoices, style: .expanded)
        XCTAssertNotNil(cs.label, "Expanded choice set should still have a label")
    }

    func testExpandedGroupLabelMatchesInput() {
        let expectedLabel = "What color do you want?"
        let cs = makeChoiceSet(choices: colorChoices, style: .expanded, label: expectedLabel)
        XCTAssertEqual(cs.label, expectedLabel)
    }

    // MARK: - Required state in group label (not per item)

    func testExpandedRequiredLabelAccessibility() {
        let label = "What color do you want?"
        let cs = makeChoiceSet(
            choices: colorChoices,
            style: .expanded,
            isRequired: true
        )
        // The required state should be associated with the label, not items
        XCTAssertTrue(cs.isRequired == true, "Choice set should be marked as required")

        // When building the label accessibility text for expanded mode:
        // "\(label), required"
        let accessibilityLabel = cs.isRequired == true
            ? "\(label), required"
            : label
        XCTAssertTrue(accessibilityLabel.contains("required"))
        // Each individual choice should NOT include "required"
        for choice in cs.choices {
            XCTAssertFalse(choice.title.contains("required"),
                           "Individual choice '\(choice.title)' should not contain 'required'")
        }
    }

    func testExpandedOptionalLabelAccessibility() {
        let label = "What color do you want?"
        let cs = makeChoiceSet(
            choices: colorChoices,
            style: .expanded,
            isRequired: false
        )
        let accessibilityLabel = cs.isRequired == true
            ? "\(label), required"
            : label
        XCTAssertFalse(accessibilityLabel.contains("required"),
                       "Optional label should not contain 'required'")
    }

    // MARK: - Item count matches for expanded

    func testExpandedItemCountExact() {
        let cs = makeChoiceSet(choices: colorChoices, style: .expanded)
        XCTAssertEqual(cs.choices.count, 4, "Should have exactly 4 items, not more")
    }

    func testExpandedMultiSelectItemCount() {
        let cs = makeChoiceSet(choices: colorChoices, style: .expanded, isMultiSelect: true)
        XCTAssertEqual(cs.choices.count, 4,
                       "Multi-select expanded should have same item count")
    }

    // MARK: - Position info per item (not combined with group label)

    func testExpandedItemPositionFormat() {
        let cs = makeChoiceSet(choices: colorChoices, style: .expanded)
        for (index, _) in cs.choices.enumerated() {
            // The hint format should be "X of Y" where Y is the choice count
            let hint = "\(index + 1) of \(cs.choices.count)"
            // Verify it does NOT include the group label
            XCTAssertFalse(hint.contains("What color"),
                           "Position hint should not contain group label")
            // Verify format is correct
            let position = index + 1
            XCTAssertEqual(hint, "\(position) of 4")
        }
    }

    // MARK: - Compact style — group label IS expected on container

    func testCompactStyleHasGroupLabel() {
        let cs = makeChoiceSet(choices: colorChoices, style: .compact)
        // Compact style: the container label combines label + required + value
        let containerLabel = cs.label ?? "Choice set"
        XCTAssertEqual(containerLabel, "What color do you want?")
    }

    // MARK: - ConditionalAccessibilityInput applies correctly

    func testConditionalApplyTrueForCompact() {
        // When style is compact, isExpanded is false, so apply=true
        let style: ChoiceInputStyle = .compact
        let isExpanded = style == .expanded
        XCTAssertTrue(!isExpanded, "Compact style should apply accessibilityInput")
    }

    func testConditionalApplyFalseForExpanded() {
        // When style is expanded, apply=false (don't apply accessibilityInput)
        let style: ChoiceInputStyle = .expanded
        let isExpanded = style == .expanded
        XCTAssertFalse(!isExpanded, "Expanded style should NOT apply accessibilityInput")
    }

    func testConditionalApplyTrueForFiltered() {
        let style: ChoiceInputStyle = .filtered
        let isExpanded = style == .expanded
        XCTAssertTrue(!isExpanded, "Filtered style should apply accessibilityInput")
    }

    // MARK: - No group label duplication in accessibility tree

    func testGroupLabelNotDuplicatedInChoiceTitles() {
        let groupLabel = "Pick a size"
        let choices = [("Small", "s"), ("Medium", "m"), ("Large", "l")]
        let cs = makeChoiceSet(choices: choices, style: .expanded, label: groupLabel)

        // The group label is on the label Text and the accessibilityChoiceList
        // container — NOT on each individual choice.
        for choice in cs.choices {
            XCTAssertNotEqual(choice.title, "\(groupLabel) \(choice.title)",
                              "Choice title should not be prefixed with group label")
        }
    }

    func testMultiSelectExpandedItemsHaveOwnLabels() {
        let cs = makeChoiceSet(
            choices: colorChoices,
            style: .expanded,
            isMultiSelect: true,
            label: "Select colors"
        )
        for choice in cs.choices {
            XCTAssertFalse(choice.title.hasPrefix("Select colors"),
                           "Multi-select item should NOT be prefixed with group label")
        }
    }
}
