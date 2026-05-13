import Foundation

// MARK: - RetryDecision

public enum RetryDecision: Sendable {
    case retry
    case doNotRetry
}

// MARK: - RequestInterceptor

public protocol RequestInterceptor: Sendable {
    /// Mutate the outgoing request (add headers, sign, etc.).
    func adapt(_ request: URLRequest) async throws -> URLRequest

    /// Called after a failed attempt. Return `.retry` to re-run the request.
    /// Default implementation always returns `.doNotRetry`.
    func retry(_ request: URLRequest, dueTo error: APIError, attempt: Int) async -> RetryDecision
}

public extension RequestInterceptor {
    func retry(_ request: URLRequest, dueTo error: APIError, attempt: Int) async -> RetryDecision {
        .doNotRetry
    }
}

// MARK: - AuthTokenInterceptor

public actor AuthTokenInterceptor: RequestInterceptor {
    private var accessToken: String?
    /// Returns a fresh access token. Inject to enable 401 → refresh → retry.
    private let tokenRefresher: (@Sendable () async throws -> String)?

    public init(
        accessToken: String? = nil,
        tokenRefresher: (@Sendable () async throws -> String)? = nil
    ) {
        self.accessToken = accessToken
        self.tokenRefresher = tokenRefresher
    }

    public func setToken(_ token: String) {
        accessToken = token
    }

    public func clearToken() {
        accessToken = nil
    }

    public func adapt(_ request: URLRequest) async throws -> URLRequest {
        var r = request
        if let token = accessToken {
            r.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return r
    }

    public func retry(_ request: URLRequest, dueTo error: APIError, attempt: Int) async -> RetryDecision {
        guard case .unauthorized = error, attempt == 1, let refresher = tokenRefresher else {
            return .doNotRetry
        }
        do {
            accessToken = try await refresher()
            return .retry
        } catch {
            accessToken = nil
            return .doNotRetry
        }
    }
}

// MARK: - TraceparentInterceptor

public struct TraceparentInterceptor: RequestInterceptor {
    public init() {}

    public func adapt(_ request: URLRequest) async throws -> URLRequest {
        var r = request
        let traceId = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        let spanId = String(traceId.prefix(16))
        r.setValue("00-\(traceId)-\(spanId)-01", forHTTPHeaderField: "traceparent")
        return r
    }
}

// MARK: - RetryInterceptor

/// Retries on 5xx server errors with exponential back-off.
public struct RetryInterceptor: RequestInterceptor {
    private let maxAttempts: Int
    private let baseDelay: TimeInterval

    public init(maxAttempts: Int = 3, baseDelay: TimeInterval = 0.5) {
        self.maxAttempts = maxAttempts
        self.baseDelay = baseDelay
    }

    public func adapt(_ request: URLRequest) async throws -> URLRequest { request }

    public func retry(_ request: URLRequest, dueTo error: APIError, attempt: Int) async -> RetryDecision {
        guard attempt < maxAttempts, case .serverError(let code, _) = error, code >= 500 else {
            return .doNotRetry
        }
        let delay = baseDelay * pow(2.0, Double(attempt - 1))
        try? await Task.sleep(for: .seconds(delay))
        return .retry
    }
}
