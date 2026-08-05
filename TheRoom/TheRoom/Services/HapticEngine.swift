import CoreHaptics

/// Breath-synced haptics: inhale ramps up, hold ticks once, exhale fades out.
/// Prebuilds patterns once, then triggers them keyed off `BreathPhase` changes
/// from `BreathingClock` — the engine itself has no concept of timing, it just
/// plays the right pattern when the phase changes.
@MainActor
final class HapticEngine {
    private var engine: CHHapticEngine?
    private let isSupported: Bool

    init() {
        isSupported = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        guard isSupported else { return }

        do {
            engine = try CHHapticEngine()
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
            engine?.stoppedHandler = { _ in }
            try engine?.start()
        } catch {
            engine = nil
        }
    }

    func start() {
        guard isSupported else { return }
        try? engine?.start()
    }

    func stop() {
        engine?.stop()
    }

    /// Call once when the phase transitions to `.inhale`. Ramps intensity 0.3 -> 0.8 over 4s.
    func playInhale(duration: TimeInterval) {
        play(makeRampPattern(from: 0.3, to: 0.8, duration: duration, sharpness: 0.5))
    }

    /// Call once when the phase transitions to `.hold`. A single soft tick.
    func playHold() {
        play(makeTickPattern())
    }

    /// Call once when the phase transitions to `.exhale`. Fades intensity 0.8 -> 0.1 over 6s.
    func playExhale(duration: TimeInterval) {
        play(makeRampPattern(from: 0.8, to: 0.1, duration: duration, sharpness: 0.3))
    }

    private func play(_ pattern: CHHapticPattern?) {
        guard isSupported, let engine, let pattern else { return }
        do {
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            // Haptics are a nice-to-have layered on top of the visual + label —
            // silently skipping a failed pattern keeps the session usable (NFR-3.3).
        }
    }

    private func makeRampPattern(from startIntensity: Float, to endIntensity: Float, duration: TimeInterval, sharpness: Float) -> CHHapticPattern? {
        let curve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [
                CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: startIntensity),
                CHHapticParameterCurve.ControlPoint(relativeTime: duration, value: endIntensity),
            ],
            relativeTime: 0
        )
        let continuous = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: startIntensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness),
            ],
            relativeTime: 0,
            duration: duration
        )
        return try? CHHapticPattern(events: [continuous], parameterCurves: [curve])
    }

    private func makeTickPattern() -> CHHapticPattern? {
        let tick = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4),
            ],
            relativeTime: 0
        )
        return try? CHHapticPattern(events: [tick], parameterCurves: [])
    }
}
