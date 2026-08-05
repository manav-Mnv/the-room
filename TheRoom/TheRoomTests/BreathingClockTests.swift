import Testing
import Foundation
@testable import TheRoom

struct BreathingClockTests {
    private let pattern = BreathingPattern.standard // 4 / 4 / 6 = 14s cycle
    private let start = Date(timeIntervalSince1970: 1_000_000)

    private func state(after seconds: TimeInterval, duration: TimeInterval = 120) -> BreathState {
        BreathingClock.state(startAt: start, pattern: pattern, duration: duration, now: start.addingTimeInterval(seconds))
    }

    @Test func beforeStart_isWaiting() {
        let s = state(after: -1.5)
        #expect(s.phase == .waitingToStart)
        #expect(s.circleProgress == 0)
        #expect(!s.isComplete)
    }

    @Test func atStart_beginsInhale() {
        let s = state(after: 0)
        #expect(s.phase == .inhale)
        #expect(s.phaseProgress == 0)
        #expect(s.circleProgress == 0)
    }

    @Test func midInhale_circleProgressTracksLinearly() {
        let s = state(after: 2) // 2 of 4s inhale
        #expect(s.phase == .inhale)
        #expect(abs(s.phaseProgress - 0.5) < 0.0001)
        #expect(abs(s.circleProgress - 0.5) < 0.0001)
    }

    @Test func endOfInhale_fullyExpanded() {
        let s = state(after: 3.999)
        #expect(s.phase == .inhale)
        #expect(s.circleProgress > 0.99)
    }

    @Test func holdPhase_staysFullyExpanded() {
        let s = state(after: 5) // 1s into 4s hold (starts at t=4)
        #expect(s.phase == .hold)
        #expect(s.circleProgress == 1)
    }

    @Test func exhalePhase_contractsLinearly() {
        // exhale starts at t=8 (4 inhale + 4 hold), runs 6s
        let s = state(after: 11) // 3s into exhale
        #expect(s.phase == .exhale)
        #expect(abs(s.phaseProgress - 0.5) < 0.0001)
        #expect(abs(s.circleProgress - 0.5) < 0.0001)
    }

    @Test func secondCycle_repeatsFromInhale() {
        // cycle is 14s; t=14 should look identical to t=0
        let s = state(after: 14)
        #expect(s.phase == .inhale)
        #expect(s.phaseProgress == 0)
    }

    @Test func remainingCountsDownToZero() {
        let s = state(after: 30, duration: 120)
        #expect(abs(s.remaining - 90) < 0.0001)
    }

    @Test func atOrAfterDuration_isComplete() {
        let exact = state(after: 120, duration: 120)
        #expect(exact.isComplete)
        #expect(exact.remaining == 0)

        let past = state(after: 200, duration: 120)
        #expect(past.isComplete)
        #expect(past.remaining == 0)
    }

    @Test func twoDevicesWithSameStartAt_produceIdenticalState() {
        // This is the entire cross-device sync guarantee: same startAt + pattern +
        // duration + "now" (from each device's own clock) => identical BreathState,
        // with zero network traffic during the session (FR-4.9).
        let now = start.addingTimeInterval(9.3)
        let deviceA = BreathingClock.state(startAt: start, pattern: pattern, duration: 120, now: now)
        let deviceB = BreathingClock.state(startAt: start, pattern: pattern, duration: 120, now: now)
        #expect(deviceA == deviceB)
    }
}
