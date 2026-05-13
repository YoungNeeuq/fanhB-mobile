import SwiftUI
import FHBDesignSystem

// MARK: - Safe array subscript

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - OTPView (MO-P1-013, MO-P1-014)

struct OTPView: View {
    let email: String
    let otpType: String
    @ObservedObject var viewModel: AuthViewModel

    @State private var code: String = ""
    @State private var resendCooldown: Int = 0
    @FocusState private var isFieldFocused: Bool

    private let digitCount = 6
    private let cooldownDuration = 60

    var body: some View {
        ZStack {
            FHBColor.canvas.ignoresSafeArea()

            VStack(spacing: FHBSpacing.xl) {
                header
                digitBoxes
                resendRow
                Spacer()
            }
            .padding(.horizontal, FHBSpacing.xl)
            .padding(.top, FHBSpacing.xxl)

            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .onAppear {
            isFieldFocused = true
            startCooldown()
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

    // MARK: - Subviews

    private var header: some View {
        VStack(spacing: FHBSpacing.sm) {
            Text("Check your email")
                .fhbTextStyle(FHBTypography.displaySM)
                .foregroundStyle(FHBColor.ink)
                .multilineTextAlignment(.center)

            Text("Enter the 6-digit code sent to")
                .fhbTextStyle(FHBTypography.bodyMD)
                .foregroundStyle(FHBColor.muted)

            Text(email)
                .fhbTextStyle(FHBTypography.titleSM)
                .foregroundStyle(FHBColor.ink)
        }
        .multilineTextAlignment(.center)
    }

    private var digitBoxes: some View {
        ZStack {
            // Hidden text field captures input and drives one-time code autofill
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFieldFocused)
                .opacity(0)
                .frame(width: 1, height: 1)
                .onChange(of: code) { _, newValue in
                    let filtered = String(newValue.filter(\.isNumber).prefix(digitCount))
                    if filtered != newValue { code = filtered }
                    if filtered.count == digitCount {
                        submitCode(filtered)
                    }
                }

            HStack(spacing: FHBSpacing.sm) {
                ForEach(0..<digitCount, id: \.self) { index in
                    digitBox(at: index)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { isFieldFocused = true }
    }

    private func digitBox(at index: Int) -> some View {
        let digit: String = {
            let chars = Array(code)
            guard index < chars.count, let char = chars[safe: index] else { return "" }
            return String(char)
        }()

        let isCurrent = code.count == index
        let isFilled = index < code.count

        return ZStack {
            RoundedRectangle(cornerRadius: FHBRounded.sm, style: .continuous)
                .fill(FHBColor.surfaceSoft)
                .overlay(
                    RoundedRectangle(cornerRadius: FHBRounded.sm, style: .continuous)
                        .stroke(
                            isCurrent ? FHBColor.brandPink : FHBColor.hairline,
                            lineWidth: isCurrent ? 2 : 1
                        )
                )
                .frame(width: 44, height: 54)

            if isFilled {
                Text(digit)
                    .fhbTextStyle(FHBTypography.titleLG)
                    .foregroundStyle(FHBColor.ink)
            } else if isCurrent {
                Rectangle()
                    .fill(FHBColor.brandPink)
                    .frame(width: 2, height: 24)
            }
        }
    }

    private var resendRow: some View {
        Group {
            if resendCooldown > 0 {
                Text("Resend code in \(resendCooldown)s")
                    .fhbTextStyle(FHBTypography.bodySM)
                    .foregroundStyle(FHBColor.muted)
            } else {
                Button("Resend code") {
                    Task {
                        await viewModel.requestOTP(email: email)
                        startCooldown()
                    }
                }
                .fhbTextStyle(FHBTypography.bodySM)
                .foregroundStyle(FHBColor.brandPink)
            }
        }
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

    // MARK: - Actions

    private func submitCode(_ fullCode: String) {
        Task {
            await viewModel.verifyOTP(email: email, code: fullCode, type: otpType)
        }
    }

    private func startCooldown() {
        resendCooldown = cooldownDuration
        Task {
            while resendCooldown > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                resendCooldown -= 1
            }
        }
    }
}
