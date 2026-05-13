import Foundation
import DomainAuth

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let repository: FanHBAuthRepository
    private let stateObserver: AuthStateObserver
    private let coordinator: AuthCoordinator

    init(
        repository: FanHBAuthRepository,
        stateObserver: AuthStateObserver,
        coordinator: AuthCoordinator
    ) {
        self.repository = repository
        self.stateObserver = stateObserver
        self.coordinator = coordinator
    }

    // MARK: - Auth actions

    func signInWithApple(appleIdentityToken: String, nonce: String) async {
        await perform {
            let (user, tokens) = try await self.repository.signInWithApple(identityToken: appleIdentityToken)
            self.stateObserver.onAuthSuccess(user: user, tokens: tokens)
            self.coordinator.complete(user: user)
        }
    }

    func signInWithGoogle(firebaseIdToken: String) async {
        await perform {
            let (user, tokens) = try await self.repository.signInWithGoogle(idToken: firebaseIdToken)
            self.stateObserver.onAuthSuccess(user: user, tokens: tokens)
            self.coordinator.complete(user: user)
        }
    }

    func signIn(email: String, password: String) async {
        await perform {
            let (user, tokens) = try await self.repository.signIn(email: email, password: password)
            self.stateObserver.onAuthSuccess(user: user, tokens: tokens)
            self.coordinator.complete(user: user)
        }
    }

    func signUp(email: String, password: String, displayName: String) async {
        await perform {
            let (user, tokens) = try await self.repository.signUp(
                email: email,
                password: password,
                displayName: displayName
            )
            self.stateObserver.onAuthSuccess(user: user, tokens: tokens)
            self.stateObserver.markProfileSetupNeeded()
            self.coordinator.complete(user: user)
        }
    }

    func requestOTP(email: String) async {
        await perform {
            try await self.repository.requestOTP(email: email)
            self.coordinator.showOTP(email: email, otpType: "verify")
        }
    }

    func verifyOTP(email: String, code: String, type: String) async {
        await perform {
            let verified = try await self.repository.verifyOTP(email: email, code: code, type: type)
            if verified, let user = await self.repository.currentUser() {
                let tokens = await KeychainTokenStore.shared.loadTokens()
                if let tokens {
                    self.stateObserver.onAuthSuccess(user: user, tokens: tokens)
                }
                self.coordinator.complete(user: user)
            }
        }
    }

    func logout() async {
        await perform {
            try await self.repository.signOut()
            self.stateObserver.onLogout()
        }
    }

    // MARK: - Private

    private func perform(_ block: @escaping () async throws -> Void) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await block()
        } catch let error as AuthError {
            errorMessage = errorMessage(for: error)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func errorMessage(for error: AuthError) -> String {
        switch error {
        case .invalidCredentials:
            return "Incorrect email or password."
        case .emailAlreadyInUse:
            return "An account with this email already exists."
        case .userNotFound:
            return "No account found with this email."
        case .tokenExpired:
            return "Your session has expired. Please sign in again."
        case .networkError:
            return "A network error occurred. Please try again."
        }
    }
}
