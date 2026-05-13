import SwiftUI

// MARK: - Hex initializer

extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - FHBColor tokens

public enum FHBColor {
    // Primary
    public static let primary        = Color(hex: 0x0A0A0A)
    public static let primaryActive  = Color(hex: 0x1F1F1F)
    public static let primaryDisabled = Color(hex: 0xE5E5E5)

    // Text
    public static let ink            = Color(hex: 0x0A0A0A)
    public static let body           = Color(hex: 0x3A3A3A)
    public static let bodyStrong     = Color(hex: 0x1A1A1A)
    public static let muted          = Color(hex: 0x6A6A6A)
    public static let mutedSoft      = Color(hex: 0x9A9A9A)

    // Borders
    public static let hairline       = Color(hex: 0xE5E5E5)
    public static let hairlineSoft   = Color(hex: 0xF0F0F0)

    // Surfaces
    public static let canvas         = Color(hex: 0xFFFAF0)
    public static let surfaceSoft    = Color(hex: 0xFAF5E8)
    public static let surfaceCard    = Color(hex: 0xF5F0E0)
    public static let surfaceStrong  = Color(hex: 0xEBE6D6)
    public static let surfaceDark    = Color(hex: 0x0A1A1A)
    public static let surfaceDarkElevated = Color(hex: 0x1A2A2A)

    // On-color
    public static let onPrimary      = Color(hex: 0xFFFFFF)
    public static let onDark         = Color(hex: 0xFFFFFF)
    public static let onDarkSoft     = Color(hex: 0xA0A0A0)

    // Brand palette
    public static let brandPink      = Color(hex: 0xFF4D8B)
    public static let brandTeal      = Color(hex: 0x1A3A3A)
    public static let brandLavender  = Color(hex: 0xB8A4ED)
    public static let brandPeach     = Color(hex: 0xFFB084)
    public static let brandOchre     = Color(hex: 0xE8B94A)
    public static let brandMint      = Color(hex: 0xA4D4C5)
    public static let brandCoral     = Color(hex: 0xFF6B5A)

    // Semantic
    public static let success        = Color(hex: 0x22C55E)
    public static let warning        = Color(hex: 0xF59E0B)
    public static let error          = Color(hex: 0xEF4444)
}
