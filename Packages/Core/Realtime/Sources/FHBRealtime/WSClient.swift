import Foundation
import FHBFoundation

public enum WSConnectionState: Sendable, Equatable {
    case disconnected
    case connecting
    case connected
    case reconnecting(attempt: Int)
}

public actor WSClient {
    private var webSocketTask: URLSessionWebSocketTask?
    private let session: URLSession
    private let logger = FHBLogger(category: "WSClient")
    private var connectionState: WSConnectionState = .disconnected
    private var reconnectAttempt = 0
    private let maxReconnectAttempts = 10
    private var messageHandlers: [(WSMessage) -> Void] = []

    public init() {
        self.session = URLSession(configuration: .default)
    }

    public var state: WSConnectionState { connectionState }

    public func connect(to url: URL) async {
        guard connectionState == .disconnected else { return }
        connectionState = .connecting
        reconnectAttempt = 0
        await performConnect(to: url)
    }

    public func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        connectionState = .disconnected
        reconnectAttempt = 0
    }

    public func send(_ message: WSMessage) async throws {
        guard case .connected = connectionState else { throw WSError.notConnected }
        try await webSocketTask?.send(.string(message.encoded))
    }

    public func onMessage(_ handler: @escaping (WSMessage) -> Void) {
        messageHandlers.append(handler)
    }

    private func performConnect(to url: URL) async {
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        connectionState = .connected
        reconnectAttempt = 0
        logger.info("WebSocket connected to \(url.absoluteString)")
        listenForMessages()
        startHeartbeat()
    }

    private func listenForMessages() {
        Task {
            guard let task = webSocketTask else { return }
            do {
                while true {
                    let result = try await task.receive()
                    switch result {
                    case .string(let text):
                        if let message = WSMessage(encoded: text) {
                            messageHandlers.forEach { $0(message) }
                        }
                    case .data(let data):
                        if let text = String(data: data, encoding: .utf8),
                           let message = WSMessage(encoded: text) {
                            messageHandlers.forEach { $0(message) }
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
            while case .connected = connectionState {
                try? await Task.sleep(for: .seconds(25))
                webSocketTask?.sendPing { [weak self] _ in _ = self }
            }
        }
    }

    private func handleDisconnect() async {
        guard reconnectAttempt < maxReconnectAttempts else {
            connectionState = .disconnected
            return
        }
        reconnectAttempt += 1
        connectionState = .reconnecting(attempt: reconnectAttempt)
        let delay = min(0.25 * pow(2.0, Double(reconnectAttempt - 1)), 8.0)
        let jitter = Double.random(in: 0...0.5)
        logger.info("Reconnecting in \(delay + jitter)s (attempt \(reconnectAttempt))")
        try? await Task.sleep(for: .seconds(delay + jitter))
        if let url = webSocketTask?.originalRequest?.url {
            await performConnect(to: url)
        }
    }
}

public struct WSMessage: Sendable {
    public let type: String
    public let payload: [String: any Sendable]

    public init(type: String, payload: [String: any Sendable] = [:]) {
        self.type = type
        self.payload = payload
    }

    var encoded: String {
        let dict: [String: Any] = ["type": type]
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
        self.payload = [:]
    }
}

public enum WSError: Error, Sendable {
    case notConnected
}
