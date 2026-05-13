import Foundation

public struct Endpoint: Sendable {
    public let path: String
    public let method: HTTPMethod
    public let headers: [String: String]
    public let body: Data?
    public let queryItems: [URLQueryItem]

    public init(
        path: String,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        body: Data? = nil,
        queryItems: [URLQueryItem] = []
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.body = body
        self.queryItems = queryItems
    }

    func urlRequest(baseURL: URL) throws -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        if !queryItems.isEmpty { components?.queryItems = queryItems }
        guard let url = components?.url else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        if body != nil { request.setValue("application/json", forHTTPHeaderField: "Content-Type") }
        return request
    }
}

public enum HTTPMethod: String, Sendable {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case patch  = "PATCH"
    case delete = "DELETE"
}

// MARK: - Convenience factories

public extension Endpoint {
    /// JSON-encodes an Encodable body and sets Content-Type automatically.
    static func json<B: Encodable & Sendable>(
        path: String,
        method: HTTPMethod,
        body: B,
        headers: [String: String] = [:],
        queryItems: [URLQueryItem] = []
    ) throws -> Endpoint {
        Endpoint(
            path: path,
            method: method,
            headers: headers,
            body: try JSONEncoder().encode(body),
            queryItems: queryItems
        )
    }

    static let health = Endpoint(path: "/_ops/health")
}
