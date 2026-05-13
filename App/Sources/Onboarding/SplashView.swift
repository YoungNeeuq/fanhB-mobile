import SwiftUI
import FHBDesignSystem

// MO-P1-001 — Splash view with animated logo (SwiftUI)

struct SplashView: View {
    @State private var heartScale: CGFloat = 0.3
    @State private var heartOpacity: Double = 0
    @State private var textOpacity: Double = 0

    var body: some View {
        ZStack {
            FHBColor.canvas.ignoresSafeArea()
            VStack(spacing: FHBSpacing.md) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(FHBColor.brandPink)
                    .scaleEffect(heartScale)
                    .opacity(heartOpacity)

                Text("fanhb")
                    .fhbTextStyle(FHBTypography.displayMD)
                    .foregroundStyle(FHBColor.ink)
                    .opacity(textOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.65)) {
                heartScale = 1.0
                heartOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                textOpacity = 1.0
            }
        }
    }
}

#Preview {
    SplashView()
}
