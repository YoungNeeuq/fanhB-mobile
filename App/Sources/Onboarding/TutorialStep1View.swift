import SwiftUI
import FHBDesignSystem

// MO-P1-006 — Tutorial step 1: pen + clear

struct TutorialStep1View: View {
    @State private var strokes: [MockStroke] = MockStroke.sample
    @State private var clearedOnce = false

    var body: some View {
        VStack(spacing: FHBSpacing.lg) {
            instructionCard
            mockCanvas
            toolbarRow
            if clearedOnce {
                Text("Nice! You cleared the canvas.")
                    .fhbTextStyle(FHBTypography.bodySM)
                    .foregroundStyle(FHBColor.success)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding(.top, FHBSpacing.lg)
        .animation(.easeInOut(duration: 0.2), value: clearedOnce)
    }

    private var instructionCard: some View {
        HStack(spacing: FHBSpacing.sm) {
            Image(systemName: "pencil.circle.fill")
                .font(.title2)
                .foregroundStyle(FHBColor.brandPink)
            Text("Draw on the canvas. Tap **Clear** when you're done.")
                .fhbTextStyle(FHBTypography.bodySM)
                .foregroundStyle(FHBColor.body)
        }
        .padding(FHBSpacing.md)
        .background(FHBColor.surfaceSoft, in: RoundedRectangle(cornerRadius: FHBRounded.md, style: .continuous))
        .padding(.horizontal, FHBSpacing.xl)
    }

    private var mockCanvas: some View {
        ZStack {
            RoundedRectangle(cornerRadius: FHBRounded.xl, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: FHBRounded.xl, style: .continuous)
                        .stroke(FHBColor.hairline, lineWidth: 1)
                )
            ZStack {
                ForEach(strokes) { stroke in
                    Path { path in
                        guard let first = stroke.points.first else { return }
                        path.move(to: first)
                        stroke.points.dropFirst().forEach { path.addLine(to: $0) }
                    }
                    .stroke(
                        stroke.color,
                        style: StrokeStyle(lineWidth: stroke.width, lineCap: .round, lineJoin: .round)
                    )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: FHBRounded.xl, style: .continuous))
        }
        .frame(height: 200)
        .padding(.horizontal, FHBSpacing.xl)
    }

    private var toolbarRow: some View {
        HStack(spacing: FHBSpacing.xl) {
            ToolIcon(icon: "pencil", label: "Pen", isSelected: true)
            ToolIcon(icon: "eraser", label: "Eraser", isSelected: false)
            Spacer()
            Button {
                withAnimation(.easeOut(duration: 0.2)) { strokes = [] }
                clearedOnce = true
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "trash")
                        .font(.system(size: 20))
                    Text("Clear")
                        .fhbTextStyle(FHBTypography.caption)
                }
                .foregroundStyle(FHBColor.error)
            }
        }
        .padding(.horizontal, FHBSpacing.xxl)
    }
}

// MARK: - Supporting types

private struct ToolIcon: View {
    let icon: String
    let label: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(isSelected ? FHBColor.brandPink : FHBColor.muted)
                .padding(FHBSpacing.xs)
                .background(
                    isSelected ? FHBColor.brandPink.opacity(0.12) : Color.clear,
                    in: RoundedRectangle(cornerRadius: FHBRounded.sm, style: .continuous)
                )
            Text(label)
                .fhbTextStyle(FHBTypography.caption)
                .foregroundStyle(isSelected ? FHBColor.brandPink : FHBColor.muted)
        }
    }
}

private struct MockStroke: Identifiable {
    let id = UUID()
    let points: [CGPoint]
    let color: Color
    let width: CGFloat

    static let sample: [MockStroke] = [
        MockStroke(
            points: [
                CGPoint(x: 40, y: 100),
                CGPoint(x: 80, y: 70),
                CGPoint(x: 130, y: 60),
                CGPoint(x: 170, y: 75),
                CGPoint(x: 200, y: 110),
                CGPoint(x: 195, y: 140),
                CGPoint(x: 160, y: 155),
                CGPoint(x: 120, y: 148),
            ],
            color: FHBColor.brandPink,
            width: 4
        ),
        MockStroke(
            points: [
                CGPoint(x: 55, y: 148),
                CGPoint(x: 90, y: 165),
                CGPoint(x: 140, y: 168),
                CGPoint(x: 175, y: 155),
            ],
            color: FHBColor.brandLavender,
            width: 3
        ),
    ]
}

#Preview {
    TutorialStep1View()
}
