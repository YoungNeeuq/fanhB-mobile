import Foundation

public enum NudgeType: String, Sendable, CaseIterable {
    case gentle = "gentle"
    case strong = "strong"
    case heartbeat = "heartbeat"
}

public struct Nudge: Identifiable, Sendable, Equatable {
    public let id: String
    public let senderId: String
    public let receiverId: String
    public let type: NudgeType
    public let message: String?
    public let drawingId: String?
    public let sentAt: Date
    public let receivedAt: Date?
}

public enum NudgeError: Error, Sendable {
    case rateLimited(retryAfter: TimeInterval)
    case partnerOffline
    case networkError(Error)
}

public protocol NudgeRepository: Sendable {
    func sendNudge(type: NudgeType, message: String?, drawingId: String?) async throws -> Nudge
    func fetchReceivedNudges(page: Int) async throws -> [Nudge]
    func markNudgeReceived(_ nudgeId: String) async throws
}
