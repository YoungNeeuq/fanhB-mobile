import SwiftUI
import FHBDesignSystem

struct RootView: View {
    @StateObject private var deepLinkRouter = DeepLinkRouter()
    @StateObject private var onboardingCoordinator = OnboardingCoordinator()

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var splashVisible = true

    var body: some View {
        ZStack {
            if splashVisible {
                SplashView()
                    .transition(.opacity)
            } else if !hasCompletedOnboarding {
                onboardingFlow
                    .transition(.opacity)
            } else {
                mainContent
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: splashVisible)
        .animation(.easeInOut(duration: 0.35), value: hasCompletedOnboarding)
        .task {
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
    }

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

#Preview {
    RootView()
}
