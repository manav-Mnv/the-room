import Foundation

/// Pure date-math for mood check-in streaks. No SwiftData, no I/O — takes the
/// set of check-in days and today's date, returns current + longest streak.
/// Kept pure and side-effect-free specifically so it's unit-testable
/// (see `TheRoomTests/StreakCalculatorTests.swift`); off-by-one bugs here are
/// otherwise guaranteed.
enum StreakCalculator {
    struct Result: Equatable {
        let current: Int
        let longest: Int
    }

    /// - Parameters:
    ///   - checkInDates: check-in days, any time-of-day — normalized internally.
    ///   - today: "now", injectable for testing.
    ///   - calendar: injectable for testing timezone edge cases.
    static func calculate(
        checkInDates: [Date],
        today: Date = .now,
        calendar: Calendar = .current
    ) -> Result {
        let days = Set(checkInDates.map { calendar.startOfDay(for: $0) })
        guard !days.isEmpty else { return Result(current: 0, longest: 0) }

        let todayStart = calendar.startOfDay(for: today)
        let current = currentStreak(days: days, todayStart: todayStart, calendar: calendar)
        let longest = longestStreak(days: days, calendar: calendar)

        return Result(current: current, longest: max(longest, current))
    }

    /// Consecutive run ending at today or yesterday. A gap of 2+ days breaks it to 0
    /// ("Fresh start today" copy, never "you lost your streak").
    private static func currentStreak(days: Set<Date>, todayStart: Date, calendar: Calendar) -> Int {
        var anchor: Date
        if days.contains(todayStart) {
            anchor = todayStart
        } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: todayStart),
                  days.contains(yesterday) {
            anchor = yesterday
        } else {
            return 0
        }

        var count = 0
        var cursor = anchor
        while days.contains(cursor) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return count
    }

    /// Longest run of consecutive days anywhere in the history.
    private static func longestStreak(days: Set<Date>, calendar: Calendar) -> Int {
        let sorted = days.sorted()
        guard !sorted.isEmpty else { return 0 }

        var longest = 1
        var run = 1
        for i in 1..<sorted.count {
            let daysBetween = calendar.dateComponents([.day], from: sorted[i - 1], to: sorted[i]).day ?? 0
            if daysBetween == 1 {
                run += 1
            } else {
                run = 1
            }
            longest = max(longest, run)
        }
        return longest
    }
}
