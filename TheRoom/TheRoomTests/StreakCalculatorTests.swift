import Testing
import Foundation
@testable import TheRoom

struct StreakCalculatorTests {
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Kolkata")!
        return cal
    }

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 15 // mid-day, so timezone shifts can't accidentally roll the date
        return calendar.date(from: components)!
    }

    @Test func noCheckIns_isZero() {
        let result = StreakCalculator.calculate(checkInDates: [], today: date(2026, 8, 6), calendar: calendar)
        #expect(result.current == 0)
        #expect(result.longest == 0)
    }

    @Test func singleCheckInToday_isStreakOfOne() {
        let today = date(2026, 8, 6)
        let result = StreakCalculator.calculate(checkInDates: [today], today: today, calendar: calendar)
        #expect(result.current == 1)
        #expect(result.longest == 1)
    }

    @Test func consecutiveDaysEndingToday_countsAll() {
        let today = date(2026, 8, 6)
        let dates = [date(2026, 8, 4), date(2026, 8, 5), today]
        let result = StreakCalculator.calculate(checkInDates: dates, today: today, calendar: calendar)
        #expect(result.current == 3)
        #expect(result.longest == 3)
    }

    @Test func checkedInYesterdayNotToday_stillCurrent() {
        // Streak stays "current" through yesterday — user hasn't missed a day yet, just hasn't
        // checked in *today*. This matters for the widget/reminder copy timing.
        let today = date(2026, 8, 6)
        let dates = [date(2026, 8, 4), date(2026, 8, 5)]
        let result = StreakCalculator.calculate(checkInDates: dates, today: today, calendar: calendar)
        #expect(result.current == 2)
    }

    @Test func gapOfTwoOrMoreDays_breaksCurrentStreakToZero() {
        let today = date(2026, 8, 6)
        let dates = [date(2026, 8, 1), date(2026, 8, 2), date(2026, 8, 3)]
        let result = StreakCalculator.calculate(checkInDates: dates, today: today, calendar: calendar)
        #expect(result.current == 0)
        #expect(result.longest == 3) // longest survives even though current resets
    }

    @Test func longestStreak_findsBestRunNotJustLatest() {
        let today = date(2026, 8, 20)
        // A 5-day run early in the month, then a break, then a 2-day run ending today.
        let dates = [
            date(2026, 8, 1), date(2026, 8, 2), date(2026, 8, 3), date(2026, 8, 4), date(2026, 8, 5),
            date(2026, 8, 19), date(2026, 8, 20),
        ]
        let result = StreakCalculator.calculate(checkInDates: dates, today: today, calendar: calendar)
        #expect(result.current == 2)
        #expect(result.longest == 5)
    }

    @Test func duplicateTimestampsOnSameDay_countOnce() {
        let today = date(2026, 8, 6)
        var withDuplicateHour = DateComponents()
        withDuplicateHour.year = 2026; withDuplicateHour.month = 8; withDuplicateHour.day = 6; withDuplicateHour.hour = 23
        let laterSameDay = calendar.date(from: withDuplicateHour)!

        let result = StreakCalculator.calculate(
            checkInDates: [today, laterSameDay],
            today: today,
            calendar: calendar
        )
        #expect(result.current == 1)
        #expect(result.longest == 1)
    }

    @Test func monthBoundary_doesNotBreakStreak() {
        let today = date(2026, 9, 1)
        let dates = [date(2026, 8, 30), date(2026, 8, 31), today]
        let result = StreakCalculator.calculate(checkInDates: dates, today: today, calendar: calendar)
        #expect(result.current == 3)
    }

    @Test func yearBoundary_doesNotBreakStreak() {
        let today = date(2027, 1, 1)
        let dates = [date(2026, 12, 30), date(2026, 12, 31), today]
        let result = StreakCalculator.calculate(checkInDates: dates, today: today, calendar: calendar)
        #expect(result.current == 3)
    }
}
