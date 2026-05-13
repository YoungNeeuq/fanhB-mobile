import SwiftUI
import FHBDesignSystem

// MARK: - AuthLandingView (MO-P1-009)

struct AuthLandingView: View {
    @ObservedObject var coordinator: AuthCoordinator
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        ZStack {
            FHBColor.canvas.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                brandSection

                Spacer()

                actionsSection
                    .padding(.bottom, FHBSpacing.xxl)
            }
            .padding(.horizontal, FHBSpacing.xl)

            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        ), actions: {
            Button("OK") { viewModel.errorMessage = nil }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
    }

    // MARK: - Sections

    private var brandSection: some View {
        VStack(spacing: FHBSpacing.md) {
            ZStack {
                Circle()
                    .fill(FHBColor.brandPink.opacity(0.12))
                    .frame(width: 96, height: 96)
                Image(systemName: "heart.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(FHBColor.brandPink)
            }

            Text("FanhB")
                .fhbTextStyle(FHBTypography.displaySM)
                .foregroundStyle(FHBColor.ink)

            Text("Every drawing tells your story")
                .fhbTextStyle(FHBTypography.bodyMD)
                .foregroundStyle(FHBColor.muted)
                .multilineTextAlignment(.center)
        }
    }

    private var actionsSection: some View {
        VStack(spacing: FHBSpacing.sm) {
            AppleSignInButton(viewModel: viewModel)
                .frame(height: 50)

            GoogleSignInButton(viewModel: viewModel)

            dividerRow

            FHBSecondaryButton("Continue with Email") {
                coordinator.showEmailSignUp()
            }

            signInLink
        }
    }

    private var dividerRow: some View {
        HStack(spacing: FHBSpacing.sm) {
            Rectangle()
                .fill(FHBColor.hairline)
                .frame(height: 1)
            Text("or")
                .fhbTextStyle(FHBTypography.caption)
                .foregroundStyle(FHBColor.muted)
            Rectangle()
                .fill(FHBColor.hairline)
                .frame(height: 1)
        }
        .padding(.vertical, FHBSpacing.xs)
    }

    private var signInLink: some View {
        Button {
            coordinator.showEmailLogin()
        } label: {
            HStack(spacing: FHBSpacing.xxs) {
                Text("Already have an account?")
                    .foregroundStyle(FHBColor.muted)
                Text("Sign in")
                    .foregroundStyle(FHBColor.brandPink)
            }
            .fhbTextStyle(FHBTypography.bodySM)
        }
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
}
