import SwiftUI

/// Small capsule label used for emotion tags, "🫂 me too · N", peer status, etc.
struct Pill: View {
    let text: String
    var background: Color = Theme.claySoft
    var foreground: Color = Theme.textPrimary
    var systemImage: String? = nil

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.caption.weight(.semibold))
            }
            Text(text)
                .font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .foregroundStyle(foreground)
        .background(background)
        .clipShape(Capsule())
    }
}

/// A small colored dot + label, used for peer presence in Breathe lobby/session.
struct PeerDot: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption.weight(.medium))
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        Pill(text: "anxious")
        Pill(text: "🫂 me too · 12", background: Theme.claySoft)
        PeerDot(color: Theme.accent, label: "Aanya joined")
    }
    .padding()
    .background(Theme.bgBase)
}
