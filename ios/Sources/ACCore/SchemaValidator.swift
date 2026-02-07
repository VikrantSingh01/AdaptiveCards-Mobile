import Foundation

public struct SchemaValidator {
    public static let validElementTypes: Set<String> = [
        "TextBlock", "Image", "Media", "RichTextBlock", "Container", "ColumnSet",
        "ImageSet", "FactSet", "ActionSet", "Table", "Input.Text", "Input.Number",
        "Input.Date", "Input.Time", "Input.Toggle", "Input.ChoiceSet", "Carousel",
        "Accordion", "CodeBlock", "Rating", "Input.Rating", "ProgressBar", "Spinner",
        "TabSet", "List", "CompoundButton", "DonutChart", "BarChart", "LineChart", "PieChart"
    ]
    
    public init() {}
    
    public func validate(json: String) -> [SchemaValidationError] {
        var errors: [SchemaValidationError] = []
        
        guard let data = json.data(using: .utf8) else {
            errors.append(SchemaValidationError(
                path: "$",
                message: "Invalid JSON string",
                expected: "Valid UTF-8 JSON",
                actual: "Invalid encoding"
            ))
            return errors
        }
        
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            errors.append(SchemaValidationError(
                path: "$",
                message: "Invalid JSON structure",
                expected: "JSON object",
                actual: "Invalid JSON"
            ))
            return errors
        }
        
        // Validate required fields
        if jsonObject["type"] == nil {
            errors.append(SchemaValidationError(
                path: "$.type",
                message: "Missing required field",
                expected: "type: String",
                actual: "undefined"
            ))
        } else if let type = jsonObject["type"] as? String, type != "AdaptiveCard" {
            errors.append(SchemaValidationError(
                path: "$.type",
                message: "Invalid card type",
                expected: "AdaptiveCard",
                actual: type
            ))
        }
        
        if jsonObject["version"] == nil {
            errors.append(SchemaValidationError(
                path: "$.version",
                message: "Missing required field",
                expected: "version: String",
                actual: "undefined"
            ))
        } else if let version = jsonObject["version"] as? String {
            if !version.matches(pattern: #"^\d+\.\d+$"#) {
                errors.append(SchemaValidationError(
                    path: "$.version",
                    message: "Invalid version format",
                    expected: "X.Y format (e.g., 1.5)",
                    actual: version
                ))
            }
        }
        
        // Validate body array if present
        if let body = jsonObject["body"] {
            if body is [Any] {
                if let bodyArray = body as? [[String: Any]] {
                    for (index, element) in bodyArray.enumerated() {
                        errors.append(contentsOf: validateElement(element, path: "$.body[\(index)]"))
                    }
                }
            } else {
                errors.append(SchemaValidationError(
                    path: "$.body",
                    message: "Invalid type",
                    expected: "Array",
                    actual: "\(type(of: body))"
                ))
            }
        }
        
        // Validate actions array if present
        if let actions = jsonObject["actions"] {
            if !(actions is [Any]) {
                errors.append(SchemaValidationError(
                    path: "$.actions",
                    message: "Invalid type",
                    expected: "Array",
                    actual: "\(type(of: actions))"
                ))
            }
        }
        
        return errors
    }
    
    private func validateElement(_ element: [String: Any], path: String) -> [SchemaValidationError] {
        var errors: [SchemaValidationError] = []
        
        if element["type"] == nil {
            errors.append(SchemaValidationError(
                path: "\(path).type",
                message: "Missing required field",
                expected: "type: String",
                actual: "undefined"
            ))
        } else if let type = element["type"] as? String {
            if !Self.validElementTypes.contains(type) {
                errors.append(SchemaValidationError(
                    path: "\(path).type",
                    message: "Unknown element type",
                    expected: "One of: \(Self.validElementTypes.sorted().joined(separator: ", "))",
                    actual: type
                ))
            }
        }
        
        return errors
    }
}

public struct SchemaValidationError: Codable, Equatable {
    public var path: String
    public var message: String
    public var expected: String?
    public var actual: String?
    
    public init(path: String, message: String, expected: String?, actual: String?) {
        self.path = path
        self.message = message
        self.expected = expected
        self.actual = actual
    }
}

extension String {
    func matches(pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.firstMatch(in: self, range: range) != nil
    }
}
