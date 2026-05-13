import Foundation
import FHBNetworking
import DomainAuth

// MARK: - DTOs

struct AuthUserDTO: Codable, Sendable {
    let id: String
    let email: String
    let displayName: String
}

struct AuthResponse: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
    let sessionId: String
    let user: AuthUserDTO
}

struct SignupRequest: Codable, Sendable {
    let email: String
    let password: String
    let displayName: String
}

struct LoginRequest: Codable, Sendable {
    let email: String
    let password: String
}

struct SocialAuthRequest: Codable, Sendable {
    let provider: String
    let idToken: String
}

struct RefreshRequest: Codable, Sendable {
    let sessionId: String
    let refreshToken: String
}

struct OTPRequestBody: Codable, Sendable {
    let email: String
}

struct OTPVerifyRequest: Codable, Sendable {
    let email: String
    let code: String
    let type: String
}

struct OTPVerifyResponse: Codable, Sendable {
    let verified: Bool
}

// MARK: - AuthAPIService

actor AuthAPIService {
    private let apiClient: any APIClientProtocol

    init(apiClient: any APIClientProtocol) {
        self.apiClient = apiClient
    }

    func signup(email: String, password: String, displayName: String) async throws -> AuthResponse {
        let endpoint = try Endpoint.json(
            path: "/v1/auth/signup",
            method: .post,
            body: SignupRequest(email: email, password: password, displayName: displayName)
        )
        return try await apiClient.request(endpoint)
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let endpoint = try Endpoint.json(
            path: "/v1/auth/login",
            method: .post,
            body: LoginRequest(email: email, password: password)
        )
        return try await apiClient.request(endpoint)
    }

    func social(provider: String, idToken: String) async throws -> AuthResponse {
        let endpoint = try Endpoint.json(
            path: "/v1/auth/social",
            method: .post,
            body: SocialAuthRequest(provider: provider, idToken: idToken)
        )
        return try await apiClient.request(endpoint)
    }

    func refresh(sessionId: String, refreshToken: String) async throws -> AuthResponse {
        let endpoint = try Endpoint.json(
            path: "/v1/auth/refresh",
            method: .post,
            body: RefreshRequest(sessionId: sessionId, refreshToken: refreshToken)
        )
        return try await apiClient.request(endpoint)
    }

    func logout() async throws {
        let endpoint = Endpoint(path: "/v1/auth/logout", method: .post)
        try await apiClient.requestVoid(endpoint)
    }

    func requestOTP(email: String) async throws {
        let endpoint = try Endpoint.json(
            path: "/v1/auth/otp/request",
            method: .post,
            body: OTPRequestBody(email: email)
        )
        try await apiClient.requestVoid(endpoint)
    }

    func verifyOTP(email: String, code: String, type: String) async throws -> OTPVerifyResponse {
        let endpoint = try Endpoint.json(
            path: "/v1/auth/otp/verify",
            method: .post,
            body: OTPVerifyRequest(email: email, code: code, type: type)
        )
        return try await apiClient.request(endpoint)
    }
}

// MARK: - Response mapping

extension AuthResponse {
    func toDomain() -> (User, AuthTokens) {
        let user = User(
            id: user.id,
            email: user.email,
            displayName: user.displayName
        )
        let tokens = AuthTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: .now.addingTimeInterval(3600),
            sessionId: sessionId
        )
        return (user, tokens)
    }
}
