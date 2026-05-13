import Foundation

public protocol RequestInterceptor: Sendable {
    func adapt(_ request: URLRequest) async throws -> URLRequest
}

public actor AuthTokenInterceptor: RequestInterceptor {
    private var accessToken: String?

    public init(accessToken: String? = nil) {
        self.accessToken = accessToken
    }

    public func setToken(_ token: String) {
        accessToken = token
    }

    public func adapt(_ request: URLRequest) async throws -> URLRequest {
        var r = request
        if let token = accessToken {
            r.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return r
    }
}

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
