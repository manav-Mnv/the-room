import Foundation

/// 4s inhale / 4s hold / 6s exhale by default (SRS FR-4.1).
struct BreathingPattern: Equatable, Codable {
    let inhale: TimeInterval
    let hold: TimeInterval
    let exhale: TimeInterval

    static let standard = BreathingPattern(inhale: 4, hold: 4, exhale: 6)

    var cycleDuration: TimeInterval { inhale + hold + exhale }
}

enum BreathPhase: Equatable {
    case waitingToStart
    case inhale
    case hold
    case exhale

    var label: String {
        switch self {
        case .waitingToStart: return "Get ready"
        case .inhale: return "Breathe in"
        case .hold: return "Hold"
        case .exhale: return "Breathe out"
        }
    }
}

struct BreathState: Equatable {
    let phase: BreathPhase
    /// 0...1 progress within the current phase.
    let phaseProgress: Double
    /// 0...1 circle expansion: 0 at rest, 1 fully expanded. Drives `BreathingCircle`.
    let circleProgress: Double
    /// Seconds left in the whole session, clamped to 0.
    let remaining: TimeInterval
    let isComplete: Bool
}

/// Pure function: given a shared start time, pattern, and duration, computes what
/// phase *any* device should be showing at a given instant. This is the entire
/// sync mechanism for group sessions — every device runs this locally from the
/// same `startAt`, so no continuous network traffic is needed (FR-4.9) and a
/// mid-session disconnect doesn't affect anything (FR-4.10). Kept pure and
/// side-effect-free specifically so it's unit-testable.
enum BreathingClock {
    static func state(
        startAt: Date,
        pattern: BreathingPattern = .standard,
        duration: TimeInterval,
        now: Date
    ) -> BreathState {
        let elapsed = now.timeIntervalSince(startAt)

        if elapsed < 0 {
            return BreathState(phase: .waitingToStart, phaseProgress: 0, circleProgress: 0, remaining: duration, isComplete: false)
        }

        if elapsed >= duration {
            return BreathState(phase: .exhale, phaseProgress: 1, circleProgress: 0, remaining: 0, isComplete: true)
        }

        let cyclePosition = elapsed.truncatingRemainder(dividingBy: pattern.cycleDuration)
        let remaining = duration - elapsed

        let phase: BreathPhase
        let phaseProgress: Double
        let circleProgress: Double

        if cyclePosition < pattern.inhale {
            phase = .inhale
            phaseProgress = pattern.inhale > 0 ? cyclePosition / pattern.inhale : 1
            circleProgress = phaseProgress
        } else if cyclePosition < pattern.inhale + pattern.hold {
            phase = .hold
            let holdElapsed = cyclePosition - pattern.inhale
            phaseProgress = pattern.hold > 0 ? holdElapsed / pattern.hold : 1
            circleProgress = 1
        } else {
            phase = .exhale
            let exhaleElapsed = cyclePosition - pattern.inhale - pattern.hold
            phaseProgress = pattern.exhale > 0 ? exhaleElapsed / pattern.exhale : 1
            circleProgress = 1 - phaseProgress
        }

        return BreathState(
            phase: phase,
            phaseProgress: min(max(phaseProgress, 0), 1),
            circleProgress: min(max(circleProgress, 0), 1),
            remaining: max(remaining, 0),
            isComplete: false
        )
    }
}
