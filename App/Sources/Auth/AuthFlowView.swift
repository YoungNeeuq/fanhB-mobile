import SwiftUI
import FHBDesignSystem
import DomainAuth

// MARK: - AuthFlowView

struct AuthFlowView: View {
    @ObservedObject var coordinator: AuthCoordinator
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            content
        }
    }

    @ViewBuilder
    private var content: some View {
        switch coordinator.step {
        case .landing:
            AuthLandingView(coordinator: coordinator, viewModel: viewModel)

        case .emailSignUp:
            EmailAuthView(mode: .signUp, coordinator: coordinator, viewModel: viewModel)

        case .emailLogin:
            EmailAuthView(mode: .signIn, coordinator: coordinator, viewModel: viewModel)

        case .otp(let email, let otpType):
            OTPView(email: email, otpType: otpType, viewModel: viewModel)

        case .forgotPassword:
            ForgotPasswordView(coordinator: coordinator, viewModel: viewModel)

        case .done:
            // The parent (RootView) reacts to authStateObserver.isAuthenticated
            // and removes AuthFlowView from the hierarchy when auth completes.
            Color.clear
        }
    }
}

// MARK: - ForgotPasswordView (placeholder)

private struct ForgotPasswordView: View {
    @ObservedObject var coordinator: AuthCoordinator
    @ObservedObject var viewModel: AuthViewModel

    @State private var email: String = ""

    var body: some View {
        ZStack {
            FHBColor.canvas.ignoresSafeArea()

            VStack(alignment: .leading, spacing: FHBSpacing.lg) {
                VStack(alignment: .leading, spacing: FHBSpacing.xs) {
                    Text("Reset password")
                        .fhbTextStyle(FHBTypography.displaySM)
                        .foregroundStyle(FHBColor.ink)
                    Text("We'll email you a code to reset your password.")
                        .fhbTextStyle(FHBTypography.bodyMD)
                        .foregroundStyle(FHBColor.muted)
                }

                VStack(alignment: .leading, spacing: FHBSpacing.xxs) {
                    Text("Email")
                        .fhbTextStyle(FHBTypography.caption)
                        .foregroundStyle(FHBColor.muted)
                    FHBTextInput("you@example.com", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }

                FHBPrimaryButton("Send reset code") {
                    Task {
                        await viewModel.requestOTP(email: email)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, FHBSpacing.xl)
            .padding(.top, FHBSpacing.xxl)
        }
    }
}
