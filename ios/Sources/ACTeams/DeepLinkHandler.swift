import Foundation

public class DeepLinkHandler {
    public init() {}
    
    public func parseDeepLink(_ url: URL) -> DeepLinkInfo? {
        guard url.scheme == "msteams" else { return nil }
        
        var parameters: [String: String] = [:]
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            for item in queryItems {
                if let value = item.value {
                    parameters[item.name] = value
                }
            }
        }
        
        return DeepLinkInfo(
            scheme: url.scheme ?? "",
            host: url.host ?? "",
            path: url.path,
            parameters: parameters
        )
    }
    
    public func handleNavigation(_ deepLink: DeepLinkInfo) {
        // Host app implements actual navigation
    }
}
