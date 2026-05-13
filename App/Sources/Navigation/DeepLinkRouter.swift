import Foundation

// MO-P1-002 — Deep-link router (URL → coordinator)

enum DeepLink: Equatable, Sendable {
    case invite(code: String)
    case drawing(id: String)
    case nudge
    case home
}

@MainActor
final class DeepLinkRouter: ObservableObject {
    @Published private(set) var pendingLink: DeepLink?

    func handle(url: URL) {
        pendingLink = route(url)
    }

    func consume() -> DeepLink? {
        defer { pendingLink = nil }
        return pendingLink
    }

    private func route(_ url: URL) -> DeepLink? {
        switch url.scheme {
        case "https", "http": return routeUniversal(url)
        case "fanhb":         return routeCustomScheme(url)
        default:              return nil
        }
    }

    // https://fanhb.app/invite/ABC123
    // https://fanhb.app/drawing/xyz
    private func routeUniversal(_ url: URL) -> DeepLink? {
        let parts = url.pathComponents.filter { $0 != "/" }
        guard let first = parts.first else { return .home }
        switch first {
        case "invite":  return parts.dropFirst().first.map { .invite(code: $0) }
        case "drawing": return parts.dropFirst().first.map { .drawing(id: $0) }
        default:        return .home
        }
    }

    // fanhb://invite/ABC123
    // fanhb://invite?code=ABC123
    // fanhb://drawing/xyz
    // fanhb://nudge
    private func routeCustomScheme(_ url: URL) -> DeepLink? {
        let host = url.host ?? ""
        let pathParts = url.pathComponents.filter { $0 != "/" }
        switch host {
        case "invite":
            if let code = pathParts.first { return .invite(code: code) }
            return queryItem("code", in: url).map { .invite(code: $0) }
        case "drawing":
            return pathParts.first.map { .drawing(id: $0) }
        case "nudge":
            return .nudge
        default:
            return .home
        }
    }

    private func queryItem(_ name: String, in url: URL) -> String? {
        URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first(where: { $0.name == name })?
            .value
    }
}
