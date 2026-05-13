import SwiftUI
import PhotosUI
import UIKit
import FHBDesignSystem

// MARK: - AvatarPickerView (MO-P1-020, MO-P1-021, MO-P1-022)

struct AvatarPickerView: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    @Binding var isPresented: Bool

    @State private var showCamera = false
    @State private var showPhotoLibrary = false

    var body: some View {
        VStack(spacing: 0) {
            dragHandle
            header
            Divider()
            actionRows
        }
        .background(FHBColor.canvas)
        .cornerRadius(FHBRounded.xl, corners: [.topLeft, .topRight])
        .sheet(isPresented: $showCamera) {
            CameraPickerView { image in
                guard let image else { return }
                Task { await profileViewModel.uploadAvatar(image: image) }
            }
        }
        .sheet(isPresented: $showPhotoLibrary) {
            PhotoLibraryPickerView { image in
                guard let image else { return }
                Task { await profileViewModel.uploadAvatar(image: image) }
            }
        }
    }

    // MARK: - Subviews

    private var dragHandle: some View {
        Capsule()
            .fill(FHBColor.hairline)
            .frame(width: 40, height: 4)
            .padding(.top, FHBSpacing.sm)
            .padding(.bottom, FHBSpacing.xs)
    }

    private var header: some View {
        HStack {
            Text("Change photo")
                .fhbTextStyle(FHBTypography.titleMD)
                .foregroundStyle(FHBColor.ink)
            Spacer()
            Button("Cancel") { isPresented = false }
                .fhbTextStyle(FHBTypography.bodyMD)
                .foregroundStyle(FHBColor.brandPink)
        }
        .padding(.horizontal, FHBSpacing.xl)
        .padding(.bottom, FHBSpacing.md)
    }

    private var actionRows: some View {
        VStack(spacing: 0) {
            pickerRow(icon: "camera.fill", title: "Take Photo") {
                showCamera = true
            }
            Divider().padding(.leading, FHBSpacing.xl + 24 + FHBSpacing.sm)
            pickerRow(icon: "photo.on.rectangle", title: "Choose from Library") {
                showPhotoLibrary = true
            }
            Divider().padding(.leading, FHBSpacing.xl + 24 + FHBSpacing.sm)
            pickerRow(icon: "trash", title: "Remove Photo", destructive: true) {
                profileViewModel.avatarImage = nil
                isPresented = false
            }
        }
        .padding(.bottom, FHBSpacing.xl)
    }

    private func pickerRow(
        icon: String,
        title: String,
        destructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: FHBSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(destructive ? FHBColor.error : FHBColor.ink)
                    .frame(width: 24)
                Text(title)
                    .fhbTextStyle(FHBTypography.bodyMD)
                    .foregroundStyle(destructive ? FHBColor.error : FHBColor.ink)
                Spacer()
            }
            .padding(.horizontal, FHBSpacing.xl)
            .frame(height: 52)
        }
    }
}

// MARK: - Corner radius helper

private extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornersShape(radius: radius, corners: corners))
    }
}

private struct RoundedCornersShape: Shape {
    let radius: CGFloat
    let corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - CameraPickerView (MO-P1-020)

struct CameraPickerView: UIViewControllerRepresentable {
    var onImagePicked: (UIImage?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var onImagePicked: (UIImage?) -> Void

        init(onImagePicked: @escaping (UIImage?) -> Void) {
            self.onImagePicked = onImagePicked
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
            picker.dismiss(animated: true)
            onImagePicked(image)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            onImagePicked(nil)
        }
    }
}

// MARK: - PhotoLibraryPickerView (MO-P1-020)
// Uses PHPickerViewController — no permission prompt required for reading user-selected photos.

struct PhotoLibraryPickerView: UIViewControllerRepresentable {
    var onImagePicked: (UIImage?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var onImagePicked: (UIImage?) -> Void

        init(onImagePicked: @escaping (UIImage?) -> Void) {
            self.onImagePicked = onImagePicked
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let result = results.first else {
                onImagePicked(nil)
                return
            }
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
                let image = object as? UIImage
                DispatchQueue.main.async {
                    self?.onImagePicked(image)
                }
            }
        }
    }
}
