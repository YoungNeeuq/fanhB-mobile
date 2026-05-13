import SwiftUI
import FHBDesignSystem

// MARK: - CreateProfileView (MO-P1-019)

struct CreateProfileView: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    var onComplete: () -> Void

    @State private var showAvatarPicker = false

    private let accentColors: [Color] = [
        FHBColor.brandPink,
        FHBColor.brandLavender,
        FHBColor.brandPeach,
        FHBColor.brandOchre,
        FHBColor.brandMint,
        FHBColor.brandCoral
    ]

    var body: some View {
        ZStack {
            FHBColor.canvas.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: FHBSpacing.xl) {
                    header
                    avatarRow
                    nameField
                    accentColorSection
                    saveButton
                }
                .padding(.horizontal, FHBSpacing.xl)
                .padding(.top, FHBSpacing.xxl)
                .padding(.bottom, FHBSpacing.xxl)
            }

            if profileViewModel.isLoading {
                loadingOverlay
            }
        }
        .sheet(isPresented: $showAvatarPicker) {
            AvatarPickerView(profileViewModel: profileViewModel, isPresented: $showAvatarPicker)
                .presentationDetents([.height(280)])
        }
        .onChange(of: profileViewModel.isDone) { _, done in
            if done { onComplete() }
        }
        .alert("Error", isPresented: Binding(
            get: { profileViewModel.errorMessage != nil },
            set: { if !$0 { profileViewModel.errorMessage = nil } }
        ), actions: {
            Button("OK") { profileViewModel.errorMessage = nil }
        }, message: {
            Text(profileViewModel.errorMessage ?? "")
        })
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(alignment: .leading, spacing: FHBSpacing.xs) {
            Text("Set up your profile")
                .fhbTextStyle(FHBTypography.displaySM)
                .foregroundStyle(FHBColor.ink)
            Text("Your partner will see this.")
                .fhbTextStyle(FHBTypography.bodyMD)
                .foregroundStyle(FHBColor.muted)
        }
    }

    private var avatarRow: some View {
        HStack(spacing: FHBSpacing.md) {
            Button {
                showAvatarPicker = true
            } label: {
                ZStack {
                    avatarCircle
                    addPhotoOverlay
                }
            }

            VStack(alignment: .leading, spacing: FHBSpacing.xxs) {
                Text("Profile photo")
                    .fhbTextStyle(FHBTypography.titleSM)
                    .foregroundStyle(FHBColor.ink)
                Text("Optional but recommended")
                    .fhbTextStyle(FHBTypography.bodySM)
                    .foregroundStyle(FHBColor.muted)
            }
        }
    }

    private var avatarCircle: some View {
        Group {
            if let image = profileViewModel.avatarImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 72, height: 72)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(profileViewModel.selectedAccentColor.opacity(0.2))
                    .frame(width: 72, height: 72)
                    .overlay(
                        Text(initialsFromName(profileViewModel.displayName))
                            .fhbTextStyle(FHBTypography.titleLG)
                            .foregroundStyle(profileViewModel.selectedAccentColor)
                    )
            }
        }
    }

    private var addPhotoOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ZStack {
                    Circle()
                        .fill(FHBColor.brandPink)
                        .frame(width: 22, height: 22)
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(FHBColor.onPrimary)
                }
            }
        }
        .frame(width: 72, height: 72)
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: FHBSpacing.xxs) {
            Text("Display name")
                .fhbTextStyle(FHBTypography.caption)
                .foregroundStyle(FHBColor.muted)
            FHBTextInput("Your name", text: $profileViewModel.displayName)
                .textContentType(.name)
        }
    }

    private var accentColorSection: some View {
        VStack(alignment: .leading, spacing: FHBSpacing.sm) {
            Text("Accent color")
                .fhbTextStyle(FHBTypography.caption)
                .foregroundStyle(FHBColor.muted)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: FHBSpacing.sm) {
                    ForEach(Array(accentColors.enumerated()), id: \.offset) { _, color in
                        colorCircle(color)
                    }
                }
                .padding(.vertical, FHBSpacing.xxs)
            }
        }
    }

    private func colorCircle(_ color: Color) -> some View {
        let isSelected = profileViewModel.selectedAccentColor == color
        return Button {
            profileViewModel.selectedAccentColor = color
        } label: {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 40, height: 40)
                if isSelected {
                    Circle()
                        .stroke(FHBColor.ink, lineWidth: 2)
                        .frame(width: 46, height: 46)
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(FHBColor.onPrimary)
                }
            }
        }
    }

    private var saveButton: some View {
        FHBPrimaryButton("Save & Continue") {
            Task { await profileViewModel.saveProfile() }
        }
        .padding(.top, FHBSpacing.sm)
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

    // MARK: - Helpers

    private func initialsFromName(_ name: String) -> String {
        let parts = name.trimmingCharacters(in: .whitespaces).components(separatedBy: " ")
        let initials = parts.compactMap { $0.first }.prefix(2).map(String.init).joined()
        return initials.isEmpty ? "?" : initials.uppercased()
    }
}
