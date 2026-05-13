import SwiftUI
import FHBDesignSystem

// MO-P1-008 — Tutorial step 3: send a nudge

struct TutorialStep3View: View {
    @State private var intensity: TutorialNudgeIntensity = .normal
    @State private var sending = false
    @State private var sent = false

    var body: some View {
        VStack(spacing: FHBSpacing.lg) {
            instructionCard
            Spacer()
            partnerBubble
            intensityPicker
            sendArea
            Spacer()
        }
        .padding(.top, FHBSpacing.lg)
        .animation(.spring(response: 0.4), value: sent)
    }

    private var instructionCard: some View {
        HStack(spacing: FHBSpacing.sm) {
            Image(systemName: "bell.badge.fill")
                .font(.title2)
                .foregroundStyle(FHBColor.brandPeach)
            Text("Tap **Send Nudge** to send your partner a gentle buzz.")
                .fhbTextStyle(FHBTypography.bodySM)
                .foregroundStyle(FHBColor.body)
        }
        .padding(FHBSpacing.md)
        .background(FHBColor.surfaceSoft, in: RoundedRectangle(cornerRadius: FHBRounded.md, style: .continuous))
        .padding(.horizontal, FHBSpacing.xl)
    }

    private var partnerBubble: some View {
        VStack(spacing: FHBSpacing.sm) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(FHBColor.brandLavender.opacity(0.25))
                    .frame(width: 80, height: 80)
                    .overlay(Text("💕").font(.system(size: 36)))
                Circle()
                    .fill(FHBColor.success)
                    .frame(width: 16, height: 16)
                    .overlay(Circle().stroke(FHBColor.canvas, lineWidth: 2))
            }
            Text("Your partner is online")
                .fhbTextStyle(FHBTypography.caption)
                .foregroundStyle(FHBColor.muted)
        }
    }

    private var intensityPicker: some View {
        VStack(alignment: .leading, spacing: FHBSpacing.sm) {
            Text("Vibration")
                .fhbTextStyle(FHBTypography.captionUppercase)
                .foregroundStyle(FHBColor.mutedSoft)

            HStack(spacing: FHBSpacing.sm) {
                ForEach(TutorialNudgeIntensity.allCases) { option in
                    IntensityChip(option: option, isSelected: intensity == option) {
                        intensity = option
                    }
                }
            }
        }
        .padding(.horizontal, FHBSpacing.xl)
    }

    @ViewBuilder
    private var sendArea: some View {
        if sent {
            VStack(spacing: FHBSpacing.sm) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(FHBColor.success)
                Text("Nudge sent!")
                    .fhbTextStyle(FHBTypography.titleMD)
                    .foregroundStyle(FHBColor.ink)
                Text("Your partner felt it.")
                    .fhbTextStyle(FHBTypography.bodySM)
                    .foregroundStyle(FHBColor.muted)
            }
            .transition(.opacity.combined(with: .scale(scale: 0.85)))
        } else {
            Button {
                guard !sending else { return }
                sending = true
                Task {
                    try? await Task.sleep(nanoseconds: 900_000_000)
                    withAnimation { sent = true; sending = false }
                }
            } label: {
                HStack(spacing: FHBSpacing.sm) {
                    if sending {
                        ProgressView().tint(FHBColor.onPrimary)
                    } else {
                        Image(systemName: "bell.badge.fill")
                    }
                    Text(sending ? "Sending…" : "Send Nudge")
                        .fhbTextStyle(FHBTypography.button)
                }
                .foregroundStyle(FHBColor.onPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    FHBColor.brandPink,
                    in: RoundedRectangle(cornerRadius: FHBRounded.md, style: .continuous)
                )
            }
            .disabled(sending)
            .padding(.horizontal, FHBSpacing.xl)
        }
    }
}

// MARK: - Supporting types

enum TutorialNudgeIntensity: String, CaseIterable, Identifiable {
    case gentle, normal, strong
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
    var icon: String {
        switch self {
        case .gentle: return "leaf"
        case .normal: return "bell"
        case .strong: return "bolt.fill"
        }
    }
}

private struct IntensityChip: View {
    let option: TutorialNudgeIntensity
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: FHBSpacing.xxs) {
                Image(systemName: option.icon)
                    .font(.system(size: 20))
                Text(option.label)
                    .fhbTextStyle(FHBTypography.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, FHBSpacing.sm)
            .foregroundStyle(isSelected ? FHBColor.brandPink : FHBColor.muted)
            .background(
                isSelected ? FHBColor.brandPink.opacity(0.1) : FHBColor.surfaceCard,
                in: RoundedRectangle(cornerRadius: FHBRounded.md, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: FHBRounded.md, style: .continuous)
                    .stroke(isSelected ? FHBColor.brandPink : FHBColor.hairline, lineWidth: 1)
            )
        }
    }
}

#Preview {
    TutorialStep3View()
}
