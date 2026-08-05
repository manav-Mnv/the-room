import SwiftUI

/// One of the 5 mood levels on the check-in row. Selected state fills terracotta.
struct MoodEmojiButton: View {
    let emoji: String
    let level: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(emoji)
                .font(.system(size: 28))
                .frame(width: 52, height: 52)
                .background(isSelected ? Theme.accent : Theme.bgElevated)
                .clipShape(Circle())
                .scaleEffect(isSelected ? 1.08 : 1)
        }
        .buttonStyle(.plain)
        .animation(Theme.Motion.gentle, value: isSelected)
        .accessibilityLabel(Text(MoodLevel.label(for: level)))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

/// Shared mood-level vocabulary used by the check-in row, calendar heatmap, and widget.
enum MoodLevel {
    static let emojis = ["😞", "😕", "😐", "🙂", "😄"]

    static func label(for level: Int) -> String {
        switch level {
        case 1: return "Very low"
        case 2: return "Low"
        case 3: return "Okay"
        case 4: return "Good"
        case 5: return "Great"
        default: return "Unrecorded"
        }
    }

    /// claySoft → terracotta intensity scale for the calendar heatmap.
    static func tint(for level: Int) -> Color {
        let t = Double(max(1, min(5, level)) - 1) / 4.0 // 0...1
        return Theme.claySoft.mix(with: Theme.accent, amount: t)
    }
}

private extension Color {
    /// Linear blend toward another color — used for the mood-intensity heatmap scale.
    func mix(with other: Color, amount: Double) -> Color {
        let a = UIColor(self).rgba
        let b = UIColor(other).rgba
        let t = CGFloat(max(0, min(1, amount)))
        return Color(
            red: Double(a.r + (b.r - a.r) * t),
            green: Double(a.g + (b.g - a.g) * t),
            blue: Double(a.b + (b.b - a.b) * t)
        )
    }
}

private extension UIColor {
    var rgba: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
}

#Preview {
    HStack {
        ForEach(0..<5) { i in
            MoodEmojiButton(emoji: MoodLevel.emojis[i], level: i + 1, isSelected: i == 3) {}
        }
    }
    .padding()
    .background(Theme.bgBase)
}
