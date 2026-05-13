import SwiftUI
import FHBDesignSystem
import FHBDependencyContainer

struct RootView: View {
    @StateObject private var deepLinkRouter = DeepLinkRouter()
    @StateObject private var onboardingCoordinator = OnboardingCoordinator()
    @StateObject private var authStateObserver = AuthStateObserver()
    @StateObject private var authCoordinator = AuthCoordinator()
    @StateObject private var profileViewModel = ProfileViewModel(
        apiClient: AppContainer.shared.apiClient()
    )

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasCompletedProfileSetup") private var hasCompletedProfileSetup = false
    @State private var splashVisible = true

    var body: some View {
        ZStack {
            if splashVisible {
                SplashView()
                    .transition(.opacity)
            } else if !hasCompletedOnboarding {
                onboardingFlow
                    .transition(.opacity)
            } else if !authStateObserver.isAuthenticated {
                AuthFlowContainer(
                    coordinator: authCoordinator,
                    stateObserver: authStateObserver
                )
                .transition(.opacity)
            } else if authStateObserver.needsProfileSetup && !hasCompletedProfileSetup {
                profileSetupFlow
                    .transition(.opacity)
            } else {
                mainContent
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: splashVisible)
        .animation(.easeInOut(duration: 0.35), value: hasCompletedOnboarding)
        .animation(.easeInOut(duration: 0.35), value: authStateObserver.isAuthenticated)
        .animation(.easeInOut(duration: 0.35), value: authStateObserver.needsProfileSetup)
        .task {
            authStateObserver.checkStoredSession()
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            splashVisible = false
        }
        .onOpenURL { url in
            deepLinkRouter.handle(url: url)
        }
        .onChange(of: onboardingCoordinator.step) { _, step in
            if step == .done { hasCompletedOnboarding = true }
        }
        .environmentObject(deepLinkRouter)
        .environmentObject(authStateObserver)
    }

    // MARK: - Flows

    @ViewBuilder
    private var onboardingFlow: some View {
        switch onboardingCoordinator.step {
        case .carousel:
            OnboardingCarouselView(coordinator: onboardingCoordinator)
        case .tutorial:
            DrawingTutorialView(coordinator: onboardingCoordinator)
        case .done:
            mainContent
        }
    }

    private var profileSetupFlow: some View {
        CreateProfileView(
            profileViewModel: profileViewModel,
            onComplete: {
                hasCompletedProfileSetup = true
                authStateObserver.markProfileSetupComplete()
            }
        )
    }

    private var mainContent: some View {
        ZStack {
            FHBColor.canvas.ignoresSafeArea()
            VStack(spacing: FHBSpacing.lg) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(FHBColor.brandPink)
                Text("FanhB")
                    .fhbTextStyle(FHBTypography.displaySM)
                    .foregroundStyle(FHBColor.ink)
                Text("More coming soon…")
                    .fhbTextStyle(FHBTypography.bodySM)
                    .foregroundStyle(FHBColor.muted)
            }
        }
    }
}

// MARK: - AuthFlowContainer
// Holds AuthViewModel as a StateObject to preserve it across re-renders.

private struct AuthFlowContainer: View {
    @ObservedObject var coordinator: AuthCoordinator
    @ObservedObject var stateObserver: AuthStateObserver

    @StateObject private var viewModel: AuthViewModelWrapper

    init(coordinator: AuthCoordinator, stateObserver: AuthStateObserver) {
        self.coordinator = coordinator
        self.stateObserver = stateObserver
        _viewModel = StateObject(wrappedValue: AuthViewModelWrapper(
            coordinator: coordinator,
            stateObserver: stateObserver
        ))
    }

    var body: some View {
        AuthFlowView(coordinator: coordinator, viewModel: viewModel.authViewModel)
    }
}

@MainActor
private final class AuthViewModelWrapper: ObservableObject {
    let authViewModel: AuthViewModel

    init(coordinator: AuthCoordinator, stateObserver: AuthStateObserver) {
        authViewModel = AuthViewModel(
            repository: AppDependencies.authRepository,
            stateObserver: stateObserver,
            coordinator: coordinator
        )
    }
}

#Preview {
    RootView()
}
