import Foundation
import FHBFoundation

// MARK: - Protocol

public protocol APIClientProtocol: Sendable {
    func request<T: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> T
    func requestVoid(_ endpoint: Endpoint) async throws
}

// MARK: - APIClient

public actor APIClient: APIClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let interceptors: [any RequestInterceptor]
    private let baseURL: URL
    private let logger = FHBLogger(category: "APIClient")
    private let maxAttempts = 5

    public init(baseURL: URL, interceptors: [any RequestInterceptor] = []) {
        self.baseURL = baseURL
        self.interceptors = interceptors
        self.session = URLSession(configuration: .default)
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            guard let date = ISO8601DateFormatter.fanhb.date(from: string) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid ISO8601 date: \(string)"
                )
            }
            return date
        }
    }

    public func request<T: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> T {
        try await execute(endpoint: endpoint) { [decoder] data, _ in
            try decoder.decode(T.self, from: data)
        }
    }

    public func requestVoid(_ endpoint: Endpoint) async throws {
        try await execute(endpoint: endpoint) { _, _ in }
    }

    // MARK: - Private

    private func execute<T>(
        endpoint: Endpoint,
        transform: (Data, HTTPURLResponse) throws -> T
    ) async throws -> T {
        var attempt = 0
        while true {
            var urlRequest = try endpoint.urlRequest(baseURL: baseURL)
            for interceptor in interceptors {
                urlRequest = try await interceptor.adapt(urlRequest)
            }
            do {
                let (data, response) = try await session.data(for: urlRequest)
                guard let http = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                try validateStatusCode(http, data: data)
                return try transform(data, http)
            } catch let error as APIError {
                attempt += 1
                guard attempt < maxAttempts,
                      await shouldRetry(request: urlRequest, error: error, attempt: attempt) else {
                    throw error
                }
                logger.info("Retrying \(endpoint.path) (attempt \(attempt))")
            }
        }
    }

    private func shouldRetry(request: URLRequest, error: APIError, attempt: Int) async -> Bool {
        await withTaskGroup(of: Bool.self) { group in
            for interceptor in interceptors {
                group.addTask {
                    await interceptor.retry(request, dueTo: error, attempt: attempt) == .retry
                }
            }
            var anyRetry = false
            for await result in group { anyRetry = anyRetry || result }
            return anyRetry
        }
    }

    private func validateStatusCode(_ response: HTTPURLResponse, data: Data) throws {
        switch response.statusCode {
        case 200...299: break
        case 401: throw APIError.unauthorized
        case 404: throw APIError.notFound
        case 422: throw APIError.unprocessableEntity(data)
        default:  throw APIError.serverError(response.statusCode, data)
        }
    }
}

// MARK: - APIError

public enum APIError: Error, Sendable {
    case invalidResponse
    case unauthorized
    case notFound
    case unprocessableEntity(Data)
    case serverError(Int, Data)
}
