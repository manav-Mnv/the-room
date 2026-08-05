import SwiftUI
import SwiftData

/// Screen 6 — Mood History Calendar: month heatmap + stats + a locally-computed
/// weekday/weekend pattern insight (no AI — simple arithmetic over local data).
struct MoodCalendarView: View {
    @Query(sort: \MoodEntry.date, order: .reverse) private var entries: [MoodEntry]
    @State private var visibleMonth: Date = Calendar.current.startOfDay(for: .now)
    @State private var selectedEntry: MoodEntry?

    private var calendar: Calendar { .current }

    private var entriesByDay: [Date: MoodEntry] {
        Dictionary(uniqueKeysWithValues: entries.map { (calendar.startOfDay(for: $0.date), $0) })
    }

    private var streak: StreakCalculator.Result {
        StreakCalculator.calculate(checkInDates: entries.map(\.date))
    }

    private var averageMood: Double {
        guard !entries.isEmpty else { return 0 }
        return Double(entries.reduce(0) { $0 + $1.level }) / Double(entries.count)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                monthHeader
                weekdayHeaders
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(daysInVisibleMonth, id: \.self) { day in
                        if let day {
                            DayCell(day: day, entry: entriesByDay[calendar.startOfDay(for: day)]) {
                                selectedEntry = entriesByDay[calendar.startOfDay(for: day)]
                            }
                        } else {
                            Color.clear.frame(height: 40)
                        }
                    }
                }

                StatsCard(current: streak.current, longest: streak.longest, average: averageMood)

                if let insight = patternInsight {
                    PatternInsightCard(text: insight)
                }
            }
            .padding(Theme.Spacing.screenMargin)
        }
        .background(Theme.bgBase)
        .scrollContentBackground(.hidden)
        .navigationTitle("Mood History")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedEntry) { entry in
            DayDetailSheet(entry: entry)
                .presentationDetents([.height(220)])
        }
    }

    private var monthHeader: some View {
        HStack {
            Button {
                withAnimation(Theme.Motion.gentle) { shiftMonth(by: -1) }
            } label: {
                Image(systemName: "chevron.left")
            }
            .accessibilityLabel("Previous month")

            Spacer()

            Text(visibleMonth, format: .dateTime.month(.wide).year())
                .font(Theme.rounded(.title3, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)

            Spacer()

            Button {
                withAnimation(Theme.Motion.gentle) { shiftMonth(by: 1) }
            } label: {
                Image(systemName: "chevron.right")
            }
            .accessibilityLabel("Next month")
        }
        .foregroundStyle(Theme.textSecondary)
    }

    private var weekdayHeaders: some View {
        HStack {
            ForEach(calendar.veryShortWeekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Theme.textMuted)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func shiftMonth(by delta: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: delta, to: visibleMonth) {
            visibleMonth = newMonth
        }
    }

    /// Full weeks for the visible month, leading/trailing `nil`s for days outside the month.
    private var daysInVisibleMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: visibleMonth),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday
        else { return [] }

        let leadingBlanks = (firstWeekday - calendar.firstWeekday + 7) % 7
        let dayCount = calendar.range(of: .day, in: .month, for: visibleMonth)?.count ?? 0

        var days: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for offset in 0..<dayCount {
            if let date = calendar.date(byAdding: .day, value: offset, to: monthInterval.start) {
                days.append(date)
            }
        }
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }

    /// Weekend vs weekday average mood, phrased as a gentle observation. Purely local arithmetic.
    private var patternInsight: String? {
        guard entries.count >= 6 else { return nil }
        let weekend = entries.filter { calendar.isDateInWeekend($0.date) }
        let weekday = entries.filter { !calendar.isDateInWeekend($0.date) }
        guard !weekend.isEmpty, !weekday.isEmpty else { return nil }

        let weekendAvg = Double(weekend.reduce(0) { $0 + $1.level }) / Double(weekend.count)
        let weekdayAvg = Double(weekday.reduce(0) { $0 + $1.level }) / Double(weekday.count)
        let diff = weekendAvg - weekdayAvg
        guard abs(diff) >= 0.3 else { return nil }

        let higherSide = diff > 0 ? "Weekends" : "Weekdays"
        return "\(higherSide) average \(String(format: "%.1f", abs(diff))) higher than the rest of the week."
    }
}

private struct DayCell: View {
    let day: Date
    let entry: MoodEntry?
    let onTap: () -> Void

    private var dayNumber: Int { Calendar.current.component(.day, from: day) }
    private var isToday: Bool { Calendar.current.isDateInToday(day) }

    var body: some View {
        Button(action: onTap) {
            Text("\(dayNumber)")
                .font(Theme.rounded(.subheadline, weight: entry != nil ? .bold : .regular))
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    if isToday {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Theme.accent, lineWidth: 1.5)
                    }
                }
        }
        .buttonStyle(.plain)
        .disabled(entry == nil)
        .accessibilityLabel(accessibilityText)
    }

    private var background: Color {
        guard let entry else { return .clear }
        return MoodLevel.tint(for: entry.level)
    }

    private var textColor: Color {
        guard let entry else { return Theme.textMuted }
        return entry.level >= 4 ? .white : Theme.textPrimary
    }

    private var accessibilityText: String {
        guard let entry else { return "\(dayNumber), no check-in" }
        return "\(dayNumber), \(MoodLevel.label(for: entry.level))"
    }
}

private struct StatsCard: View {
    let current: Int
    let longest: Int
    let average: Double

    var body: some View {
        RoomCard {
            HStack {
                stat(label: "🔥 current", value: "\(current)")
                Spacer()
                stat(label: "longest", value: "\(longest)")
                Spacer()
                stat(label: "avg mood", value: average > 0 ? String(format: "%.1f", average) : "—", tint: Theme.olive)
            }
        }
    }

    private func stat(label: String, value: String, tint: Color = Theme.textPrimary) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(Theme.rounded(.title3, weight: .bold))
                .foregroundStyle(tint)
            Text(label)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
    }
}

private struct PatternInsightCard: View {
    let text: String

    var body: some View {
        RoomCard(background: Theme.bgBreathe) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("✦ PATTERN")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.accent)
                    .tracking(1)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(Theme.onBreathePrimary)
            }
        }
    }
}

private struct DayDetailSheet: View {
    let entry: MoodEntry
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            BottomSheetHeader(title: entry.date.formatted(date: .abbreviated, time: .omitted), onCancel: { dismiss() }) {
                EmptyView()
            }
            Text(MoodLevel.emojis[entry.level - 1])
                .font(.system(size: 40))
            if let note = entry.note, !note.isEmpty {
                Text(note)
                    .font(.subheadline)
                    .foregroundStyle(Theme.textPrimary)
            } else {
                Text("No note for this day")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textMuted)
            }
            Spacer()
        }
        .padding(Theme.Spacing.lg)
        .bottomSheetSurface()
    }
}

#Preview {
    NavigationStack { MoodCalendarView() }
        .modelContainer(for: [MoodEntry.self, JournalEntry.self], inMemory: true)
}
