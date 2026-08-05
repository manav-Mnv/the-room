import WidgetKit
import SwiftUI
import SwiftData

/// Home-screen widget: streak 🔥 + today's check-in state, with 3 interactive
/// one-tap mood buttons (😞😐😄 → levels 1/3/5 — all 5 don't fit the small widget).
struct StreakWidget: Widget {
    let kind = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakTimelineProvider()) { entry in
            StreakWidgetView(entry: entry)
                .containerBackground(Theme.bgBase, for: .widget)
        }
        .configurationDisplayName("The Room Streak")
        .description("See your streak and check in with one tap.")
        .supportedFamilies([.systemSmall])
    }
}

struct StreakEntry: TimelineEntry {
    let date: Date
    let currentStreak: Int
    let checkedInLevel: Int?
}

struct StreakTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: .now, currentStreak: 3, checkedInLevel: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let entry = currentEntry()
        // Widget content only changes on check-in (which forces a reload itself),
        // so a distant next-refresh is enough — avoids unnecessary wakeups.
        completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(6 * 3600))))
    }

    @MainActor
    private func currentEntry() -> StreakEntry {
        let context = ModelContext(AppModelContainer.shared)
        let allEntries = (try? context.fetch(FetchDescriptor<MoodEntry>())) ?? []
        let streak = StreakCalculator.calculate(checkInDates: allEntries.map(\.date))

        let startOfToday = Calendar.current.startOfDay(for: .now)
        let today = allEntries.first { Calendar.current.isDate($0.date, inSameDayAs: startOfToday) }

        return StreakEntry(date: .now, currentStreak: streak.current, checkedInLevel: today?.level)
    }
}

struct StreakWidgetView: View {
    let entry: StreakEntry

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack(spacing: 4) {
                Text("🔥")
                Text("\(entry.currentStreak)")
                    .font(Theme.rounded(.title2, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
            }

            Spacer(minLength: 0)

            if let level = entry.checkedInLevel {
                HStack(spacing: 6) {
                    Text(MoodLevel.emojis[level - 1])
                        .font(.title3)
                    Text("Checked in")
                        .font(.caption2)
                        .foregroundStyle(Theme.textSecondary)
                }
            } else {
                HStack(spacing: 8) {
                    ForEach([1, 3, 5], id: \.self) { level in
                        Button(intent: LogMoodIntent(level: level)) {
                            Text(MoodLevel.emojis[level - 1])
                                .font(.title3)
                                .frame(width: 32, height: 32)
                                .background(Theme.bgElevated)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(MoodLevel.label(for: level))
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

#Preview(as: .systemSmall) {
    StreakWidget()
} timeline: {
    StreakEntry(date: .now, currentStreak: 4, checkedInLevel: nil)
    StreakEntry(date: .now, currentStreak: 5, checkedInLevel: 4)
}
