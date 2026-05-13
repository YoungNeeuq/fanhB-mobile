import Foundation

public extension Result {
    var value: Success? {
        guard case .success(let v) = self else { return nil }
        return v
    }

    var error: Failure? {
        guard case .failure(let e) = self else { return nil }
        return e
    }

    var isSuccess: Bool { value != nil }
}
