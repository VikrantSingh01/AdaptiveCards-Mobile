import XCTest
@testable import ACInputs
@testable import ACCore

final class InputValidatorTests: XCTestCase {
    
    func testValidateTextRequired() {
        let input = TextInput(id: "test", isRequired: true)
        
        // Test empty value
        let error1 = InputValidator.validateText(value: nil, input: input)
        XCTAssertNotNil(error1)
        XCTAssertTrue(error1?.contains("required") ?? false)
        
        // Test valid value
        let error2 = InputValidator.validateText(value: "Test", input: input)
        XCTAssertNil(error2)
    }
    
    func testValidateTextMaxLength() {
        let input = TextInput(id: "test", maxLength: 5)
        
        // Test value exceeding max length
        let error1 = InputValidator.validateText(value: "TestValue", input: input)
        XCTAssertNotNil(error1)
        
        // Test valid value
        let error2 = InputValidator.validateText(value: "Test", input: input)
        XCTAssertNil(error2)
    }
    
    func testValidateTextRegex() {
        let input = TextInput(id: "test", regex: "^[0-9]+$")
        
        // Test invalid format
        let error1 = InputValidator.validateText(value: "abc", input: input)
        XCTAssertNotNil(error1)
        
        // Test valid format
        let error2 = InputValidator.validateText(value: "123", input: input)
        XCTAssertNil(error2)
    }
    
    func testValidateNumberRequired() {
        let input = NumberInput(id: "test", isRequired: true)
        
        // Test nil value
        let error1 = InputValidator.validateNumber(value: nil, input: input)
        XCTAssertNotNil(error1)
        
        // Test valid value
        let error2 = InputValidator.validateNumber(value: 10, input: input)
        XCTAssertNil(error2)
    }
    
    func testValidateNumberMinMax() {
        let input = NumberInput(id: "test", min: 0, max: 100)
        
        // Test value below min
        let error1 = InputValidator.validateNumber(value: -5, input: input)
        XCTAssertNotNil(error1)
        
        // Test value above max
        let error2 = InputValidator.validateNumber(value: 150, input: input)
        XCTAssertNotNil(error2)
        
        // Test valid value
        let error3 = InputValidator.validateNumber(value: 50, input: input)
        XCTAssertNil(error3)
    }
    
    func testValidateDateRequired() {
        let input = DateInput(id: "test", isRequired: true)
        
        // Test empty value
        let error1 = InputValidator.validateDate(value: nil, input: input)
        XCTAssertNotNil(error1)
        
        // Test valid value
        let error2 = InputValidator.validateDate(value: "2024-01-15", input: input)
        XCTAssertNil(error2)
    }
    
    func testValidateTimeRequired() {
        let input = TimeInput(id: "test", isRequired: true)
        
        // Test empty value
        let error1 = InputValidator.validateTime(value: nil, input: input)
        XCTAssertNotNil(error1)
        
        // Test valid value
        let error2 = InputValidator.validateTime(value: "14:30", input: input)
        XCTAssertNil(error2)
    }
    
    func testValidateChoiceSetRequired() {
        let input = ChoiceSetInput(
            id: "test",
            isRequired: true,
            choices: [
                ChoiceSetInput.Choice(title: "Option 1", value: "1"),
                ChoiceSetInput.Choice(title: "Option 2", value: "2")
            ]
        )
        
        // Test empty value
        let error1 = InputValidator.validateChoiceSet(value: nil, input: input)
        XCTAssertNotNil(error1)
        
        // Test valid value
        let error2 = InputValidator.validateChoiceSet(value: "1", input: input)
        XCTAssertNil(error2)
    }
}
