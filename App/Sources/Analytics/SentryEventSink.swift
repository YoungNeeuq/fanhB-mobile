import Sentry
import FHBAnalytics

public actor SentryEventSink: EventSink {
    public init() {}

    public func track(_ event: AnalyticsEvent) async {
        let crumb = Breadcrumb()
        crumb.category = "analytics"
        crumb.message = event.name
        crumb.data = event.properties
        crumb.level = .info
        SentrySDK.addBreadcrumb(crumb)
    }

    public func identify(userId: String, properties: [String: String]) async {
        let user = Sentry.User(userId: userId)
        user.data = properties
        SentrySDK.setUser(user)
    }

    public func reset() async {
        SentrySDK.setUser(nil)
    }
}
