import Foundation

public protocol WSClientProtocol: Actor {
    /// Current connection state.
    var state: WSConnectionState { get }
    /// Async stream of inbound messages. Each new consumer gets the shared stream.
    var messages: AsyncStream<WSMessage> { get }
    /// Async stream of connection state changes.
    var connectionStates: AsyncStream<WSConnectionState> { get }

    func connect(to url: URL) async
    func disconnect()
    func send(_ message: WSMessage) async throws
}
