import SwiftUI
import FHBDesignSystem

// MO-P1-003 — Onboarding carousel layout
// MO-P1-004 — Carousel content (3 slides) + skip CTA

struct OnboardingCarouselView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var currentPage = 0

    private let slides = OnboardingSlide.all

    var body: some View {
        ZStack {
            FHBColor.canvas.ignoresSafeArea()
            VStack(spacing: 0) {
                skipButton
                slideTabView
                bottomControls
            }
        }
    }

    private var skipButton: some View {
        HStack {
            Spacer()
            Button("Skip") { coordinator.skipOnboarding() }
                .fhbTextStyle(FHBTypography.navLink)
                .foregroundStyle(FHBColor.muted)
                .padding(.trailing, FHBSpacing.md)
                .padding(.top, FHBSpacing.md)
        }
    }

    private var slideTabView: some View {
        TabView(selection: $currentPage) {
            ForEach(slides.indices, id: \.self) { i in
                OnboardingSlideView(slide: slides[i])
                    .tag(i)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut, value: currentPage)
    }

    private var bottomControls: some View {
        VStack(spacing: FHBSpacing.lg) {
            pageIndicator
            if currentPage < slides.count - 1 {
                FHBPrimaryButton("Next") {
                    withAnimation { currentPage += 1 }
                }
            } else {
                FHBPrimaryButton("Let's Draw!") {
                    coordinator.carouselCompleted()
                }
            }
        }
        .padding(.horizontal, FHBSpacing.xl)
        .padding(.bottom, FHBSpacing.xxl)
    }

    private var pageIndicator: some View {
        HStack(spacing: FHBSpacing.xs) {
            ForEach(slides.indices, id: \.self) { i in
                Capsule()
                    .fill(i == currentPage ? FHBColor.brandPink : FHBColor.hairline)
                    .frame(width: i == currentPage ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3), value: currentPage)
            }
        }
    }
}

// MARK: - Slide model

struct OnboardingSlide {
    let icon: String
    let accentColor: Color
    let title: String
    let subtitle: String

    static let all: [OnboardingSlide] = [
        OnboardingSlide(
            icon: "hand.draw.fill",
            accentColor: FHBColor.brandPink,
            title: "Draw Together",
            subtitle: "Send hand-drawn moments to your partner in real time."
        ),
        OnboardingSlide(
            icon: "photo.stack.fill",
            accentColor: FHBColor.brandLavender,
            title: "Your Memory Vault",
            subtitle: "Every drawing is saved so you can relive your story."
        ),
        OnboardingSlide(
            icon: "bell.badge.fill",
            accentColor: FHBColor.brandPeach,
            title: "Send a Nudge",
            subtitle: "A gentle buzz to say "I'm thinking of you" — no words needed."
        ),
    ]
}

// MARK: - Single slide view

private struct OnboardingSlideView: View {
    let slide: OnboardingSlide

    var body: some View {
        VStack(spacing: FHBSpacing.lg) {
            Spacer()
            ZStack {
                Circle()
                    .fill(slide.accentColor.opacity(0.12))
                    .frame(width: 180, height: 180)
                Image(systemName: slide.icon)
                    .font(.system(size: 72))
                    .foregroundStyle(slide.accentColor)
            }
            VStack(spacing: FHBSpacing.sm) {
                Text(slide.title)
                    .fhbTextStyle(FHBTypography.displaySM)
                    .foregroundStyle(FHBColor.ink)
                    .multilineTextAlignment(.center)
                Text(slide.subtitle)
                    .fhbTextStyle(FHBTypography.bodyMD)
                    .foregroundStyle(FHBColor.muted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, FHBSpacing.xl)
            }
            Spacer()
        }
    }
}

#Preview {
    OnboardingCarouselView(coordinator: OnboardingCoordinator())
}
