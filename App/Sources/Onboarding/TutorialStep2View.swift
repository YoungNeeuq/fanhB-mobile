import SwiftUI
import UIKit
import FHBDesignSystem

// MO-P1-007 — Tutorial step 2: color picker

struct TutorialStep2View: View {
    @State private var hue: Double = 0.93
    @State private var saturation: Double = 0.70
    @State private var brightness: Double = 1.0

    private var selectedColor: Color {
        Color(hue: hue, saturation: saturation, brightness: brightness)
    }

    private let swatches: [Color] = [
        FHBColor.brandPink,
        FHBColor.brandCoral,
        FHBColor.brandPeach,
        FHBColor.brandOchre,
        FHBColor.brandMint,
        FHBColor.brandLavender,
        FHBColor.brandTeal,
        .black,
    ]

    var body: some View {
        VStack(spacing: FHBSpacing.lg) {
            instructionCard
            colorPreview
            swatchPalette
            hsbSliders
        }
        .padding(.top, FHBSpacing.lg)
    }

    private var instructionCard: some View {
        HStack(spacing: FHBSpacing.sm) {
            Image(systemName: "paintpalette.fill")
                .font(.title2)
                .foregroundStyle(FHBColor.brandLavender)
            Text("Tap a swatch or drag the sliders to pick your color.")
                .fhbTextStyle(FHBTypography.bodySM)
                .foregroundStyle(FHBColor.body)
        }
        .padding(FHBSpacing.md)
        .background(FHBColor.surfaceSoft, in: RoundedRectangle(cornerRadius: FHBRounded.md, style: .continuous))
        .padding(.horizontal, FHBSpacing.xl)
    }

    private var colorPreview: some View {
        RoundedRectangle(cornerRadius: FHBRounded.lg, style: .continuous)
            .fill(selectedColor)
            .frame(height: 72)
            .padding(.horizontal, FHBSpacing.xl)
            .overlay(
                Text("Your color")
                    .fhbTextStyle(FHBTypography.caption)
                    .foregroundStyle(.white.opacity(0.8))
            )
            .animation(.easeInOut(duration: 0.15), value: hue)
            .animation(.easeInOut(duration: 0.15), value: saturation)
            .animation(.easeInOut(duration: 0.15), value: brightness)
    }

    private var swatchPalette: some View {
        VStack(alignment: .leading, spacing: FHBSpacing.sm) {
            Text("Quick colors")
                .fhbTextStyle(FHBTypography.captionUppercase)
                .foregroundStyle(FHBColor.mutedSoft)
                .padding(.leading, FHBSpacing.xl)

            HStack(spacing: FHBSpacing.sm) {
                ForEach(swatches.indices, id: \.self) { i in
                    let swatch = swatches[i]
                    Circle()
                        .fill(swatch)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: isSelected(swatch) ? 3 : 0)
                        )
                        .shadow(color: .black.opacity(0.12), radius: 2, y: 1)
                        .onTapGesture { applyUIColor(UIColor(swatch)) }
                }
            }
            .padding(.horizontal, FHBSpacing.xl)
        }
    }

    private var hsbSliders: some View {
        VStack(spacing: FHBSpacing.sm) {
            HSBSlider(label: "Hue", value: $hue, gradient: hueGradient)
            HSBSlider(label: "Saturation", value: $saturation, gradient: satGradient)
            HSBSlider(label: "Brightness", value: $brightness, gradient: brightGradient)
        }
        .padding(.horizontal, FHBSpacing.xl)
    }

    private func isSelected(_ color: Color) -> Bool {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(color).getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return abs(Double(h) - hue) < 0.02 && abs(Double(s) - saturation) < 0.05
    }

    private func applyUIColor(_ uiColor: UIColor) {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        hue = Double(h)
        saturation = Double(s)
        brightness = max(Double(b), 0.1)
    }

    private var hueGradient: LinearGradient {
        LinearGradient(
            colors: stride(from: 0.0, through: 1.0, by: 0.05).map {
                Color(hue: $0, saturation: 1, brightness: 1)
            },
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var satGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hue: hue, saturation: 0, brightness: brightness),
                Color(hue: hue, saturation: 1, brightness: brightness),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var brightGradient: LinearGradient {
        LinearGradient(
            colors: [.black, Color(hue: hue, saturation: saturation, brightness: 1)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

private struct HSBSlider: View {
    let label: String
    @Binding var value: Double
    let gradient: LinearGradient

    var body: some View {
        HStack(spacing: FHBSpacing.sm) {
            Text(label)
                .fhbTextStyle(FHBTypography.caption)
                .foregroundStyle(FHBColor.muted)
                .frame(width: 72, alignment: .leading)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(gradient)
                    .frame(height: 20)

                GeometryReader { geo in
                    Circle()
                        .fill(.white)
                        .frame(width: 24, height: 24)
                        .shadow(color: .black.opacity(0.2), radius: 2)
                        .offset(x: geo.size.width * value - 12, y: -2)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { drag in
                                    value = min(1, max(0, drag.location.x / geo.size.width))
                                }
                        )
                }
                .frame(height: 20)
            }
        }
    }
}

#Preview {
    TutorialStep2View()
}
