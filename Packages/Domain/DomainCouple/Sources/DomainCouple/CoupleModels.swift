import Foundation

public struct Couple: Identifiable, Sendable, Equatable {
    public let id: String
    public let partnerId: String
    public let partnerDisplayName: String
    public let partnerAvatarURL: URL?
    public let anniversaryDate: Date?
    public let accentColorHex: String
    public let inviteCode: String
    public let createdAt: Date

    public var daysTogetherCount: Int {
        guard let anniversary = anniversaryDate else { return 0 }
        return max(0, Calendar.current.dateComponents([.day], from: anniversary, to: .now).day ?? 0)
    }
}

public enum CoupleError: Error, Sendable {
    case inviteCodeNotFound
    case alreadyConnected
    case partnerNotFound
    case networkError(Error)
}

public protocol CoupleRepository: Sendable {
    func generateInviteCode() async throws -> String
    func connectWithCode(_ code: String) async throws -> Couple
    func fetchCurrentCouple() async throws -> Couple?
    func updateAnniversary(_ date: Date) async throws -> Couple
}
