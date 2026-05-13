import Foundation

public protocol EventSink: Sendable {
    func track(_ event: AnalyticsEvent) async
    func identify(userId: String, properties: [String: String]) async
    func reset() async
}

public actor NoOpEventSink: EventSink {
    public init() {}
    public func track(_ event: AnalyticsEvent) async {}
    public func identify(userId: String, properties: [String: String]) async {}
    public func reset() async {}
}

public actor CompositeEventSink: EventSink {
    private let sinks: [any EventSink]

    public init(sinks: [any EventSink]) {
        self.sinks = sinks
    }

    public func track(_ event: AnalyticsEvent) async {
        await withTaskGroup(of: Void.self) { group in
            for sink in sinks {
                group.addTask { await sink.track(event) }
            }
        }
    }

    public func identify(userId: String, properties: [String: String]) async {
        await withTaskGroup(of: Void.self) { group in
            for sink in sinks {
                group.addTask { await sink.identify(userId: userId, properties: properties) }
            }
        }
    }

    public func reset() async {
        await withTaskGroup(of: Void.self) { group in
            for sink in sinks {
                group.addTask { await sink.reset() }
            }
        }
    }
}
