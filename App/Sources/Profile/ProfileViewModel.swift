import SwiftUI
import UIKit
import FHBDesignSystem
import FHBNetworking

// MARK: - ProfileViewModel

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var displayName: String = ""
    @Published var selectedAccentColor: Color = FHBColor.brandPink
    @Published var avatarImage: UIImage? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isDone: Bool = false

    private let apiClient: any APIClientProtocol

    init(apiClient: any APIClientProtocol) {
        self.apiClient = apiClient
    }

    // MARK: - Actions

    func saveProfile() async {
        guard !displayName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter a display name."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // TODO: Replace with real PATCH /v1/users/me once API is documented
            let body = UpdateProfileRequest(
                displayName: displayName.trimmingCharacters(in: .whitespaces),
                accentColor: accentColorHex(selectedAccentColor)
            )
            let endpoint = try Endpoint.json(path: "/v1/users/me", method: .patch, body: body)
            let _: UpdateProfileResponse = try await apiClient.request(endpoint)
            isDone = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func uploadAvatar(image: UIImage) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // MO-P1-021: Stub — obtain presigned URL
            let presignResponse = try await fetchAvatarPresignURL()

            // MO-P1-021: Upload image data via PUT to presigned URL
            guard let imageData = image.jpegData(compressionQuality: 0.85) else {
                errorMessage = "Failed to process image."
                return
            }
            try await uploadToPresignedURL(presignResponse.presignedUrl, data: imageData)

            // MO-P1-022: Finalize — tell backend the upload completed
            try await finalizeAvatarUpload(key: presignResponse.key)

            avatarImage = image
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Private stubs

    private func fetchAvatarPresignURL() async throws -> PresignResponse {
        // TODO: Replace with real GET /v1/users/me/avatar/presign once API is documented
        let endpoint = Endpoint(path: "/v1/users/me/avatar/presign", method: .get)
        return try await apiClient.request(endpoint)
    }

    private func uploadToPresignedURL(_ urlString: String, data: Data) async throws {
        // TODO: Replace with real PUT <presignedUrl> once API is documented
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = data
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }

    private func finalizeAvatarUpload(key: String) async throws {
        // TODO: Replace with real PATCH /v1/users/me/avatar/finalize once API is documented
        let endpoint = try Endpoint.json(
            path: "/v1/users/me/avatar/finalize",
            method: .patch,
            body: FinalizeAvatarRequest(key: key)
        )
        try await apiClient.requestVoid(endpoint)
    }

    private func accentColorHex(_ color: Color) -> String? {
        switch color {
        case FHBColor.brandPink:     return "#FF4D8B"
        case FHBColor.brandLavender: return "#B8A4ED"
        case FHBColor.brandPeach:    return "#FFB084"
        case FHBColor.brandOchre:    return "#E8B94A"
        case FHBColor.brandMint:     return "#A4D4C5"
        case FHBColor.brandCoral:    return "#FF6B5A"
        default:                     return nil
        }
    }
}

// MARK: - Request / Response DTOs

private struct UpdateProfileRequest: Codable, Sendable {
    let displayName: String
    let accentColor: String?
}

private struct UpdateProfileResponse: Codable, Sendable {
    let id: String
    let email: String
    let displayName: String
}

private struct PresignResponse: Codable, Sendable {
    let presignedUrl: String
    let key: String
}

private struct FinalizeAvatarRequest: Codable, Sendable {
    let key: String
}
