import SwiftUI
import FHBDesignSystem

// TODO: Add GoogleSignIn package to project.yml when the SDK is approved.
// Package: https://github.com/google/GoogleSignIn-iOS from: "7.0.0"

#if canImport(GoogleSignIn)
import GoogleSignIn
import FirebaseAuth
#endif

// MARK: - GoogleSignInButton (MO-P1-011)

struct GoogleSignInButton: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        Button(action: handleSignIn) {
            HStack(spacing: FHBSpacing.sm) {
                googleIcon
                Text("Continue with Google")
                    .fhbTextStyle(FHBTypography.button)
                    .foregroundStyle(FHBColor.ink)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(FHBColor.canvas, in: RoundedRectangle(cornerRadius: FHBRounded.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: FHBRounded.md, style: .continuous)
                    .stroke(FHBColor.hairline, lineWidth: 1)
            )
        }
    }

    // MARK: - Private

    private var googleIcon: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 20, height: 20)
            Text("G")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color(red: 0.26, green: 0.52, blue: 0.96))
        }
    }

    private func handleSignIn() {
#if canImport(GoogleSignIn)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            guard error == nil,
                  let user = result?.user,
                  let idToken = user.idToken?.tokenString else { return }

            let accessToken = user.accessToken.tokenString
            Task {
                // Exchange Google ID token for a Firebase credential, then obtain a Firebase ID token
                // so the FanHB backend receives a verifiable token from a trusted identity provider.
                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: accessToken
                )
                do {
                    let authResult = try await Auth.auth().signIn(with: credential)
                    let firebaseIdToken = try await authResult.user.getIDToken()
                    await viewModel.signInWithGoogle(firebaseIdToken: firebaseIdToken)
                } catch {
                    // Errors surface through the view model's errorMessage publisher
                }
            }
        }
#else
        // GoogleSignIn SDK not yet added to the project.
        // This path compiles but does nothing until the package is integrated.
#endif
    }
}
