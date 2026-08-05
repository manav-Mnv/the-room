import SwiftUI

/// The Room's design system: a warm nude palette with a single terracotta accent.
/// Colors are defined as dynamic `Color`s (light/dark) rather than an asset catalog
/// so the whole design system lives in source and is reviewable without Xcode.
enum Theme {

    // MARK: - Colors

    /// App background.
    static let bgBase = Color.dynamic(light: 0xFAF6F1, dark: 0x1E1A17)
    /// Cards / surfaces.
    static let bgCard = Color.dynamic(light: 0xF3ECE4, dark: 0x2A2420)
    /// Sheets, pressed states.
    static let bgElevated = Color.dynamic(light: 0xEDE3D7, dark: 0x362E28)
    /// Breathing screens — stays dark in BOTH light and dark mode.
    static let bgBreathe = Color.dynamic(light: 0x2C2420, dark: 0x14100D)

    /// Never pure black.
    static let textPrimary = Color.dynamic(light: 0x3E3A36, dark: 0xEDE6DD)
    static let textSecondary = Color.dynamic(light: 0x8A8178, dark: 0xA99E92)
    static let textMuted = Color.dynamic(light: 0xB5AB9F, dark: 0x7A7166)

    /// Terracotta — THE ONLY ACCENT. Buttons, breathing circle, selection, streak.
    static let accent = Color.fixed(0xC97B5D)
    /// Accent-tinted fills, reflection cards.
    static let claySoft = Color.dynamic(light: 0xE5C3B3, dark: 0x8A5540)
    /// Success / streak positive.
    static let olive = Color.dynamic(light: 0x7D8A5C, dark: 0x8FA06A)
    /// Gentle warnings — NEVER use red anywhere in this app.
    static let ochre = Color.fixed(0xD9A45B)

    /// Text that always sits on `bgBreathe`, regardless of system color scheme.
    static let onBreathePrimary = Color.dynamic(light: 0xEDE6DD, dark: 0xEDE6DD)
    static let onBreatheSecondary = Color.dynamic(light: 0xA99E92, dark: 0xA99E92)

    // MARK: - Metrics

    enum Radius {
        static let card: CGFloat = 24
        static let sheet: CGFloat = 32
        static let capsule: CGFloat = 999
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        /// Standard side margin for bottom-anchored primary buttons and screen edges.
        static let screenMargin: CGFloat = 24
    }

    enum Motion {
        /// Calm, gentle spring for selection / tap feedback. Nothing flashy.
        static let gentle = Animation.spring(response: 0.35, dampingFraction: 0.75)
        /// Slightly slower spring for sheet/screen transitions.
        static let transition = Animation.spring(response: 0.45, dampingFraction: 0.82)
    }

    // MARK: - Typography

    /// Rounded heading style — use for headlines, mood numbers, streak counts.
    static func rounded(_ style: Font.TextStyle, weight: Font.Weight = .semibold) -> Font {
        .system(style, design: .rounded).weight(weight)
    }
}

private extension Color {
    /// A color that differs between light and dark appearance.
    static func dynamic(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }

    /// A color that is identical in both appearances (e.g. the terracotta accent).
    static func fixed(_ hex: UInt32) -> Color {
        Color(uiColor: UIColor(hex: hex))
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        let r = CGFloat((hex & 0xFF0000) >> 16) / 255
        let g = CGFloat((hex & 0x00FF00) >> 8) / 255
        let b = CGFloat(hex & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
