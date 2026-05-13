import Foundation

/// In-memory stub for use in SwiftUI previews and unit tests.
///
/// Usage:
///   let stub = StubAPIClient()
///   stub.stub(path: "/_ops/health", with: HealthResponse(status: "ok"))
///   stub.stub(path: "/users/me", throwing: APIError.unauthorized)
public actor StubAPIClient: APIClientProtocol {
    private var responses: [String: Any] = [:]
    private var errors: [String: Error] = [:]

    public init() {}

    /// Register a canned success response for a given path.
    public func stub<T: Sendable>(path: String, with response: T) {
        responses[path] = response
    }

    /// Register a canned error for a given path.
    public func stub(path: String, throwing error: Error) {
        errors[path] = error
    }

    public func request<T: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> T {
        if let error = errors[endpoint.path] { throw error }
        guard let value = responses[endpoint.path] as? T else { throw APIError.notFound }
        return value
    }

    public func requestVoid(_ endpoint: Endpoint) async throws {
        if let error = errors[endpoint.path] { throw error }
    }
}
