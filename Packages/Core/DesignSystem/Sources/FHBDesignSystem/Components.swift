import SwiftUI

public struct FanhBPrimaryButton: View {
    let title: String
    let action: () -> Void

    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.fanhbHeadline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.fanhbPrimary, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}

public struct FanhBLoadingView: View {
    public init() {}

    public var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(.fanhbPrimary)
    }
}
