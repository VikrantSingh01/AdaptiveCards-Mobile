import Foundation
import ACCore

public class InputValidator {
    
    /// Validates a text input
    public static func validateText(
        value: String?,
        input: TextInput
    ) -> String? {
        // Check required
        if input.isRequired == true {
            if value == nil || value?.isEmpty == true {
                return input.errorMessage ?? "This field is required"
            }
        }
        
        // Check max length
        if let maxLength = input.maxLength,
           let value = value,
           value.count > maxLength {
            return input.errorMessage ?? "Maximum length is \(maxLength) characters"
        }
        
        // Check regex
        if let regex = input.regex,
           let value = value,
           !value.isEmpty {
            if !matchesRegex(value, pattern: regex) {
                return input.errorMessage ?? "Invalid format"
            }
        }
        
        return nil
    }
    
    /// Validates a number input
    public static func validateNumber(
        value: Double?,
        input: NumberInput
    ) -> String? {
        // Check required
        if input.isRequired == true {
            if value == nil {
                return input.errorMessage ?? "This field is required"
            }
        }
        
        guard let value = value else {
            return nil
        }
        
        // Check min
        if let min = input.min, value < min {
            return input.errorMessage ?? "Minimum value is \(min)"
        }
        
        // Check max
        if let max = input.max, value > max {
            return input.errorMessage ?? "Maximum value is \(max)"
        }
        
        return nil
    }
    
    /// Validates a date input
    public static func validateDate(
        value: String?,
        input: DateInput
    ) -> String? {
        // Check required
        if input.isRequired == true {
            if value == nil || value?.isEmpty == true {
                return input.errorMessage ?? "This field is required"
            }
        }
        
        guard let value = value, !value.isEmpty else {
            return nil
        }
        
        // Check date format (YYYY-MM-DD)
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        
        guard let date = dateFormatter.date(from: value) else {
            return input.errorMessage ?? "Invalid date format"
        }
        
        // Check min
        if let min = input.min,
           let minDate = dateFormatter.date(from: min),
           date < minDate {
            return input.errorMessage ?? "Date must be on or after \(min)"
        }
        
        // Check max
        if let max = input.max,
           let maxDate = dateFormatter.date(from: max),
           date > maxDate {
            return input.errorMessage ?? "Date must be on or before \(max)"
        }
        
        return nil
    }
    
    /// Validates a time input
    public static func validateTime(
        value: String?,
        input: TimeInput
    ) -> String? {
        // Check required
        if input.isRequired == true {
            if value == nil || value?.isEmpty == true {
                return input.errorMessage ?? "This field is required"
            }
        }
        
        guard let value = value, !value.isEmpty else {
            return nil
        }
        
        // Check time format (HH:mm)
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        guard let time = timeFormatter.date(from: value) else {
            return input.errorMessage ?? "Invalid time format"
        }
        
        // Check min
        if let min = input.min,
           let minTime = timeFormatter.date(from: min),
           time < minTime {
            return input.errorMessage ?? "Time must be on or after \(min)"
        }
        
        // Check max
        if let max = input.max,
           let maxTime = timeFormatter.date(from: max),
           time > maxTime {
            return input.errorMessage ?? "Time must be on or before \(max)"
        }
        
        return nil
    }
    
    /// Validates a choice set input
    public static func validateChoiceSet(
        value: String?,
        input: ChoiceSetInput
    ) -> String? {
        // Check required
        if input.isRequired == true {
            if value == nil || value?.isEmpty == true {
                return input.errorMessage ?? "This field is required"
            }
        }
        
        return nil
    }
    
    // MARK: - Helper Methods
    
    private static func matchesRegex(_ string: String, pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return false
        }
        
        let range = NSRange(string.startIndex..., in: string)
        return regex.firstMatch(in: string, range: range) != nil
    }
}
