import SwiftUI
import FHBDesignSystem
import FHBNetworking
import FHBDependencyContainer

struct RootView: View {
    @State private var healthStatus: HealthStatus = .checking

    private let apiClient: any APIClientProtocol = AppContainer.shared.apiClient()

    var body: some View {
        ZStack {
            FHBColor.canvas.ignoresSafeArea()
            VStack(spacing: FHBSpacing.lg) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(FHBColor.brandPink)

                Text("FanhB")
                    .fhbTextStyle(FHBTypography.displaySM)
                    .foregroundStyle(FHBColor.ink)

                statusBadge
            }
        }
        .task { await checkHealth() }
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch healthStatus {
        case .checking:
            FHBBadgePill("Connecting…")
        case .ok(let label):
            FHBBadgePill(label)
                .foregroundStyle(FHBColor.success)
        case .error(let message):
            FHBBadgePill(message)
                .foregroundStyle(FHBColor.error)
        }
    }

    private func checkHealth() async {
        do {
            let response: HealthResponse = try await apiClient.request(.health)
            healthStatus = .ok(response.status)
        } catch {
            healthStatus = .error("Offline")
        }
    }
}

// MARK: - Supporting types

private enum HealthStatus {
    case checking
    case ok(String)
    case error(String)
}

private struct HealthResponse: Decodable, Sendable {
    let status: String
}

// MARK: - Preview

#Preview {
    RootView()
}
