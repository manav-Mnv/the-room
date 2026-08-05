import SwiftUI

/// Screen 11 — Breathe completion. Reached by every device's own timer hitting
/// `isComplete` at the same instant (they all started from the same `startAt`),
/// so this screen "syncs" automatically with zero extra coordination.
struct BreatheCompletionView: View {
    let peers: [BreathePeer]
    let durationMinutes: Int

    @Environment(\.dismiss) private var dismiss
    @State private var showAnotherSession = false

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Theme.accent.opacity(0.2))
                    .frame(width: 180, height: 180)
                Circle()
                    .fill(Theme.accent)
                    .frame(width: 120, height: 120)
                Text("🫂")
                    .font(.system(size: 44))
            }

            VStack(spacing: Theme.Spacing.sm) {
                Text("You breathed together for \(durationMinutes) minutes")
                    .font(Theme.rounded(.title2, weight: .bold))
                    .foregroundStyle(Theme.onBreathePrimary)
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Theme.onBreatheSecondary)
                    .multilineTextAlignment(.center)
            }

            if !peers.isEmpty {
                HStack(spacing: -10) {
                    ForEach(peers.prefix(6)) { peer in
                        Circle()
                            .fill(peerColor(for: peer.colorSeed))
                            .frame(width: 36, height: 36)
                            .overlay(Text(String(peer.displayName.prefix(1))).font(.caption.weight(.bold)).foregroundStyle(Theme.bgBase))
                            .overlay(Circle().stroke(Theme.bgBreathe, lineWidth: 2))
                    }
                }
            }

            Spacer()

            VStack(spacing: Theme.Spacing.md) {
                Button {
                    showAnotherSession = true
                } label: {
                    PrimaryButtonLabel(title: "Breathe again")
                }
                SecondaryButton(title: "Done") { dismiss() }
            }
        }
        .padding(Theme.Spacing.screenMargin)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.bgBreathe)
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showAnotherSession) {
            BreatheSessionView(startAt: .now.addingTimeInterval(1), pattern: .standard, duration: 120, peers: peers, sessionManager: nil)
        }
    }

    private var subtitle: String {
        guard !peers.isEmpty else { return "You slowed down, one breath at a time." }
        let names = peers.prefix(3).map(\.displayName).joined(separator: ", ")
        return "You, \(names) slowed down on the same beat."
    }

    private func peerColor(for seed: Int) -> Color {
        let palette = [Theme.accent, Theme.olive, Theme.ochre, Theme.claySoft]
        return palette[abs(seed) % palette.count]
    }
}

#Preview {
    NavigationStack {
        BreatheCompletionView(peers: [], durationMinutes: 2)
    }
}
