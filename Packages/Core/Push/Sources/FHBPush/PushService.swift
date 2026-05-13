import UserNotifications
import FHBFoundation

public actor PushService {
    public static let shared = PushService()

    private let center = UNUserNotificationCenter.current()
    private let logger = FHBLogger(category: "Push")

    public func requestAuthorization() async throws -> Bool {
        let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        logger.info("Push authorization granted: \(granted)")
        return granted
    }

    public func currentAuthorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    public func setBadge(count: Int) async {
        do {
            try await center.setBadgeCount(count)
        } catch {
            logger.error("Failed to set badge: \(error.localizedDescription)")
        }
    }
}
