import SwiftUI
import FHBDesignSystem

// MO-P1-005 — Drawing tutorial UI shell (3 steps)

enum TutorialStep: Int, CaseIterable {
    case penAndClear = 0
    case colorPicker
    case sendNudge

    var title: String {
        switch self {
        case .penAndClear:  return "Your Pen"
        case .colorPicker:  return "Pick a Color"
        case .sendNudge:    return "Send a Nudge"
        }
    }

    var stepLabel: String { "\(rawValue + 1) of \(TutorialStep.allCases.count)" }
}

struct DrawingTutorialView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var currentStep: TutorialStep = .penAndClear

    var body: some View {
        ZStack {
            FHBColor.canvas.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                stepContent
                    .frame(maxHeight: .infinity)
                footer
            }
        }
    }

    private var header: some View {
        VStack(spacing: FHBSpacing.sm) {
            // Segmented progress bar
            HStack(spacing: FHBSpacing.xs) {
                ForEach(TutorialStep.allCases, id: \.rawValue) { step in
                    Capsule()
                        .fill(step.rawValue <= currentStep.rawValue
                              ? FHBColor.brandPink
                              : FHBColor.hairline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 4)
                        .animation(.spring(response: 0.3), value: currentStep)
                }
            }
            .padding(.horizontal, FHBSpacing.xl)

            HStack {
                Text(currentStep.title)
                    .fhbTextStyle(FHBTypography.titleLG)
                    .foregroundStyle(FHBColor.ink)
                Spacer()
                Text(currentStep.stepLabel)
                    .fhbTextStyle(FHBTypography.caption)
                    .foregroundStyle(FHBColor.mutedSoft)
            }
            .padding(.horizontal, FHBSpacing.xl)
            .padding(.top, FHBSpacing.xs)
        }
        .padding(.top, FHBSpacing.lg)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case .penAndClear:  TutorialStep1View()
        case .colorPicker:  TutorialStep2View()
        case .sendNudge:    TutorialStep3View()
        }
    }

    private var footer: some View {
        VStack(spacing: FHBSpacing.sm) {
            FHBPrimaryButton(isLastStep ? "Let's Go!" : "Next", action: advance)

            if currentStep.rawValue > 0 {
                Button("Back") {
                    withAnimation {
                        currentStep = TutorialStep(rawValue: currentStep.rawValue - 1) ?? .penAndClear
                    }
                }
                .fhbTextStyle(FHBTypography.navLink)
                .foregroundStyle(FHBColor.muted)
            }
        }
        .padding(.horizontal, FHBSpacing.xl)
        .padding(.bottom, FHBSpacing.xxl)
    }

    private var isLastStep: Bool {
        currentStep == TutorialStep.allCases.last
    }

    private func advance() {
        if isLastStep {
            coordinator.tutorialCompleted()
        } else {
            withAnimation {
                currentStep = TutorialStep(rawValue: currentStep.rawValue + 1) ?? .sendNudge
            }
        }
    }
}

#Preview {
    DrawingTutorialView(coordinator: OnboardingCoordinator())
}
