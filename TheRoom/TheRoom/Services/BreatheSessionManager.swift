import Foundation
import MultipeerConnectivity
import UIKit

/// Broadcast once at session start: the shared start timestamp, pattern, and
/// duration. Every device (host included) then runs `BreathingClock` locally
/// from this — no further network traffic during the session (FR-4.8, FR-4.9).
struct BreatheSyncMessage: Codable, Equatable {
    let startAt: Date
    let pattern: BreathingPattern
    let duration: TimeInterval
}

struct BreathePeer: Identifiable, Equatable {
    let id: String // MCPeerID.displayName is the natural key here — no persistent identity needed
    let displayName: String
    let colorSeed: Int
}

/// Host/join a group breathing session over MultipeerConnectivity, service type
/// "theroom-breathe". Deliberately minimal protocol: peers exchange presence
/// during the lobby, then exactly one sync message at start. A connection drop
/// mid-session doesn't matter because each device's `BreathingClock` needs
/// nothing further (FR-4.10) — verified by design, not by keeping the socket alive.
@MainActor
final class BreatheSessionManager: NSObject, ObservableObject {
    static let serviceType = "theroom-breathe"

    @Published private(set) var connectedPeers: [BreathePeer] = []
    @Published private(set) var discoveredHosts: [MCPeerID] = []
    @Published private(set) var receivedSync: BreatheSyncMessage?
    @Published private(set) var isHosting = false
    @Published private(set) var isBrowsing = false
    @Published private(set) var isConnectedToHost = false

    private let myPeerID: MCPeerID
    private var session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    init(displayName: String) {
        let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        myPeerID = MCPeerID(displayName: trimmed.isEmpty ? UIDevice.current.name : trimmed)
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        super.init()
        session.delegate = self
    }

    // MARK: - Host

    func startHosting() {
        let advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: Self.serviceType)
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        self.advertiser = advertiser
        isHosting = true
    }

    func stopHosting() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
        isHosting = false
    }

    /// Host-only: sends the single sync message to every connected peer, then
    /// immediately applies it locally too (host runs the same clock as everyone else).
    func broadcastStart(pattern: BreathingPattern = .standard, duration: TimeInterval) {
        let message = BreatheSyncMessage(startAt: .now.addingTimeInterval(2), pattern: pattern, duration: duration)
        if let data = try? JSONEncoder().encode(message), !session.connectedPeers.isEmpty {
            try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
        }
        receivedSync = message
    }

    // MARK: - Join

    func startBrowsing() {
        let browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: Self.serviceType)
        browser.delegate = self
        browser.startBrowsingForPeers()
        self.browser = browser
        isBrowsing = true
    }

    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser = nil
        isBrowsing = false
    }

    func invite(host: MCPeerID) {
        browser?.invitePeer(host, to: session, withContext: nil, timeout: 10)
    }

    // MARK: - Teardown

    func disconnect() {
        session.disconnect()
        stopHosting()
        stopBrowsing()
        connectedPeers = []
        isConnectedToHost = false
        receivedSync = nil
    }
}

extension BreatheSessionManager: MCSessionDelegate {
    nonisolated func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        Task { @MainActor in
            switch state {
            case .connected:
                if !self.connectedPeers.contains(where: { $0.id == peerID.displayName }) {
                    self.connectedPeers.append(
                        BreathePeer(id: peerID.displayName, displayName: peerID.displayName, colorSeed: peerID.displayName.hashValue)
                    )
                }
                self.isConnectedToHost = true
            case .notConnected:
                self.connectedPeers.removeAll { $0.id == peerID.displayName }
            case .connecting:
                break
            @unknown default:
                break
            }
        }
    }

    nonisolated func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let message = try? JSONDecoder().decode(BreatheSyncMessage.self, from: data) else { return }
        Task { @MainActor in
            self.receivedSync = message
        }
    }

    nonisolated func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    nonisolated func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    nonisolated func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension BreatheSessionManager: MCNearbyServiceAdvertiserDelegate {
    nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Friends-nearby is low-stakes by design (SRS 2.4: local-only, no accounts) —
        // auto-accept keeps the lobby flow to a single tap, matching FR-4.7.
        Task { @MainActor in
            invitationHandler(true, self.session)
        }
    }
}

extension BreatheSessionManager: MCNearbyServiceBrowserDelegate {
    nonisolated func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        Task { @MainActor in
            if !self.discoveredHosts.contains(peerID) {
                self.discoveredHosts.append(peerID)
            }
        }
    }

    nonisolated func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        Task { @MainActor in
            self.discoveredHosts.removeAll { $0 == peerID }
        }
    }
}
