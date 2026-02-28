import Foundation

// MARK: - Authentication

public struct Authentication: Codable, Equatable {
    public var text: String?
    public var connectionName: String?
    public var tokenExchangeResource: TokenExchangeResource?
    public var buttons: [AuthCardButton]?

    public init(
        text: String? = nil,
        connectionName: String? = nil,
        tokenExchangeResource: TokenExchangeResource? = nil,
        buttons: [AuthCardButton]? = nil
    ) {
        self.text = text
        self.connectionName = connectionName
        self.tokenExchangeResource = tokenExchangeResource
        self.buttons = buttons
    }

    public struct AuthCardButton: Codable, Equatable {
        public var type: String
        public var title: String
        public var image: String?
        public var value: String

        public init(type: String, title: String, image: String? = nil, value: String) {
            self.type = type
            self.title = title
            self.image = image
            self.value = value
        }
    }
}

// MARK: - TokenExchangeResource

public struct TokenExchangeResource: Codable, Equatable {
    public var id: String
    public var uri: String
    public var providerId: String

    public init(id: String, uri: String, providerId: String) {
        self.id = id
        self.uri = uri
        self.providerId = providerId
    }
}

// MARK: - Refresh

public struct Refresh: Codable, Equatable {
    public var action: CardAction
    public var userIds: [String]?
    /// ISO-8601 timestamp indicating when the card content expires (v1.6)
    public var expires: String?

    public init(action: CardAction, userIds: [String]? = nil, expires: String? = nil) {
        self.action = action
        self.userIds = userIds
        self.expires = expires
    }
}
