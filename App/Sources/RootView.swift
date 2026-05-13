import SwiftUI

struct RootView: View {
    @State private var healthStatus = "Checking…"

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.fill")
                .font(.system(size: 64))
                .foregroundStyle(.pink)
            Text("FanhB")
                .font(.largeTitle.bold())
            Text(healthStatus)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .task { await checkHealth() }
    }

    private func checkHealth() async {
        guard let url = URL(string: "https://api.fanhb.app/_ops/health") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            healthStatus = String(decoding: data, as: UTF8.self)
        } catch {
            healthStatus = "Offline (\(error.localizedDescription))"
        }
    }
}
