import SwiftUI

/// The terracotta breathing circle with two soft outer glow layers.
/// Purely presentational — driven by a 0...1 `progress` (inhale→exhale amount),
/// so it can be reused by the solo session, the lobby discovery ring, and previews.
struct BreathingCircle: View {
    /// 0 = fully contracted (post-exhale), 1 = fully expanded (post-inhale).
    var progress: CGFloat
    var diameter: CGFloat = 220

    private var scale: CGFloat { 0.72 + progress * 0.28 }

    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.accent.opacity(0.15))
                .frame(width: diameter * 1.5, height: diameter * 1.5)
                .scaleEffect(scale)

            Circle()
                .fill(Theme.accent.opacity(0.3))
                .frame(width: diameter * 1.2, height: diameter * 1.2)
                .scaleEffect(scale)

            Circle()
                .fill(Theme.accent)
                .frame(width: diameter, height: diameter)
                .scaleEffect(scale)
        }
        .animation(.easeInOut(duration: 0.3), value: progress)
        .accessibilityHidden(true)
    }
}

/// Dashed discovery ring used in the Breathe lobby while waiting for peers.
struct DashedDiscoveryRing: View {
    var diameter: CGFloat = 220
    @State private var rotation: Double = 0

    var body: some View {
        Circle()
            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6, 10]))
            .foregroundStyle(Theme.onBreatheSecondary.opacity(0.6))
            .frame(width: diameter, height: diameter)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    ZStack {
        Theme.bgBreathe.ignoresSafeArea()
        BreathingCircle(progress: 0.6)
    }
}
