import Foundation

/// Custom decoder utilities for handling type discriminators
public class ElementDecoder {
    /// Decodes an element based on its type discriminator
    public static func decode<T: Decodable>(
        _ type: T.Type,
        from container: KeyedDecodingContainer<DynamicCodingKeys>,
        using decoder: Decoder
    ) throws -> T {
        return try T(from: decoder)
    }
    
    /// Helper to get the type string from a container
    public static func getType(
        from container: KeyedDecodingContainer<DynamicCodingKeys>
    ) throws -> String {
        guard let typeKey = DynamicCodingKeys(stringValue: "type") else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unable to create coding key for 'type'"
                )
            )
        }
        return try container.decode(String.self, forKey: typeKey)
    }
}

/// Dynamic coding keys for flexible decoding
public struct DynamicCodingKeys: CodingKey {
    public var stringValue: String
    public var intValue: Int?
    
    public init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    public init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}
