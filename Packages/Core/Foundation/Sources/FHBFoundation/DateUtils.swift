import Foundation

public extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    func daysBetween(_ other: Date) -> Int {
        Calendar.current.dateComponents([.day], from: startOfDay, to: other.startOfDay).day ?? 0
    }

    func formatted(style: DateFormatter.Style) -> String {
        let f = DateFormatter()
        f.dateStyle = style
        f.timeStyle = .none
        return f.string(from: self)
    }
}

public extension ISO8601DateFormatter {
    static let fanhb: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
}
