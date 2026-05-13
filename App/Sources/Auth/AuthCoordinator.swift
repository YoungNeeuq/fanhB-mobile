import Foundation
import DomainAuth

// MARK: - AuthStep

enum AuthStep: Equatable {
    case landing
    case emailSignUp
    case emailLogin
    case otp(email: String, otpType: String)
    case forgotPassword
    case done(User)

    static func == (lhs: AuthStep, rhs: AuthStep) -> Bool {
        switch (lhs, rhs) {
        case (.landing, .landing): return true
        case (.emailSignUp, .emailSignUp): return true
        case (.emailLogin, .emailLogin): return true
        case (.forgotPassword, .forgotPassword): return true
        case (.otp(let le, let lt), .otp(let re, let rt)): return le == re && lt == rt
        case (.done(let lu), .done(let ru)): return lu == ru
        default: return false
        }
    }
}

// MARK: - AuthCoordinator

@MainActor
final class AuthCoordinator: ObservableObject {
    @Published private(set) var step: AuthStep = .landing
    private var history: [AuthStep] = []

    func showEmailSignUp() {
        push(.emailSignUp)
    }

    func showEmailLogin() {
        push(.emailLogin)
    }

    func showOTP(email: String, otpType: String) {
        push(.otp(email: email, otpType: otpType))
    }

    func showForgotPassword() {
        push(.forgotPassword)
    }

    func back() {
        guard let previous = history.popLast() else { return }
        step = previous
    }

    func complete(user: User) {
        step = .done(user)
    }

    // MARK: - Private

    private func push(_ newStep: AuthStep) {
        history.append(step)
        step = newStep
    }
}
