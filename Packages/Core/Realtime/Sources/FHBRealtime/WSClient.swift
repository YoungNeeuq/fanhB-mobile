import Foundation
import FHBFoundation

// MARK: - Types

public enum WSConnectionState: Sendable, Equatable {
    case disconnected
    case connecting
    case connected
    case reconnecting(attempt: Int)
}

public struct WSMessage: Sendable {
    public let type: String
    public let payload: [String: String]

    public init(type: String, payload: [String: String] = [:]) {
        self.type = type
        self.payload = payload
    }

    var encoded: String {
        var dict: [String: Any] = ["type": type]
        if !payload.isEmpty { dict["payload"] = payload }
        let data = (try? JSONSerialization.data(withJSONObject: dict)) ?? Data()
        return String(decoding: data, as: UTF8.self)
    }

    init?(encoded: String) {
        guard
            let data = encoded.data(using: .utf8),
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let type = dict["type"] as? String
        else { return nil }
        self.type = type
        self.payload = (dict["payload"] as? [String: String]) ?? [:]
    }
}

public enum WSError: Error, Sendable {
    case notConnected
}

// MARK: - WSClient

public actor WSClient: WSClientProtocol {
    public let messages: AsyncStream<WSMessage>
    public let connectionStates: AsyncStream<WSConnectionState>

    private let messageContinuation: AsyncStream<WSMessage>.Continuation
    private let stateContinuation: AsyncStream<WSConnectionState>.Continuation
    private let session: URLSession
    private let logger = FHBLogger(category: "WSClient")
    private let maxReconnectAttempts = 10

    private var webSocketTask: URLSessionWebSocketTask?
    private var reconnectAttempt = 0
    private var _state: WSConnectionState = .disconnected

    public var state: WSConnectionState { _state }

    public init() {
        let (msgStream, msgCont) = AsyncStream<WSMessage>.makeStream()
        let (stateStream, stateCont) = AsyncStream<WSConnectionState>.makeStream()
        messages = msgStream
        connectionStates = stateStream
        messageContinuation = msgCont
        stateContinuation = stateCont
        session = URLSession(configuration: .default)
    }

    // MARK: - Public interface

    public func connect(to url: URL) async {
        guard _state == .disconnected else { return }
        reconnectAttempt = 0
        await performConnect(to: url)
    }

    public func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        transition(to: .disconnected)
        reconnectAttempt = 0
    }

    public func send(_ message: WSMessage) async throws {
        guard case .connected = _state else { throw WSError.notConnected }
        try await webSocketTask?.send(.string(message.encoded))
    }

    // MARK: - Private

    private func performConnect(to url: URL) async {
        transition(to: .connecting)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        transition(to: .connected)
        reconnectAttempt = 0
        logger.info("WebSocket connected to \(url.absoluteString)")
        listenForMessages()
        startHeartbeat()
    }

    private func transition(to newState: WSConnectionState) {
        _state = newState
        stateContinuation.yield(newState)
    }

    private func listenForMessages() {
        Task {
            guard let task = webSocketTask else { return }
            do {
                while true {
                    let result = try await task.receive()
                    switch result {
                    case .string(let text):
                        if let msg = WSMessage(encoded: text) { messageContinuation.yield(msg) }
                    case .data(let data):
                        if let text = String(data: data, encoding: .utf8),
                           let msg = WSMessage(encoded: text) {
                            messageContinuation.yield(msg)
                        }
                    @unknown default:
                        break
                    }
                }
            } catch {
                logger.warning("WebSocket receive error: \(error.localizedDescription)")
                await handleDisconnect()
            }
        }
    }

    private func startHeartbeat() {
        Task {
            while case .connected = _state {
                try? await Task.sleep(for: .seconds(25))
                webSocketTask?.sendPing { _ in }
            }
        }
    }

    private func handleDisconnect() async {
        guard reconnectAttempt < maxReconnectAttempts else {
            transition(to: .disconnected)
            return
        }
        reconnectAttempt += 1
        transition(to: .reconnecting(attempt: reconnectAttempt))
        let delay = min(0.25 * pow(2.0, Double(reconnectAttempt - 1)), 8.0)
        let jitter = Double.random(in: 0...0.5)
        logger.info("Reconnecting in \(String(format: "%.2f", delay + jitter))s (attempt \(reconnectAttempt))")
        try? await Task.sleep(for: .seconds(delay + jitter))
        if let url = webSocketTask?.originalRequest?.url {
            await performConnect(to: url)
        }
    }
}
