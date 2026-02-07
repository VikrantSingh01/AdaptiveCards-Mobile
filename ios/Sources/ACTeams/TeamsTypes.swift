import Foundation

public protocol AuthTokenProvider {
    func getToken() async throws -> String
}

public enum TeamsTheme: String {
    case light
    case dark
    case highContrast
}

public struct DeepLinkInfo {
    public let scheme: String
    public let host: String
    public let path: String
    public let parameters: [String: String]
    
    public init(scheme: String, host: String, path: String, parameters: [String: String]) {
        self.scheme = scheme
        self.host = host
        self.path = path
        self.parameters = parameters
    }
}
