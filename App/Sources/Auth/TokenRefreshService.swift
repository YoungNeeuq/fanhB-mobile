import Foundation
import FHBNetworking
import DomainAuth

// MARK: - TokenRefreshService (MO-P1-016)

actor TokenRefreshService {
    private let apiService: AuthAPIService
    private let tokenStore: KeychainTokenStore
    private let authInterceptor: AuthTokenInterceptor

    // Single-flight: callers who arrive while a refresh is already running
    // await the same Task rather than firing parallel refresh requests.
    private var activeTask: Task<String, Error>?

    init(
        apiService: AuthAPIService,
        tokenStore: KeychainTokenStore,
        authInterceptor: AuthTokenInterceptor
    ) {
        self.apiService = apiService
        self.tokenStore = tokenStore
        self.authInterceptor = authInterceptor
    }

    func refreshAccessToken() async throws -> String {
        if let task = activeTask {
            return try await task.value
        }

        let task = Task<String, Error> {
            defer { Task { await self.clearActiveTask() } }

            guard let tokens = await tokenStore.loadTokens(),
                  let sessionId = tokens.sessionId else {
                throw AuthError.tokenExpired
            }

            let response = try await apiService.refresh(
                sessionId: sessionId,
                refreshToken: tokens.refreshToken
            )
            let (user, newTokens) = response.toDomain()

            if let existingUser = await tokenStore.loadUser() {
                try await tokenStore.save(tokens: newTokens, user: existingUser)
            } else {
                try await tokenStore.save(tokens: newTokens, user: user)
            }

            await authInterceptor.setToken(newTokens.accessToken)
            return newTokens.accessToken
        }

        activeTask = task
        return try await task.value
    }

    private func clearActiveTask() {
        activeTask = nil
    }
}
