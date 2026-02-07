import Foundation

public enum CardParserError: Error, LocalizedError {
    case invalidJSON(String)
    case decodingFailed(String)
    case missingRequiredField(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidJSON(let message):
            return "Invalid JSON: \(message)"
        case .decodingFailed(let message):
            return "Decoding failed: \(message)"
        case .missingRequiredField(let field):
            return "Missing required field: \(field)"
        }
    }
}

public class CardParser {
    private let decoder: JSONDecoder
    private let fallbackHandler: FallbackHandler
    
    public init(fallbackHandler: FallbackHandler = FallbackHandler()) {
        self.decoder = JSONDecoder()
        self.fallbackHandler = fallbackHandler
    }
    
    /// Parses a JSON string into an AdaptiveCard
    public func parse(_ jsonString: String) throws -> AdaptiveCard {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw CardParserError.invalidJSON("Unable to convert string to data")
        }
        
        return try parse(jsonData)
    }
    
    /// Parses JSON data into an AdaptiveCard
    public func parse(_ jsonData: Data) throws -> AdaptiveCard {
        do {
            return try decoder.decode(AdaptiveCard.self, from: jsonData)
        } catch let decodingError as DecodingError {
            let errorMessage = decodingErrorMessage(decodingError)
            throw CardParserError.decodingFailed(errorMessage)
        } catch {
            throw CardParserError.decodingFailed(error.localizedDescription)
        }
    }
    
    /// Encodes an AdaptiveCard to JSON string
    public func encode(_ card: AdaptiveCard) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let jsonData = try encoder.encode(card)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw CardParserError.invalidJSON("Unable to convert data to string")
        }
        
        return jsonString
    }
    
    private func decodingErrorMessage(_ error: DecodingError) -> String {
        switch error {
        case .typeMismatch(let type, let context):
            return "Type mismatch for type \(type) at \(context.codingPath.map { $0.stringValue }.joined(separator: ".")): \(context.debugDescription)"
        case .valueNotFound(let type, let context):
            return "Value not found for type \(type) at \(context.codingPath.map { $0.stringValue }.joined(separator: ".")): \(context.debugDescription)"
        case .keyNotFound(let key, let context):
            return "Key '\(key.stringValue)' not found at \(context.codingPath.map { $0.stringValue }.joined(separator: ".")): \(context.debugDescription)"
        case .dataCorrupted(let context):
            return "Data corrupted at \(context.codingPath.map { $0.stringValue }.joined(separator: ".")): \(context.debugDescription)"
        @unknown default:
            return "Unknown decoding error: \(error.localizedDescription)"
        }
    }
}
