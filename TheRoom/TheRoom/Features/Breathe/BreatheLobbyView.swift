import SwiftUI
import MultipeerConnectivity

/// Screen 10 — Breathe lobby. Same UI serves both the host (who can start) and a
/// joiner (who waits for the host's single sync broadcast) — the only difference
/// is which MultipeerConnectivity role is active and whether "Start breathing" shows.
struct BreatheLobbyView: View {
    enum Role { case host, joiner }
    let role: Role

    @AppStorage("groupSessionDisplayName") private var displayName: String = ""
    @StateObject private var manager: BreatheSessionManager
    @State private var navigateToSession = false
    @State private var navigateToSolo = false

    private let maxPeers = 8

    init(role: Role) {
        self.role = role
        // AppStorage isn't available before init finishes, so read UserDefaults directly here.
        let stored = UserDefaults.standard.string(forKey: "groupSessionDisplayName") ?? ""
        _manager = StateObject(wrappedValue: BreatheSessionManager(displayName: stored))
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            VStack(spacing: Theme.Spacing.xs) {
                Text("Breathe together")
                    .font(Theme.rounded(.title, weight: .bold))
                    .foregroundStyle(Theme.onBreathePrimary)
                Text("Friends nearby can see this session")
                    .font(.subheadline)
                    .foregroundStyle(Theme.onBreatheSecondary)
            }

            ZStack {
                DashedDiscoveryRing(diameter: 200)
                if manager.connectedPeers.isEmpty {
                    Text("waiting…")
                        .font(.subheadline)
                        .foregroundStyle(Theme.onBreatheSecondary)
                } else {
                    Text("\(manager.connectedPeers.count + 1)")
                        .font(Theme.rounded(.largeTitle, weight: .bold))
                        .foregroundStyle(Theme.accent)
                }
            }
            .frame(height: 200)

            if !manager.connectedPeers.isEmpty {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    ForEach(manager.connectedPeers) { peer in
                        HStack {
                            PeerDot(color: peerColor(for: peer.colorSeed), label: "\(peer.displayName) joined")
                                .foregroundStyle(Theme.onBreathePrimary)
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundStyle(Theme.olive)
                        }
                    }
                }
                .padding(Theme.Spacing.md)
                .background(Theme.bgCard.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
            }

            Text(statusText)
                .font(.caption)
                .foregroundStyle(Theme.onBreatheSecondary)

            Spacer()

            VStack(spacing: Theme.Spacing.md) {
                if role == .host {
                    Button {
                        manager.broadcastStart(duration: 120)
                    } label: {
                        PrimaryButtonLabel(title: "Start breathing · 2 min")
                    }
                    SecondaryButton(title: "or start alone") { navigateToSolo = true }
                } else {
                    Text(manager.isConnectedToHost ? "Waiting for the host to start…" : "Looking for a nearby session…")
                        .font(.subheadline)
                        .foregroundStyle(Theme.onBreatheSecondary)
                }
            }
        }
        .padding(Theme.Spacing.screenMargin)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.bgBreathe)
        .preferredColorScheme(.dark)
        .onAppear {
            switch role {
            case .host: manager.startHosting()
            case .joiner: manager.startBrowsing()
            }
        }
        .onDisappear {
            if !navigateToSession { manager.disconnect() }
        }
        .onChange(of: manager.discoveredHosts) { _, hosts in
            guard role == .joiner, !manager.isConnectedToHost, let firstHost = hosts.first else { return }
            manager.invite(host: firstHost)
        }
        .onChange(of: manager.receivedSync) { _, sync in
            guard sync != nil else { return }
            navigateToSession = true
        }
        .navigationDestination(isPresented: $navigateToSession) {
            if let sync = manager.receivedSync {
                BreatheSessionView(
                    startAt: sync.startAt,
                    pattern: sync.pattern,
                    duration: sync.duration,
                    peers: manager.connectedPeers,
                    sessionManager: manager
                )
            }
        }
        .navigationDestination(isPresented: $navigateToSolo) {
            BreatheSessionView(startAt: .now.addingTimeInterval(1), pattern: .standard, duration: 120, peers: [], sessionManager: nil)
        }
    }

    private var statusText: String {
        let room = maxPeers - (manager.connectedPeers.count + 1)
        guard room > 0 else { return "\(manager.connectedPeers.count + 1) friends here · room is full" }
        return "\(manager.connectedPeers.count + 1) friend\(manager.connectedPeers.count == 0 ? "" : "s") here · room for \(room) more"
    }

    private func peerColor(for seed: Int) -> Color {
        let palette = [Theme.accent, Theme.olive, Theme.ochre, Theme.claySoft]
        return palette[abs(seed) % palette.count]
    }
}

#Preview {
    NavigationStack { BreatheLobbyView(role: .host) }
}
