import SwiftUI

// MARK: - Buttons

public struct FHBPrimaryButton: View {
    let title: String
    let action: () -> Void

    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .fhbTextStyle(FHBTypography.button)
                .foregroundStyle(FHBColor.onPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .padding(.horizontal, FHBSpacing.xl)
                .background(FHBColor.primary, in: RoundedRectangle(cornerRadius: FHBRounded.md, style: .continuous))
        }
    }
}

public struct FHBSecondaryButton: View {
    let title: String
    let action: () -> Void

    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .fhbTextStyle(FHBTypography.button)
                .foregroundStyle(FHBColor.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .padding(.horizontal, FHBSpacing.xl)
                .background(FHBColor.canvas, in: RoundedRectangle(cornerRadius: FHBRounded.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: FHBRounded.md, style: .continuous)
                        .stroke(FHBColor.hairline, lineWidth: 1)
                )
        }
    }
}

// MARK: - Feature Cards

public enum FHBFeatureCardVariant {
    case pink, teal, lavender, peach, ochre, cream

    var backgroundColor: Color {
        switch self {
        case .pink:     return FHBColor.brandPink
        case .teal:     return FHBColor.brandTeal
        case .lavender: return FHBColor.brandLavender
        case .peach:    return FHBColor.brandPeach
        case .ochre:    return FHBColor.brandOchre
        case .cream:    return FHBColor.surfaceCard
        }
    }

    var textColor: Color {
        switch self {
        case .pink, .teal: return FHBColor.onDark
        default:           return FHBColor.ink
        }
    }
}

public struct FHBFeatureCard<Content: View>: View {
    let variant: FHBFeatureCardVariant
    let content: Content

    public init(variant: FHBFeatureCardVariant, @ViewBuilder content: () -> Content) {
        self.variant = variant
        self.content = content()
    }

    public var body: some View {
        content
            .foregroundStyle(variant.textColor)
            .padding(FHBSpacing.xl)
            .background(variant.backgroundColor, in: RoundedRectangle(cornerRadius: FHBRounded.xl, style: .continuous))
    }
}

// MARK: - Content Cards

public struct FHBTestimonialCard<Content: View>: View {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(FHBSpacing.lg)
            .background(FHBColor.surfaceCard, in: RoundedRectangle(cornerRadius: FHBRounded.lg, style: .continuous))
    }
}

public struct FHBProductMockupCard<Content: View>: View {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(FHBSpacing.lg)
            .background(FHBColor.canvas, in: RoundedRectangle(cornerRadius: FHBRounded.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: FHBRounded.lg, style: .continuous)
                    .stroke(FHBColor.hairline, lineWidth: 1)
            )
    }
}

// MARK: - Badge Pill

public struct FHBBadgePill: View {
    let label: String

    public init(_ label: String) {
        self.label = label
    }

    public var body: some View {
        Text(label)
            .fhbTextStyle(FHBTypography.caption)
            .foregroundStyle(FHBColor.ink)
            .padding(.horizontal, FHBSpacing.sm)
            .padding(.vertical, FHBSpacing.xxs)
            .background(FHBColor.surfaceCard, in: Capsule())
    }
}

// MARK: - Text Input

public struct FHBTextInput: View {
    let placeholder: String
    @Binding var text: String

    public init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        TextField(placeholder, text: $text)
            .fhbTextStyle(FHBTypography.bodyMD)
            .foregroundStyle(FHBColor.ink)
            .frame(height: 44)
            .padding(.horizontal, FHBSpacing.md)
            .background(FHBColor.canvas, in: RoundedRectangle(cornerRadius: FHBRounded.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: FHBRounded.md, style: .continuous)
                    .stroke(FHBColor.hairline, lineWidth: 1)
            )
    }
}

// MARK: - Loading

public struct FanhBLoadingView: View {
    public init() {}

    public var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(FHBColor.primary)
    }
}
