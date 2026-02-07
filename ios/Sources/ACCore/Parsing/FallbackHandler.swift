import Foundation

/// Handles fallback elements when unknown types are encountered
public class FallbackHandler {
    public enum FallbackMode {
        case drop       // Drop the element entirely
        case error      // Throw an error
        case textBlock  // Convert to a TextBlock with fallback text
    }
    
    public var mode: FallbackMode
    
    public init(mode: FallbackMode = .drop) {
        self.mode = mode
    }
    
    /// Handles a fallback element based on the configured mode
    public func handleFallback(
        for type: String,
        at codingPath: [CodingKey]
    ) -> CardElement? {
        switch mode {
        case .drop:
            return nil
        case .error:
            // This would be handled by the decoder throwing an error
            return nil
        case .textBlock:
            let fallbackText = "Unsupported element type: \(type)"
            return .textBlock(TextBlock(text: fallbackText))
        }
    }
    
    /// Checks if an element has a fallback property
    public func hasFallback(in json: [String: Any]) -> Bool {
        return json["fallback"] != nil
    }
}
