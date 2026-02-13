import Foundation

/// Schema validator for Adaptive Cards v1.6
/// Validates card JSON against the v1.6 schema specification
public struct SchemaValidator {
    /// Target schema version for validation
    public static let targetSchemaVersion = "1.6"
    
    /// Valid element types in Adaptive Cards v1.6 (including custom chart extensions)
    public static let validElementTypes: Set<String> = [
        // Core elements (v1.0)
        "TextBlock", "Image", "Media", "RichTextBlock",
        // Container elements (v1.0)
        "Container", "ColumnSet", "ImageSet", "FactSet", "ActionSet",
        // Input elements (v1.0)
        "Input.Text", "Input.Number", "Input.Date", "Input.Time", "Input.Toggle", "Input.ChoiceSet",
        // Advanced elements (v1.3+)
        "Carousel", "Accordion", "CodeBlock", "Rating", "Input.Rating", "ProgressBar", "Spinner",
        "TabSet", "List",
        // v1.6 elements
        "Table", "CompoundButton",
        // Custom chart extensions
        "DonutChart", "BarChart", "LineChart", "PieChart"
    ]
    
    /// Valid action types in Adaptive Cards v1.6
    public static let validActionTypes: Set<String> = [
        "Action.Submit", "Action.OpenUrl", "Action.ShowCard", 
        "Action.ToggleVisibility", "Action.Execute"
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
                    expected: "X.Y format (e.g., 1.6)",
                    actual: version
                ))
            }
            // Note: We accept versions up to and including 1.6
            // Higher versions are accepted but features may not be supported
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
            if actions is [Any] {
                if let actionsArray = actions as? [[String: Any]] {
                    for (index, action) in actionsArray.enumerated() {
                        errors.append(contentsOf: validateAction(action, path: "$.actions[\(index)]"))
                    }
                }
            } else {
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
    
    /// Validates an action object
    private func validateAction(_ action: [String: Any], path: String) -> [SchemaValidationError] {
        var errors: [SchemaValidationError] = []
        
        if action["type"] == nil {
            errors.append(SchemaValidationError(
                path: "\(path).type",
                message: "Missing required field",
                expected: "type: String",
                actual: "undefined"
            ))
        } else if let type = action["type"] as? String {
            if !Self.validActionTypes.contains(type) {
                errors.append(SchemaValidationError(
                    path: "\(path).type",
                    message: "Unknown action type",
                    expected: "One of: \(Self.validActionTypes.sorted().joined(separator: ", "))",
                    actual: type
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
