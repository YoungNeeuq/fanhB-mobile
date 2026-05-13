import SwiftUI

// MARK: - FHBTextStyle
// Pairs a Font with its tracking (letter-spacing) value.
// Apply both together: Text("…").font(style.font).tracking(style.tracking)
//
// Display tokens use Inter Medium (weight .medium) with negative tracking —
// substitute for Plain Black until the custom typeface is embedded.
// Body/UI tokens use Inter Regular/SemiBold via .system with .default design.

public struct FHBTextStyle {
    public let font: Font
    public let tracking: CGFloat

    public init(font: Font, tracking: CGFloat = 0) {
        self.font = font
        self.tracking = tracking
    }
}

// MARK: - FHBTypography tokens

public enum FHBTypography {
    // Display — Plain Black substitute: Inter Medium, rounded design, negative tracking
    public static let displayXL  = FHBTextStyle(font: .system(size: 72, weight: .medium, design: .rounded), tracking: -2.5)
    public static let displayLG  = FHBTextStyle(font: .system(size: 56, weight: .medium, design: .rounded), tracking: -2.0)
    public static let displayMD  = FHBTextStyle(font: .system(size: 40, weight: .medium, design: .rounded), tracking: -1.0)
    public static let displaySM  = FHBTextStyle(font: .system(size: 32, weight: .medium, design: .rounded), tracking: -0.5)

    // Title — Inter SemiBold
    public static let titleLG    = FHBTextStyle(font: .system(size: 24, weight: .semibold), tracking: -0.3)
    public static let titleMD    = FHBTextStyle(font: .system(size: 18, weight: .semibold))
    public static let titleSM    = FHBTextStyle(font: .system(size: 16, weight: .semibold))

    // Body — Inter Regular
    public static let bodyMD     = FHBTextStyle(font: .system(size: 16, weight: .regular))
    public static let bodySM     = FHBTextStyle(font: .system(size: 14, weight: .regular))

    // Caption
    public static let caption          = FHBTextStyle(font: .system(size: 13, weight: .medium))
    public static let captionUppercase = FHBTextStyle(font: .system(size: 12, weight: .semibold), tracking: 1.5)

    // UI
    public static let button   = FHBTextStyle(font: .system(size: 14, weight: .semibold))
    public static let navLink  = FHBTextStyle(font: .system(size: 14, weight: .medium))
}

// MARK: - Text convenience modifier

public struct FHBTextStyleModifier: ViewModifier {
    let style: FHBTextStyle

    public func body(content: Content) -> some View {
        content
            .font(style.font)
            .tracking(style.tracking)
    }
}

public extension View {
    func fhbTextStyle(_ style: FHBTextStyle) -> some View {
        modifier(FHBTextStyleModifier(style: style))
    }
}
