import Foundation
import FHBNetworking
import FHBDependencyContainer
import DomainAuth

// MARK: - AppDependencies

enum AppDependencies {
    private static var _authRepository: FanHBAuthRepository?
    private static var _tokenRefreshService: TokenRefreshService?

    static func configure(container: AppContainer) {
        let authInterceptor = container.authInterceptor()

        // Load any previously saved token into the interceptor immediately so
        // the first authenticated request after a cold launch doesn't 401.
        if let stored = KeychainTokenStore.shared.loadTokensSync(),
           !stored.isExpired {
            Task { await authInterceptor.setToken(stored.accessToken) }
        }

        let apiService = AuthAPIService(apiClient: container.apiClient())
        let firebaseRepo = FirebaseAuthRepository()
        let tokenStore = KeychainTokenStore.shared

        let refreshService = TokenRefreshService(
            apiService: apiService,
            tokenStore: tokenStore,
            authInterceptor: authInterceptor
        )
        _tokenRefreshService = refreshService

        // Wire the refresher closure into a new interceptor instance with
        // token refresh support. The factory re-creates the interceptor so
        // we swap the singleton registration before first real use.
        let wiredInterceptor = AuthTokenInterceptor(
            accessToken: KeychainTokenStore.shared.loadTokensSync()?.accessToken,
            tokenRefresher: { [refreshService] in
                try await refreshService.refreshAccessToken()
            }
        )
        container.authInterceptor.register { wiredInterceptor }

        _authRepository = FanHBAuthRepository(
            apiService: apiService,
            firebaseRepo: firebaseRepo,
            tokenStore: tokenStore
        )
    }

    static var authRepository: FanHBAuthRepository {
        guard let repo = _authRepository else {
            fatalError("AppDependencies.configure(container:) must be called before accessing authRepository")
        }
        return repo
    }

    static var tokenStore: KeychainTokenStore { .shared }
}
