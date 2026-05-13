import Foundation

enum OnboardingStep: Equatable {
    case carousel
    case tutorial
    case done
}

@MainActor
final class OnboardingCoordinator: ObservableObject {
    @Published private(set) var step: OnboardingStep = .carousel

    func skipOnboarding() {
        step = .done
    }

    func carouselCompleted() {
        step = .tutorial
    }

    func tutorialCompleted() {
        step = .done
    }
}
