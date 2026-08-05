import SwiftUI

/// Screen 9 — Breathe session (solo or group; identical UI either way). Driven
/// entirely by `BreathingClock.state(now:)` recomputed on every timeline tick —
/// no per-device mutable "current phase" state to drift out of sync.
struct BreatheSessionView: View {
    let startAt: Date
    let pattern: BreathingPattern
    let duration: TimeInterval
    let peers: [BreathePeer]
    let sessionManager: BreatheSessionManager?

    @Environment(\.dismiss) private var dismiss
    @State private var haptics = HapticEngine()
    @State private var lastPhase: BreathPhase?
    @State private var navigateToCompletion = false

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
            let state = BreathingClock.state(startAt: startAt, pattern: pattern, duration: duration, now: context.date)

            VStack(spacing: Theme.Spacing.xl) {
                header

                if !peers.isEmpty {
                    peerPill
                }

                Spacer()

                BreathingCircle(progress: state.circleProgress, diameter: 220)
                    .overlay {
                        Text(state.phase.label)
                            .font(Theme.rounded(.title2, weight: .semibold))
                            .foregroundStyle(Theme.bgBase)
                    }

                Text(timeString(state.remaining))
                    .font(Theme.rounded(.headline, weight: .medium))
                    .foregroundStyle(Theme.onBreatheSecondary)
                    .monospacedDigit()

                Spacer()

                SecondaryButton(title: "End session", style: .outline) {
                    sessionManager?.disconnect()
                    dismiss()
                }
            }
            .padding(Theme.Spacing.screenMargin)
            .onChange(of: state.phase) { _, newPhase in
                triggerHaptics(for: newPhase)
            }
            .onChange(of: state.isComplete) { _, isComplete in
                if isComplete { navigateToCompletion = true }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.bgBreathe)
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true)
        .onAppear { haptics.start() }
        .onDisappear { haptics.stop() }
        .navigationDestination(isPresented: $navigateToCompletion) {
            BreatheCompletionView(peers: peers, durationMinutes: Int(duration / 60))
        }
    }

    private var header: some View {
        Text("The Room")
            .font(.caption.weight(.semibold))
            .foregroundStyle(Theme.onBreatheSecondary)
            .tracking(1)
    }

    private var peerPill: some View {
        HStack(spacing: Theme.Spacing.xs) {
            ForEach(peers.prefix(4)) { peer in
                Circle()
                    .fill(peerColor(for: peer.colorSeed))
                    .frame(width: 8, height: 8)
            }
            Text("Breathing with \(peers.count) friend\(peers.count == 1 ? "" : "s")")
                .font(.caption.weight(.medium))
                .foregroundStyle(Theme.onBreathePrimary)
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.sm)
        .background(Theme.bgCard.opacity(0.15))
        .clipShape(Capsule())
    }

    private func triggerHaptics(for phase: BreathPhase) {
        guard phase != lastPhase else { return }
        lastPhase = phase
        switch phase {
        case .inhale: haptics.playInhale(duration: pattern.inhale)
        case .hold: haptics.playHold()
        case .exhale: haptics.playExhale(duration: pattern.exhale)
        case .waitingToStart: break
        }
    }

    private func timeString(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds.rounded()))
        return String(format: "%d:%02d remaining", total / 60, total % 60)
    }

    private func peerColor(for seed: Int) -> Color {
        let palette = [Theme.accent, Theme.olive, Theme.ochre, Theme.claySoft]
        return palette[abs(seed) % palette.count]
    }
}

#Preview {
    NavigationStack {
        BreatheSessionView(startAt: .now, pattern: .standard, duration: 120, peers: [], sessionManager: nil)
    }
}
