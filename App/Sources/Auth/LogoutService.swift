import Foundation
import FHBNetworking

// MARK: - LogoutService (MO-P1-017)

actor LogoutService {
    private let apiService: AuthAPIService
    private let tokenStore: KeychainTokenStore
    private let authInterceptor: AuthTokenInterceptor

    init(
        apiService: AuthAPIService,
        tokenStore: KeychainTokenStore,
        authInterceptor: AuthTokenInterceptor
    ) {
        self.apiService = apiService
        self.tokenStore = tokenStore
        self.authInterceptor = authInterceptor
    }

    func logout() async throws {
        // Best-effort server-side invalidation; proceed with local cleanup regardless
        try? await apiService.logout()
        await tokenStore.clear()
        await authInterceptor.clearToken()
    }
}
