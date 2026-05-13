import Foundation

public final class AppGroupStore: @unchecked Sendable {
    public static let shared = AppGroupStore()

    private let defaults: UserDefaults?
    public static let suiteName = "group.com.fanhb.shared"

    public init() {
        defaults = UserDefaults(suiteName: Self.suiteName)
    }

    public var latestDrawingThumbnailData: Data? {
        get { defaults?.data(forKey: Keys.latestDrawingThumbnail) }
        set { defaults?.set(newValue, forKey: Keys.latestDrawingThumbnail) }
    }

    public var daysTogetherCount: Int {
        get { defaults?.integer(forKey: Keys.daysTogether) ?? 0 }
        set { defaults?.set(newValue, forKey: Keys.daysTogether) }
    }

    public var streakCount: Int {
        get { defaults?.integer(forKey: Keys.streak) ?? 0 }
        set { defaults?.set(newValue, forKey: Keys.streak) }
    }

    public var hideDrawingPreview: Bool {
        get { defaults?.bool(forKey: Keys.hideDrawingPreview) ?? false }
        set { defaults?.set(newValue, forKey: Keys.hideDrawingPreview) }
    }

    private enum Keys {
        static let latestDrawingThumbnail = "latestDrawingThumbnail"
        static let daysTogether = "daysTogether"
        static let streak = "streak"
        static let hideDrawingPreview = "hideDrawingPreview"
    }
}
