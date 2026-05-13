import Foundation

public struct Streak: Sendable, Equatable {
    public let currentCount: Int
    public let longestCount: Int
    public let lastActivityDate: Date?
    public let freezeTokensAvailable: Int
}

public struct Achievement: Identifiable, Sendable, Equatable {
    public let id: String
    public let title: String
    public let description: String
    public let iconName: String
    public let unlockedAt: Date?
    public var isUnlocked: Bool { unlockedAt != nil }
}

public protocol GamificationRepository: Sendable {
    func fetchStreak(coupleId: String) async throws -> Streak
    func fetchAchievements(userId: String) async throws -> [Achievement]
    func useStreakFreeze(coupleId: String) async throws -> Streak
}
