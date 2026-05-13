import Foundation
import FHBFoundation

public protocol APIClientProtocol: Sendable {
    func request<T: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> T
}

public actor APIClient: APIClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let interceptors: [any RequestInterceptor]
    private let baseURL: URL
    private let logger = FHBLogger(category: "APIClient")

    public init(baseURL: URL, interceptors: [any RequestInterceptor] = []) {
        self.baseURL = baseURL
        self.interceptors = interceptors
        self.session = URLSession(configuration: .default)
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            guard let date = ISO8601DateFormatter.fanhb.date(from: string) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ISO8601 date: \(string)")
            }
            return date
        }
    }

    public func request<T: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> T {
        var urlRequest = try endpoint.urlRequest(baseURL: baseURL)
        for interceptor in interceptors {
            urlRequest = try await interceptor.adapt(urlRequest)
        }
        let (data, response) = try await session.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        try validateStatusCode(http, data: data)
        return try decoder.decode(T.self, from: data)
    }

    private func validateStatusCode(_ response: HTTPURLResponse, data: Data) throws {
        switch response.statusCode {
        case 200...299: break
        case 401: throw APIError.unauthorized
        case 404: throw APIError.notFound
        case 422: throw APIError.unprocessableEntity(data)
        default: throw APIError.serverError(response.statusCode, data)
        }
    }
}

public enum APIError: Error, Sendable {
    case invalidResponse
    case unauthorized
    case notFound
    case unprocessableEntity(Data)
    case serverError(Int, Data)
}
