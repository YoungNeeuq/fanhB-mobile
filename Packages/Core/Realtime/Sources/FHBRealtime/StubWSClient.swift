import Foundation

/// In-memory stub for use in SwiftUI previews and unit tests.
///
/// Usage:
///   let stub = StubWSClient()
///   await stub.connect(to: URL(string: "wss://example.com")!)
///   await stub.inject(message: WSMessage(type: "canvas:stroke", payload: ["x": "10"]))
public actor StubWSClient: WSClientProtocol {
    public let messages: AsyncStream<WSMessage>
    public let connectionStates: AsyncStream<WSConnectionState>

    private let messageContinuation: AsyncStream<WSMessage>.Continuation
    private let stateContinuation: AsyncStream<WSConnectionState>.Continuation
    private var _state: WSConnectionState = .disconnected

    public var state: WSConnectionState { _state }

    public init() {
        let (msgStream, msgCont) = AsyncStream<WSMessage>.makeStream()
        let (stateStream, stateCont) = AsyncStream<WSConnectionState>.makeStream()
        messages = msgStream
        connectionStates = stateStream
        messageContinuation = msgCont
        stateContinuation = stateCont
    }

    public func connect(to url: URL) async {
        _state = .connected
        stateContinuation.yield(.connected)
    }

    public func disconnect() {
        _state = .disconnected
        stateContinuation.yield(.disconnected)
    }

    public func send(_ message: WSMessage) async throws {
        // no-op — inspect sent messages via a custom recording if needed in tests
    }

    /// Push a message into the stream as if it arrived from the server.
    public func inject(message: WSMessage) {
        messageContinuation.yield(message)
    }
}
