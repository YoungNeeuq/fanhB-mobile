import PostHog
import FHBAnalytics

public actor PostHogEventSink: EventSink {
    public init() {}

    public func track(_ event: AnalyticsEvent) async {
        PostHogSDK.shared.capture(event.name, properties: event.properties)
    }

    public func identify(userId: String, properties: [String: String]) async {
        PostHogSDK.shared.identify(userId, userProperties: properties)
    }

    public func reset() async {
        PostHogSDK.shared.reset()
    }
}
