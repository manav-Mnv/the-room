import WidgetKit
import SwiftUI

/// Home-screen widget: streak 🔥 + today's check-in state, with interactive
/// one-tap mood logging. Phase 0: minimal skeleton. Filled in during Phase 1.
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
    let checkedInToday: Bool
}

struct StreakTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: .now, currentStreak: 0, checkedInToday: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        completion(StreakEntry(date: .now, currentStreak: 0, checkedInToday: false))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let entry = StreakEntry(date: .now, currentStreak: 0, checkedInToday: false)
        completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(3600))))
    }
}

struct StreakWidgetView: View {
    let entry: StreakEntry

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("🔥")
                .font(.title2)
            Text("\(entry.currentStreak)")
                .font(Theme.rounded(.title, weight: .bold))
                .foregroundStyle(Theme.textPrimary)
            Text(entry.checkedInToday ? "Checked in today" : "Tap to check in")
                .font(.caption2)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
    }
}

#Preview(as: .systemSmall) {
    StreakWidget()
} timeline: {
    StreakEntry(date: .now, currentStreak: 4, checkedInToday: false)
}
