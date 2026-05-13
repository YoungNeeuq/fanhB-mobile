import Foundation
import Security
import DomainAuth

actor KeychainTokenStore {
    static let shared = KeychainTokenStore()

    private let service = "com.fanhb.app"
    private let tokensAccount = "auth.tokens"
    private let userAccount = "auth.user"

    private init() {}

    func save(tokens: AuthTokens, user: User) throws {
        let tokensData = try JSONEncoder().encode(StoredTokens(tokens: tokens))
        let userData = try JSONEncoder().encode(StoredUser(user: user))
        try write(data: tokensData, account: tokensAccount)
        try write(data: userData, account: userAccount)
    }

    func loadTokens() -> AuthTokens? {
        guard let data = read(account: tokensAccount),
              let stored = try? JSONDecoder().decode(StoredTokens.self, from: data) else {
            return nil
        }
        return stored.asAuthTokens()
    }

    func loadUser() -> User? {
        guard let data = read(account: userAccount),
              let stored = try? JSONDecoder().decode(StoredUser.self, from: data) else {
            return nil
        }
        return stored.asUser()
    }

    func clear() {
        delete(account: tokensAccount)
        delete(account: userAccount)
    }

    // Non-isolated synchronous read used only at app startup before the event
    // loop is running. Safe because no other actor is yet mutating the Keychain.
    nonisolated func loadTokensSync() -> AuthTokens? {
        guard let data = readSync(account: tokensAccount),
              let stored = try? JSONDecoder().decode(StoredTokens.self, from: data) else {
            return nil
        }
        return stored.asAuthTokens()
    }

    // MARK: - Private Keychain helpers

    private func write(data: Data, account: String) throws {
        delete(account: account)

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.writeFailed(status)
        }
    }

    private func read(account: String) -> Data? {
        readSync(account: account)
    }

    private nonisolated func readSync(account: String) -> Data? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    private func delete(account: String) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Keychain error

enum KeychainError: Error {
    case writeFailed(OSStatus)
}

// MARK: - Codable storage types

private struct StoredTokens: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
    let sessionId: String?

    init(tokens: AuthTokens) {
        self.accessToken = tokens.accessToken
        self.refreshToken = tokens.refreshToken
        self.expiresAt = tokens.expiresAt
        self.sessionId = tokens.sessionId
    }

    func asAuthTokens() -> AuthTokens {
        AuthTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: expiresAt,
            sessionId: sessionId
        )
    }
}

private struct StoredUser: Codable {
    let id: String
    let email: String
    let displayName: String
    let avatarURL: URL?
    let createdAt: Date

    init(user: User) {
        self.id = user.id
        self.email = user.email
        self.displayName = user.displayName
        self.avatarURL = user.avatarURL
        self.createdAt = user.createdAt
    }

    func asUser() -> User {
        User(
            id: id,
            email: email,
            displayName: displayName,
            avatarURL: avatarURL,
            createdAt: createdAt
        )
    }
}
