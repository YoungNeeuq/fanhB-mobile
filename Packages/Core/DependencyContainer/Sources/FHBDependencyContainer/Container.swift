import Foundation
import Factory
import FHBNetworking
import FHBRealtime
import FHBPersistence
import FHBAppGroupStore
import FHBPush
import FHBAnalytics

// MARK: - AppContainer

public final class AppContainer: SharedContainer {
    public static let shared = AppContainer()
    public var manager = ContainerManager()
    public init() {}
}

// MARK: - Factory registrations

public extension AppContainer {
    var apiClient: Factory<any APIClientProtocol> {
        self {
            APIClient(
                baseURL: URL(string: "https://api.fanhb.app")!,
                interceptors: [self.authInterceptor(), TraceparentInterceptor()]
            )
        }
    }

    var authInterceptor: Factory<AuthTokenInterceptor> {
        self { AuthTokenInterceptor() }.singleton
    }

    var wsClient: Factory<WSClient> {
        self { WSClient() }.singleton
    }

    var persistence: Factory<PersistenceController> {
        self { .shared }
    }

    var appGroupStore: Factory<AppGroupStore> {
        self { .shared }
    }

    var pushService: Factory<PushService> {
        self { .shared }
    }

    // Override in app startup to wire real sinks (Sentry + PostHog).
    // Override in tests to inject a mock/spy.
    var analytics: Factory<any EventSink> {
        self { NoOpEventSink() as any EventSink }.singleton
    }
}
