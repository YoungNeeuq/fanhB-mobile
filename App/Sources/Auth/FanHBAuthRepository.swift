import Foundation
import DomainAuth
import FHBNetworking

// MARK: - FanHBAuthRepository

actor FanHBAuthRepository: AuthRepository {
    private let apiService: AuthAPIService
    private let firebaseRepo: FirebaseAuthRepository
    private let tokenStore: KeychainTokenStore

    init(
        apiService: AuthAPIService,
        firebaseRepo: FirebaseAuthRepository,
        tokenStore: KeychainTokenStore
    ) {
        self.apiService = apiService
        self.firebaseRepo = firebaseRepo
        self.tokenStore = tokenStore
    }

    // MARK: - AuthRepository

    func signIn(email: String, password: String) async throws -> (User, AuthTokens) {
        do {
            let response = try await apiService.login(email: email, password: password)
            let (user, tokens) = response.toDomain()
            try await tokenStore.save(tokens: tokens, user: user)
            return (user, tokens)
        } catch let error as APIError {
            throw mapAPIError(error)
        }
    }

    func signUp(email: String, password: String, displayName: String) async throws -> (User, AuthTokens) {
        do {
            let response = try await apiService.signup(email: email, password: password, displayName: displayName)
            let (user, tokens) = response.toDomain()
            try await tokenStore.save(tokens: tokens, user: user)
            return (user, tokens)
        } catch let error as APIError {
            throw mapAPIError(error)
        }
    }

    func signInWithApple(identityToken: String) async throws -> (User, AuthTokens) {
        // Exchange Apple identity token through Firebase first to get a Firebase ID token,
        // then pass that to the FanHB backend social auth endpoint.
        let (_, firebaseTokens) = try await firebaseRepo.signInWithApple(identityToken: identityToken)
        do {
            let response = try await apiService.social(provider: "apple", idToken: firebaseTokens.accessToken)
            let (user, tokens) = response.toDomain()
            try await tokenStore.save(tokens: tokens, user: user)
            return (user, tokens)
        } catch let error as APIError {
            throw mapAPIError(error)
        }
    }

    func signInWithGoogle(idToken: String) async throws -> (User, AuthTokens) {
        // idToken here is the Firebase ID token obtained after GIDSignIn → Firebase credential exchange
        do {
            let response = try await apiService.social(provider: "google", idToken: idToken)
            let (user, tokens) = response.toDomain()
            try await tokenStore.save(tokens: tokens, user: user)
            return (user, tokens)
        } catch let error as APIError {
            throw mapAPIError(error)
        }
    }

    func signOut() async throws {
        do {
            try await apiService.logout()
        } catch {
            // Proceed with local cleanup even if the network call fails
        }
        await tokenStore.clear()
        try? await firebaseRepo.signOut()
    }

    func refreshTokens(_ tokens: AuthTokens) async throws -> AuthTokens {
        guard let sessionId = tokens.sessionId else {
            throw AuthError.tokenExpired
        }
        do {
            let response = try await apiService.refresh(sessionId: sessionId, refreshToken: tokens.refreshToken)
            let (user, newTokens) = response.toDomain()
            if let existingUser = await tokenStore.loadUser() {
                try await tokenStore.save(tokens: newTokens, user: existingUser)
            } else {
                try await tokenStore.save(tokens: newTokens, user: user)
            }
            return newTokens
        } catch let error as APIError {
            throw mapAPIError(error)
        }
    }

    func currentUser() async throws -> User? {
        await tokenStore.loadUser()
    }

    // MARK: - OTP

    func requestOTP(email: String) async throws {
        do {
            try await apiService.requestOTP(email: email)
        } catch let error as APIError {
            throw mapAPIError(error)
        }
    }

    func verifyOTP(email: String, code: String, type: String) async throws -> Bool {
        do {
            let response = try await apiService.verifyOTP(email: email, code: code, type: type)
            return response.verified
        } catch let error as APIError {
            throw mapAPIError(error)
        }
    }

    // MARK: - Private

    private func mapAPIError(_ error: APIError) -> AuthError {
        switch error {
        case .unauthorized:
            return .tokenExpired
        case .notFound:
            return .userNotFound
        default:
            return .networkError(error)
        }
    }
}
