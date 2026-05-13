import Foundation

public enum AnalyticsEvent: Sendable {
    case onboardingComplete
    case coupleConnected(coupleId: String)
    case firstDrawingSent
    case drawingSent(drawingId: String)
    case drawingReceived(drawingId: String)
    case nudgeSent
    case nudgeReceived
    case streakReached(days: Int)
    case paywallViewed(source: String)
    case subscriptionStarted(plan: String)
    case subscriptionCancelled(plan: String)

    public var name: String {
        switch self {
        case .onboardingComplete: return "onboarding_complete"
        case .coupleConnected: return "couple_connected"
        case .firstDrawingSent: return "first_drawing_sent"
        case .drawingSent: return "drawing_sent"
        case .drawingReceived: return "drawing_received"
        case .nudgeSent: return "nudge_sent"
        case .nudgeReceived: return "nudge_received"
        case .streakReached: return "streak_reached"
        case .paywallViewed: return "paywall_viewed"
        case .subscriptionStarted: return "subscription_started"
        case .subscriptionCancelled: return "subscription_cancelled"
        }
    }

    public var properties: [String: String] {
        switch self {
        case .coupleConnected(let id): return ["couple_id": id]
        case .drawingSent(let id): return ["drawing_id": id]
        case .drawingReceived(let id): return ["drawing_id": id]
        case .streakReached(let days): return ["days": "\(days)"]
        case .paywallViewed(let source): return ["source": source]
        case .subscriptionStarted(let plan): return ["plan": plan]
        case .subscriptionCancelled(let plan): return ["plan": plan]
        default: return [:]
        }
    }
}
