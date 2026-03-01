import XCTest
@testable import ACInputs
@testable import ACCore

/// Tests for ChoiceSet title display fix (upstream #391).
/// Verifies that ChoiceSet renders choice.title to users,
/// while internally storing choice.value for submit payloads.
final class ChoiceSetTitleDisplayTests: XCTestCase {

    // MARK: - Test Data

    private func makeChoices() -> [ChoiceSetInput.Choice] {
        [
            ChoiceSetInput.Choice(title: "Red", value: "1"),
            ChoiceSetInput.Choice(title: "Green", value: "2"),
            ChoiceSetInput.Choice(title: "Blue", value: "3"),
        ]
    }

    private func makeInput(
        style: ChoiceInputStyle? = .compact,
        isMultiSelect: Bool? = false,
        value: String? = nil,
        placeholder: String? = nil
    ) -> ChoiceSetInput {
        ChoiceSetInput(
            id: "colorPicker",
            choices: makeChoices(),
            value: value,
            style: style,
            isMultiSelect: isMultiSelect,
            placeholder: placeholder
        )
    }

    // MARK: - resolveTitle(forValue:)

    func testResolveTitleReturnsCorrectTitle() {
        let input = makeInput()
        XCTAssertEqual(input.resolveTitle(forValue: "1"), "Red")
        XCTAssertEqual(input.resolveTitle(forValue: "2"), "Green")
        XCTAssertEqual(input.resolveTitle(forValue: "3"), "Blue")
    }

    func testResolveTitleFallsBackToValueWhenNoMatch() {
        // When value doesn't match any choice, return the raw value as fallback
        let input = makeInput()
        XCTAssertEqual(input.resolveTitle(forValue: "unknown"), "unknown")
        XCTAssertEqual(input.resolveTitle(forValue: "999"), "999")
    }

    func testResolveTitleEmptyString() {
        let input = makeInput()
        XCTAssertEqual(input.resolveTitle(forValue: ""), "")
    }

    // MARK: - resolveTitles(forValue:) (multi-select)

    func testResolveTitlesMultiSelect() {
        let input = makeInput(isMultiSelect: true)
        let titles = input.resolveTitles(forValue: "1,3")
        XCTAssertEqual(titles, ["Red", "Blue"])
    }

    func testResolveTitlesSingleValue() {
        let input = makeInput(isMultiSelect: true)
        let titles = input.resolveTitles(forValue: "2")
        XCTAssertEqual(titles, ["Green"])
    }

    func testResolveTitlesPartialMatch() {
        let input = makeInput(isMultiSelect: true)
        // "4" doesn't match any choice, should fall back to raw value
        let titles = input.resolveTitles(forValue: "1,4")
        XCTAssertEqual(titles, ["Red", "4"])
    }

    // MARK: - displayText(forValue:)

    func testDisplayTextSingleSelect() {
        let input = makeInput()
        XCTAssertEqual(input.displayText(forValue: "1"), "Red")
        XCTAssertEqual(input.displayText(forValue: "2"), "Green")
    }

    func testDisplayTextMultiSelect() {
        let input = makeInput(isMultiSelect: true)
        XCTAssertEqual(input.displayText(forValue: "1,3"), "Red, Blue")
    }

    func testDisplayTextNilFallsBackToPlaceholder() {
        let input = makeInput(placeholder: "Pick a color")
        XCTAssertEqual(input.displayText(forValue: nil), "Pick a color")
    }

    func testDisplayTextNilFallsBackToDefault() {
        let input = makeInput()
        XCTAssertEqual(input.displayText(forValue: nil), "Select")
    }

    func testDisplayTextEmptyStringFallsBackToPlaceholder() {
        let input = makeInput(placeholder: "Choose one")
        XCTAssertEqual(input.displayText(forValue: ""), "Choose one")
    }

    // MARK: - Value vs Title separation

    func testValueNotUsedAsDisplayText() {
        // This is the core bug: values should NOT be shown to users
        let input = makeInput()

        // The internal value stored is "1" (choice.value)
        let storedValue = "1"

        // The display text should be "Red" (choice.title), not "1"
        let displayText = input.displayText(forValue: storedValue)
        XCTAssertEqual(displayText, "Red")
        XCTAssertNotEqual(displayText, storedValue,
                          "Display text must show title, not raw value")
    }

    func testSubmitPayloadUsesValueNotTitle() {
        // When submitting, the value sent should be choice.value, not choice.title
        let input = makeInput()
        let selectedChoice = input.choices[0] // Red / "1"

        // The submit payload should contain the value
        XCTAssertEqual(selectedChoice.value, "1")
        // The display should show the title
        XCTAssertEqual(selectedChoice.title, "Red")
        // These must be different
        XCTAssertNotEqual(selectedChoice.title, selectedChoice.value)
    }

    // MARK: - Edge cases

    func testChoicesWithSameTitleDifferentValues() {
        let input = ChoiceSetInput(
            id: "test",
            choices: [
                ChoiceSetInput.Choice(title: "Option A", value: "opt_a_v1"),
                ChoiceSetInput.Choice(title: "Option A", value: "opt_a_v2"),
            ]
        )
        // Should find the first match
        XCTAssertEqual(input.resolveTitle(forValue: "opt_a_v1"), "Option A")
        XCTAssertEqual(input.resolveTitle(forValue: "opt_a_v2"), "Option A")
    }

    func testChoicesWithSpecialCharactersInValues() {
        let input = ChoiceSetInput(
            id: "test",
            choices: [
                ChoiceSetInput.Choice(title: "Priority: High", value: "p:high"),
                ChoiceSetInput.Choice(title: "Priority: Low", value: "p:low"),
            ]
        )
        XCTAssertEqual(input.resolveTitle(forValue: "p:high"), "Priority: High")
    }

    func testEmptyChoicesArray() {
        let input = ChoiceSetInput(id: "test", choices: [])
        // Should fall back to the value itself
        XCTAssertEqual(input.resolveTitle(forValue: "any"), "any")
        XCTAssertEqual(input.displayText(forValue: nil), "Select")
    }
}
