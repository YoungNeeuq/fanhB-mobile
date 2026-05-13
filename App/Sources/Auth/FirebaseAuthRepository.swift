import FirebaseAuth
import DomainAuth

public final class FirebaseAuthRepository: AuthRepository, @unchecked Sendable {
    public init() {}

    public func signIn(email: String, password: String) async throws -> (DomainAuth.User, AuthTokens) {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return try await map(result.user)
        } catch {
            throw mapError(error)
        }
    }

    public func signInWithApple(identityToken: String) async throws -> (DomainAuth.User, AuthTokens) {
        // Nonce is generated in the UI layer by AppleAuthCoordinator (Phase 1)
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: identityToken,
            rawNonce: ""
        )
        do {
            let result = try await Auth.auth().signIn(with: credential)
            return try await map(result.user)
        } catch {
            throw mapError(error)
        }
    }

    public func signInWithGoogle(idToken: String) async throws -> (DomainAuth.User, AuthTokens) {
        // accessToken is obtained by GIDSignIn in the UI layer (Phase 1)
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: "")
        do {
            let result = try await Auth.auth().signIn(with: credential)
            return try await map(result.user)
        } catch {
            throw mapError(error)
        }
    }

    public func signUp(email: String, password: String, displayName: String) async throws -> (DomainAuth.User, AuthTokens) {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()
            return try await map(result.user)
        } catch {
            throw mapError(error)
        }
    }

    public func signOut() async throws {
        do {
            try Auth.auth().signOut()
        } catch {
            throw mapError(error)
        }
    }

    public func refreshTokens(_ tokens: AuthTokens) async throws -> AuthTokens {
        guard let fbUser = Auth.auth().currentUser else { throw AuthError.userNotFound }
        do {
            let idToken = try await fbUser.getIDToken(forcingRefresh: true)
            return AuthTokens(
                accessToken: idToken,
                refreshToken: fbUser.refreshToken ?? tokens.refreshToken,
                expiresAt: .now.addingTimeInterval(3600),
                sessionId: tokens.sessionId
            )
        } catch {
            throw mapError(error)
        }
    }

    public func currentUser() async throws -> DomainAuth.User? {
        guard let fbUser = Auth.auth().currentUser else { return nil }
        return DomainAuth.User(
            id: fbUser.uid,
            email: fbUser.email ?? "",
            displayName: fbUser.displayName ?? "",
            createdAt: fbUser.metadata.creationDate ?? .now
        )
    }

    private func map(_ fbUser: FirebaseAuth.User) async throws -> (DomainAuth.User, AuthTokens) {
        let idToken = try await fbUser.getIDToken()
        let user = DomainAuth.User(
            id: fbUser.uid,
            email: fbUser.email ?? "",
            displayName: fbUser.displayName ?? "",
            createdAt: fbUser.metadata.creationDate ?? .now
        )
        let tokens = AuthTokens(
            accessToken: idToken,
            refreshToken: fbUser.refreshToken ?? "",
            expiresAt: .now.addingTimeInterval(3600),
            sessionId: nil
        )
        return (user, tokens)
    }

    private func mapError(_ error: Error) -> AuthError {
        guard let code = AuthErrorCode(rawValue: (error as NSError).code) else {
            return .networkError(error)
        }
        switch code {
        case .wrongPassword, .invalidEmail, .invalidCredential:
            return .invalidCredentials
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .userNotFound:
            return .userNotFound
        case .networkError:
            return .networkError(error)
        default:
            return .networkError(error)
        }
    }
}
