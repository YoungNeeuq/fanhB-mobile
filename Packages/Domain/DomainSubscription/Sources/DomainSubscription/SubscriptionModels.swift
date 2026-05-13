import Foundation

public enum SubscriptionPlan: String, Sendable, CaseIterable {
    case free
    case premiumMonthly = "com.fanhb.premium.monthly"
    case premiumYearly = "com.fanhb.premium.yearly"
}

public struct Subscription: Sendable, Equatable {
    public let plan: SubscriptionPlan
    public let expiresAt: Date?
    public let isActive: Bool
    public let autoRenews: Bool
}

public enum SubscriptionError: Error, Sendable {
    case purchaseFailed(Error)
    case restoreFailed(Error)
    case verificationFailed
    case networkError(Error)
}

public protocol SubscriptionRepository: Sendable {
    func fetchCurrentSubscription() async throws -> Subscription
    func purchase(plan: SubscriptionPlan) async throws -> Subscription
    func restore() async throws -> Subscription
    func verifyReceipt() async throws -> Subscription
}
