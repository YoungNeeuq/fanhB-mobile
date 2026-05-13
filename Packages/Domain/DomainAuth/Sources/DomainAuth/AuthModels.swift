import Foundation

public struct User: Identifiable, Sendable, Equatable {
    public let id: String
    public let email: String
    public let displayName: String
    public let avatarURL: URL?
    public let createdAt: Date

    public init(id: String, email: String, displayName: String, avatarURL: URL? = nil, createdAt: Date = .now) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.createdAt = createdAt
    }
}

public struct AuthTokens: Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresAt: Date
    public let sessionId: String?

    public init(
        accessToken: String,
        refreshToken: String,
        expiresAt: Date,
        sessionId: String? = nil
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
        self.sessionId = sessionId
    }

    public var isExpired: Bool { expiresAt < .now }
}

public enum AuthError: Error, Sendable {
    case invalidCredentials
    case emailAlreadyInUse
    case networkError(Error)
    case tokenExpired
    case userNotFound
}

public protocol AuthRepository: Sendable {
    func signIn(email: String, password: String) async throws -> (User, AuthTokens)
    func signUp(email: String, password: String, displayName: String) async throws -> (User, AuthTokens)
    func signInWithApple(identityToken: String) async throws -> (User, AuthTokens)
    func signInWithGoogle(idToken: String) async throws -> (User, AuthTokens)
    func signOut() async throws
    func refreshTokens(_ tokens: AuthTokens) async throws -> AuthTokens
    func currentUser() async throws -> User?
}
