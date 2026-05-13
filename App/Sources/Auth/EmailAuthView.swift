import SwiftUI
import FHBDesignSystem

// MARK: - EmailAuthMode

enum EmailAuthMode {
    case signUp
    case signIn
}

// MARK: - EmailAuthView (MO-P1-012)

struct EmailAuthView: View {
    let mode: EmailAuthMode
    @ObservedObject var coordinator: AuthCoordinator
    @ObservedObject var viewModel: AuthViewModel

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var displayName: String = ""
    @State private var emailError: String? = nil
    @State private var passwordError: String? = nil

    private var isSignUp: Bool { mode == .signUp }
    private var title: String { isSignUp ? "Create account" : "Welcome back" }
    private var submitTitle: String { isSignUp ? "Create Account" : "Sign In" }

    var body: some View {
        ZStack {
            FHBColor.canvas.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: FHBSpacing.lg) {
                    header
                    form
                    submitButton
                    if isSignUp {
                        signInPrompt
                    } else {
                        forgotPasswordLink
                    }
                }
                .padding(.horizontal, FHBSpacing.xl)
                .padding(.top, FHBSpacing.xxl)
            }

            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .navigationBarBackButtonHidden(false)
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        ), actions: {
            Button("OK") { viewModel.errorMessage = nil }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(alignment: .leading, spacing: FHBSpacing.xs) {
            Text(title)
                .fhbTextStyle(FHBTypography.displaySM)
                .foregroundStyle(FHBColor.ink)
            Text(isSignUp ? "Start your story together." : "Pick up where you left off.")
                .fhbTextStyle(FHBTypography.bodyMD)
                .foregroundStyle(FHBColor.muted)
        }
    }

    private var form: some View {
        VStack(spacing: FHBSpacing.md) {
            if isSignUp {
                fieldGroup(label: "Your name") {
                    FHBTextInput("e.g. Jamie", text: $displayName)
                }
            }

            fieldGroup(label: "Email", error: emailError) {
                FHBTextInput("you@example.com", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
            }

            fieldGroup(label: "Password", error: passwordError) {
                SecureFieldInput("At least 8 characters", text: $password)
            }
        }
    }

    private func fieldGroup<Content: View>(
        label: String,
        error: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: FHBSpacing.xxs) {
            Text(label)
                .fhbTextStyle(FHBTypography.caption)
                .foregroundStyle(FHBColor.muted)
            content()
            if let error {
                Text(error)
                    .fhbTextStyle(FHBTypography.caption)
                    .foregroundStyle(FHBColor.error)
            }
        }
    }

    private var submitButton: some View {
        FHBPrimaryButton(submitTitle) {
            guard validate() else { return }
            Task {
                if isSignUp {
                    await viewModel.signUp(email: email, password: password, displayName: displayName)
                } else {
                    await viewModel.signIn(email: email, password: password)
                }
            }
        }
        .padding(.top, FHBSpacing.sm)
    }

    private var signInPrompt: some View {
        HStack(spacing: FHBSpacing.xxs) {
            Text("Already have an account?")
                .foregroundStyle(FHBColor.muted)
            Button("Sign in") { coordinator.showEmailLogin() }
                .foregroundStyle(FHBColor.brandPink)
        }
        .fhbTextStyle(FHBTypography.bodySM)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, FHBSpacing.xs)
    }

    private var forgotPasswordLink: some View {
        Button("Forgot password?") {
            coordinator.showForgotPassword()
        }
        .fhbTextStyle(FHBTypography.bodySM)
        .foregroundStyle(FHBColor.brandPink)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, FHBSpacing.xs)
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.25).ignoresSafeArea()
            ProgressView()
                .progressViewStyle(.circular)
                .tint(FHBColor.onPrimary)
                .padding(FHBSpacing.xl)
                .background(FHBColor.ink.opacity(0.8), in: RoundedRectangle(cornerRadius: FHBRounded.lg))
        }
    }

    // MARK: - Validation

    private func validate() -> Bool {
        emailError = nil
        passwordError = nil

        let emailRegex = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            emailError = "Email is required."
        } else if email.range(of: emailRegex, options: .regularExpression) == nil {
            emailError = "Enter a valid email address."
        }

        if password.isEmpty {
            passwordError = "Password is required."
        } else if password.count < 8 {
            passwordError = "Password must be at least 8 characters."
        }

        return emailError == nil && passwordError == nil
    }
}

// MARK: - SecureFieldInput helper

private struct SecureFieldInput: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        SecureField(placeholder, text: $text)
            .fhbTextStyle(FHBTypography.bodyMD)
            .foregroundStyle(FHBColor.ink)
            .frame(height: 44)
            .padding(.horizontal, FHBSpacing.md)
            .background(FHBColor.canvas, in: RoundedRectangle(cornerRadius: FHBRounded.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: FHBRounded.md, style: .continuous)
                    .stroke(FHBColor.hairline, lineWidth: 1)
            )
            .textContentType(.password)
    }
}
