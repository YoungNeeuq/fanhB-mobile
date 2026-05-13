import Foundation
import DomainAuth

@MainActor
final class AuthStateObserver: ObservableObject {
    @Published var user: User? = nil
    @Published var isAuthenticated: Bool = false
    @Published var needsProfileSetup: Bool = false

    func checkStoredSession() {
        let tokenStore = KeychainTokenStore.shared
        Task {
            let tokens = await tokenStore.loadTokens()
            let storedUser = await tokenStore.loadUser()

            guard let tokens, let storedUser, !tokens.isExpired else {
                user = nil
                isAuthenticated = false
                return
            }

            user = storedUser
            isAuthenticated = true
        }
    }

    func onAuthSuccess(user: User, tokens: AuthTokens) {
        self.user = user
        self.isAuthenticated = true
        Task {
            try? await KeychainTokenStore.shared.save(tokens: tokens, user: user)
        }
    }

    func onLogout() {
        user = nil
        isAuthenticated = false
        needsProfileSetup = false
        Task {
            await KeychainTokenStore.shared.clear()
        }
    }

    func markProfileSetupNeeded() {
        needsProfileSetup = true
    }

    func markProfileSetupComplete() {
        needsProfileSetup = false
    }
}
