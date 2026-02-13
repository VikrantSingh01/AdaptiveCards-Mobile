import Foundation

public class HostConfigParser {
    private let decoder: JSONDecoder

    public init() {
        self.decoder = JSONDecoder()
    }

    /// Parses a JSON string into a HostConfig
    public func parse(_ jsonString: String) throws -> HostConfig {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw CardParserError.invalidJSON("Unable to convert string to data")
        }

        return try parse(jsonData)
    }

    /// Parses JSON data into a HostConfig
    public func parse(_ jsonData: Data) throws -> HostConfig {
        do {
            return try decoder.decode(HostConfig.self, from: jsonData)
        } catch {
            throw CardParserError.decodingFailed(error.localizedDescription)
        }
    }

    /// Encodes a HostConfig to JSON string
    public func encode(_ hostConfig: HostConfig) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let jsonData = try encoder.encode(hostConfig)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw CardParserError.invalidJSON("Unable to convert data to string")
        }

        return jsonString
    }
}
