import SwiftUI
import Sentry
import PostHog
import FirebaseCore
import FHBAnalytics
import FHBDependencyContainer

@main
struct FanhBApp: App {
    init() {
        configureSentry()
        configurePostHog()
        configureFirebase()
        configureAnalytics()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }

    // MARK: - SDK configuration

    private func configureSentry() {
        let dsn = Bundle.main.infoDictionary?["SentryDSN"] as? String ?? ""
        guard !dsn.isEmpty else { return }
        SentrySDK.start { options in
            options.dsn = dsn
            options.tracesSampleRate = 0.2
            options.enableAutoSessionTracking = true
        }
    }

    private func configurePostHog() {
        let apiKey = Bundle.main.infoDictionary?["PostHogApiKey"] as? String ?? ""
        guard !apiKey.isEmpty else { return }
        let config = PostHogConfig(apiKey: apiKey)
        PostHogSDK.shared.setup(config)
    }

    private func configureFirebase() {
        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            return
        }
        FirebaseApp.configure()
    }

    private func configureAnalytics() {
        AppContainer.shared.analytics.register {
            CompositeEventSink(sinks: [
                SentryEventSink(),
                PostHogEventSink(),
            ]) as any EventSink
        }
    }
}
