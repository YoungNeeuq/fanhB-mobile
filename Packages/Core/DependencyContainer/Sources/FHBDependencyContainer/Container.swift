import Foundation
import FHBNetworking
import FHBRealtime
import FHBPersistence
import FHBAppGroupStore
import FHBPush
import FHBAnalytics

@MainActor
public final class AppContainer {
    public static let shared = AppContainer()

    public lazy var apiClient: any APIClientProtocol = APIClient(
        baseURL: URL(string: "https://api.fanhb.app")!,
        interceptors: [authInterceptor, TraceparentInterceptor()]
    )

    public let authInterceptor = AuthTokenInterceptor()
    public let wsClient = WSClient()
    public let persistence = PersistenceController.shared
    public let appGroupStore = AppGroupStore.shared
    public let pushService = PushService.shared
    public var analytics: any EventSink = NoOpEventSink()
}
